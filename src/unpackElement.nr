// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/unpackElement.circom

fn unpackElement(input: Field, num: Field) -> [Field]{
  let bits = input.to_le_bits(256);
  let mut output: [Field] = [num; 0];

  for i in 0..num {
    for j in 0..50 {
      output[i] += bits[j + 50 * i] as Field * (1 << j as u16) as Field;
    }
  }

  output
}
