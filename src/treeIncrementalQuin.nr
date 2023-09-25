use dep::std;
mod utils;
mod treeCheckRoot;

global LEAVES_PER_NODE = 5;
global LEAVES_PER_PATH_LEVEL = 4; // LEAVES_PER_NODE - 1
global BASE = 5;

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

fn quinSelector(index: Field, quin: [Field]) -> Field {
  assert(index as u3 < quin.len() as u3);
  let mut num : [Field] = [];
  for i in 0..quin.len() {
    if (index == i){
      num[i] = quin[i];
    } else {
      num[i] = 0;
    }
  }
  let calcTotal = utils::calculateTotal(quin.len(), num);
  calcTotal
}

fn splicer(numItems: Field, input: [Field; LEAVES_PER_PATH_LEVEL], leaf: Field, index: Field) -> [Field]{
  let numOutputItems = numItems + 1;
  let mut quinSelectors : [Field] = [];
  let mut output : [Field] = [];
  for i in 0..numOutputItems{
    let greaterThan = if (i as u3 > index as u3){
      1
    } else {
      0
    };
    let isLeafIndex = if (i == index){
      1
    } else {
      0
    };
    
    let mut quin : [Field] = input;
    quin[numItems] = 0;
    quinSelectors[i] = quinSelector(i - greaterThan, quin);
    let mux = utils::mux1([quinSelectors[i], leaf], isLeafIndex);
    output[i] = mux;
  }
  output
}


fn quinTreeInclusionProof(
  levels: Field, leaf: Field, pathIndex: [Field], pathElements: [[Field; LEAVES_PER_PATH_LEVEL]]
  ) -> Field {

  let mut splicers : [[Field]] = [];
  let mut hashers : [Field] = [];
  splicers[0] = splicer(LEAVES_PER_PATH_LEVEL, pathElements[0], leaf, pathIndex[0]);
  let mut splicer0Input: [Field; LEAVES_PER_NODE] = [0; LEAVES_PER_NODE];
    for j in 0..LEAVES_PER_NODE {
      splicer0Input[j] = splicers[0][j];
    }

  hashers[0] = std::hash::poseidon::bn254::hash_5(splicer0Input);

  for i in 1..levels {
    splicers[i] = splicer(LEAVES_PER_PATH_LEVEL, pathElements[i], hashers[i-1], pathIndex[i]);
    let mut splicerInput: [Field; LEAVES_PER_NODE] = [0; LEAVES_PER_NODE];
    for j in 0..LEAVES_PER_NODE {
      splicerInput[j] = splicers[i][j];
    }
    hashers[i] = std::hash::poseidon::bn254::hash_5(splicerInput);
  }
  hashers[levels - 1]
}

fn quinLeafExists(
  levels: Field, leaf: Field, pathIndex: [Field], pathElements: [[Field; LEAVES_PER_PATH_LEVEL]], root: Field
  ) {
  assert(quinTreeInclusionProof(levels, leaf, pathIndex, pathElements) == root);
}

fn quinBatchLeavesExists(
  levels: Field, 
  batchLevels: Field, 
  leaves: [Field], 
  pathIndex: [Field], 
  pathElements: [[Field; LEAVES_PER_PATH_LEVEL]], 
  root: Field
){
  let leavesPerBatch = LEAVES_PER_NODE.pow_32(batchLevels);
  let mut quinLeaves : [Field] = [];
  for i in 0..leavesPerBatch{
    quinLeaves[i] = leaves[i];
  }
  let quinRoot = quinCheckRoot(batchLevels, quinLeaves);
  for _ in 0..(levels - batchLevels) {
    quinLeafExists(levels - batchLevels, quinRoot, pathIndex, pathElements, root);
  }
}

fn quinGeneratePathIndices(levels: Field, input: Field) -> [Field] {
  let mut out : [Field] = [];
  let mut n : [Field] = [];
  let mut m = input;
  for i in 0..levels {
    n[i] = m;
    out[i] = m % BASE;
    m = m / BASE;
  }
  out[levels] = m;
  out
}