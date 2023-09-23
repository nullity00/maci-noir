use dep::std;

fn hashSha256LeftRight(left : u8, right: u8) -> [u8; 32]{
  std::hash::sha256([left, right])
}