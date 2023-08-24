use dep::std::collections::vec::Vec;

fn main(){
    let mut vector: Vec<Field> = Vec::new();
    for i in 0..5 {
        vector.push(i);
    }
    assert(vector.len() == 5);
}