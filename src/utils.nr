
// Calculates in^5
fn sigma(inputs: Field) -> Field {
  let exp = inputs.pow_32(5);
  exp
}

fn ark(t: Field, c: [Field], inputs: [Field], r: Field) -> [Field] {
  let mut result : [Field] = [];
  for i in 0..t {
    result[i] = inputs[i] + c[i+r];
  }
  result
}

fn mix(t: Field, m: [Field], inputs: [Field]) -> Field {
  let mut sum : Field = 0;
  for i in 0..t {
    for j in 0..t {
      sum += m[i] * inputs[j];
    }
  }
  sum
}

fn calculateTotal(num_length: Field, num: [Field]) -> Field{
  let mut sum : Field = 0;
  for i in 0..num_length {
    sum += num[i];
  }
  sum
}

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
