`timescale 1ns / 1ps

module pedestrian_fsm_controller(
    input  logic clk,
    input  logic rst,
    input  logic tick,
    input  logic request_pulse,
    output logic red_led,
    output logic green_led,
    output logic yellow_led,
    output logic walk_led
);
    typedef enum logic [1:0] {
        RED,
        GREEN,
        YELLOW,
        WALK
    } state_t;

    state_t state, next_state;

    logic [1:0] elapsed;
    logic request_pending;
    logic service;

    // Sticky pending-request flip-flop.
    // Priority: reset -> new request -> service -> hold.
    always_ff @(posedge clk) begin
        if (rst)
            request_pending <= 1'b0;
        else if (request_pulse)
            request_pending <= 1'b1;
        else if (service)
            request_pending <= 1'b0;
    end

    // State register and elapsed-tick counter.
    always_ff @(posedge clk) begin
        if (rst) begin
            state   <= RED;
            elapsed <= '0;
        end
        else begin
            state <= next_state;

            if (next_state != state)
                elapsed <= '0;
            else if (tick)
                elapsed <= elapsed + 1'b1;
        end
    end

    // Next-state logic.
    always_comb begin
        next_state = state;

        case (state)
            RED: begin
                if (tick && elapsed == 2'b10)
                    next_state = GREEN;
            end

            GREEN: begin
                if (tick && elapsed == 2'b11)
                    next_state = YELLOW;
            end

            YELLOW: begin
                if (tick && elapsed == 2'b01) begin
                    if (request_pending)
                        next_state = WALK;
                    else
                        next_state = RED;
                end
            end

            WALK: begin
                if (tick && elapsed == 2'b10)
                    next_state = RED;
            end

            default: begin
                next_state = RED;
            end
        endcase
    end

    // Acknowledge a stored request exactly when it is accepted for WALK.
    assign service = (state == YELLOW) &&
                     tick &&
                     (elapsed == 2'b01) &&
                     request_pending;

    // Moore output logic.
    always_comb begin
        red_led    = 1'b0;
        green_led  = 1'b0;
        yellow_led = 1'b0;
        walk_led   = 1'b0;

        case (state)
            RED: begin
                red_led = 1'b1;
            end

            GREEN: begin
                green_led = 1'b1;
            end

            YELLOW: begin
                yellow_led = 1'b1;
            end

            WALK: begin
                red_led  = 1'b1;
                walk_led = 1'b1;
            end

            default: begin
                red_led    = 1'b0;
                green_led  = 1'b0;
                yellow_led = 1'b0;
                walk_led   = 1'b0;
            end
        endcase
    end
endmodule
