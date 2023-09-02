// https://github.com/privacy-scaling-explorations/maci/blob/master/circuits/circom/privToPubKey.circom
use dep::std;

fn privToPubKey(privKey: Field) -> [Field; 2]{
  let scal = std::scalar_mul::fixed_base(privKey);
  scal
}