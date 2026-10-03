`timescale 1ns / 1ps

module debounce #(
    parameter integer STABLE_CYCLES = 1_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic sync_in,
    output logic debounced_out
);
    localparam integer COUNT_WIDTH = $clog2(STABLE_CYCLES + 1);
    logic [COUNT_WIDTH-1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            count         <= '0;
            debounced_out <= 1'b0;
        end
        else if (sync_in == debounced_out) begin
            count <= '0;
        end
        else if (count == STABLE_CYCLES - 1) begin
            debounced_out <= sync_in;
            count         <= '0;
        end
        else begin
            count <= count + 1'b1;
        end
    end
endmodule
