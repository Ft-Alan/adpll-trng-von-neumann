`timescale 1ns/1ps

// ------------------------------------------------------------
// ADPLL-Based Entropy Source (Behavioral Model)
// ------------------------------------------------------------
// NOTE:
// - This is a behavioral model using real delays
// - Intended for simulation only (NOT synthesizable)
// - Models jitter/phase variation to generate entropy
// ------------------------------------------------------------

module adpll_entropy (
    input  wire clk_ref,
    input  wire rst_n,
    output reg  raw_bit,
    output reg  raw_valid
);

    parameter real BASE_PERIOD_NS = 8.0;

    // Internal oscillator (DCO)
    reg dco;
    real cur_period;

    // Control loop variables
    integer ctrl_word;
    integer integrator;

    // Edge tracking
    reg prev_ref, prev_dco;
    reg [15:0] dco_edge_counter;

    // ------------------------------------------------------------
    // Initialization
    // ------------------------------------------------------------
    initial begin
        dco = 0;
        cur_period = BASE_PERIOD_NS;
        ctrl_word = 0;
        integrator = 0;
        prev_ref = 0;
        prev_dco = 0;
        dco_edge_counter = 0;
        raw_bit = 0;
        raw_valid = 0;
    end

    // ------------------------------------------------------------
    // Digitally Controlled Oscillator (DCO)
    // Frequency varies based on control word (jitter source)
    // ------------------------------------------------------------
    always begin
        #(cur_period / 2.0);
        dco = ~dco;
    end

    // ------------------------------------------------------------
    // Control loop: adjusts oscillator period
    // ------------------------------------------------------------
    always @(ctrl_word) begin
        cur_period = BASE_PERIOD_NS * (1 + 0.015 * ctrl_word);

        // Limit minimum period
        if (cur_period < 0.5)
            cur_period = 0.5;
    end

    // ------------------------------------------------------------
    // Phase detector + loop filter (simplified)
    // ------------------------------------------------------------
    always @(posedge clk_ref or negedge rst_n) begin
        if (!rst_n) begin
            prev_ref   <= 0;
            prev_dco   <= 0;
            integrator <= 0;
            ctrl_word  <= 0;
        end else begin
            prev_ref <= clk_ref;
            prev_dco <= dco;

            // Simple phase comparison
            if (clk_ref && !prev_ref) begin
                if (dco)
                    integrator <= integrator - 1;
                else
                    integrator <= integrator + 1;

                // Update control word (low-pass effect)
                ctrl_word <= ctrl_word + (integrator >>> 4);

                // Clamp control word
                if (ctrl_word > 10)  ctrl_word <= 10;
                if (ctrl_word < -10) ctrl_word <= -10;

                // Integrator leakage (stabilization)
                if (integrator > 0)
                    integrator <= integrator - 1;
                else if (integrator < 0)
                    integrator <= integrator + 1;
            end
        end
    end

    // ------------------------------------------------------------
    // Count DCO edges (entropy extraction)
    // ------------------------------------------------------------
    always @(posedge dco) begin
        dco_edge_counter <= dco_edge_counter + 1;
    end

    // ------------------------------------------------------------
    // Output raw random bit
    // LSB of edge counter used as entropy
    // ------------------------------------------------------------
    always @(posedge clk_ref or negedge rst_n) begin
        if (!rst_n) begin
            raw_bit   <= 0;
            raw_valid <= 0;
        end else begin
            raw_bit   <= dco_edge_counter[0];
            raw_valid <= 1; // always valid per cycle
        end
    end

endmodule
