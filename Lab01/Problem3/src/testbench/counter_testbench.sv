module counter_testbench;

    // Test parameters
    parameter int CLOCK_PERIOD = 10; // 10ns clock period
    
    // Test signals
    logic clk;
    logic async_reset_n;
    logic enable;
    logic load_enable;
    
    // Test for 2-bit counter
    logic [1:0] load_value_2bit, counter_out_2bit;
    logic [1:0] expected_2bit;
    
    // Test for 4-bit counter  
    logic [3:0] load_value_4bit, counter_out_4bit;
    logic [3:0] expected_4bit;
    
    // Test for 6-bit counter
    logic [5:0] load_value_6bit, counter_out_6bit;
    logic [5:0] expected_6bit;
    
    // Error counters
    int errors_2bit = 0, errors_4bit = 0, errors_6bit = 0;
    
    // DUT instances
    parameterizable_counter #(.N_BITS(2)) dut_2bit (
        .clk(clk),
        .async_reset_n(async_reset_n),
        .enable(enable),
        .load_enable(load_enable),
        .load_value(load_value_2bit),
        .counter_out(counter_out_2bit)
    );
    
    parameterizable_counter #(.N_BITS(4)) dut_4bit (
        .clk(clk),
        .async_reset_n(async_reset_n),
        .enable(enable),
        .load_enable(load_enable),
        .load_value(load_value_4bit),
        .counter_out(counter_out_4bit)
    );
    
    parameterizable_counter #(.N_BITS(6)) dut_6bit (
        .clk(clk),
        .async_reset_n(async_reset_n),
        .enable(enable),
        .load_enable(load_enable),
        .load_value(load_value_6bit),
        .counter_out(counter_out_6bit)
    );
    
    // Clock generation
    always #(CLOCK_PERIOD/2) clk = ~clk;
    
    // Self-checking procedure
    task automatic check_counter_2bit();
        if (counter_out_2bit !== expected_2bit) begin
            $error("2-bit Counter: Expected %0d, Got %0d at time %0t", 
                   expected_2bit, counter_out_2bit, $time);
            errors_2bit++;
        end else begin
            $display("2-bit Counter: PASS - Value %0d at time %0t", 
                     counter_out_2bit, $time);
        end
    endtask
    
    task automatic check_counter_4bit();
        if (counter_out_4bit !== expected_4bit) begin
            $error("4-bit Counter: Expected %0d, Got %0d at time %0t", 
                   expected_4bit, counter_out_4bit, $time);
            errors_4bit++;
        end else begin
            $display("4-bit Counter: PASS - Value %0d at time %0t", 
                     counter_out_4bit, $time);
        end
    endtask
    
    task automatic check_counter_6bit();
        if (counter_out_6bit !== expected_6bit) begin
            $error("6-bit Counter: Expected %0d, Got %0d at time %0t", 
                   expected_6bit, counter_out_6bit, $time);
            errors_6bit++;
        end else begin
            $display("6-bit Counter: PASS - Value %0d at time %0t", 
                     counter_out_6bit, $time);
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("Starting Self-Checking Testbench for Parameterizable Counter");
        $display("========================================================");
        
        // Initialize signals
        clk = 0;
        async_reset_n = 0;
        enable = 0;
        load_enable = 0;
        load_value_2bit = 0;
        load_value_4bit = 0;
        load_value_6bit = 0;
        expected_2bit = 0;
        expected_4bit = 0;
        expected_6bit = 0;
        
        // Reset test
        #(CLOCK_PERIOD*2);
        async_reset_n = 1;
        #(CLOCK_PERIOD);
        
        $display("\n=== Testing Reset Functionality ===");
        check_counter_2bit();
        check_counter_4bit();
        check_counter_6bit();
        
        // Test counting functionality
        $display("\n=== Testing Count Functionality ===");
        enable = 1;
        
        // Test multiple increments
        for (int i = 1; i <= 10; i++) begin
            #(CLOCK_PERIOD);
            expected_2bit = (i > 3) ? (i - 4) : i; // 2-bit wraps at 4
            expected_4bit = (i > 15) ? (i - 16) : i; // 4-bit wraps at 16
            expected_6bit = i; // 6-bit won't wrap in this test
            
            check_counter_2bit();
            check_counter_4bit();
            check_counter_6bit();
        end
        
        enable = 0;
        
        // Test load functionality
        $display("\n=== Testing Load Functionality ===");
        load_value_2bit = 2'b10;
        load_value_4bit = 4'b1010;
        load_value_6bit = 6'b101010;
        expected_2bit = 2'b10;
        expected_4bit = 4'b1010;
        expected_6bit = 6'b101010;
        
        load_enable = 1;
        #(CLOCK_PERIOD);
        load_enable = 0;
        
        check_counter_2bit();
        check_counter_4bit();
        check_counter_6bit();
        
        // Test wrap-around for 2-bit counter
        $display("\n=== Testing Wrap-around (2-bit counter) ===");
        load_value_2bit = 2'b11; // Load max value
        expected_2bit = 2'b11;
        load_enable = 1;
        #(CLOCK_PERIOD);
        load_enable = 0;
        check_counter_2bit();
        
        // Next increment should wrap to 0
        enable = 1;
        expected_2bit = 2'b00;
        #(CLOCK_PERIOD);
        enable = 0;
        check_counter_2bit();
        
        // Test async reset during operation
        $display("\n=== Testing Asynchronous Reset ===");
        enable = 1;
        #(CLOCK_PERIOD*2); // Let counters increment
        
        async_reset_n = 0; // Assert reset
        expected_2bit = 0;
        expected_4bit = 0;
        expected_6bit = 0;
        #(CLOCK_PERIOD/4); // Check reset is immediate
        
        check_counter_2bit();
        check_counter_4bit();
        check_counter_6bit();
        
        async_reset_n = 1;
        enable = 0;
        
        // Final results
        #(CLOCK_PERIOD*2);
        $display("\n========== Test Results ==========");
        $display("2-bit Counter Errors: %0d", errors_2bit);
        $display("4-bit Counter Errors: %0d", errors_4bit);
        $display("6-bit Counter Errors: %0d", errors_6bit);
        
        if (errors_2bit == 0 && errors_4bit == 0 && errors_6bit == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** SOME TESTS FAILED ***");
        end
        
        $display("Testbench completed at time %0t", $time);
        $finish;
    end

endmodule