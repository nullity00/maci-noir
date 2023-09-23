// https://github.com/weijiekoh/circomlib/blob/feat/poseidon-encryption/circuits/poseidon.circom

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
