// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/messageValidator.circom

mod verifySignature;

global PACKED_CMD_LENGTH = 4;

fn messageValidator(
  stateTreeIndex: Field, 
  numSignups: Field, 
  voteOptionIndex: Field, 
  maxVoteOptions: Field,
  originalNonce: Field, 
  nonce: Field,
  cmd: [Field; PACKED_CMD_LENGTH], 
  pubKey: [Field; 2],
  sigR8: [Field; 2],
  sigS: Field,
  slTimestamp: Field,
  pollEndTimestamp: Field,
  currentVoiceCreditBalance: Field,
  currentVotesForOption: Field,
  voteWeight: Field,
  ) -> Field {

  let validSignature = verifySignature::verifySignature(pubKey, sigR8, sigS, cmd);

  let validStateLeafIndex = if stateTreeIndex as u252 <= numSignups as u252 {
    1
  } else {
    0
  };

  let validVoteOptionIndex = if voteOptionIndex as u252 <= maxVoteOptions as u252 {
    1
  } else {
    0
  };

  let validNonce = if originalNonce + 1 == nonce {
    1
  } else {
    0
  };

  let validTimestamp = if slTimestamp as u252 < pollEndTimestamp as u252 {
    1
  } else {
    0
  };

  let validVoteWeight = if voteWeight as u252 <= 147946756881789319005730692170996259609 as u252 {
    1
  } else {
    0
  };

  let sufficientVoiceCredits = 
  if (voteWeight as u252 * voteWeight as u252) <= ((currentVotesForOption as u252 * currentVotesForOption as u252) + currentVoiceCreditBalance as u252) {
    1
  } else {
    0
  };

  let isValid = if (7 == sufficientVoiceCredits + validVoteWeight + validNonce + validStateLeafIndex + validTimestamp + validVoteOptionIndex + validSignature) {
    1
  } else {
    0
  };

  isValid
}