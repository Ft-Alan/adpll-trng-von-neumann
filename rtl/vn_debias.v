`timescale 1ns/1ps

// ------------------------------------------------------------
// Von Neumann Debiasing Block
// ------------------------------------------------------------
// Removes bias from input bitstream by processing bit pairs
//
// Input pairs:
//   01 -> output 0
//   10 -> output 1
//   00 / 11 -> discarded
//
// Trade-off: improves randomness but reduces throughput
// ------------------------------------------------------------

module vn_debias (
    input  wire clk,
    input  wire rst_n,
    input  wire in_bit,
    output reg  out_bit,
    output reg  valid
);

    reg [1:0] buffer;
    reg       have_pair;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buffer    <= 2'b00;
            have_pair <= 0;
            valid     <= 0;
            out_bit   <= 0;
        end else begin
            // Shift in incoming bit
            buffer <= {buffer[0], in_bit};

            if (!have_pair) begin
                have_pair <= 1;
                valid     <= 0;
            end else begin
                // Evaluate pair
                case (buffer)
                    2'b01: begin
                        out_bit <= 0;
                        valid   <= 1;
                    end
                    2'b10: begin
                        out_bit <= 1;
                        valid   <= 1;
                    end
                    default: begin
                        valid <= 0; // discard
                    end
                endcase

                have_pair <= 0;
            end
        end
    end

endmodule
