

# Setup a circuit + test it 

Requirement: have installed [circom](https://github.com/iden3/circomlib).

## 0. Initialize project 

```
npm init
npm i circomlib
```

## 1. Create and build circuit
Create a file `sudoku.circom`. 
Add the code for the circuit. 
Create a folder called `build`. 
Run
```
circom sudoku.circom --wasm --r1cs -o ./build
```

## 2. Get preprocessed verification key file (for testing use an existing one)

For production, must generate own file. 

```
wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_12.ptau
```

## 3. Generate proving and verification key 

Generate proving key.
```
npx snarkjs groth16 setup build/sudoku.r1cs powersOfTau28_hez_final_12.ptau circuit_sudoku_1.zkey
```

Generate verification key.
```
npx snarkjs zkey export verificationkey circuit_sudoku_1.zkey verification_key_sudoku_1.json
```

## 4. Create js testfile

```
npm i snarkjs
```

Create a file `test_sudoku.js`.

To generate a proof use something like:
```javascript
  const input = {
    "solution":
      [
        ["1","9","4","8","6","5","2","3","7"],
        ["7","3","5","4","1","2","9","6","8"],
        ["8","6","2","3","9","7","1","4","5"],
        ["9","2","1","7","4","8","3","5","6"],
        ["6","7","8","5","3","1","4","2","9"],
        ["4","5","3","9","2","6","8","7","1"],
        ["3","8","9","6","5","4","7","1","2"],
        ["2","4","6","1","7","9","5","8","3"],
        ["5","1","7","2","8","3","6","9","4"]
      ],
    "puzzle":
      [
        ["0","0","0","8","6","0","2","3","0"],
        ["7","0","5","0","0","0","9","0","8"],
        ["0","6","0","3","0","7","0","4","0"],
        ["0","2","0","7","0","8","0","5","0"],
        ["0","7","8","5","0","0","0","0","0"],
        ["4","0","0","9","0","6","0","7","0"],
        ["3","0","9","0","5","0","7","0","2"],
        ["0","4","0","1","0","9","0","8","0"],
        ["5","0","7","0","8","0","0","9","4"]
      ]
  };

  // GENERATE PROOF
    const { proof, publicSignals } = await snarkjs.groth16.fullProve( input, "build/sudoku_js/sudoku.wasm", "circuit_sudoku_1.zkey");
    console.log(publicSignals);
    console.log(proof);
```

To verify the proof, use something like:

```javascript
  // VERIFIY PROOF

    const vKey = JSON.parse(fs.readFileSync("verification_key_sudoku_1.json"));
    const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }
```

## 5. Run test

```
node test_sudoko.js
```