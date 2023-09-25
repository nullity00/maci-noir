use dep::std;
mod hasherPoseidon;
mod utils;

fn merkleTreeInclusionProof(n_levels : Field, leaf: Field, pathIndex: [Field], pathElements: [[Field; 1]]) -> Field {

  assert(n_levels == pathIndex.len());
  assert(n_levels == pathElements.len());
  
  let mut levelHashes : [Field] = [];
  levelHashes[0] = leaf;

  for i in 0..n_levels {
    assert(pathIndex[i] * (pathIndex[1] - 1) == 0);

    let mut hashMux : [[Field; 2]] = [];
    hashMux[0] = [levelHashes[i], pathElements[i][0]];
    hashMux[1] = [pathElements[i][1], levelHashes[i]];

    let output = utils::multiMux1(pathIndex[i], hashMux, 2);
    levelHashes[i+1] = hasherPoseidon::hashLeftRight(output[0], output[1]);
  }

  levelHashes[n_levels]
}

fn leafExists(levels: Field, leaf: Field, pathElements: [[Field; 1]], pathIndex: [Field], root: Field){
  let merkleRoot = merkleTreeInclusionProof(levels, leaf, pathIndex, pathElements);
  assert(merkleRoot == root);
}

fn checkRoot(levels: Field, leaves : [Field]) -> Field {
  let totalLeaves = 2.pow_32(levels);
  let numLeafHashers = totalLeaves / 2;
  let numIntermediateHashers = numLeafHashers - 1;
  let mut hashers : [Field] = [];
  for i in 0..numLeafHashers {
    hashers[i] = hasherPoseidon::hashLeftRight(leaves[i*2], leaves[i*2+1]);
  }
  let mut k = 0;
  for i in numLeafHashers..(numLeafHashers + numIntermediateHashers) {
    hashers[i] = hasherPoseidon::hashLeftRight(hashers[k*2], hashers[k*2+1]);
    k = k + 1;
  }
  hashers[totalLeaves - 2]
}
