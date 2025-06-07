# ----------------------------------------
# Variables
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
BOOT_OBJ           := $(BOOT_DIR)/boot.o
BOOT_BIN           := $(BOOT_DIR)/boot.bin

LINKER_SCRIPT      := $(KERNEL_DIR)/linker.ld

KERNEL_ARCHIVE     := $(KERNEL_DIR)/target/$(TARGET)/$(BUILD_MODE)/libkernel.a
KERNEL_ELF         := kernel.elf
KERNEL_IMG         := kernel.img

PFLASH_BIN         := pflash.bin
PFLASH_SIZE        := 67108864  # 64 MiB
KERNEL_FLASH_OFFSET:= 1048576  # 1 MiB (0x00100000)

# ----------------------------------------
# Rules
# ----------------------------------------

.PHONY: all run clean

all: $(PFLASH_BIN)

# Bootloader (assembly -> binary)
$(BOOT_OBJ): $(BOOT_SRC)
	@echo "==> Assemblage bootloader"
	$(AS) -o $@ $<

$(BOOT_BIN): $(BOOT_OBJ)
	@echo "==> Génération binaire bootloader"
	$(OBJCOPY) -O binary $< $@

# 2. Kernel (compiling rlib)
$(KERNEL_ARCHIVE):
	@echo "==> Compilation kernel Rust (lib)"
	$(CARGO) build --manifest-path $(CARGO_TOML) --target $(TARGET) $(BUILD_FLAG)

# 3. link kernel with linker.ld
$(KERNEL_ELF): $(KERNEL_ARCHIVE) $(LINKER_SCRIPT)
	@echo "==> Linkage kernel"
	$(LD) -T $(LINKER_SCRIPT) -o $@ --gc-sections --nostdlib $<

# 4. extract binary from kernel
$(KERNEL_IMG): $(KERNEL_ELF)
	@echo "==> Génération binaire kernel"
	$(OBJCOPY) -O binary $< $@

	@echo "==> Patch image_size dans header Arm64"
	@filesize=$$(stat -c %s $@); \
	 aligned_size=$$(( ($$filesize + 7) & ~7 )); \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 0)  & 0xFF )))" >  tmp_patch.bin; \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 8)  & 0xFF )))" >> tmp_patch.bin; \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 16) & 0xFF )))" >> tmp_patch.bin; \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 24) & 0xFF )))" >> tmp_patch.bin; \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 32) & 0xFF )))" >> tmp_patch.bin; \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 40) & 0xFF )))" >> tmp_patch.bin; \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 48) & 0xFF )))" >> tmp_patch.bin; \
	 printf "$$(printf '\\x%02x' $$(( ($$aligned_size >> 56) & 0xFF )))" >> tmp_patch.bin; \
	 dd if=tmp_patch.bin of=$@ bs=1 seek=16 count=8 conv=notrunc status=none; \
	 rm tmp_patch.bin


# 5. create flash img
$(PFLASH_BIN): $(BOOT_BIN) $(KERNEL_IMG)
	@echo "==> Création image pflash (64 MiB)"
	dd if=/dev/zero of=$@ bs=1 count=0 seek=$(PFLASH_SIZE)

	@echo "==> Insertion bootloader à 0x00000000"
	dd if=$(BOOT_BIN) of=$@ bs=1 conv=notrunc

	@echo "==> Insertion kernel à 0x00100000"
	dd if=$(KERNEL_IMG) of=$@ bs=1 seek=$(KERNEL_FLASH_OFFSET) conv=notrunc

run: $(PFLASH_BIN)
	@echo "==> Démarrage QEMU depuis pflash"
	$(QEMU) -M virt -cpu cortex-a53 -nographic \
	        -drive if=pflash,format=raw,file=$(PFLASH_BIN)

clean:
	@echo "==> Nettoyage"
	rm -f $(BOOT_OBJ) $(BOOT_BIN)
	rm -f $(KERNEL_ELF) $(KERNEL_IMG)
	rm -f $(PFLASH_BIN)
	$(CARGO) clean --manifest-path $(CARGO_TOML)
