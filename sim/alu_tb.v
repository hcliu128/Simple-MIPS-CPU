`timescale 1ps/1ps
`define HALFT 5
`include "src/alu.v"
`include "src/mux.v"

module alu_tb();

reg [31:0] a, b;
reg [5:0] alu_control;
reg sel;
wire zero;
wire [31:0] result, result_mux;
alu dut(
    .a(a),
    .b(b),
    .alu_control(alu_control), // ADD operation
    .result(result),
    .zero(zero)
);

mux #(.WIDTH(32)) mux_inst (
    .a(a),
    .b(b),
    .sel(sel),
    .out(result_mux) // Using mux to select result based on zero flag
);

reg clk = 1;
always #(`HALFT) clk = ~clk;

initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);
end

initial begin
    #(`HALFT * 2);
    // Test ADD operation
    a = 32'h00000001; // Operand A
    b = 32'h00000002; // Operand B
    alu_control = 6'b100000; // ADD operation
    #(`HALFT * 2);
    if (result !== 32'h00000003 || zero !== 0) begin
        $display("Test failed: ADD result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: ADD result = %h, zero = %b", result, zero);
    end
    // Test SUB operation
    a = 32'h00000005; // Operand A
    b = 32'h00000003; // Operand B
    alu_control = 6'b100010; // SUB operation
    #(`HALFT * 2);
    if (result !== 32'h00000002 || zero !== 0) begin
        $display("Test failed: SUB result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: SUB result = %h, zero = %b", result, zero);
    end
    // Test AND operation
    a = 32'h0000000F; // Operand A
    b = 32'h00000003; // Operand B
    alu_control = 6'b100100; // AND operation
    #(`HALFT * 2);
    if (result !== 32'h00000003 || zero !== 0) begin
        $display("Test failed: AND result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: AND result = %h, zero = %b", result, zero);
    end
    // Test OR operation
    a = 32'h0000000F; // Operand A
    b = 32'h000000F0; // Operand B
    alu_control = 6'b100101; // OR operation
    #(`HALFT * 2);
    if (result !== 32'h000000FF || zero !== 0) begin
        $display("Test failed: OR result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: OR result = %h, zero = %b", result, zero);
    end
    // Test SLT operation
    a = 32'h00000001; // Operand A
    b = 32'h00000002; // Operand B
    alu_control = 6'b101010; // SLT operation
    #(`HALFT * 2);
    if (result !== 32'h00000001 || zero !== 0) begin
        $display("Test failed: SLT result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: SLT result = %h, zero = %b", result, zero);
    end
    // Test NOR operation
    a = 32'h0000000F; // Operand A
    b = 32'h000000F0; // Operand B
    alu_control = 6'b100111; // NOR operation
    #(`HALFT * 2);
    if (result !== 32'hFFFFFF00 || zero !== 0) begin
        $display("Test failed: NOR result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: NOR result = %h, zero = %b", result, zero);
    end
    // Test XOR operation
    a = 32'h0000000F; // Operand A
    b = 32'h000000F0; // Operand B
    alu_control = 6'b100110; // XOR operation
    #(`HALFT * 2);
    if (result !== 32'h000000FF || zero !== 0) begin
        $display("Test failed: XOR result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: XOR result = %h, zero = %b", result, zero);
    end
    // Test SLL operation
    a = 32'h00000001; // Operand A
    b = 32'h00000002; // Operand B (shift amount)
    alu_control = 6'b000000; // SLL operation
    #(`HALFT * 2);
    if (result !== 32'h00000004 || zero !== 0) begin
        $display("Test failed: SLL result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: SLL result = %h, zero = %b", result, zero);
    end
    // Test SRL operation
    a = 32'h00000004; // Operand A
    b = 32'h00000002; // Operand B (shift amount)
    alu_control = 6'b000010; // SRL operation
    sel = 0;
    #(`HALFT * 2);
    if (result !== 32'h00000001 || zero !== 0) begin
        $display("Test failed: SRL result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: SRL result = %h, zero = %b", result, zero);
    end
    if (result_mux !== a) begin
        $display("Test failed: Mux output = %h, expected = %h", result_mux, a);
    end else begin
        $display("Test passed: Mux output = %h, expected = %h", result_mux, a);
    end
    // Test SRA operation
    a = 32'h80000004; // Operand A (negative number)
    b = 32'h00000002; // Operand B (shift amount)
    alu_control = 6'b000011; // SRA operation
    #(`HALFT * 2);
    if (result !== 32'he0000001 || zero !== 0) begin
        $display("Test failed: SRA result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: SRA result = %h, zero = %b", result, zero);
    end
    // Test default case
    a = 32'h00000001; // Operand A
    b = 32'h00000002; // Operand B
    alu_control = 6'b111111; // Invalid operation
    sel = 1;
    #(`HALFT * 2);
    if (result !== 32'b0 || zero !== 1) begin
        $display("Test failed: Default case result = %h, zero = %b", result, zero);
    end else begin
        $display("Test passed: Default case result = %h, zero = %b", result, zero);
    end
    if (result_mux !== b) begin
        $display("Test failed: Mux output = %h, expected = %h", result_mux, b);
    end else begin
        $display("Test passed: Mux output = %h, expected = %h", result_mux, b);
    end
    $finish;
end

endmodule