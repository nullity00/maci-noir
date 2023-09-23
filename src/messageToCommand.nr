// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/messageToCommand.circom

mod unpackElement;

global MSG_LENGTH = 7;
global PACKED_CMD_LENGTH = 4;
global UNPACKED_CMD_LENGTH = 8;

fn messageToCommand(msg: [Field; 11], pubkey: [Field; 2], encPrivkey: Field) -> [Field] {

  let unpackedElements : [Field] = unpackElement::unpackElement(msg[0], 5);
  let pollId = unpackedElements[0];
  let nonce = unpackedElements[1];
  let newVoteWeight = unpackedElements[2];
  let voteOptionIndex = unpackedElements[3];
  let stateIndex = unpackedElements[4];

  [pollId, nonce, newVoteWeight, voteOptionIndex, stateIndex]
}