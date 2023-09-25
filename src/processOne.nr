use dep::std;
mod hasherPoseidon;
mod treeIncrementalQuin;
mod utils;
mod stateLeafAndBallotTransformer;

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

fn processOne(
  stateTreeDepth: Field, 
  voteOptionTreeDepth: Field,
  msgType: Field,
  numSignUps: Field,
  maxVoteOptions: Field,
  pollEndTimestamp: Field,
  currentStateRoot: Field,
  currentBallotRoot: Field,
  stateLeaf: [Field; STATE_LEAF_LENGTH],
  stateLeafPathElements: [[Field; TREE_ARITY - 1]],
  ballot: [Field; BALLOT_LENGTH],
  ballotPathElements: [[Field; TREE_ARITY - 1]],
  currentVoteWeight: Field,
  currentVoteWeightsPathElements: [[Field; TREE_ARITY - 1]],
  cmdStateIndex: Field,
  topupStateIndex: Field,
  cmdNewPubKey: [Field; 2],
  cmdVoteOptionIndex: Field,
  cmdNewVoteWeight: Field,
  cmdNonce: Field,
  cmdPollId: Field,
  cmdSalt: Field,
  cmdSigR8: [Field; 2],
  cmdSigS: Field,
  packedCmd: [Field; PACKED_CMD_LENGTH],
) -> [Field; 2] {
  let transformer : stateLeafAndBallotTransformer::TransformerOutput = 
    stateLeafAndBallotTransformer::stateLeafAndBallotTransformer(
    numSignUps, 
    maxVoteOptions,
    [stateLeaf[STATE_LEAF_PUB_X_IDX], stateLeaf[STATE_LEAF_PUB_Y_IDX]],
    stateLeaf[STATE_LEAF_VOICE_CREDIT_BALANCE_IDX],
    stateLeaf[STATE_LEAF_TIMESTAMP_IDX],
    pollEndTimestamp,
    ballot[BALLOT_NONCE_IDX],
    currentVoteWeight, 
    cmdStateIndex, 
    cmdNewPubKey,
    cmdVoteOptionIndex, 
    cmdNewVoteWeight, 
    cmdNonce, 
    cmdPollId, 
    cmdSalt, 
    cmdSigR8, 
    cmdSigS,
    packedCmd
  );

  let indexByType = cmdStateIndex * (2 - msgType) + topupStateIndex * (msgType - 1);
  let stateIndexMux = utils::mux1([0, indexByType], transformer.isValid + msgType - 1);

  let stateLeafPathIndices = treeIncrementalQuin::quinGeneratePathIndices(stateTreeDepth, stateIndexMux);
  let stateLeafHasher = std::hash::poseidon::bn254::hash_4([stateLeaf[0], stateLeaf[1], stateLeaf[2], stateLeaf[4]]);
  let stateLeafQip = treeIncrementalQuin::quinTreeInclusionProof(
    stateTreeDepth, stateLeafHasher, stateLeafPathIndices, stateLeafPathElements
  );
  assert(stateLeafQip == currentStateRoot);

  let ballotHasher = hasherPoseidon::hashLeftRight(ballot[BALLOT_NONCE_IDX], ballot[BALLOT_VO_ROOT_IDX]);
  let ballotQip = treeIncrementalQuin::quinTreeInclusionProof(
    stateTreeDepth, ballotHasher, stateLeafPathIndices, ballotPathElements
  );
  assert(ballotQip == currentBallotRoot);

  let b = currentVoteWeight * currentVoteWeight;
  let c = cmdNewVoteWeight * cmdNewVoteWeight;

  let enoughVoiceCredits = if ((stateLeaf[STATE_LEAF_VOICE_CREDIT_BALANCE_IDX] + b - c) as u52 > 0){
    1
  } else {
    0
  };

  let isMessageValid = if (transformer.isValid + enoughVoiceCredits == 2){
    1
  } else {
    0
  };

  let cmdVoteOptionIndexMux = utils::mux1([0, cmdVoteOptionIndex], isMessageValid);
  let currentVoteWeightPathIndices = 
  treeIncrementalQuin::quinGeneratePathIndices(voteOptionTreeDepth, cmdVoteOptionIndexMux);

  let currentVoteWeightQip = treeIncrementalQuin::quinTreeInclusionProof(
    voteOptionTreeDepth, currentVoteWeight, currentVoteWeightPathIndices, currentVoteWeightsPathElements);
  assert(currentVoteWeightQip == ballot[BALLOT_VO_ROOT_IDX]);

  let voteWeightMux = utils::mux1([currentVoteWeight, cmdNewVoteWeight], isMessageValid);
  let newSlVoiceCreditBalance = utils::mux1(
    [stateLeaf[STATE_LEAF_VOICE_CREDIT_BALANCE_IDX], stateLeaf[STATE_LEAF_VOICE_CREDIT_BALANCE_IDX] + b - c],
    enoughVoiceCredits
  );

  let voiceCreditBalanceMux = utils::mux1(
    [stateLeaf[STATE_LEAF_VOICE_CREDIT_BALANCE_IDX], newSlVoiceCreditBalance],
    isMessageValid
  );

  let newVoteOptionTreeQip = treeIncrementalQuin::quinTreeInclusionProof(
    voteOptionTreeDepth, voteWeightMux, currentVoteWeightPathIndices, currentVoteWeightsPathElements);

  let newBallotVoRoot = utils::mux1([ballot[BALLOT_VO_ROOT_IDX], newVoteOptionTreeQip], isMessageValid);
  let newStateLeafHasher = std::hash::poseidon::bn254::hash_4(
    [transformer.newSlPubKey[STATE_LEAF_PUB_X_IDX], 
    transformer.newSlPubKey[STATE_LEAF_PUB_Y_IDX], 
    voiceCreditBalanceMux, 
    stateLeaf[STATE_LEAF_TIMESTAMP_IDX]]
  );

  let newStateRoot = treeIncrementalQuin::quinTreeInclusionProof(
    stateTreeDepth, newStateLeafHasher, stateLeafPathIndices, stateLeafPathElements
  );

  let newBallotNonceMux = utils::mux1([ballot[BALLOT_NONCE_IDX], transformer.newBallotNonce], isMessageValid);
  let newBallotHasher = hasherPoseidon::hashLeftRight(newBallotNonceMux, newBallotVoRoot);
  let newBallotRoot = treeIncrementalQuin::quinTreeInclusionProof(
    stateTreeDepth, newBallotHasher, stateLeafPathIndices, ballotPathElements
  );

  [newStateRoot, newBallotRoot]
}
