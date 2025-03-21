module DSP48A1 #(
    parameter A0REG = 1'b0,
    parameter A1REG = 1'b1,
    parameter B0REG = 1'b0,
    parameter B1REG = 1'b1,
    parameter CREG = 1'b1,
    parameter PREG = 1'b1,
    parameter MREG = 1'b1,
    parameter DREG = 1'b1,
    parameter CARRYINREG = 1'b1,
    parameter CARRYOUTREG = 1'b1,
    parameter OPMODEREG = 1'b1,
    parameter CARRYINSEL = "OPMODE5", // "CARRYIN" or "OPMODE5"
    parameter B_INPUT_SEL = "DIRECT", // "DIRECT" or "CASCADE"
    parameter RSTTYPE = "SYNC" // "SYNC" or "ASYNC"
) (
    input [17 : 0] A, B, D,
    input [47 : 0] C, PCIN,
    input [17 : 0] BCIN,
    input [7 : 0] OPMODE,
    input CLK, CARRYIN,
    input RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTOPMODE, RSTCARRYIN, RSTCARRYOUT,
    input CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE, CECARRYOUT,
    output [47 : 0] P,
    output [35 : 0] M,
    output [47 : 0] PCOUT,
    output [17 : 0] BCOUT,
    output CARRYOUT, CARRYOUTF
);
    wire [17 : 0] A_REG0, B_REG0, D_REG;
    wire [17 : 0] A_REG1, B_REG1;
    wire [47 : 0] C_REG;
    wire [17 : 0] MUX_B_OUT, B0_MUX;
    wire [7 : 0] opmode_mux;
    wire [17 : 0] pre_adder_sub_out;
    wire [35 : 0] multiplier_out;
    wire carry_in_reg, CIN, SUM_CARRY_OUT;
    reg [47:0] X_mux ,Z_mux;
    wire [47:0] SUM_OUT;

    assign pre_adder_sub_out =(opmode_mux[6])? (D_REG - B_REG0) : (D_REG + B_REG0);
    assign MUX_B_OUT = (B_INPUT_SEL == "DIRECT")? B : (B_INPUT_SEL == "CASCADE")? BCIN : 0;
    assign B0_MUX = (opmode_mux[4])? B_REG0 : pre_adder_sub_out;
    assign multiplier_out = A_REG1 * B_REG1;
    assign carry_in_reg = (CARRYINSEL == "OPMODE5")? opmode_mux[5] : (CARRYINSEL == "CARRYIN")? CARRYIN : 0;
    assign {SUM_CARRY_OUT , SUM_OUT} = (opmode_mux[7])? (Z_mux - (X_mux + CIN)) : (Z_mux + (X_mux + CIN));
    assign PCOUT = P;
    assign BCOUT = B_REG1;
    assign CARRYOUTF = CARRYOUT;

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(18)
    ) reg_a0 (
        .CLK(CLK), .RST(RSTA), .CE(CEA), .SEL(A0REG),
        .D(A), .MUX_OUT(A_REG0)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(18)
    ) reg_a1 (
        .CLK(CLK), .RST(RSTA), .CE(CEA), .SEL(A1REG),
        .D(A_REG0), .MUX_OUT(A_REG1)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(18)
    ) reg_b0 (
        .CLK(CLK), .RST(RSTB), .CE(CEB), .SEL(B0REG),
        .D(MUX_B_OUT), .MUX_OUT(B_REG0)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(18)
    ) reg_b1 (
        .CLK(CLK), .RST(RSTB), .CE(CEB), .SEL(B1REG),
        .D(B0_MUX), .MUX_OUT(B_REG1)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(18)
    ) reg_d (
        .CLK(CLK), .RST(RSTD), .CE(CED), .SEL(DREG),
        .D(D), .MUX_OUT(D_REG)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(48)
    ) reg_c (
        .CLK(CLK), .RST(RSTC), .CE(CEC), .SEL(CREG),
        .D(C), .MUX_OUT(C_REG)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(8)
    ) reg_pc (
        .CLK(CLK), .RST(RSTOPMODE), .CE(CEOPMODE), .SEL(OPMODEREG),
        .D(OPMODE), .MUX_OUT(opmode_mux)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(36)
    ) M_REG (
        .CLK(CLK), .RST(RSTM), .CE(CEM), .SEL(MREG),
        .D(multiplier_out), .MUX_OUT(M)
    );

     reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(1)
    ) CYI (
        .CLK(CLK), .RST(RSTCARRYIN), .CE(CECARRYIN), .SEL(CARRYINREG),
        .D(carry_in_reg), .MUX_OUT(CIN)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(1)
    ) CYO (
        .CLK(CLK), .RST(RSTCARRYOUT), .CE(CECARRYOUT), .SEL(CARRYOUTREG),
        .D(SUM_CARRY_OUT), .MUX_OUT(CARRYOUT)
    );

    reg_mux #(
        .RSTTYPE(RSTTYPE),
        .REG_WIDTH(48)
    ) P_REG (
        .CLK(CLK), .RST(RSTP), .CE(CEP), .SEL(PREG),
        .D(SUM_OUT), .MUX_OUT(P)
    );

   always @(*) begin
    case({opmode_mux[3],opmode_mux[2]})
        2'b00 : Z_mux = 48'b0;
        2'b01 : Z_mux = PCIN;
        2'b10 : Z_mux = P;
        2'b11 : Z_mux = C_REG;
    endcase
   end

    always @(*) begin
        case({opmode_mux[1],opmode_mux[0]})
            2'b00 : X_mux = 48'b0;
            2'b01 : X_mux = {12'b0, M};
            2'b10 : X_mux = PCOUT;
            2'b11 : X_mux = {D_REG[11 : 0], A_REG1, B_REG1};
        endcase
    end
endmodule
