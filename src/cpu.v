// 包含所有需要的子模組
`include "./src/alu.v"
`include "./src/control_unit.v"
`include "./src/mux.v"
`include "./src/memory.v"
`include "./src/reg_file.v"
`include "./src/alu_control.v"
`include "./src/inst_mem.v"
`include "./src/pc.v"
`include "./src/sign_extension.v"

module cpu(
    input clk,
    input rst
);
    // ------------------- Control Signals (Wires) -------------------
    wire        reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump;
    wire [1:0]  alu_op;

    // ------------------- Data Path (Wires) -------------------------
    // PC and Instruction
    wire [31:0] pc_current, pc_next, pc_plus_4;
    wire [31:0] instruction;
    
    // Register File
    wire [4:0]  write_reg_addr;
    wire [31:0] write_reg_data;
    wire [31:0] rs1_data, rs2_data;

    // Immediate
    wire [31:0] sign_extended_imm;

    // ALU
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [5:0]  final_alu_control;
    wire        alu_zero;

    // Data Memory
    wire [31:0] mem_read_data;

    // Branch/Jump Address Calculation
    wire [31:0] branch_addr;
    wire [31:0] pc_after_branch;
    wire [31:0] jump_addr;

    // =================================================================
    //  STAGE 1: Instruction Fetch (IF)
    // =================================================================
    
    // PC Register: Stores the current PC, updates on next clock edge
    pc pc_reg(
        .clk(clk),
        .rst(rst),
        .next_pc(pc_next),
        .pc(pc_current)
    );

    // Instruction Memory: Fetches instruction at the current PC
    instruction_memory inst_mem (
        .addr(pc_current),
        .instruction(instruction)
    );

    // PC + 4 Adder
    assign pc_plus_4 = pc_current + 4;

    // =================================================================
    //  STAGE 2: Instruction Decode & Register Fetch (ID)
    // =================================================================
    
    // Control Unit: Decodes the opcode to generate control signals
    control_unit ctrl_unit(
        .opcode(instruction[31:26]),
        .funct(instruction[5:0]), // funct is not used here but wired for completeness
        .alu_op(alu_op),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump)
    );

    // Register File: Reads data from rs1 and rs2
    reg_file reg_file_inst(
        .clk(clk),
        .rst(rst),
        .rs1(instruction[25:21]),
        .rs2(instruction[20:16]),
        .rd(write_reg_addr),
        .write_data(write_reg_data),
        .write_enable(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Mux for Destination Register Address (chooses between rt and rd)
    mux #(.WIDTH(5)) reg_dst_mux(
        .a(instruction[20:16]), // I-type destination is rt
        .b(instruction[15:11]), // R-type destination is rd
        .sel(reg_dst),
        .out(write_reg_addr)
    );

    // Sign Extension for immediate values
    sign_extension sign_ext_inst(
        .imm(instruction[15:0]),
        .extended_imm(sign_extended_imm)
    );

    // =================================================================
    //  STAGE 3: Execute (EX)
    // =================================================================

    // ALU Control: Decodes alu_op and funct to get the final ALU operation
    alu_control alu_ctrl_inst(
        .funct(instruction[5:0]),
        .alu_op(alu_op),
        .alu_control(final_alu_control)
    );

    // Mux for ALU's second operand (chooses between rs2_data and immediate)
    mux #(.WIDTH(32)) alu_src_mux(
        .a(rs2_data),
        .b(sign_extended_imm),
        .sel(alu_src),
        .out(alu_input_b)
    );
    
    // ALU: Performs the calculation
    alu alu_inst(
        .a(rs1_data),
        .b(alu_input_b),
        .alu_control(final_alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

    // =================================================================
    //  STAGE 4: Memory Access (MEM)
    // =================================================================

    // Data Memory: Reads from or writes to memory
    memory data_mem(
        .clk(clk),
        .rst(rst),
        .address(alu_result), // Address comes from ALU result (for lw/sw)
        .write_data(rs2_data), // Data to be written comes from rs2
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );

    // =================================================================
    //  STAGE 5: Write Back (WB) & PC Update
    // =================================================================

    // Mux for Write-Back data (chooses between ALU result and memory data)
    mux #(.WIDTH(32)) mem_to_reg_mux(
        .a(alu_result),
        .b(mem_read_data),
        .sel(mem_to_reg),
        .out(write_reg_data)
    );

    // --- PC Update Logic ---
    
    // Branch Address Calculation: PC+4 + (offset * 4)
    assign branch_addr = pc_plus_4 + (sign_extended_imm << 2);
    
    // Mux for Branch decision (PC+4 or Branch Address)
    mux #(.WIDTH(32)) branch_mux(
        .a(pc_plus_4),
        .b(branch_addr),
        .sel(branch && alu_zero), // Branch is taken only if branch signal is high AND zero flag is high
        .out(pc_after_branch)
    );

    // Jump Address Calculation: { (PC+4)[31:28], instruction[25:0], 2'b00 }
    assign jump_addr = {pc_plus_4[31:28], instruction[25:0], 2'b00};

    // Final Mux for Next PC (Jump has priority over Branch)
    mux #(.WIDTH(32)) pc_next_mux(
        .a(pc_after_branch), // Result from branch logic
        .b(jump_addr),         // Jump address
        .sel(jump),
        .out(pc_next)
    );

endmodule