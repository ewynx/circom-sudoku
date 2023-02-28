pragma circom 2.0.0;

template NonEqual() {
  signal input in0;
  signal input in1;

  // check that (in0-in1) is non-zero
  signal inverse;
  inverse <-- 1/(in0-in1);
  // we also need to check this constraint is respected 
  inverse*(in0-in1) === 1;
}


// ensures that all elements are unique in the array
template Distinct(n) {
  signal input in[n];
  component nonEqual[n][n];

  // for every pair we create a component to ensure this pair is non-equal
  for(var i = 0; i < n; i++) {
    for (var j = 0; j < i; j++) {
      nonEqual[i][j] = NonEqual(); 

      nonEqual[i][j].in0 <== in[i];
      nonEqual[i][j].in1 <== in[j];
    }
  }
}

// Enforce that 0 <= in < 16 (fits in 4 bits)
template Bits4() {
  signal input in;
  signal bits[4];
  var bitsum = 0;
  // calculates the number that is held in the first 4 bits
  for (var i = 0; i < 4; i++) {
    bits[i] <-- (in >>i) & 1;
    bits[i] * (bits[i]-1) === 0; 
    bitsum = bitsum + 2 ** i * bits[i];
  }
  // checks whether the nr held in the first 4 bits is equal to the original number
  bitsum === in;
}

template OneToNine() {
  signal input in;
  component lowerBound = Bits4();
  component upperBound = Bits4();
  // lowerbound in Bits4 is 0, so need to subtract 1
  lowerBound.in <== in - 1;
  // upperbound in Bits4 is 15, 9+6=15
  upperBound.in <== in + 6;
}

template Sudoku(n) {
  // SOLUTION is 2D array; indices are (row_i, col_i)
  signal input solution[n][n];
  // PUZZLE is the same, but a zero indicates a blank
  signal input puzzle[n][n];

  // ensure all inputs of the SOLUTION are in range
  component inRange[n][n];
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n; j++) {
      inRange[i][j] = OneToNine();
      inRange[i][j].in <== solution[i][j];
    }
  }

  // ensure that the PUZZLE and the SOLUTION agree; 
  // -> all nonzero values in SOLUTION should equal to the PUZZLE
  // -> the PUZZLE is possibly not yet complete; when there's a zero, it stands for a blank
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n; j++) {
      // perform check: puzzle_cell * (puzzle_cell - solution_cell) === 0
      // either: 
      // (a) puzzle_cell is 0
      // (b) puzzle_cell equals solution_cell
      puzzle[i][j] * (puzzle[i][j] - solution[i][j]) === 0;
    }
  }

  // ensure uniqueness in rows of SOLUTION
  component distinct_rows[n];
  for (var i = 0; i < n; i++) {
    // for each row we need a new component
    // Distinct checks that all elements in array are distinct (by compairing all pairs)
    distinct_rows[i] = Distinct(n);
    for (var j = 0; j < n; j++) {
      distinct_rows[i].in[j] <== solution[i][j];
    }
  }

  // ensure uniqueness in columns of SOLUTION
  component distinct_columns[n];
  for (var i = 0; i < n; i++) {
    distinct_columns[i] = Distinct(n);
    for (var j = 0; j < n; j++) {
      distinct_columns[i].in[j] <== solution[j][i];
    }
  }

  component distinct_grids[n];
  for (var i = 0; i < n; i += 3) { 
    distinct_grids[i] = Distinct(n);
    
    // the n arrays must be filled with the n grids of 3x3
    var index = 0; 
    for (var j = 0; j < 3; j++) {// j=0,1,2
      for (var k = 0; k < 3; k++) {// k=0,1,2
        distinct_grids[i].in[index] <== solution[j][k];// (j,k) = 0,0 0,1 0,2 1,0 1,1 1,2 2,0 2,
        index++;
      }
    }
  }
}

component main {public[puzzle]} = Sudoku(9);
