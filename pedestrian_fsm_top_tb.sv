`timescale 1ns / 1ps

module pedestrian_fsm_top_tb;
    logic clk;
    logic rst;
    logic pedestrian_button_async;

    logic red_led;
    logic green_led;
    logic yellow_led;
    logic walk_led;

    pedestrian_fsm_top #(
        .CLK_FREQ_HZ(4),
        .STABLE_CYCLES(5)
    ) DUT (
        .clk                     (clk),
        .rst                     (rst),
        .pedestrian_button_async (pedestrian_button_async),
        .red_led                 (red_led),
        .green_led               (green_led),
        .yellow_led              (yellow_led),
        .walk_led                (walk_led)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk; // 10 ns period

    task automatic reset_dut;
        begin
            pedestrian_button_async = 1'b0;
            rst = 1'b1;
            repeat (3) @(posedge clk);
            rst = 1'b0;
            @(posedge clk);
        end
    endtask

    task automatic press_button;
        begin
            pedestrian_button_async = 1'b1;
            #100; // long enough to pass STABLE_CYCLES=5 conditioning
            pedestrian_button_async = 1'b0;
            #100; // allow release to debounce before another press
        end
    endtask

    initial begin
        // Test 1: baseline - no request. WALK should not occur.
        reset_dut();
        #420;

        // Test 2: valid request during GREEN -> WALK after YELLOW.
        reset_dut();
        wait (DUT.FSM.state == 2'd1); // GREEN
        #20;
        press_button();
        #300;

        // Test 3: request during WALK is retained for the next service point.
        reset_dut();
        wait (DUT.FSM.state == 2'd1); // GREEN
        #20;
        press_button();
        wait (DUT.FSM.state == 2'd3); // WALK
        #20;
        press_button();
        #650;

        $finish;
    end

    initial begin
        $monitor(
            "t=%0t state=%0d tick=%b pulse=%b pending=%b service=%b LEDs=%b%b%b%b",
            $time,
            DUT.FSM.state,
            DUT.tick_result,
            DUT.button_pulse,
            DUT.FSM.request_pending,
            DUT.FSM.service,
            red_led, green_led, yellow_led, walk_led
        );
    end
endmodule
