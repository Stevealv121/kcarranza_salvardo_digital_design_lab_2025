module counter_tb;
    // Test parameters
    localparam CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Test signals
    logic clk;
    logic rst_n;
    logic start;
    
    // 2-bit counter signals
    logic [1:0] start_value_2bit;
    logic [1:0] count_2bit;
    logic full_2bit;
    
    // 4-bit counter signals  
    logic [3:0] start_value_4bit;
    logic [3:0] count_4bit;
    logic full_4bit;
    
    // 6-bit counter signals
    logic [5:0] start_value_6bit;
    logic [5:0] count_6bit;
    logic full_6bit;

    // Instantiate counters with different widths
    counter #(.WIDTH(2)) counter_2bit (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .start_value(start_value_2bit),
        .count(count_2bit),
        .full(full_2bit)
    );
    
    counter #(.WIDTH(4)) counter_4bit (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .start_value(start_value_4bit),
        .count(count_4bit),
        .full(full_4bit)
    );
    
    counter #(.WIDTH(6)) counter_6bit (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .start_value(start_value_6bit),
        .count(count_6bit),
        .full(full_6bit)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("Starting Counter Testbench");
        $display("Time\t2-bit\tFull2\t4-bit\tFull4\t6-bit\tFull6");
        $display("----\t-----\t-----\t-----\t-----\t-----\t-----");
        
        // Initialize signals
        rst_n = 1'b0;
        start = 1'b0;
        start_value_2bit = 2'b00;
        start_value_4bit = 4'b0000;
        start_value_6bit = 6'b000000;
        
        // Wait a few cycles
        repeat(3) @(posedge clk);
        
        // Release reset
        rst_n = 1'b1;
        @(posedge clk);
        
        // Test 1: Count from 0 to maximum for all counters
        $display("\n=== Test 1: Count from 0 to maximum ===");
        start = 1'b1;
        
        // Count until all reach maximum
        repeat(70) begin
            @(posedge clk);
            $display("%0t\t%0d\t%0b\t%0d\t%0b\t%0d\t%0b", 
                    $time, count_2bit, full_2bit, 
                    count_4bit, full_4bit, 
                    count_6bit, full_6bit);
        end
        
        start = 1'b0;
        @(posedge clk);
        
        // Test 2: Reset and start from different values
        $display("\n=== Test 2: Different start values ===");
        rst_n = 1'b0;
        start_value_2bit = 2'b01;   // Start at 1
        start_value_4bit = 4'b1100; // Start at 12
        start_value_6bit = 6'b111000; // Start at 56
        @(posedge clk);
        
        rst_n = 1'b1;
        @(posedge clk);
        
        start = 1'b1;
        repeat(20) begin
            @(posedge clk);
            $display("%0t\t%0d\t%0b\t%0d\t%0b\t%0d\t%0b", 
                    $time, count_2bit, full_2bit, 
                    count_4bit, full_4bit, 
                    count_6bit, full_6bit);
        end
        
        $display("\nTestbench completed successfully!");
        $finish;
    end
    
    // Monitor for full flags
    always @(posedge clk) begin
        if (full_2bit)
            $display("*** 2-bit counter reached maximum (3) at time %0t ***", $time);
        if (full_4bit)
            $display("*** 4-bit counter reached maximum (15) at time %0t ***", $time);
        if (full_6bit)
            $display("*** 6-bit counter reached maximum (63) at time %0t ***", $time);
    end

endmodule