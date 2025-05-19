# ----------------------------------------
# Variables générales
# ----------------------------------------

BOOT_DIR           := bootloader
KERNEL_DIR         := kernel
CARGO_TOML         := $(KERNEL_DIR)/Cargo.toml

TARGET             := aarch64-unknown-none
BUILD_MODE         := release
BUILD_FLAG         := --$(BUILD_MODE)

AS                 := aarch64-linux-gnu-as
LD                 := aarch64-linux-gnu-ld
OBJCOPY            := aarch64-linux-gnu-objcopy
CARGO              := cargo
QEMU               := qemu-system-aarch64

BOOT_SRC           := $(BOOT_DIR)/boot.S
LINKER_SCRIPT      := $(BOOT_DIR)/linker.ld

BOOT_OBJ           := $(BOOT_DIR)/boot.o
BOOT_ELF           := $(BOOT_DIR)/boot.elf
BOOT_BIN           := $(BOOT_DIR)/boot.bin

KERNEL_ARCHIVE     := $(KERNEL_DIR)/target/$(TARGET)/$(BUILD_MODE)/libkernel.a
KERNEL_ELF         := kernel.elf
KERNEL_IMG         := kernel.img

PFLASH_BIN         := pflash.bin
PFLASH_SIZE        := 67108864  # 64 MiB
KERNEL_FLASH_OFFSET:= 1048576  # 1 MiB (0x00100000)

# ----------------------------------------
# Règles principales
# ----------------------------------------

.PHONY: all run clean

all: $(PFLASH_BIN)

# 1. Bootloader
$(BOOT_OBJ): $(BOOT_SRC)
	@echo "==> Assemblage bootloader"
	$(AS) -o $@ $<

$(BOOT_ELF): $(BOOT_OBJ)
	@echo "==> Linkage bootloader"
	$(LD) -T $(LINKER_SCRIPT) -o $@ $<

$(BOOT_BIN): $(BOOT_ELF)
	@echo "==> Génération binaire bootloader"
	$(OBJCOPY) -O binary $< $@

# 2. Kernel (lib statique compilée avec Rust)
$(KERNEL_ARCHIVE):
	@echo "==> Compilation kernel Rust (lib)"
	$(CARGO) build --manifest-path $(CARGO_TOML) --target $(TARGET) $(BUILD_FLAG)

# 3. Linkage kernel ELF
$(KERNEL_ELF): $(KERNEL_ARCHIVE) $(LINKER_SCRIPT)
	@echo "==> Linkage kernel"
	$(LD) -T $(LINKER_SCRIPT) -o $@ --gc-sections --nostdlib $<

# 4. Extraction image binaire
$(KERNEL_IMG): $(KERNEL_ELF)
	@echo "==> Génération binaire kernel"
	$(OBJCOPY) -O binary $< $@

# 5. Création image flash
$(PFLASH_BIN): $(BOOT_BIN) $(KERNEL_IMG)
	@echo "==> Création image pflash (64 MiB)"
	dd if=/dev/zero of=$@ bs=1 count=0 seek=$(PFLASH_SIZE)

	@echo "==> Insertion bootloader à 0x00000000"
	dd if=$(BOOT_BIN) of=$@ bs=1 conv=notrunc

	@echo "==> Insertion kernel à 0x00100000"
	dd if=$(KERNEL_IMG) of=$@ bs=1 seek=$(KERNEL_FLASH_OFFSET) conv=notrunc

# 6. Lancement avec QEMU
run: $(PFLASH_BIN)
	@echo "==> Démarrage QEMU depuis pflash"
	$(QEMU) -M virt -cpu cortex-a53 -nographic \
	        -drive if=pflash,format=raw,file=$(PFLASH_BIN)

# 7. Nettoyage
clean:
	@echo "==> Nettoyage"
	rm -f $(BOOT_OBJ) $(BOOT_ELF) $(BOOT_BIN)
	rm -f $(KERNEL_ELF) $(KERNEL_IMG)
	rm -f $(PFLASH_BIN)
	$(CARGO) clean --manifest-path $(CARGO_TOML)
