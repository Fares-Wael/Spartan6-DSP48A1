module DSP48A1_TB();

  reg CLK, RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTOPMODE, RSTCARRYIN, RSTCARRYOUT;
  reg CEA, CEB, CEC, CED, CEM, CEP, CEOPMODE, CECARRYIN, CECARRYOUT;
  reg [17:0] A, B, D;
  reg [47:0] C, PCIN;
  reg [17:0] BCIN;
  reg [7:0] OPMODE;
  reg CARRYIN;

  wire [47:0] P, PCOUT;
  wire [17:0] BCOUT;
  wire CARRYOUT, CARRYOUTF;
  wire [35:0] M;

  //Test Signals
  reg [35 : 0] M_Test;
  reg [47 : 0] P_Test, PCOUT_Test;
  reg [17 : 0] PRE_ADDER_OUT;
  reg CARRYOUT_Test, CARRYOUTF_Test;

  DSP48A1 #(
      .A0REG      (1'b1),
      .A1REG      (1'b1),
      .B0REG      (1'b1),
      .B1REG      (1'b1),
      .CREG       (1'b1),
      .PREG       (1'b1),
      .MREG       (1'b1),
      .DREG       (1'b1),
      .CARRYINREG (1'b1),
      .CARRYOUTREG(1'b1),
      .OPMODEREG  (1'b1),
      .CARRYINSEL ("OPMODE5"),  // Choose between "CARRYIN" or "OPMODE5"
      .B_INPUT_SEL("DIRECT"),   // Choose between "DIRECT" or "CASCADE"
      .RSTTYPE    ("SYNC")      // Choose between "SYNC" or "ASYNC"
  ) uut (
      .CLK(CLK),
      .RSTA(RSTA),
      .RSTB(RSTB),
      .RSTC(RSTC),
      .RSTD(RSTD),
      .RSTM(RSTM),
      .RSTP(RSTP),
      .RSTOPMODE(RSTOPMODE),
      .RSTCARRYIN(RSTCARRYIN),
      .RSTCARRYOUT(RSTCARRYOUT),
      .CEA(CEA),
      .CEB(CEB),
      .CEC(CEC),
      .CED(CED),
      .CEM(CEM),
      .CEP(CEP),
      .CEOPMODE(CEOPMODE),
      .CECARRYIN(CECARRYIN),
      .CECARRYOUT(CECARRYOUT),
      .A(A),
      .B(B),
      .D(D),
      .C(C),
      .PCIN(PCIN),
      .BCIN(BCIN),
      .OPMODE(OPMODE),
      .CARRYIN(CARRYIN),
      .P(P),
      .PCOUT(PCOUT),
      .BCOUT(BCOUT),
      .CARRYOUT(CARRYOUT),
      .CARRYOUTF(CARRYOUTF),
      .M(M)
  );

  always #5 CLK = ~CLK;

  initial begin
    CLK = 0;

    // Activate Reset
    RSTA = 1; RSTB = 1; RSTC = 1; RSTD = 1;
    RSTM = 1; RSTP = 1; RSTOPMODE = 1; RSTCARRYIN = 1; RSTCARRYOUT = 1;
    
    CEA = 1; CEB = 1; CEC = 1; CED = 1;
    CEM = 1; CEP = 1; CEOPMODE = 1; CECARRYIN = 1; CECARRYOUT = 1;

    A = 10; B = 10; D = 10;
    C = 10; PCIN = 1; BCIN = 1;
    OPMODE = 8'b00101101; // Test with carryin
    CARRYIN = 1;
    CARRYOUT_Test = 0;
    CARRYOUTF_Test = 0;
    PCOUT_Test = 0;
    P_Test = 0;
    M_Test = 0;
    @(negedge CLK);
    if (M !== M_Test || P !== P_Test || PCOUT !== PCOUT_Test || CARRYOUT !== CARRYOUT_Test || CARRYOUTF !== CARRYOUTF_Test)
        $display("Reset Test Failed! M = %d, P = %d", M, P);
    else
        $display("Reset Test Passed! M = %d, P = %d", M, P);

    #20;
    RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0;
    RSTCARRYIN = 0; RSTM = 0; RSTP = 0; RSTOPMODE = 0;

    repeat(2) @(negedge CLK);

    PRE_ADDER_OUT = D + B;
    @(negedge CLK);

    M_Test = PRE_ADDER_OUT * A;
    @(negedge CLK);

    P_Test = M_Test + C + OPMODE[5];
    @(negedge CLK);

    PCOUT_Test = P_Test;
    @(negedge CLK);

    CARRYOUT_Test = 0;
    CARRYOUTF_Test = CARRYOUT_Test;
    @(negedge CLK);

    if (M !== M_Test || P !== P_Test || PCOUT !== PCOUT_Test || CARRYOUT !== CARRYOUT_Test || CARRYOUTF !== CARRYOUTF_Test)
        $display("Test Failed! M = %d, P = %d", M, P);
    else
        $display("Test Passed! M = %d, P = %d", M, P);

    @(negedge CLK);
    @(negedge CLK);
    OPMODE = 8'b00001101; // Test with carryin disabled

    if (M !== M_Test || P !== P_Test || PCOUT !== PCOUT_Test || CARRYOUT !== CARRYOUT_Test || CARRYOUTF !== CARRYOUTF_Test)
        $display("Test Failed! M = %d, P = %d", M, P);
    else
        $display("Test Passed! M = %d, P = %d", M, P);
    $stop;
end
initial begin
    $monitor("Time: %0t | CLK: %b | RST: %b | B: %d | D: %d | BCOUT: %d | PRE_ADDER_OUT: %d | A: %d | M: %d | M_Test: %d | P: %d | P_Test: %d | CARRYOUT: %b | CARRYOUT_Test: %b", 
             $time, CLK, RSTA, B, D, BCOUT, PRE_ADDER_OUT, A, M, M_Test, P, P_Test, CARRYOUT, CARRYOUT_Test);
end

endmodule
