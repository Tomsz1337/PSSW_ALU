package alu_scoreboard_pkg;
  
  import logger_pkg::*;
  import alu_pkg::*;
  
  class alu_scoreboard;
    mailbox #(alu_transaction) drv_mbx;
    mailbox #(alu_transaction) mon_mbx;
    
    int match_count = 0;
    int mismatch_count = 0;
    
    function new(mailbox #(alu_transaction) drv_mbx, mailbox #(alu_transaction) mon_mbx);
      this.drv_mbx = drv_mbx;
      this.mon_mbx = mon_mbx;
    endfunction
    
    task run();
      alu_transaction exp_tx;
      alu_transaction act_tx;
      
      forever begin
        drv_mbx.get(exp_tx);
        mon_mbx.get(act_tx);
        
        predict_result(exp_tx);
        check(exp_tx, act_tx);
      end
    endtask
    
    function void predict_result(alu_transaction tx);
      logic [16:0] temp_result = 17'b0;
      tx.result   = 16'b0;
      tx.carry    = 1'b0;
      tx.overflow = 1'b0;
      
      case (tx.opcode)
        OP_ADD: begin
          temp_result = {1'b0, tx.a} + {1'b0, tx.b};
          tx.result   = temp_result[15:0];
          tx.carry    = temp_result[16];
          tx.overflow = (tx.a[15] == tx.b[15]) && (tx.result[15] != tx.a[15]);
        end
        OP_SUB: begin
          temp_result = {1'b0, tx.a} - {1'b0, tx.b};
          tx.result   = temp_result[15:0];
          tx.carry    = temp_result[16];
          tx.overflow = (tx.a[15] != tx.b[15]) && (tx.result[15] != tx.a[15]);
        end
        OP_INC:  tx.result = tx.a + 1'b1;
        OP_DEC:  tx.result = tx.a - 1'b1;
        OP_AND:  tx.result = tx.a & tx.b;
        OP_OR:   tx.result = tx.a | tx.b;
        OP_XOR:  tx.result = tx.a ^ tx.b;
        OP_NOR:  tx.result = ~(tx.a | tx.b);
        OP_NOT:  tx.result = ~tx.a;
        OP_PASS: tx.result = tx.a;
        OP_LSL:  tx.result = tx.a << 1;
        OP_LSR:  tx.result = tx.a >> 1;
        OP_ASR:  tx.result = $signed(tx.a) >>> 1;
        OP_ROL:  tx.result = {tx.a[14:0], tx.a[15]};
        OP_ROR:  tx.result = {tx.a[0], tx.a[15:1]};
        OP_SLT:  tx.result = ($signed(tx.a) < $signed(tx.b)) ? 16'b1 : 16'b0;
        default: tx.result = 16'b0;
      endcase
      
      tx.zero = (tx.result == 16'b0);
    endfunction
    
    function void check(alu_transaction exp, alu_transaction act);
      bit error = 0;
      
      if (exp.result !== act.result) begin
        `log_err($sformatf("Result Mismatch! Exp: 0x%0h, Act: 0x%0h", exp.result, act.result));
        error = 1;
      end
      if (exp.zero !== act.zero) begin
        `log_err($sformatf("Zero Flag Mismatch! Exp: %b, Act: %b", exp.zero, act.zero));
        error = 1;
      end
      if (exp.carry !== act.carry) begin
        `log_err($sformatf("Carry Flag Mismatch! Exp: %b, Act: %b", exp.carry, act.carry));
        error = 1;
      end
      if (exp.overflow !== act.overflow) begin
        `log_err($sformatf("Overflow Flag Mismatch! Exp: %b, Act: %b", exp.overflow, act.overflow));
        error = 1;
      end
      
      if (error) begin
        mismatch_count++;
        `log_err($sformatf("Failed TX Info -> %s", act.convert2string()));
      end else begin
        match_count++;
      end
    endfunction
    
  endclass

endpackage