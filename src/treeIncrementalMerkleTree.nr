use dep::std;
mod hasherPoseidon;

fn multiMux1(selector: Field, constants: [(Field, Field)], n: Field) -> [Field]{
  let mut result : [Field] = [];
  for i in 0..n {
    result[i] = (constants[i].0 - constants[i].1) * selector + constants[i].0;
  }
  result
}

fn MerkleTreeInclusionProof(n_levels : Field, leaf: Field, pathIndex: [Field], path_elements: [(Field, Field)]) -> Field {

  assert(n_levels == pathIndex.len());
  assert(n_levels == path_elements.len());
  
  let mut levelHashes : [Field] = [];
  levelHashes[0] = leaf;

  for i in 0..n_levels {
    assert(pathIndex[i] * (pathIndex[1] - 1) == 0);

    let mut hashMux : [(Field, Field)] = [];
    hashMux[0] = (levelHashes[i], path_elements[i].0);
    hashMux[1] = (path_elements[i].1, levelHashes[i]);

    let output = multiMux1(pathIndex[i], hashMux, 2);
    levelHashes[i+1] = hasherPoseidon::hashLeftRight(output[0], output[1]);
  }

  levelHashes[n_levels]
}
