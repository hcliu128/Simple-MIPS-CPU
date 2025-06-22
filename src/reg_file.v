// 2R1W
// Reg 0 is hardwired to 0
module reg_file(
    input clk, 
    input rst,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    input write_enable,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data
);

reg [31:0] registers [0:31]; // 32 registers of 32 bits each
integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rs1_data <= 32'b0;
        rs2_data <= 32'b0;
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0; // Reset all registers to 0
        end
    end else begin
        // Write to register rd if write_enable is high and rd is not zero
        if (write_enable && rd != 5'b0) begin
            registers[rd] <= write_data;
        end
    end
end

assign rs1_data = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
assign rs2_data = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

endmodule 