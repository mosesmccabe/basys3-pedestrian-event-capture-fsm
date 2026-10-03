`timescale 1ns / 1ps

module pedestrian_fsm_top #(
    parameter integer CLK_FREQ_HZ   = 100_000_000,
    parameter integer STABLE_CYCLES = 1_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic pedestrian_button_async,
    output logic red_led,
    output logic green_led,
    output logic yellow_led,
    output logic walk_led
);
    logic button_pulse;
    logic tick_result;

    button_conditioner #(
        .STABLE_CYCLES(STABLE_CYCLES)
    ) BUTTON_PULSE (
        .clk          (clk),
        .rst          (rst),
        .button_async (pedestrian_button_async),
        .button_pulse (button_pulse)
    );

    tick_generator #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    ) TICK_GENERATOR (
        .clk  (clk),
        .rst  (rst),
        .tick (tick_result)
    );

    pedestrian_fsm_controller FSM (
        .clk           (clk),
        .rst           (rst),
        .tick          (tick_result),
        .request_pulse (button_pulse),
        .red_led       (red_led),
        .green_led     (green_led),
        .yellow_led    (yellow_led),
        .walk_led      (walk_led)
    );
endmodule
