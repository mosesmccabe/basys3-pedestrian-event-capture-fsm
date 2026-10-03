`timescale 1ns / 1ps

module button_conditioner #(
    parameter integer STABLE_CYCLES = 1_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic button_async,
    output logic button_pulse
);
    logic sync_button;
    logic debounced_button;

    sync_2ff SYNC (
        .clk      (clk),
        .async_in (button_async),
        .sync_out (sync_button)
    );

    debounce #(
        .STABLE_CYCLES(STABLE_CYCLES)
    ) DEBOUNCE (
        .clk           (clk),
        .rst           (rst),
        .sync_in       (sync_button),
        .debounced_out (debounced_button)
    );

    edge_detect EDGE_DETECTOR (
        .clk          (clk),
        .rst          (rst),
        .debounced_in (debounced_button),
        .pulse        (button_pulse)
    );
endmodule
