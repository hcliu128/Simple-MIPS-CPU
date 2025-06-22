module sign_extension(
    input wire [15:0] imm,
    output reg [31:0] extended_imm
);

always @(*) begin
    if (imm[15] == 1'b1) begin
        extended_imm = {16'b1111111111111111, imm};
    end else begin
        extended_imm = {16'b0000000000000000, imm};
    end
end
endmodule