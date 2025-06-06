#[repr(C)]
#[derive(Debug)]
pub struct Arm64Header {
    pub code0: u32,
    pub code1: u32,
    pub text_offset: u64,
    pub image_size: u64,
    pub flags: u64,
    pub res2: u64,
    pub res3: u64,
    pub res4: u64,
    pub magic: u32,
    pub res5: u32,
}

impl Arm64Header {
    // Magic must be 'ARM\x64'
    const MAGIC: u32 = 0x644d5241;

    pub const fn new() -> Self {
        let branch_instr = 0x14000010u32;

        Arm64Header {
            code0: branch_instr,
            code1: 0,
            text_offset: 0x80000,
            image_size: 0,
            flags: 0x0,
            res2: 0,
            res3: 0,
            res4: 0,
            magic: Self::MAGIC,
            res5: 0,
        }
    }
}
