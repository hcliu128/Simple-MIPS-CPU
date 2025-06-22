// data memory
module memory(
    input clk,
    input rst,
    input [31:0] address,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    output reg [31:0] read_data
);  

    integer i;
    reg [7:0] mem[0:1023]; // Memory array of 1024 bytes
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 1024; i = i + 1) begin
                mem[i] <= 32'b0;
            end
        end else begin
            if (mem_write) begin // little endian
                mem[address + 0] <= write_data[7:0]; 
                mem[address + 1] <= write_data[15:8]; 
                mem[address + 2] <= write_data[23:16]; 
                mem[address + 3] <= write_data[31:24]; 
            end
        end
    end

    always @(*) begin
        if (mem_read) begin
            read_data = {mem[address + 3], mem[address + 2], mem[address + 1], mem[address + 0]};
        end else begin
            read_data = 32'b0; // Default value when not reading
        end
    end

endmodule