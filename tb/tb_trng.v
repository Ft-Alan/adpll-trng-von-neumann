`timescale 1ns/1ps

// ------------------------------------------------------------
// Testbench: ADPLL TRNG with Von Neumann Debiasing
// ------------------------------------------------------------
// Purpose:
// - Verify functionality of TRNG
// - Evaluate statistical randomness
//
// Metrics computed:
// - Transition probability (ideal ≈ 0.5)
// - Mean of output bits
// - Lag-1 autocorrelation
//
// Simulation collects 2048 valid output samples
// ------------------------------------------------------------

module tb_trng;

    // ------------------------------------------------------------
    // Clock and Reset
    // ------------------------------------------------------------
    reg clk_ref;
    reg rst_n;

    initial begin
        clk_ref = 0;
        forever #10 clk_ref = ~clk_ref; // 50 MHz clock
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end

    // ------------------------------------------------------------
    // DUT Signals
    // ------------------------------------------------------------
    wire trng_bit;
    wire valid;

    // Instantiate TRNG
    top_trng dut (
        .clk_ref(clk_ref),
        .rst_n  (rst_n),
        .trng_bit(trng_bit),
        .valid  (valid)
    );

    // ------------------------------------------------------------
    // Statistics Variables
    // ------------------------------------------------------------
    integer ones = 0;
    integer zeros = 0;
    integer total = 0;
    integer transitions = 0;

    integer last_bit = 0;

    // Autocorrelation variables
    integer prev_bit = -1;
    integer sum_product = 0;

    // Real outputs
    real transition_prob;
    real mean;
    real autocorr;

    // ------------------------------------------------------------
    // Data Collection
    // ------------------------------------------------------------
    initial begin
        @(posedge rst_n);

        $display("Collecting 2048 valid TRNG samples...");

        while (total < 2048) begin
            @(posedge clk_ref);

            if (valid) begin
                // Count ones and zeros
                if (trng_bit == 1)
                    ones = ones + 1;
                else
                    zeros = zeros + 1;

                // Count transitions
                if (total > 0 && trng_bit != last_bit)
                    transitions = transitions + 1;

                // Autocorrelation product
                if (prev_bit != -1)
                    sum_product = sum_product + (trng_bit & prev_bit);

                prev_bit = trng_bit;
                last_bit = trng_bit;

                total = total + 1;
            end
        end

        // ------------------------------------------------------------
        // Compute Metrics
        // ------------------------------------------------------------
        transition_prob = transitions * 1.0 / (total - 1);
        mean = ones * 1.0 / total;

        real p_product;
        p_product = sum_product * 1.0 / (total - 1);

        autocorr = p_product - (mean * mean);

        // ------------------------------------------------------------
        // Display Results
        // ------------------------------------------------------------
        $display("========================================");
        $display("TRNG STATISTICAL RESULTS");
        $display("========================================");

        $display("Total Samples        = %0d", total);
        $display("Ones                 = %0d", ones);
        $display("Zeros                = %0d", zeros);

        $display("Transition Probability = %f", transition_prob);
        $display("Mean                  = %f", mean);
        $display("Lag-1 Autocorrelation = %f", autocorr);

        $display("========================================");

        $finish;
    end

endmodule
