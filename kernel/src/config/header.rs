#[derive(Debug)]
pub struct KernelHeader {
    code0: u32,
    code1: u32,
    text_offset: u64,
    image_size: u64,
    flags: u64,
    res2: u64,
    res3: u64,
    res4: u64,
    magic: u32,
    res5: u32,
}

impl KernelHeader {
    // Magic must be 'ARM\x64'
    const MAGIC: u32 = 0x644d5241;

    pub fn new() -> Self {
        KernelHeader {
            code0: 0,
            code1: 0,
            text_offset: 0,
            image_size: 0,
            flags: 0,
            res2: 0,
            res3: 0,
            res4: 0,
            magic: Self::MAGIC,
            res5: 0,
        }
    }
}
