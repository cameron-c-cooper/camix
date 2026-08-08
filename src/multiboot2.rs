/*
 * Alright. I need to make the multiboot spec bindings in rust. Will need to
 * recreate the info structures and everything from multiboot2, as multiboot1
 * will not have the same structures as multiboot2 has. From there, will need
 * to parse the tags and flags for different memory maps, and other features.
 */

use core::ffi::c_uint;

#[repr(C)]
pub struct Tag {
    pub tag_type: TagType,

    pub size: u32,
}

// fail compilation if target doesnt work. Forces mb2 uint32_t -> u32
const _: () = assert!(core::mem::size_of::<c_uint>() == core::mem::size_of::<u32>());

#[repr(C)]
pub struct Info<'a> {
    pub total_size: u32,
    pub reserved: u32,
    pub tags: &'a [Tag]
}

#[repr(C)]
pub struct MemMapEntry {
    pub addr: u64,
    pub len: u64,
    pub map_type: MemMapType,
    pub zero: u32
}

#[repr(C)]
pub struct Header {
    pub magic: u32,
    pub arch: u32,
    pub len: u32,
    pub checksum: u32
}

#[repr(C)]
pub struct HeaderTag {
    tag_type: HeaderTagType,
    flags: u16,
    size: u32
}

#[repr(u32)]
pub enum MemMapType {
    Available       = 1,
    Reserved        = 2,
    AcpiReclaimable = 3,
    Nvs             = 4,
    BadRam          = 5
}

#[repr(u16)]
pub enum HeaderTagType {
    Yes
}

#[repr(u32)]
pub enum TagType {
    End             = 0,
    CmdLine         = 1,
    BootLoaderName  = 2,
    Module          = 3,
    BasicMemInfo    = 4,
    Bootdev         = 5,
    Mmap            = 6,
    Vbe             = 7,
    Framebuffer     = 8,
    ElfSections     = 9,
    Apm             = 10,
    Efi32           = 11,
    Efi64           = 12,
    Smbios          = 13,
    AcpiOld         = 14,
    AcpiNew         = 15,
    Network         = 16,
    EfiMmap         = 17,
    EfiBs           = 18,
    Efi32Ih         = 19,
    Efi64Ih         = 20,
    LoadBaseAddr    = 21,
}

pub struct Fixed {
    total_size: u32,
    reserved: u32
}

// fucking hate this
#[inline]
pub fn load<'a>(start_addr: usize) -> &'a Info<'static> {
    unsafe {core::mem::transmute(&*(start_addr as *const Info)) }
}
