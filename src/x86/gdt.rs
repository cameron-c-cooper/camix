use bitfield::bitfield;

#[repr(C, packed)]
pub struct TaskStateSegment {
    reserved_0: u32,
    pub rsp: [u64; 3],
    reserved_1: u64,
    pub ist: [u64; 7],
    reserved_2: u64,
    reserved_3: u16,
    pub iomap_base: u16, //offset from tss base to io permission bitmap
}

bitfield! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
    #[repr(transparent)]
    pub struct SegmentDescriptor(u64);

    pub limit_low, set_limit_low: 15, 0;
    pub limit_high, set_limit_high: 51, 48;

    pub base_low, set_base_low: 39, 16;
    pub base_high, set_base_high: 63, 56;

    pub accessed, set_accessed: 40;
    pub read_write, set_read_write: 41;
    pub conforming, set_conforming: 42;
    pub executable, set_executable: 43;
    pub descriptor_type, set_descriptor_type: 44; // 0 = Sys, 1 = Code/Data
    pub dpl, set_dpl: 46, 45;
    pub present, set_present: 47;

    pub available, set_available: 52;
    pub long_mode, set_long_mode: 53;
    pub db_size, set_db_size: 54;
    pub granularity, set_granularity: 55; // 1 = 4 KiB, 0 = 1 byte units
}

bitfield! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
    #[repr(C, align(8))]
    pub struct SystemSegmentDescriptor(u128);

    pub limit_low, set_limit_low: 15, 0;
    pub base_low, set_base_low: 39, 16;
    pub base_mid, set_base_mid: 63, 56;
    
    pub accessed, set_accessed: 40;
    pub read_write, set_read_write: 41;
    pub conforming, set_conforming: 42;
    pub executable, set_executable: 43;
    pub descriptor_type, set_descriptor_type: 44;
    pub dpl, set_dpl: 46, 45;
    pub present, set_present: 47;
    
    pub limit_high, set_limit_high: 51, 48;
    pub available, set_available: 52;
    pub granularity, set_granularity: 55;

    pub base_high, set_base_high: 95, 64;
}

const _: () = assert!(core::mem::size_of::<SystemSegmentDescriptor>() == 16);
const _: () = assert!(core::mem::size_of::<SegmentDescriptor>() == 8);
const _: () = assert!(core::mem::align_of::<SegmentDescriptor>() == 8);

#[allow(unused)]
impl SegmentDescriptor {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn set_limit(&mut self, limit: u32) {
        let limit = limit as u64;
        self.set_limit_low(limit & 0xffff);
        self.set_limit_high((limit >> 16) & 0xf);
    }
    pub fn limit(&self) -> u32 {
        (self.limit_low() | (self.limit_high() << 16))
            .try_into().unwrap()
    }
    pub fn set_base(&mut self, base: u32) {
        let base = base as u64;
        self.set_base_low(base & 0xff_ffff);
        self.set_base_high((base >> 24) & 0xff);
    }
}

impl SystemSegmentDescriptor {
    #[allow(unused)]
    pub fn new_tss(base: u64, limit: u32) -> Self {
        let mut desc = Self::default();
        
        // set the 64 bit base address across the split fields
        let base = base as u128;
        desc.set_base_low(base & 0xff_ffff);
        desc.set_base_mid((base >> 24) & 0xff);
        desc.set_base_high((base >> 32) & 0xffffffff);
        
        // set the 20 bit limit
        let limit = limit as u128;
        desc.set_limit_low(limit & 0xffff);
        desc.set_limit_high((limit >> 16) & 0xf);
        
        // set standard tss type flags
        desc.set_present(true);
        desc.set_descriptor_type(false); // 0 = System Descriptor
        
        // in long mode system segments, executable = 1 and read_write = 0 
        // means available. When loaded, the cpu sets read_write to 1/"Busy".
        desc.set_executable(true);   
        desc.set_read_write(false);  
        desc.set_accessed(true);
        
        // usually TSS doesn't use granularity flags unless it's huge, 
        // so bytes granularity (0) is normal.
        desc.set_granularity(false); 
        desc
    }
}

