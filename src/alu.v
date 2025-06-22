module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [5:0] alu_control,
    output reg [31:0] result,
    output reg zero
);

parameter ADD = 6'b100000, SUB = 6'b100010, AND = 6'b100100, OR = 6'b100101,
          SLT = 6'b101010, NOR = 6'b100111, XOR = 6'b100110, SLL = 6'b000000,
          SRL = 6'b000010, SRA = 6'b000011;

always @(*) begin
    case (alu_control)
        ADD: result = a + b;
        SUB: result = a - b;
        AND: result = a & b;
        OR: result = a | b;
        SLT: result = ($signed(a) < $signed(b)) ? 1 : 0; // Set on less than
        NOR: result = ~(a | b);
        XOR: result = a ^ b;
        SLL: result = a << b[4:0]; // Shift left logical
        SRL: result = a >> b[4:0]; // Shift right logical
        SRA: result = $signed(a) >>> b[4:0]; // Shift right arithmetic
        default: result = 32'b0; // Default case
    endcase

    zero = (result == 32'b0); // Set zero flag if result is zero
end

endmodule