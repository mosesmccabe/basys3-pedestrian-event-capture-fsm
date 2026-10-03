`timescale 1ns / 1ps

// Focused corner-case test: a new request arrives on the same clock edge
// that an older request is serviced. request_pulse has priority over service,
// so request_pending must remain asserted while the FSM enters WALK.
module pedestrian_fsm_controller_corner_tb;
    logic clk;
    logic rst;
    logic tick;
    logic request_pulse;
    logic red_led, green_led, yellow_led, walk_led;

    pedestrian_fsm_controller DUT (
        .clk           (clk),
        .rst           (rst),
        .tick          (tick),
        .request_pulse (request_pulse),
        .red_led       (red_led),
        .green_led     (green_led),
        .yellow_led    (yellow_led),
        .walk_led      (walk_led)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic send_tick;
        begin
            tick = 1'b1;
            @(posedge clk);
            #1;
            tick = 1'b0;
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        tick = 1'b0;
        request_pulse = 1'b0;
        rst = 1'b1;
        repeat (2) @(posedge clk);
        #1 rst = 1'b0;

        // RED: 3 ticks -> GREEN
        repeat (3) send_tick();
        // GREEN: 4 ticks -> YELLOW
        repeat (4) send_tick();

        // Capture an existing request while in YELLOW.
        request_pulse = 1'b1;
        @(posedge clk);
        #1 request_pulse = 1'b0;

        // First YELLOW tick: elapsed becomes 1.
        send_tick();

        // Final YELLOW tick and a NEW request occur together.
        // service is also high because an older request is pending.
        tick = 1'b1;
        request_pulse = 1'b1;
        @(posedge clk);
        #1;
        tick = 1'b0;
        request_pulse = 1'b0;

        if (DUT.state !== 2'd3)
            $error("Expected WALK after final YELLOW tick");
        if (DUT.request_pending !== 1'b1)
            $error("New request should win over service and remain pending");

        $display("Corner-case PASS: state=WALK and request_pending remains 1");
        #20;
        $finish;
    end
endmodule
