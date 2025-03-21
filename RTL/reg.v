module reg_mux #(
    parameter RSTTYPE = "SYNC", // "SYNC" or "ASYNC"
    parameter REG_WIDTH = 18
) (
    input CLK, RST, CE, SEL,
    input [REG_WIDTH-1:0] D,
    output [REG_WIDTH-1:0] MUX_OUT
);

    reg [REG_WIDTH-1:0] OUT_SYNC;

    generate
        if (RSTTYPE == "SYNC") begin : sync_reset
            always @(posedge CLK) begin
                if (RST) 
                    OUT_SYNC <= {REG_WIDTH{1'b0}};
                else if (CE) 
                    OUT_SYNC <= D;
            end
        end else begin : async_reset
            always @(posedge CLK or posedge RST) begin
                if (RST) 
                    OUT_SYNC <= {REG_WIDTH{1'b0}};
                else if (CE) 
                    OUT_SYNC <= D;
            end
        end
    endgenerate

    assign MUX_OUT = (SEL) ? OUT_SYNC : D;

endmodule
