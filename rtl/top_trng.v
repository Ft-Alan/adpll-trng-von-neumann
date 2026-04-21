`timescale 1ns/1ps

// ------------------------------------------------------------
// Top-Level TRNG Module
// ------------------------------------------------------------
// Integrates:
//   1. ADPLL entropy source
//   2. Von Neumann debiasing
// ------------------------------------------------------------

module top_trng (
    input  wire clk_ref,
    input  wire rst_n,
    output wire trng_bit,
    output wire valid
);

    wire raw_bit;
    wire raw_valid;

    // Entropy source
    adpll_entropy entropy_inst (
        .clk_ref(clk_ref),
        .rst_n  (rst_n),
        .raw_bit(raw_bit),
        .raw_valid(raw_valid)
    );

    // Debiasing block
    vn_debias vn_inst (
        .clk    (clk_ref),
        .rst_n  (rst_n),
        .in_bit (raw_bit),
        .out_bit(trng_bit),
        .valid  (valid)
    );

endmodule
