// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/processMessages.circom

use dep::std;
mod hasherPoseidon;
mod processMessagesInputHasher;
mod messageHasher;
mod treeIncrementalQuin;
mod privToPubKey;
mod messageToCommand;
mod utils;
mod processTopUp;
mod stateLeafAndBallotTransformer;
mod processOne;

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

fn processMessages(
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
  let mut msgBatchLeaves : [Field] = [];
  for i in 0..batchSize {
    let lessThan = if ((inputHasher.batchStartIndex + i) as u32< inputHasher.batchEndIndex as u32){
      1
    } else {
      0
    };

    let mux = utils::mux1([msgTreeZeroValue, messageHashes[i]], lessThan);
    msgBatchLeaves[i] = mux;
  }

  let msgBatchPathIndices : [Field] = treeIncrementalQuin::quinGeneratePathIndices(msgTreeDepth, inputHasher.batchStartIndex);
  let mut msgBatchPathIndex : [Field] = [];
  for i in msgBatchDepth..msgTreeDepth {
      msgBatchPathIndex[i - msgBatchDepth] = msgBatchPathIndices[i];
  }
  treeIncrementalQuin::quinBatchLeavesExists(
    msgTreeDepth, msgBatchDepth,msgBatchLeaves,msgBatchPathIndex,msgSubrootPathElements,msgRoot
  );
  
  let derivedPubKey: [Field; 2] = privToPubKey::privToPubKey(coordPrivKey);
  assert(derivedPubKey[0] == coordPubKey[0]);
  assert(derivedPubKey[1] == coordPubKey[1]);

  let mut command : [messageToCommand::Command] = [];
  for i in 0..batchSize {
    command[i] = messageToCommand::messageToCommand(msgs[i], encPubKeys[i], coordPrivKey);
  }

  let mut stateRoots : [Field] = [];
  let mut ballotRoots : [Field] = [];
  
  let mut processors : [[Field; 2]] = [];
  let mut processors2 : [Field] = [];

  stateRoots[batchSize] = currentStateRoot;
  ballotRoots[batchSize] = currentBallotRoot;

  for k in 0..(batchSize - 1) {
    let i = batchSize - k - 1;
    processors[i] = processOne::processOne(
      stateTreeDepth, 
      voteOptionTreeDepth,
      msgs[i][0],
      inputHasher.numSignUps,
      inputHasher.maxVoteOptions,
      pollEndTimeStamp,
      stateRoots[i + 1],
      ballotRoots[i + 1],
      currentStateLeaves[i],
      currentStateLeavesPathElements[i],
      currentBallots[i],
      currentBallotsPathElements[i],
      currentVoteWeights[i],
      currentVoteWeightsPathElements[i],
      command[i].stateIndex,
      msgs[i][1],
      command[i].newPubkey,
      command[i].voteOptionIndex,
      command[i].newVoteWeight,
      command[i].nonce,
      command[i].pollId,
      command[i].salt,
      command[i].sigR8,
      command[i].sigS,
      command[i].packedCommand,
    );
    processors2[i] = processTopUp::processTopUp(
      stateTreeDepth,
      msgs[i][0],
      msgs[i][1],
      msgs[i][2],
      inputHasher.numSignUps,
      currentStateLeaves[i],
      currentStateLeavesPathElements[i],
    );

    stateRoots[i] = processors[i][0] * (2-msgs[i][0]) + stateRoots[i+1] * (msgs[i][0]-1);
    ballotRoots[i] = processors[i][1] * (2-msgs[i][0]) + ballotRoots[i+1] * (msgs[i][0]-1);
  }
  
  let sbCommitmentHasher = std::hash::poseidon::bn254::hash_3([stateRoots[0], ballotRoots[0], newSbSalt]);
  assert(sbCommitmentHasher == newSbCommitment);
}