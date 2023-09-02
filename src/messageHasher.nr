// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/messageHasher.circom

mod hasherPoseidon;

fn messageHasher(msg: Field[11], pubkey: Field[2]) -> Field {
  let mut arr : [Field; 13] = msg;
  arr[11] = pubkey[0];
  arr[12] = pubkey[1];

  let hash =  hasherPoseidon::hasher13(arr);
  hash
}