module control_unit(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    output reg [1:0] alu_op,
    output reg reg_dst,
    output reg alu_src,
    output reg mem_to_reg,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg jump
);

always @(*) begin
    case (opcode)
        6'b000000: begin // R-type instructions
            alu_op = 2'b10; // ALU operation determined by funct
            reg_dst = 1; // Write to rd
            alu_src = 0; // ALU source is from registers
            mem_to_reg = 0; // Write back to register from ALU
            reg_write = 1; // Enable register write
            mem_read = 0; // No memory read
            mem_write = 0; // No memory write
            branch = 0; // No branch
            jump = 0; // No jump
        end
        6'b100011: begin // LW instruction
            alu_op = 2'b00; // ALU operation for address calculation
            reg_dst = 0; // Write to rt
            alu_src = 1; // ALU source is immediate value
            mem_to_reg = 1; // Write back to register from memory
            reg_write = 1; // Enable register write
            mem_read = 1; // Enable memory read
            mem_write = 0; // No memory write
            branch = 0; // No branch
            jump = 0; // No jump
        end
        6'b101011: begin // SW instruction
            alu_op = 2'b00; // ALU operation for address calculation
            reg_dst = 0; // Not used, no register writeback
            alu_src = 1; // ALU source is immediate value
            mem_to_reg = 0; // Not used, no register writeback
            reg_write = 0; // Disable register write
            mem_read = 0; // No memory read
            mem_write = 1; // Enable memory write
            branch = 0; // No branch
            jump = 0; // No jump
        end
        6'b001000: begin // ADDI instruction
            alu_op = 2'b00; // ALU operation for addition
            reg_dst = 0; // Write to rt
            alu_src = 1; // ALU source is immediate value
            mem_to_reg = 0; // Write back to register from ALU
            reg_write = 1; // Enable register write
            mem_read = 0; // No memory read
            mem_write = 0; // No memory write
            branch = 0; // No branch
            jump = 0; // No jump
        end
        6'b000100: begin // BEQ instruction
            alu_op = 2'b01; // ALU operation for comparison (subtract)
            reg_dst = 0; // Not used, no register writeback
            alu_src = 0; // ALU source is from registers
            mem_to_reg = 0; // Not used, no register writeback
            reg_write = 0; // Disable register write
            mem_read = 0; // No memory read
            mem_write = 0; // No memory write
            branch = 1; // Enable branch
            jump = 0; // No jump
        end
        6'b000010: begin // J instruction
            alu_op = 2'b00; // No ALU operation needed
            reg_dst = 0; // Not used, no register writeback
            alu_src = 0; // Not used, no ALU source
            mem_to_reg = 0; // Not used, no register writeback
            reg_write = 0; // Disable register write
            mem_read = 0; // No memory read
            mem_write = 0; // No memory write
            branch = 0; // No branch
            jump = 1; // Enable jump
        end
        default: begin // Default case for unrecognized opcodes
            alu_op = 2'b00; // No ALU operation
            reg_dst = 0; // Not used
            alu_src = 0; // Not used
            mem_to_reg = 0; // Not used
            reg_write = 0; // Disable register write
            mem_read = 0; // No memory read
            mem_write = 0; // No memory write
            branch = 0; // No branch
            jump = 0; // No jump
        end
    endcase
end

endmodule