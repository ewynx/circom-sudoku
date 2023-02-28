const snarkjs = require("snarkjs");
const fs = require("fs");

(async function () {

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


  // VERIFIY PROOF

    const vKey = JSON.parse(fs.readFileSync("verification_key_sudoku_1.json"));
    const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }

    process.exit(0);
})();