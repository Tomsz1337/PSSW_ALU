`timescale 1ns / 1ps

module tb_top();
  import logger_pkg::*;
  import alu_pkg::*;
  import alu_driver_pkg::*;
  import alu_monitor_pkg::*;
  import alu_scoreboard_pkg::*;
  
  logic clk;
  
  alu_if vif();
  
  mailbox #(alu_transaction) gen_to_drv_mbx = new();
  mailbox #(alu_transaction) drv_to_sb_mbx  = new();
  mailbox #(alu_transaction) mon_to_sb_mbx  = new();
  
  alu_driver     drv;
  alu_monitor    mon;
  alu_scoreboard sb;
  
  assign vif.clk = clk;
  
  alu dut (
    .a        (vif.a),
    .b        (vif.b),
    .opcode   (vif.opcode),
    .result   (vif.result),
    .zero     (vif.zero),
    .carry    (vif.carry),
    .overflow (vif.overflow)
  );

  function alu_transaction create_alu_tx(
    input logic [15:0] a_val,
    input logic [15:0] b_val,
    input enum_op_t    op_val
  );
    automatic alu_transaction tx = new();
    tx.a = a_val;
    tx.b = b_val;
    tx.opcode = op_val;
    return tx;
  endfunction

  function alu_transaction create_random_tx(
    input enum_op_t op_val
  );
    automatic alu_transaction tx = new();
    void'(tx.randomize() with { opcode == op_val; });
    return tx;
  endfunction

  initial begin : clk_proc
    clk = '0;
    forever begin
      #10 clk = ~clk;
    end
  end
  
  initial begin : drv_proc
    drv = new(vif, gen_to_drv_mbx, drv_to_sb_mbx);
    drv.run(1);
  end
  
  initial begin : monitor_proc
    mon = new(vif, mon_to_sb_mbx);
    mon.run();
  end

  initial begin : scoreboard_proc
    sb = new(drv_to_sb_mbx, mon_to_sb_mbx);
    sb.run();
  end

  initial begin : main_proc
    alu_transaction tx;
    logger::init();

    `log_info("Start of test - Executing specific scenario cases");

    tx = create_alu_tx(16'h0005, 16'h0003, OP_ADD);
    gen_to_drv_mbx.put(tx);
    
    tx = create_alu_tx(16'h000A, 16'h0004, OP_SUB);
    gen_to_drv_mbx.put(tx);
    
    tx = create_alu_tx(16'hFFFF, 16'h0001, OP_ADD);
    gen_to_drv_mbx.put(tx);

    tx = create_alu_tx(16'h7FFF, 16'h0001, OP_ADD);
    gen_to_drv_mbx.put(tx);

    `log_info("Executing automated loop for all 16 opcodes with random data");
    
    for (int i = 0; i < 16; i++) begin
      enum_op_t current_op = enum_op_t'(i);
      repeat (5) begin
        tx = create_random_tx(current_op);
        gen_to_drv_mbx.put(tx);
      end
    end

    repeat (100) @(posedge clk);
    
    `log_info("End of test simulation run");
    logger::summary();
    $finish();
  end

endmodule