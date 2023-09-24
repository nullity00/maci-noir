use dep::std;
mod hasherPoseidon;
mod processMessagesInputHasher;
mod messageHasher;
mod treeIncrementalQuin;
mod privToPubKey;
mod messageToCommand;

global TREE_ARITY = 5;
global MSG_LENGTH = 11;
global PACKED_CMD_LENGTH = 4;

global STATE_LEAF_LENGTH = 4;
global BALLOT_LENGTH = 2;

global BALLOT_NONCE_IDX = 0;
global BALLOT_VO_ROOT_IDX = 1;

global STATE_LEAF_PUB_X_IDX = 0;
global STATE_LEAF_PUB_Y_IDX = 1;
global STATE_LEAF_VOICE_CREDIT_BALANCE_IDX = 2;
global STATE_LEAF_TIMESTAMP_IDX = 3;

fn main(
  stateTreeDepth: Field,
  msgTreeDepth: Field,
  msgBatchDepth: Field,
  voteOptionTreeDepth: Field,
  inputHash: Field,
  packedVals: Field,
  pollEndTimeStamp: Field,
  msgRoot: Field,
  msgs: [[Field; MSG_LENGTH]],
  msgSubrootPathElements : [[Field; TREE_ARITY - 1]],
  coordPrivKey: Field,
  coordPubKey: [Field; 2],
  encPubKeys: [[Field; 2]],
  currentStateRoot: Field,
  currentStateLeaves: [[Field; STATE_LEAF_LENGTH]],
  currentStateLeavesPathElements: [[[Field; TREE_ARITY - 1]]],
  currentSbCommitment: Field,
  currentSbSalt: Field,
  newSbCommitment: Field,
  newSbSalt: Field,
  currentBallotRoot: Field,
  currentBallots: [[Field; BALLOT_LENGTH]],
  currentBallotsPathElements: [[[Field; TREE_ARITY - 1]]],
  currentVoteWeights: [Field],
  currentVoteWeightsPathElements: [[[Field; TREE_ARITY - 1]]],
  ) {

  let batchSize = TREE_ARITY.pow_32(msgBatchDepth);
  let msgTreeZeroValue = 8370432830353022751713833565135785980866757267633941821328460903436894336785;

  let currentSbCommitmentHasher = std::hash::poseidon::bn254::hash_3([currentStateRoot, currentBallotRoot, currentSbSalt]);
  assert(currentSbCommitmentHasher == currentSbCommitment);

  let inputHasher : processMessagesInputHasher::ProcessOutput = processMessagesInputHasher::processMessagesInputHasher(
    packedVals, coordPubKey, msgRoot, currentSbCommitment, newSbCommitment, pollEndTimeStamp
  );

  assert(inputHasher.hash == inputHash);

  assert(inputHasher.maxVoteOptions as u32 < TREE_ARITY.pow_32(voteOptionTreeDepth) as u32);
  assert(inputHasher.numSignUps as u32 < TREE_ARITY.pow_32(stateTreeDepth) as u32);

  let mut messageHashes: [Field] = [];
  for i in 0..batchSize {
    messageHashes[i] = messageHasher::messageHasher(msgs[i], encPubKeys[i]);
  }

  let msgBatchLeavesExists = treeIncrementalQuin::quinBatchLeavesExists(); // TODO: implement
  for i in 0..batchSize {
    assert((inputHasher.batchStartIndex + i) as u32< inputHasher.batchEndIndex as u32);
  }

  let derivedPubKey: [Field; 2] = privToPubKey::privToPubKey(coordPrivKey);
  assert(derivedPubKey[0] == coordPubKey[0]);
  assert(derivedPubKey[1] == coordPubKey[1]);

  let mut command : [messageToCommand::Command] = [];
  for i in 0..batchSize {
    command[i] = messageToCommand::messageToCommand(msgs[i], encPubKeys[i], coordPrivKey);
  }
  

  // Process messages
   
}