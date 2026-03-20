`timescale 1ns / 1ps

module Traffic (
    input  logic clk, 
    input  logic rst,   // Reset sinyali
    input  logic TAORB, // Traffic on A (1) or on B (0)
    output logic [5:0] led // led[5:3] -> LA (R,Y,G), led[2:0] -> LB (R,Y,G)
);

    // Durum (State) isimlendirmeleri
    typedef enum logic [1:0] {
        S0 = 2'b00,  // LA Green, LB Red
        S1 = 2'b01,  // LA Yellow, LB Red
        S2 = 2'b10,  // LA Red, LB Green
        S3 = 2'b11   // LA Red, LB Yellow
    } state_t;

    // Register tanımlamaları (Şu anki durum ve timer için)
    state_t current_state, next_state;
    logic [2:0] timer, next_timer; 


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= S0;
            timer         <= 3'b000;
        end else begin
            current_state <= next_state;
            timer         <= next_timer;
        end
    end

    always_comb begin

        next_state = current_state; 
        next_timer = 3'b000; 

        case (current_state)
            S0: begin
                if (!TAORB) begin
                    next_state = S1;
                end else begin
                    next_state = S0;
                end
            end

            S1: begin

                if (timer < 3'd4) begin
                    next_state = S1;
                    next_timer = timer + 1'b1;
                end else begin
                    // 5 saniye doldu, S2'ye geç
                    next_state = S2;
                end
            end

            S2: begin
                if (TAORB) begin
                    next_state = S3;
                end else begin
                    next_state = S2;
                end
            end

            S3: begin
         
                if (timer < 3'd4) begin
                    next_state = S3;
                    next_timer = timer + 1'b1;
                end else begin
                    // 5 saniye doldu, başa (S0'a) dön
                    next_state = S0;
                end
            end
            
            default: next_state = S0;
        endcase
    end

    always_comb begin
        // LED Dizilimi: 6'b(LA_Red)(LA_Yellow)(LA_Green)_(LB_Red)(LB_Yellow)(LB_Green)
        case (current_state)
            S0: led = 6'b001_100; // LA Green, LB Red
            S1: led = 6'b010_100; // LA Yellow, LB Red
            S2: led = 6'b100_001; // LA Red, LB Green
            S3: led = 6'b100_010; // LA Red, LB Yellow
            default: led = 6'b001_100;
        endcase
    end

endmodule