const GDT_ENTRIES: usize = 7;

#[repr(C, align(8))]
#[derive(Debug)]
pub struct Gdt([u64; GDT_ENTRIES]);

pub const NULL_SEL: u16 = 0;
pub const KERNEL_CS: u16 = 8;
pub const KERNEL_DS: u16 = 2 * 8;
pub const USER_CS: u16 = 3 * 8;
pub const USER_DS: u16 = 4 * 8;
pub const TSS_SEL: u16 = 5 * 8;

// lowkey horrendous
#[allow(clippy::unnecessary_cast)]
#[unsafe(no_mangle)]
pub static mut GDT: Gdt = unsafe { core::mem::transmute([0 as u64; GDT_ENTRIES]) };

#[allow(clippy::unnecessary_cast)]
#[unsafe(no_mangle)]
pub static mut TSS: TaskStateSegment = unsafe { 
    // i love this bullshit
    core::mem::transmute([0; core::mem::size_of::<TaskStateSegment>()/4]) 
};

impl Gdt {
    pub fn new(tss: *const TaskStateSegment) -> Self {
        let mut kcode = SegmentDescriptor::default();
        kcode.set_present(true);
        kcode.set_descriptor_type(true);
        kcode.set_executable(true);
        kcode.set_read_write(true);
        kcode.set_long_mode(true);
        kcode.set_dpl(0);

        let mut kdata = SegmentDescriptor::default();
        kdata.set_present(true);
        kdata.set_descriptor_type(true);
        kdata.set_read_write(true);
        kdata.set_dpl(0);

        let mut ucode = kcode;
        ucode.set_dpl(3);

        let mut udata = kdata;
        udata.set_dpl(3);
        
        let tss_desc = SystemSegmentDescriptor::new_tss(
            tss as *const _ as u64,
            (core::mem::size_of::<TaskStateSegment>() - 1) as u32,
        );
        let tss_raw = tss_desc.0;
        Gdt([
            0,
            kcode.0,
            kdata.0,
            ucode.0,
            udata.0,
            tss_raw as u64,
            (tss_raw >> 64) as u64,
        ])
    }
}

impl TaskStateSegment {
    pub const fn new() -> Self {
        Self {
            reserved_0: 0,
            rsp: [0; 3],
            reserved_1: 0,
            ist: [0; 7],
            reserved_2: 0,
            reserved_3: 0,
            iomap_base: core::mem::size_of::<TaskStateSegment>() as u16
        }
    }
}

#[repr(C, packed)]
struct DescriptorTablePointer {
    limit: u16,
    base: u64
}

pub fn init() {
    unsafe {
        TSS = TaskStateSegment::new();
        GDT = Gdt::new(&raw const TSS);
        load_gdt(&raw const GDT);
    }
}

// that static ref is killing me.
pub fn load_gdt(gdt: *const Gdt) {
    let ptr = DescriptorTablePointer {
        limit: (core::mem::size_of::<Gdt>() - 1) as u16,
        base: gdt as *const _ as u64,
    };
    /* SAFETY: this is already safe idiot */
    unsafe {
        core::arch::asm!("lgdt [{}]", in(reg) &ptr);
        core::arch::asm!(
            "mov ax, {sel:x}", "mov ds, ax", "mov es, ax",
            "mov ss, ax", "mov fs, ax", "mov gs, ax",
            sel = in(reg) KERNEL_DS,
        );

        core::arch::asm!(
            "push {sel}", "lea rax, [rip + 2f]", "push rax", "retfq", "2:",
            sel = in(reg) KERNEL_CS as u64,
            out("rax") _,
        );
        core::arch::asm!("ltr {sel:x}", sel = in(reg) TSS_SEL);
    }
}
