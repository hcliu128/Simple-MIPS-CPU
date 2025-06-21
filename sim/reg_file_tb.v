`timescale 1ps/1ps
`define HALFT 5
`include "src/reg_file.v"

module reg_file_tb();

reg clk, rst, WEN;
reg [4:0] WADDR, RADDR0, RADDR1;
reg [31:0] WDATA; 
wire [31:0] RDATA0, RDATA1;
reg_file dut(
    .clk(clk),
    .rst(rst),
    .rs1(RADDR0),
    .rs2(RADDR1),
    .rd(WADDR),
    .write_data(WDATA), 
    .write_enable(WEN), 
    .rs1_data(RDATA0),
    .rs2_data(RDATA1)
);


always #(`HALFT) clk = ~clk;

initial begin
    clk = 1;
    WEN = 0;
    rst = 1;
    #(`HALFT * 2);
    rst = 0;    
    #(`HALFT * 2);
    WEN = 1;
    WADDR = 5'b00001; // Write to register 1
    WDATA = 32'hA5A5A5A5; // Example data to write
    #(`HALFT * 2);
    WADDR = 5'b00010; // Write to register 2
    WDATA = 32'h5A5A5A5A; // Example data to write
    #(`HALFT * 2);
    WADDR = 5'b00000; // Write to register 0 (should not change, as it is hardwired to 0)
    WDATA = 32'hFFFFFFFF; // Attempt to write to register 0 (should not change)
    #(`HALFT * 2);
    WEN = 0; // Disable writing
    RADDR0 = 5'b00001; // Read from register 1
    RADDR1 = 5'b00010; // Read from register 2
    #(`HALFT * 2);
    // Check the read data
    if (RDATA0 !== 32'hA5A5A5A5 || RDATA1 !== 32'h5A5A5A5A) begin
        $display("Test failed: RDATA0 = %h, RDATA1 = %h", RDATA0, RDATA1);
    end else begin
        $display("Test passed: RDATA0 = %h, RDATA1 = %h", RDATA0, RDATA1);
    end
    // Check register 0
    RADDR0 = 5'b00000; // Read from register 0
    #(`HALFT * 2);
    if (RDATA0 !== 32'b0) begin
        $display("Test failed: RDATA0 (register 0) = %h", RDATA0);
    end else begin
        $display("Test passed: RDATA0 (register 0) = %h", RDATA0);
    end
    $finish;
end


endmodule