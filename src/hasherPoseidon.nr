use dep::std;

fn hasher13(input: [Field; 13]) -> Field{
  let mut arr1 : [Field; 5] = [0; 5];
  let mut arr2 : [Field; 5] = [0; 5];
    for i in 0..5 {
      arr1[i] = input[i+1];
      arr2[i] = input[i+6];
    }

  let hash51 = std::hash::poseidon::bn254::hash_5(arr1);
  let hash52 = std::hash::poseidon::bn254::hash_5(arr2);

  let arr3 : [Field; 5] = [input[0], hash51, hash52, input[11], input[12]];

  let hash5 = std::hash::poseidon::bn254::hash_5(arr3);
  hash5
}

fn hashLeftRight(left : Field, right: Field) -> Field{
  std::hash::poseidon::bn254::hash_2([left, right])
}