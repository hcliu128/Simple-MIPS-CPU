module alu_control(
    input wire [5:0] funct,
    input wire [1:0] alu_op,
    output reg [5:0] alu_control
);  

parameter ADD = 6'b100000, SUB = 6'b100010, AND = 6'b100100, OR = 6'b100101,
          SLT = 6'b101010, NOR = 6'b100111, XOR = 6'b100110, SLL = 6'b000000,
          SRL = 6'b000010, SRA = 6'b000011;

always @(*) begin
    case (alu_op)
        2'b00: alu_control = ADD; // LW, SW, ADDI
        2'b01: alu_control = SUB; // Branch instructions
        2'b10: begin // R-type instructions
            case (funct)
                6'b100000: alu_control = ADD; 
                6'b100010: alu_control = SUB; 
                6'b100100: alu_control = AND; 
                6'b100101: alu_control = OR;
                6'b101010: alu_control = SLT; 
                6'b100111: alu_control = NOR; 
                6'b100110: alu_control = XOR; 
                6'b000000: alu_control = SLL; 
                6'b000010: alu_control = SRL; 
                6'b000011: alu_control = SRA; 
                default: alu_control = 6'b000000; // Default case
            endcase
        end
        default: alu_control = 6'b000000; // Default case for unsupported ALU operations
    endcase
end


endmodule