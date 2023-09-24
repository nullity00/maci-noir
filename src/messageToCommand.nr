// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/messageToCommand.circom

mod utils;
mod poseidonDecrypt;
mod ecdh;

global MSG_LENGTH = 7;
global PACKED_CMD_LENGTH = 4;
global UNPACKED_CMD_LENGTH = 8;

struct Command {
  pollId: Field,
  nonce: Field,
  newVoteWeight: Field,
  voteOptionIndex: Field,
  stateIndex: Field,
  newPubkey: [Field; 2],
  salt: Field,
  sigR8: [Field; 2],
  sigS: Field,
  packedCommand: [Field; PACKED_CMD_LENGTH],
}

fn messageToCommand(msg: [Field; 11], pubkey: [Field; 2], encPrivkey: Field) -> Command {

  let sharedKey : [Field; 2] = ecdh::ecdh(encPrivkey, pubkey);
  let mut inputMessage : [Field] = [0; 10];

  for i in 0..10 {
    inputMessage[i] = msg[i+1];
  }

  let decryptor = poseidonDecrypt::poseidonDecryptWithoutCheck(MSG_LENGTH, inputMessage, 0, sharedKey);

  let mut packedCommand : [Field; PACKED_CMD_LENGTH] = [0; PACKED_CMD_LENGTH];

  for i in 0..PACKED_CMD_LENGTH {
    packedCommand[i] = decryptor[i];
  }

  let unpackedElements : [Field] = utils::unpackElement(packedCommand[0], 5);
  let pollId = unpackedElements[0];
  let nonce = unpackedElements[1];
  let newVoteWeight = unpackedElements[2];
  let voteOptionIndex = unpackedElements[3];
  let stateIndex = unpackedElements[4];
  let newPubkey : [Field; 2] = [packedCommand[1], packedCommand[2]];
  let salt = packedCommand[3];
  let sigR8 : [Field; 2] = [decryptor[4], decryptor[5]];
  let sigS = decryptor[6];

  Command {pollId, nonce, newVoteWeight, voteOptionIndex, stateIndex, newPubkey, salt, sigR8, sigS, packedCommand }
}