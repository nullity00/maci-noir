mod constants
mod poseidonUtils


global N_ROUNDS_P = [56, 57, 56, 60, 60, 63, 64, 63, 60, 66, 60, 65, 70, 60, 64, 68];
global nRoundsF = 8;

fn poseidonPerm(t: Field, inputs: [Field]) -> [Field]{

  let nRoundsP = N_ROUNDS_P[t - 2];

  let totalRounds = nRoundsF + nRoundsP;
  let c : [Field] = constants::POSEIDON_C(t);

  let mut mixOut: [[Field]] = [];
  let mut arkOut: [[Field]] = [];
  let mut sigmaFOut: [[Field]] = [];
  let mut sigmaPOut: [Field] = [];
  
  let mut k = 0;
  for i in 0..totalRounds {
    let mut arkInput : [Field] = [];
    arkOut[i] = poseidonUtils::ark(t, c, inputs, t*i);
    for j in 0..t {
      if (i == 0){
        arkInput[j] = inputs[j];
      } else {
        arkInput[j] = mixOut[i-1][j];
      }
    }

    let mut mixInputs : [Field] = [];

    if ((i as u128 < nRoundsF as u128 / 2 ) | i as u128 >= nRoundsP as u128 + nRoundsF as u128/2) {

      if (i as u128< nRoundsF as u128/2) {
        k = i;
      } else {
        k = i - nRoundsP;
      }
      for j in 0..t {
        sigmaFOut[k][j] = poseidonUtils::sigma(arkOut[i][j]);
        mixInputs[j] = sigmaFOut[k][j];
      }

    } else {

      k = i - nRoundsF/2;
      sigmaPOut[k] = poseidonUtils::sigma(arkOut[i][0]);
      mixInputs[0] = sigmaPOut[k];
      for j in 1..t {
        mixInputs[j] = arkOut[i][j];
      }

    }
  }

  let mut out : [Field] = [];

  for i in 0..t {
    out[i] = mixOut[totalRounds-1][i];
  }

  out
}