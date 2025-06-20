# Writing an OS in Rust: Bootloader #1

## Table of contents

- [Prerequisites](#prerequisites)
- [Introduction](#introduction)
- [Development Environment](#development-environment)
  - [Cross-Compilation](#cross-compilation)
  - [Rust Toolchain](#rust-Toolchain)
- [Understanding the Boot Process on ARM](#understanding-the-boot-process-on-arm)
  - [Writing the Bootloader](#writing-the-Bootloader)
  - [Configuring the Linker Script](#configuring-the-linker-script)
  - [Write Our first rust programm](#write-our-first-rust-programm)
- [First Bare-Metal Boot](#first-bare-metal-boot)
  - [Building the whole thing](#building-the-whole-thing)
  - [Testing with QEMU](#testing-with-qemu)
- [Conclusion](#conclusion)
- [Sources](#sources)

## Prerequisites

This article is intended for developers who are curious about kernel development and want to explore what happens behind the scenes when a computer boots.

While no prior experience in operating system or kernel development is required, a few foundational concepts will help you get the most out of this guide. You should have a basic understanding of how modern computers work: processor architecture, assembly language, and how source code is transformed into a binary through the compilation and linking process.

It’s also important to have a general idea of how an executable is laid out especially how sections like `.text`, `.data`, and `.bss` are structured within a binary.

That said, you don’t need to know anything about kernel development or Rust to follow along. I personally started from scratch, and this article is meant to reflect that learning journey.

However, if you're completely new to Rust, reading through [The Rust Programming Language Book](https://doc.rust-lang.org/book/) will greatly help you understand the syntax and patterns used throughout the code.

## Introduction

The goal of this article is to walk through the first steps of writing an operating system for the ARM64 architecture using Rust. We’ll start from the very beginning—no existing OS, no firmware, just a bare-metal machine and our own code.

Instead of diving straight into hardware drivers or complex kernel internals, we’ll begin by understanding how a computer boots, what a bootloader really is, and how we can implement one ourselves to load and launch a kernel written in Rust.

This journey is all about demystifying the boot process, especially on ARM systems. If you’ve ever wondered how your code gets from storage into execution, this is exactly what we’ll uncover.

We’ll work on real-world concepts like:

- How the ARM boot process is structured, from ROM to OS.
- What expectations Linux has when booting on an ARM system.
- How to simulate all of this using QEMU, so we can develop without dedicated hardware.

And, importantly, we'll write everything ourselves: the bootloader in assembly, and the kernel in Rust, building up a working system and learning how all the pieces fit together.

By the end of this article, we will have a minimal system that can boot in QEMU, load a Rust kernel, and respect the Linux ARM boot protocol. It won’t do much at first, just display a message on the screen, but it’s a necessary first step toward building a fully functional kernel.

## Development Environment

### Cross-Compilation

Before we can run code on our ARM64 target, we have to solve a key problem: a binary compiled on one machine won’t necessarily run on another. That’s because different CPU architectures (like x86_64 and ARM64) use completely different instruction sets.

To deal with this, we use cross-compilation: building code on one system (the host) to run it on another (the target). This is essential when working with bare-metal environments or embedded systems, where the target might not have the resources or OS needed to compile code itself.

In our case:

- `Host`: your development machine (usually x86_64 with Linux/macOS/WSL).
- `Target`: a virtual ARM64 board (QEMU virt).

That’s why we use the GNU `aarch64-linux-gnu-` toolchain, it allows us to assemble and link everything (like the bootloader written in assembly and the Rust-compiled kernel) into a format that the ARM64 machine can actually understand and run.

### Rust Toolchain

One of the main reasons we’re using Rust to build our kernel is its strong focus on memory safety without relying on a garbage collector. Unlike C or C++, Rust ensures that many classes of bugs (like buffer overflows or use-after-free errors) are caught at compile time. This is especially important in kernel development, where such bugs can crash the whole system or introduce security vulnerabilities.

Rust also guarantees no undefined behavior by default, which adds an extra layer of reliability when writing low-level code. Because of these features, Rust is gaining traction in OS development and is being adopted by major projects such as the Linux kernel.

To get started, first install [Rust and it's build system Cargo](https://doc.rust-lang.org/book/ch01-00-getting-started.html) if you haven’t already. Once installed, reload your shell or open a new terminal, then add the AArch64 bare-metal target with the following command:

```shell
rustup target add aarch64-unknown-none
```

This tells Rust that we want to compile for an ARM64 system without an operating system, which is known as a freestanding environment. This is essential when writing low-level code like a kernel, where we can’t rely on any OS-provided services or standard libraries.

## Understanding the Boot Process on ARM

### Writing the Bootloader

For all systems:

- If EL3 is present:
  - SCR_EL3.HCE (bit 8) must be initialised to 0b1.\

For systems with a GICv3 interrupt controller to be used in v3 mode:

- If EL3 is present:
  - ICC_SRE_EL3.Enable (bit 3) must be initialised to 0b1.
  - ICC_SRE_EL3.SRE (bit 0) must be initialised to 0b1.
  - ICC_CTLR_EL3.PMHE (bit 6) must be set to the same value across all CPUs the kernel is executing on, and must stay constant for the lifetime of the kernel.

### Write Our first rust programm

### Configuring the Linker Script

## First Bare-Metal Boot

### Building the whole thing

### Testing with QEMU

## Conclusion

## Sources

- [Linux Boot Protocol AArch64](https://docs.kernel.org/arch/arm64/booting.html)
- [Theory behind bootloader](https://reversepcb.com/bootloader/)
- [Explanation about linker scripts](https://wiki.osdev.org/Linker_Scripts)
- [How to write a linker script](https://users.informatik.haw-hamburg.de/~krabat/FH-Labor/gnupro/5_GNUPro_Utilities/c_Using_LD/ldLinker_scripts.html)
- [QEMU specifications](https://www.qemu.org/docs/master/system/arm/virt.html)
- [Rust embedded development](https://docs.rust-embedded.org/book/intro/index.html)
