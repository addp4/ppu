`timescale 1ns / 1ps

module test_up1 ();
   reg clk;
   reg rst_n;
   wire [7:0] pc, mar;
   wire [15:0] accum, mdr, ir;
   
   ppu # (
	  .ADDR_WIDTH(8),
	  .DATA_WIDTH(16)
	  )
   test_ppu(
	    .clk(clk),
	    .rst_n(rst_n),
	    .program_counter_out(pc),
	    .register_AC_out(accum),
	    .memory_data_register_out(mdr),
	    .memory_addr_register_out(mar),
	    .instruction_register_out(ir)
	    );

   // generate the clock
   initial begin
      clk = 1'b0;
      forever #1 clk = ~clk;
   end

   // Generate the reset
  initial begin
     rst_n = 1'b0;
     #10
     rst_n = 1'b1;
  end

   
endmodule // test_up1

