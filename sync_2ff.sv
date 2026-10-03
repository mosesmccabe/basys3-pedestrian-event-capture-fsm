`timescale 1ns / 1ps

module sync_2ff(
    input  logic clk,
    input  logic async_in,
    output logic sync_out
);
    logic sync_ff1;

    always_ff @(posedge clk) begin
        sync_ff1 <= async_in;
        sync_out <= sync_ff1;
    end
endmodule
