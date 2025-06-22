module mux #(parameter WIDTH = 5)(
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire sel,
    output reg [WIDTH-1:0] out
);

always @(*) begin
    if (sel) begin
        out = b; // If sel is high, output b
    end else begin
        out = a; // If sel is low, output a
    end
end

endmodule