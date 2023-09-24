

fn calculateTotal(num_length: Field, num: [Field]) -> Field{
  let mut sum : Field = 0;
  for i in 0..num_length {
    sum += num[i];
  }
  sum
}