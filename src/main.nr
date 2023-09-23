use dep::std;
mod hasherPoseidon;
mod unpackElement;

global ZERO = 0;

fn main(msg: [Field; 11], pubkey: [Field; 2], encPrivkey: Field) -> pub [Field] {

  let unpackedElements : [Field] = unpackElement::unpackElement(msg[0], 5);
  let pollId = unpackedElements[0];
  let nonce = unpackedElements[1];
  let newVoteWeight = unpackedElements[2];
  let voteOptionIndex = unpackedElements[3];
  let stateIndex = unpackedElements[4];

  [pollId, nonce, newVoteWeight, voteOptionIndex, stateIndex]
}
//   let bits: [u1] = input.to_le_bits(256);

  
//   [2, 3]
    // let input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    // let mut arr : [Field; 13] = input;
    // arr[11] = 0;
    // arr[12] = 0;

    // let hash =  hasherPoseidon::hasher13(arr);
    // let mut arr1 : [Field; 5] = [0; 5];
    // let mut arr2 : [Field; 5] = [0; 5];
    //     for i in 0..5 {
    //     arr1[i] = input[i+1];
    //     arr2[i] = input[i+6];
    //     }

    // let hash51 = std::hash::poseidon::bn254::hash_5(arr1);
    // let hash52 = std::hash::poseidon::bn254::hash_5(arr2);

    // let arr3 : [Field; 5] = [input[0], hash51, hash52, input[11], input[12]];

    // let hash5 = std::hash::poseidon::bn254::hash_5(arr3);