// ==================================================
// Testbench for 4-bit Full Subtractor
// ==================================================
`timescale 1ns/1ps

module tb_full_subtractor_4bit;

    // Testbench signals
    logic [3:0] minuend;
    logic [3:0] subtrahend;
    logic       borrow_in;
    logic [3:0] difference;
    logic       borrow_out;
    logic       negative;
    
    // Expected results for verification
    logic [4:0] expected_result;  // 5 bits to handle borrow
    logic [3:0] expected_diff;
    logic       expected_borrow;
    
    // Test counter
    integer test_case = 0;
    integer errors = 0;

    // Instantiate the Device Under Test (DUT)
    full_subtractor_4bit dut (
        .minuend(minuend),
        .subtrahend(subtrahend),
        .borrow_in(borrow_in),
        .difference(difference),
        .borrow_out(borrow_out),
        .negative(negative)
    );

    // Task to check results
    task check_result;
        input [3:0] min_val;
        input [3:0] sub_val;
        input       borrow_val;
        input [4:0] expected;
        begin
            test_case = test_case + 1;
            minuend = min_val;
            subtrahend = sub_val;
            borrow_in = borrow_val;
            
            // Calculate expected values
            expected_diff = expected[3:0];
            expected_borrow = expected[4];
            
            #10; // Wait for propagation
            
            $display("Test %0d: %0d - %0d - %0d", test_case, min_val, sub_val, borrow_val);
            $display("  Expected: diff=%0d, borrow=%0d", expected_diff, expected_borrow);
            $display("  Got:      diff=%0d, borrow=%0d", difference, borrow_out);
            
            if (difference !== expected_diff || borrow_out !== expected_borrow) begin
                $display("  ❌ ERROR: Mismatch detected!");
                errors = errors + 1;
            end else begin
                $display("  ✅ PASS");
            end
            $display("");
        end
    endtask

    // Task to perform comprehensive test
    task test_all_combinations;
        integer i, j;
        logic [4:0] calc_result;
        begin
            $display("=== Comprehensive Test (without initial borrow) ===");
            borrow_in = 1'b0;
            
            for (i = 0; i < 16; i++) begin
                for (j = 0; j < 16; j++) begin
                    minuend = i;
                    subtrahend = j;
                    
                    // Calculate expected result
                    if (i >= j) begin
                        calc_result = i - j;
                    end else begin
                        calc_result = 16 + i - j;  // Two's complement representation
                        calc_result[4] = 1'b1;     // Set borrow bit
                    end
                    
                    #5;
                    
                    if (difference !== calc_result[3:0] || borrow_out !== calc_result[4]) begin
                        $display("ERROR at %0d - %0d: Expected diff=%0d, borrow=%0d, Got diff=%0d, borrow=%0d",
                                i, j, calc_result[3:0], calc_result[4], difference, borrow_out);
                        errors = errors + 1;
                    end
                end
            end
        end
    endtask

    // Main test sequence
    initial begin
        $display("==================================================");
        $display("Starting 4-bit Full Subtractor Testbench");
        $display("==================================================");
        
        // Initialize
        errors = 0;
        
        // Test Case 1: Simple subtraction (no borrow needed)
        check_result(4'd8, 4'd3, 1'b0, 5'b00101);  // 8 - 3 = 5
        
        // Test Case 2: Subtraction with borrow
        check_result(4'd3, 4'd8, 1'b0, 5'b11011);  // 3 - 8 = -5 (in 4-bit: 11, borrow=1)
        
        // Test Case 3: Equal numbers
        check_result(4'd7, 4'd7, 1'b0, 5'b00000);  // 7 - 7 = 0
        
        // Test Case 4: Subtract from zero
        check_result(4'd0, 4'd5, 1'b0, 5'b11011);  // 0 - 5 = -5 (in 4-bit: 11, borrow=1)
        
        // Test Case 5: Maximum values
        check_result(4'd15, 4'd0, 1'b0, 5'b01111); // 15 - 0 = 15
        
        // Test Case 6: With initial borrow
        check_result(4'd8, 4'd3, 1'b1, 5'b00100);  // 8 - 3 - 1 = 4
        
        // Test Case 7: Maximum subtraction
        check_result(4'd15, 4'd15, 1'b0, 5'b00000); // 15 - 15 = 0
        
        // Test Case 8: Another borrow case
        check_result(4'd1, 4'd2, 1'b0, 5'b11111);  // 1 - 2 = -1 (in 4-bit: 15, borrow=1)
        
        $display("=== Manual Test Cases Complete ===");
        $display("Errors in manual tests: %0d", errors);
        
        // Run comprehensive test
        test_all_combinations();
        
        // Final results
        $display("==================================================");
        if (errors == 0) begin
            $display("🎉 ALL TESTS PASSED! 🎉");
        end else begin
            $display("❌ %0d ERRORS FOUND", errors);
        end
        $display("==================================================");
        
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t: %0d - %0d - %0d = %0d (borrow=%0b, negative=%0b)", 
                 $time, minuend, subtrahend, borrow_in, difference, borrow_out, negative);
    end

endmodule