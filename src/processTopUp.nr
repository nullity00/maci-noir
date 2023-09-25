use dep::std;
mod utils;
mod treeIncrementalQuin;

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

fn processTopUp(
  stateTreeDepth: Field,
  msgType: Field, 
  stateTreeIndex: Field, 
  amount: Field, 
  numSignups: Field, 
  stateLeaf: [Field; STATE_LEAF_LENGTH], 
  stateLeafPathElements: [[Field; TREE_ARITY - 1]],
  ) -> Field {

  let index = stateTreeIndex * (msgType - 1);
  let amt = amount * (msgType - 1);
  let validStateLeafIndex = if (index as u252 < numSignups as u252){
    index
  } else {
    0
  };

  let indexMux = utils::mux1([0, index], validStateLeafIndex);
  let amtMux = utils::mux1([0, amt], validStateLeafIndex);

  let newCreditBalance = stateLeaf[STATE_LEAF_VOICE_CREDIT_BALANCE_IDX] + amtMux;
  assert(stateLeaf[STATE_LEAF_VOICE_CREDIT_BALANCE_IDX] as u252 < newCreditBalance as u252);

  let newStateLeafHasher = std::hash::poseidon::bn254::hash_4(
    [stateLeaf[STATE_LEAF_PUB_X_IDX], stateLeaf[STATE_LEAF_PUB_Y_IDX], newCreditBalance, stateLeaf[STATE_LEAF_TIMESTAMP_IDX]]
  );

  let stateLeafPathIndices = treeIncrementalQuin::quinGeneratePathIndices(stateTreeDepth, indexMux);
  let newStateLeafQip = treeIncrementalQuin::quinTreeInclusionProof(
    stateTreeDepth, newStateLeafHasher, stateLeafPathIndices, stateLeafPathElements);
  newStateLeafQip
}