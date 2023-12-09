`timescale 1ns / 1ps
// `default_nettype wire

module ppu
  #(parameter ADDR_WIDTH = 8,
    DATA_WIDTH = 16
    )
   (
    input 		    clk, // system clock 50Mhz on board
    input 		    rst_n, 
    output [ADDR_WIDTH-1:0] program_counter_out, // 
    output [DATA_WIDTH-1:0] register_AC_out,
    output [DATA_WIDTH-1:0] memory_data_register_out,

    output [ADDR_WIDTH-1:0] memory_addr_register_out,
    output [DATA_WIDTH-1:0] instruction_register_out
    );

   localparam RESET_PC = 1;
   localparam FETCH = 2;
   localparam DECODE = 3;
   localparam EXECUTE_ADD = 4;
   localparam EXECUTE_LOAD = 5;
   localparam EXECUTE_STORE = 6;
   localparam EXECUTE_STORE2 = 7;
   localparam EXECUTE_STORE3 = 8;
   localparam EXECUTE_JUMP = 9;

   reg [3:0] state;
   reg [DATA_WIDTH-1:0] ir, mdr, accum;
   reg [ADDR_WIDTH-1:0] pc, mar;
   reg memory_write;
   reg [15:0] mem[255:0];
   
   assign program_counter_out = pc;
   assign register_AC_out = accum;
   assign memory_data_register_out = mdr;
   assign memory_addr_register_out = mar;
   assign instruction_register_out = ir;

   always @(*) begin
      if (!rst_n) state = RESET_PC;
      if (memory_write) mem[mar] = accum;
      else mdr = mem[mar];
   end
   
   always @(posedge clk) begin
      case (state)
	RESET_PC: begin
	   pc  <= 0;
	   mar <= 0;
	   accum <= 0;
	   memory_write <= 0;
	   state <= !rst_n ? RESET_PC : FETCH;
	   mem[0] <= 16'h0211;
	   mem[1] <= 16'h0012;
	   mem[2] <= 16'h0110;
	   mem[3] <= 16'h0301;
	   mem[16] <= 16'h0000;
	   mem[17] <= 16'h0004;
	   mem[18] <= 16'h0003;
	end

	FETCH: begin
	   ir <= mdr;
	   pc <= pc + 1;
	   memory_write <= 0;
	   state <= DECODE;
	end

	DECODE: begin
	   mar <= ir[ADDR_WIDTH-1:0];
	   case (ir[15:8])
	     8'd0: state <= EXECUTE_ADD;
	     8'd1: state <= EXECUTE_STORE;
	     8'd2: state <= EXECUTE_LOAD;
	     8'd3: state <= EXECUTE_JUMP;
	     default: state <= FETCH;
	   endcase // case (ir[15:8])
	end

	EXECUTE_ADD: begin
	   accum <= accum + mdr;
	   mar <= pc;
	   state <= FETCH;
	end

	EXECUTE_STORE: begin
	   memory_write <= 1;
	   state <= EXECUTE_STORE2;
	   
	end

	EXECUTE_STORE2: begin
	   memory_write <= 0;
	   state <= EXECUTE_STORE3;
	end

	EXECUTE_STORE3: begin
	   mar <= pc;
	   state <= FETCH;
	end

	EXECUTE_LOAD: begin
	   accum <= mdr;
	   mar <= pc;
	   state <= FETCH;
	end

	EXECUTE_JUMP: begin
	   pc <= ir[7:0];
	   mar <= ir[7:0];
	   state <= FETCH;
	end

	default: begin
	   mar <= pc;
	   state <= FETCH;
	end

      endcase // case (state)

      
   end // always @ (posedge clk)
   
endmodule


