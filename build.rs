use std::env;
use std::path::PathBuf;
use std::process::Command;

fn main() {
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let boot_asm = PathBuf::from("src/boot/boot.asm");
    let boot_obj = out_dir.join("boot.o");
    let status = Command::new("nasm")
        .args(["-f", "elf64"])
        .arg(&boot_asm)
        .arg("-o")
        .arg(&boot_obj)
        .status()
        .expect("Failed to run nasm");
    assert!(status.success(), "nasm failed to assemble boot.asm");

    let lib_name = "boot";
    let lib_path = out_dir.join(format!("lib{lib_name}.a"));

    let status = Command::new("ar")
        .arg("crus")
        .arg(&lib_path)
        .arg(&boot_obj)
        .status()
        .expect("failed to run ar");

    assert!(status.success(), "ar failed to create static lib");

    println!("cargo:rustc-link-search=native={}", out_dir.display());
    println!("cargo:rustc-link-lib=static={lib_name}");

    let linker_script = PathBuf::from("linker.ld")
        .canonicalize()
        .expect("linker.ld not found in proj root");
    println!("cargo:rustc-link-arg=-T{}", linker_script.display());

    println!("cargo:rerun-if-changed=src/boot/boot.asm");
    println!("cargo:rerun-if-changed=linker.ld");
    println!("cargo:rerun-if-changed=build.rs");
}
