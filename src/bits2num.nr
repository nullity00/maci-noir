
fn bits2num(bits: [u1]) -> u254 {
    let mut num = 0;
    for bit in 0..254 {
        num = num + (2).pow_32(bit) as u254 * bits[bit] as u254;
    }
    num
}