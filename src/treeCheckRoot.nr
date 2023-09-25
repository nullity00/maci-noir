use dep::std;

global LEAVES_PER_NODE = 5;

fn quinCheckRoot(levels: Field, leaves: [Field]) -> Field{

  let totalLeaves = LEAVES_PER_NODE.pow_32(levels);
  assert(leaves.len() == totalLeaves);

  let numLeafHashers = LEAVES_PER_NODE.pow_32(levels - 1);

  let mut numHashers: Field = 0;
  for l in 0..levels {
    numHashers += LEAVES_PER_NODE.pow_32(l);
  }

  let mut hashers : [Field] = [];

  for i in 0..numLeafHashers {
    let mut hash_input : [Field; LEAVES_PER_NODE] = [0; LEAVES_PER_NODE];
    for j in 0..LEAVES_PER_NODE {
      hash_input[j] = leaves[i * LEAVES_PER_NODE + j];
    }
    hashers[i] = std::hash::poseidon::bn254::hash_5(hash_input);
  }

  let mut counter = 0;
  for i in numLeafHashers..numHashers {
    let mut hash_input : [Field; LEAVES_PER_NODE] = [0; LEAVES_PER_NODE];
    for j in 0..LEAVES_PER_NODE {
      hash_input[j] = hashers[counter * LEAVES_PER_NODE + j];
    }
    hashers[i] = std::hash::poseidon::bn254::hash_5(hash_input);
    counter += 1;
  }

  hashers[numHashers - 1]
}