# Writing an OS in Rust: Bootloader #1

## 1. Introduction

## 2. Development Environment

### 2.1 Cross-Compilation

### 2.2 Rust Toolchain

## 3. Understanding the Boot Process on ARM

### 3.1 Writing the Bootloader

For all systems:

- If EL3 is present:
  - SCR_EL3.HCE (bit 8) must be initialised to 0b1.\

For systems with a GICv3 interrupt controller to be used in v3 mode:

- If EL3 is present:
  - ICC_SRE_EL3.Enable (bit 3) must be initialised to 0b1.
  - ICC_SRE_EL3.SRE (bit 0) must be initialised to 0b1.
  - ICC_CTLR_EL3.PMHE (bit 6) must be set to the same value across all CPUs the kernel is executing on, and must stay constant for the lifetime of the kernel.

### 3.2 Configuring the Linker Script

### 3.3 Write Our first rust programm

## 4. First Bare-Metal Boot

### 4.1 Building the whole thing

### 4.2 Testing with QEMU

## 5. Conclusion

## Sources

- https://jcomes.org/aarch64-os-hello_world
- https://lowenware.com/blog/aarch64-mmu-programming/
