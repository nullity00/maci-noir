// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/processMessages.circom

use dep::std;
mod hasherPoseidon;
mod utils;

struct ProcessOutput {
  maxVoteOptions: Field,
  numSignUps: Field,
  batchStartIndex: Field,
  batchEndIndex: Field,
  hash: Field,
}

fn processMessagesInputHasher(
  packedVals: Field,
  coordPubKey: [Field; 2],
  msgRoot: Field,
  currentSbCommitment: Field,
  newSbCommitment: Field,
  pollEndTimestamp: Field) -> ProcessOutput {
    
  let unpackedElements : [Field] = utils::unpackElement(packedVals, 4);

  let maxVoteOptions = unpackedElements[3];
  let numSignUps = unpackedElements[2];
  let batchStartIndex = unpackedElements[1];
  let batchEndIndex = unpackedElements[0];

  let pubKeyHasher = hasherPoseidon::hashLeftRight(coordPubKey[0], coordPubKey[1]);

  // std::hash::sha256([packedVals, pubKeyHasher, msgRoot, currentSbCommitment, newSbCommitment, pollEndTimestamp])
  let hash = 123;

  ProcessOutput {
    maxVoteOptions,
    numSignUps,
    batchStartIndex,
    batchEndIndex,
    hash: hash,
  }
   
}