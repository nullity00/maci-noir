// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/stateLeafAndBallotTransformer.circom

global PACKED_CMD_LENGTH = 4;

struct TransformerOutput {
  newSlPubKey: [Field; 2],
  newBallotNonce: Field,
  isValid: Field,
}

fn stateLeafAndBallotTransformer(
  numSignUps: Field,
  maxVoteOptions: Field,
  // State leaf
  slPubKey: [Field; 2],
  slVoiceCreditBalance: Field,
  slTimestamp: Field,
  pollEndTimestamp: Field,
  // Ballot
  ballotNonce: Field,
  ballotCurrentVotesForOption: Field,
  // Command
  cmdStateIndex: Field,
  cmdNewPubKey: [Field; 2],
  cmdVoteOptionIndex: Field,
  cmdNewVoteWeight: Field,
  cmdNonce: Field,
  cmdPollId: Field,
  cmdSalt: Field,
  cmdSigR8: [Field; 2],
  cmdSigS: Field,
  // Note: we assume that packedCommand is valid!
  packedCommand: [Field; PACKED_CMD_LENGTH],

) -> TransformerOutput{
  TransformerOutput{
    newSlPubKey: [0, 0],
    newBallotNonce: 0,
    isValid: 0,
  }
}