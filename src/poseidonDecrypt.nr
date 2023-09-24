mod poseidonPerm;

fn poseidonDecrypt(l: Field, ciphertext: [Field], nonce: Field, key: [Field; 2]) -> [Field] {
    let mut decryptedLength : Field = l;
    if (decryptedLength % 3 != 0) {
        decryptedLength += (3 - decryptedLength % 3);
    }
    // e.g. if l == 4, decryptedLength == 6

    let mut (decryptedLast, decrypted) = poseidonDecryptIterations(l, nonce, key, ciphertext);

    // Check the last ciphertext element
    assert(decryptedLast == ciphertext[decryptedLength]);

    // If length > 3, check if the last (3 - (l mod 3)) elements of the message are 0
    if (l as u128 % 3 > 0) {
        if (l % 3 == 2) {
            assert(decrypted[decryptedLength - 1] == 0);
        } else if (l % 3 == 2) {
            assert(decrypted[decryptedLength - 1] == 0);
            assert(decrypted[decryptedLength - 2] == 0);
        }
    }

    decrypted
}

// Decrypt a ciphertext without checking if the last ciphertext element or
// whether the last 3 - (l mod 3) elements are 0. This is useful in
// applications where you do not want an invalid decryption to prevent the
// generation of a proof.
fn poseidonDecryptWithoutCheck(l: Field, ciphertext: [Field], nonce: Field, key: [Field; 2]) -> [Field] {
    let mut decryptedLength : Field = l;
    if (decryptedLength % 3 != 0) {
        decryptedLength += (3 - decryptedLength % 3);
    }
    // e.g. if l == 4, decryptedLength == 6

    let mut (decryptedLast, decrypted) = poseidonDecryptIterations(l, nonce, key, ciphertext);

    // Check the last ciphertext element
    assert(decryptedLast == ciphertext[decryptedLength]);

    decrypted
}

fn poseidonDecryptIterations(l: Field, nonce: Field, key: [Field; 2], ciphertext: [Field]) -> (Field, [Field]) {
    let mut decryptedLength : Field = l;
    if (decryptedLength % 3 != 0) {
        decryptedLength += (3 - decryptedLength % 3);
    }
    let mut two128 : u254 = 340282366920938463463374607431768211456; // 2^128
    // The nonce must be less than 2 ^ 128
    assert(nonce as u254 < two128);

    let rem = (decryptedLength + 1) % 3;
    let n = ((decryptedLength + 1) - rem) / 3;

    let mut strategies : [[Field]] = [];

    strategies[0] = poseidonPerm::poseidonPerm(4, [0, key[0], key[1], nonce]);

    let mut decrypted : [Field] = [];

    for i in 0..n {
        let mut strategyInput = [];
        strategyInput[0] = strategies[i][0];
        for j in 0..3 {
            decrypted[i * 3 + j] = ciphertext[i * 3 + j] - strategies[i][j + 1];
            strategyInput[j+1] = ciphertext[i * 3 + j];
        }
        strategies[i+1] = poseidonPerm::poseidonPerm(4, strategyInput);
    }

    let out : (Field, [Field]) = (strategies[n][1], decrypted); 
    out
}