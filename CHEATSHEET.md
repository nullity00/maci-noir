### Noir Cheat sheet

```
nargo codegen-verifier  // Creates Verifier Contract
nargo new <project-name> // Creates new project
nargo init // New project in current directory
nargo check // creates prover.toml & verifier.toml
nargo prove p // generates p.proof
nargo prove p -v // generates p.proof & verifies it
nargo verify p // verifier p.proof
nargo prove -p OtherProver my_proof // Takes proving values from OtherProver.toml to generate my_proof.proof
nargo compile <circuit-name> // Outputs ABI of circuit in JSON
nargo compile <circuit-name> --print-acir // Displays ACIR as well
nargo compile <circuit-name> -c // Compiles contract fn as well
nargo gates // Counts occurrences of different gates
nargo test // runs all tests
nargo test <pattern> // runs tests with the pattern in test name
```