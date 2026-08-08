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

const _: () = assert!(core::mem::size_of::<c_uint>() == core::mem::size_of::<u32>());

#[repr(C)]
pub struct Info<'a> {
    pub total_size: u32,
    pub reserved: u32,
    pub tags: &'a [Tag]
}

#[repr(C)]
pub struct MemMapEntry {
    pub size: u32,
    pub base_addr_low: u32,
    pub base_addr_high: u32,
    pub len_low: u32,
    pub len_high: u32,
    pub map_type: MemMapType
}

#[repr(u32)]
pub enum MemMapType {
    Available       = 1,
    Reserved        = 2,
    AcpiReclaimable = 3,
    Nvs             = 4,
    BadRam          = 5
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
