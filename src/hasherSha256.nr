use dep::std;

fn hashSha256LeftRight(left : u8, right: u8) -> [u8; 32]{
  std::hash::sha256([left, right])
}

// TO DO : implement a function that takes a field, converts it to list of bytes and returns a hash in field type