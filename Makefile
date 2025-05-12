# Makefile pour bootloader + kernel Rust AArch64 + QEMU

# ----------------------------------------
# Variables générales
# ----------------------------------------
# Répertoire du bootloader et du linker script
BOOT_DIR       := bootloader
BOOT_SRC       := $(BOOT_DIR)/boot.S
LINKER_SCRIPT  := $(BOOT_DIR)/linker.ld

# Répertoire du kernel Rust
KERNEL_DIR     := kernel
CARGO_TOML     := $(KERNEL_DIR)/Cargo.toml

# Cible Rust bare-metal
TARGET         := aarch64-unknown-none

# Configuration de build
BUILD_MODE     := release
BUILD_FLAG     := --$(BUILD_MODE)

# Outils
AS             := aarch64-linux-gnu-as
LD             := ld.lld             # Linker fourni par Rust (LLVM lld)
OBJCOPY        := aarch64-linux-gnu-objcopy         # ou rust-objcopy si disponible
CARGO          := cargo
QEMU           := qemu-system-aarch64

# Noms de fichiers générés
BOOT_OBJ       := $(BOOT_DIR)/boot.o
KRNL_ARCHIVE   := kernel/target/$(TARGET)/$(BUILD_MODE)/lib$(notdir $(KERNEL_DIR)).a
KERNEL_ELF     := kernel.elf
KERNEL_IMG     := kernel.img

# ----------------------------------------
# Targets principaux
# ----------------------------------------
.PHONY: all run clean

all: $(KERNEL_IMG)

# 1) Assembler le boot.S
$(BOOT_OBJ): $(BOOT_SRC)
	@echo "==> Assemblage de $< → $@"
	$(AS) $< -o $@

# 2) Compiler le kernel Rust (staticlib)
$(KRNL_ARCHIVE): $(CARGO_TOML)
	@echo "==> Compilation Rust du kernel ($(BUILD_MODE))"
	$(CARGO) build --manifest-path $(CARGO_TOML) --target $(TARGET) $(BUILD_FLAG)

# 3) Lier bootloader + kernel dans un ELF
$(KERNEL_ELF): $(BOOT_OBJ) $(KRNL_ARCHIVE) $(LINKER_SCRIPT)
	@echo "==> Linkage → $@"
	$(LD) -o $@ \
	  -nostdlib -T $(LINKER_SCRIPT) \
	  $(BOOT_OBJ) $(KRNL_ARCHIVE)

# 4) Générer l'image binaire brute pour QEMU
$(KERNEL_IMG): $(KERNEL_ELF)
	@echo "==> Conversion ELF → binaire brut ($@)"
	$(OBJCOPY) -O binary $< $@

# Nettoyage
clean:
	@echo "==> Nettoyage des fichiers générés"
	rm -f $(BOOT_OBJ) $(KERNEL_ELF) $(KERNEL_IMG)
	$(CARGO) clean --manifest-path $(CARGO_TOML)

