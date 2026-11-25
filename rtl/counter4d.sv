// Module: counter4d
// Project: counter4d
// SAD: 3.1
// Risk: LOW
// REQ-IDs: REQ-3.1.1, REQ-3.1.2, REQ-3.1.3, REQ-3.1.4, REQ-3.1.5, REQ-3.1.6
// Author: Kemi
// PURPOSE: 4-bit up counter with enable and synchronous active-low reset.
// DEBUG NOTES: probe cnt_value_ff, cnt_value_next, then en and rst_n; waveform: add wave cnt_*
// KNOWN GOTCHAS: reset is synchronous; count is unspecified before the first reset edge (ADR-02).
// PREFIXES: cnt
`default_nettype none
`timescale 1ns/1ps

// -- A · MODULE — SAD 3.1 ---
module counter4d (
    // -- B · PORTS — SAD 3.1 ---
    input  wire logic       clk,   // REQ-3.1.6
    input  wire logic       rst_n, // REQ-3.1.1
    input  wire logic       en,    // REQ-3.1.2
    output      logic [3:0] count  // REQ-3.1.2
);

  // -- C · DECLARATIONS — SAD 3.1 ---
  logic [3:0] cnt_value_ff;  // REQ-3.1.1, REQ-3.1.2, REQ-3.1.3
  logic [3:0] cnt_value_next; // REQ-3.1.2, REQ-3.1.3, REQ-3.1.5

  // -- D · COMBINATIONAL — SAD 3.1 ---
  // .. cnt : next value — REQ-3.1.2, REQ-3.1.3, REQ-3.1.5
  assign cnt_value_next = en ? (cnt_value_ff + 4'd1) : cnt_value_ff;  // wraps 15 to 0

  // -- E · SEQUENTIAL — SAD 3.1 ---
  // .. cnt : reset and count register — REQ-3.1.1, REQ-3.1.4, REQ-3.1.6
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      cnt_value_ff <= '0;
    end else begin
      cnt_value_ff <= cnt_value_next;
    end
  end

  // -- F · ASSERTIONS — SAD 3.1 ---
`ifndef SYNTHESIS
  // .. cnt : increment and hold checks — REQ-3.1.2, REQ-3.1.3
  always @(posedge clk) begin
    if (en && (cnt_value_next !== (cnt_value_ff + 4'd1))) begin
      $error("cnt_value_next: increment check failed");
    end
    if (!en && (cnt_value_next !== cnt_value_ff)) begin
      $error("cnt_value_next: hold check failed");
    end
  end
`endif

  // -- G · OUTPUTS — SAD 3.1 ---
  assign count = cnt_value_ff;  // REQ-3.1.2

endmodule

`default_nettype wire
