`timescale 1ns / 1ps

module edge_detect(
    input  logic clk,
    input  logic rst,
    input  logic debounced_in,
    output logic pulse
);
    logic prev;

    always_ff @(posedge clk) begin
        if (rst)
            prev <= 1'b0;
        else
            prev <= debounced_in;
    end

    assign pulse = debounced_in & ~prev;
endmodule
