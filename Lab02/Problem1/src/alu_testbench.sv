module alu_testbench();
    // Parámetros
    parameter N = 4;
    parameter CLK_PERIOD = 10;
    
    // Señales del testbench
    logic [N-1:0] a, b;
    logic [3:0] opcode;
    logic [N-1:0] result;
    logic [N-1:0] expected_result;
    logic N_flag, Z_flag, C_flag, V_flag;
    logic div_by_zero_error, mod_by_zero_error;
    
    // Instancia del módulo bajo prueba
    alu #(N) dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .N_flag(N_flag),
        .Z_flag(Z_flag),
        .C_flag(C_flag),
        .V_flag(V_flag),
        .div_by_zero_error(div_by_zero_error),
        .mod_by_zero_error(mod_by_zero_error)
    );
    
    // Proceso principal de pruebas
    initial begin
        $display("=== Iniciando Testbench de Auto-chequeo para ALU ===");
        $display("Tiempo: %0t", $time);
        
        // ========== PRUEBAS DE SUMA (OpCode 0000) ==========
        $display("\n--- Probando SUMA ---");
        
        // Suma Caso 1: 3 + 2 = 5
        a = 4'd3;
        b = 4'd2;
        opcode = 4'b0000;
        expected_result = 4'd5;
        #1;
        assert(result == expected_result) 
            $display("PASS: %0d + %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d + %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // Suma Caso 2: 7 + 8 = 15
        a = 4'd7;
        b = 4'd8;
        opcode = 4'b0000;
        expected_result = 4'd15;
        #1;
        assert(result == expected_result) 
            $display("PASS: %0d + %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d + %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // ========== PRUEBAS DE RESTA (OpCode 0001) ==========
        $display("\n--- Probando RESTA ---");
        
        // Resta Caso 1: 5 - 3 = 2
        a = 4'd5;
        b = 4'd3;
        opcode = 4'b0001;
        expected_result = 4'd2;
        #1;
        assert(result == expected_result) 
            $display("PASS: %0d - %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d - %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // Resta Caso 2: 10 - 6 = 4
        a = 4'd10;
        b = 4'd6;
        opcode = 4'b0001;
        expected_result = 4'd4;
        #1;
        assert(result == expected_result) 
            $display("PASS: %0d - %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d - %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // ========== PRUEBAS DE MULTIPLICACIÓN (OpCode 0010) ==========
        $display("\n--- Probando MULTIPLICACIÓN ---");
        
        // Multiplicación Caso 1: 3 * 2 = 6
        a = 4'd3;
        b = 4'd2;
        opcode = 4'b0010;
        expected_result = 4'd6;
        #1;
        assert(result == expected_result) 
            $display("PASS: %0d * %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d * %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // Multiplicación Caso 2: 4 * 3 = 12
        a = 4'd4;
        b = 4'd3;
        opcode = 4'b0010;
        expected_result = 4'd12;
        #1;
        assert(result == expected_result) 
            $display("PASS: %0d * %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d * %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // ========== PRUEBAS DE DIVISIÓN (OpCode 0011) ==========
        $display("\n--- Probando DIVISIÓN ---");
        
        // División Caso 1: 8 / 2 = 4
        a = 4'd8;
        b = 4'd2;
        opcode = 4'b0011;
        expected_result = 4'd4;
        #1;
        assert(result == expected_result && !div_by_zero_error) 
            $display("PASS: %0d / %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d / %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // División Caso 2: 15 / 3 = 5
        a = 4'd15;
        b = 4'd3;
        opcode = 4'b0011;
        expected_result = 4'd5;
        #1;
        assert(result == expected_result && !div_by_zero_error) 
            $display("PASS: %0d / %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d / %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // ========== PRUEBAS DE MÓDULO (OpCode 0100) ==========
        $display("\n--- Probando MÓDULO ---");
        
        // Módulo Caso 1: 7 % 3 = 1
        a = 4'd7;
        b = 4'd3;
        opcode = 4'b0100;
        expected_result = 4'd1;
        #1;
        assert(result == expected_result && !mod_by_zero_error) 
            $display("PASS: %0d %% %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d %% %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // Módulo Caso 2: 10 % 4 = 2
        a = 4'd10;
        b = 4'd4;
        opcode = 4'b0100;
        expected_result = 4'd2;
        #1;
        assert(result == expected_result && !mod_by_zero_error) 
            $display("PASS: %0d %% %0d = %0d", a, b, result);
        else 
            $error("FAIL: %0d %% %0d = %0d, esperado %0d", a, b, result, expected_result);
        
        // ========== PRUEBAS DE AND (OpCode 0101) ==========
        $display("\n--- Probando AND ---");
        
        // AND Caso 1: 1111 & 0101 = 0101 (15 & 5 = 5)
        a = 4'b1111;
        b = 4'b0101;
        opcode = 4'b0101;
        expected_result = 4'b0101;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b & %04b = %04b", a, b, result);
        else 
            $error("FAIL: %04b & %04b = %04b, esperado %04b", a, b, result, expected_result);
        
        // AND Caso 2: 1100 & 1010 = 1000 (12 & 10 = 8)
        a = 4'b1100;
        b = 4'b1010;
        opcode = 4'b0101;
        expected_result = 4'b1000;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b & %04b = %04b", a, b, result);
        else 
            $error("FAIL: %04b & %04b = %04b, esperado %04b", a, b, result, expected_result);
        
        // ========== PRUEBAS DE OR (OpCode 0110) ==========
        $display("\n--- Probando OR ---");
        
        // OR Caso 1: 1010 | 0101 = 1111 (10 | 5 = 15)
        a = 4'b1010;
        b = 4'b0101;
        opcode = 4'b0110;
        expected_result = 4'b1111;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b | %04b = %04b", a, b, result);
        else 
            $error("FAIL: %04b | %04b = %04b, esperado %04b", a, b, result, expected_result);
        
        // OR Caso 2: 1100 | 0011 = 1111 (12 | 3 = 15)
        a = 4'b1100;
        b = 4'b0011;
        opcode = 4'b0110;
        expected_result = 4'b1111;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b | %04b = %04b", a, b, result);
        else 
            $error("FAIL: %04b | %04b = %04b, esperado %04b", a, b, result, expected_result);
        
        // ========== PRUEBAS DE XOR (OpCode 0111) ==========
        $display("\n--- Probando XOR ---");
        
        // XOR Caso 1: 1111 ^ 0101 = 1010 (15 ^ 5 = 10)
        a = 4'b1111;
        b = 4'b0101;
        opcode = 4'b0111;
        expected_result = 4'b1010;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b ^ %04b = %04b", a, b, result);
        else 
            $error("FAIL: %04b ^ %04b = %04b, esperado %04b", a, b, result, expected_result);
        
        // XOR Caso 2: 1100 ^ 1010 = 0110 (12 ^ 10 = 6)
        a = 4'b1100;
        b = 4'b1010;
        opcode = 4'b0111;
        expected_result = 4'b0110;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b ^ %04b = %04b", a, b, result);
        else 
            $error("FAIL: %04b ^ %04b = %04b, esperado %04b", a, b, result, expected_result);
        
        // ========== PRUEBAS DE SHIFT LEFT (OpCode 1000) ==========
        $display("\n--- Probando SHIFT LEFT ---");
        
        // Shift Left Caso 1: 0101 << 1 = 1010 (5 << 1 = 10)
        a = 4'b0101;
        b = 4'd1;
        opcode = 4'b1000;
        expected_result = 4'b1010;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b << %0d = %04b", a, b, result);
        else 
            $error("FAIL: %04b << %0d = %04b, esperado %04b", a, b, result, expected_result);
        
        // Shift Left Caso 2: 0011 << 2 = 1100 (3 << 2 = 12)
        a = 4'b0011;
        b = 4'd2;
        opcode = 4'b1000;
        expected_result = 4'b1100;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b << %0d = %04b", a, b, result);
        else 
            $error("FAIL: %04b << %0d = %04b, esperado %04b", a, b, result, expected_result);
        
        // ========== PRUEBAS DE SHIFT RIGHT (OpCode 1001) ==========
        $display("\n--- Probando SHIFT RIGHT ---");
        
        // Shift Right Caso 1: 1010 >> 1 = 0101 (10 >> 1 = 5)
        a = 4'b1010;
        b = 4'd1;
        opcode = 4'b1001;
        expected_result = 4'b0101;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b >> %0d = %04b", a, b, result);
        else 
            $error("FAIL: %04b >> %0d = %04b, esperado %04b", a, b, result, expected_result);
        
        // Shift Right Caso 2: 1100 >> 2 = 0011 (12 >> 2 = 3)
        a = 4'b1100;
        b = 4'd2;
        opcode = 4'b1001;
        expected_result = 4'b0011;
        #1;
        assert(result == expected_result) 
            $display("PASS: %04b >> %0d = %04b", a, b, result);
        else 
            $error("FAIL: %04b >> %0d = %04b, esperado %04b", a, b, result, expected_result);
        
        // ========== PRUEBAS DE CASOS ESPECIALES ==========
        $display("\n--- Probando CASOS ESPECIALES ---");
        
        // División por cero
        a = 4'd5;
        b = 4'd0;
        opcode = 4'b0011;
        expected_result = 4'd0;
        #1;
        assert(result == expected_result && div_by_zero_error) 
            $display("PASS: División por cero detectada correctamente");
        else 
            $error("FAIL: División por cero no manejada correctamente");
        
        // Módulo por cero
        a = 4'd5;
        b = 4'd0;
        opcode = 4'b0100;
        expected_result = 4'd0;
        #1;
        assert(result == expected_result && mod_by_zero_error) 
            $display("PASS: Módulo por cero detectado correctamente");
        else 
            $error("FAIL: Módulo por cero no manejado correctamente");
        
        // ========== RESUMEN ==========
        $display("\n=== Testbench Completado ===");
        $display("Tiempo final: %0t", $time);
        $display("Si no aparecieron errores, todas las pruebas pasaron exitosamente!");
        
        $finish;
    end
    
endmodule