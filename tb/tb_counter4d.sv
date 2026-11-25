// TC-001: reset drives count to 0 while rst_n is 0 (VPS-01, REQ-3.1.1, REQ-3.1.6)
// TC-002: hold at 5 while en is 0 (VPS-02, REQ-3.1.3)
// TC-003: increment by 1 per edge (VPS-03, REQ-3.1.2)
// TC-004: wrap 15 to 0 (VPS-04, REQ-3.1.5, REQ-3.4.2)
// TC-005: reset priority over en (VPS-05, REQ-3.1.4)
// TC-006: sweep all values 0 to 15 (VPS-06, REQ-3.4.2)
// TC-007: reset-to-idle: count 0 after reset (REQ-3.1.1)
// TC-008: no X after reset: count has no X or Z once reset is released (REQ-3.1.1)
// TC-009: no deadlock: count moves within 1 cycle of en rising (REQ-3.1.2)
`default_nettype none
`timescale 1ns/1ps

module tb_counter4d;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic en = 1'b0;
  logic [3:0] count;

  integer cycle = 0;
  integer errors = 0;
  integer i;

  counter4d dut (.clk(clk), .rst_n(rst_n), .en(en), .count(count));

  always #5 clk = ~clk;
  always @(posedge clk) cycle <= cycle + 1;

  task automatic check(input string signal, input logic [63:0] expected, input logic [63:0] actual);
    if (actual !== expected) begin
      errors = errors + 1;
      $display("MISMATCH cycle=%0d signal=%s expected=%0h actual=%0h", cycle, signal, expected, actual);
    end
  endtask

  initial begin
    // inputs change only at falling edges (REQ-3.4.1)
    @(negedge clk);
    @(negedge clk);
    @(posedge clk); #1;
    check("count", 4'd0, count);  // TC-007 / TC-001
    @(negedge clk); rst_n = 1'b1;
    @(posedge clk); #1;
    check("count", 4'd0, count);  // TC-008 no X (!== catches X)
    // TC-003 increment
    @(negedge clk); en = 1'b1;
    for (i = 1; i <= 5; i = i + 1) begin
      @(posedge clk); #1;
      check("count", i, count);
    end
    // TC-002 hold
    @(negedge clk); en = 1'b0;
    repeat (4) begin
      @(posedge clk); #1;
      check("count", 4'd5, count);
    end
    // TC-005 reset priority
    @(negedge clk); en = 1'b1; rst_n = 1'b0;
    @(posedge clk); #1;
    check("count", 4'd0, count);
    @(posedge clk); #1;
    check("count", 4'd0, count);  // TC-001
    // TC-004 / TC-006 sweep and wrap
    @(negedge clk); rst_n = 1'b1;
    for (i = 1; i <= 17; i = i + 1) begin
      @(posedge clk); #1;
      check("count", i % 16, count);
    end
    $display("DONE errors=%0d", errors);
    $finish;
  end
endmodule

`default_nettype wire
