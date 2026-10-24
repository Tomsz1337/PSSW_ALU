package alu_driver_pkg;
  
  import logger_pkg::*;
  import alu_pkg::*; 
  
  class alu_driver;
    virtual interface alu_if          vif;
    mailbox #(alu_transaction)        packet_mbx; 
    mailbox #(alu_transaction)        out_mbx;    
    
    function new(virtual interface alu_if vif, mailbox #(alu_transaction) packet_mbx, mailbox #(alu_transaction) out_mbx);
      this.vif          = vif;
      this.packet_mbx   = packet_mbx;
      this.out_mbx      = out_mbx;
    endfunction
    
    task run(int wait_cycles);
      alu_transaction tx;
      alu_transaction dup;
      
      vif.a      <= 16'h0000;
      vif.b      <= 16'h0000;
      vif.opcode <= 4'b0000;
    
      forever begin

        packet_mbx.get(tx);
        
        dup = tx.copy();
        out_mbx.put(dup);
        
        `log_info($sformatf("Driver: Received TX -> %s", tx.convert2string()));
        
        @(posedge vif.clk);
        `log_info($sformatf("Driver: driving inputs to ALU [Opcode: %s]", tx.opcode.name()));
        
        vif.a      <= tx.a;
        vif.b      <= tx.b;
        vif.opcode <= tx.opcode;

        @(posedge vif.clk);
        
        vif.a      <= 16'h0000;
        vif.b      <= 16'h0000;
        
        for(int i = 0; i < wait_cycles; i++) begin
          @(posedge vif.clk);
        end
      end
      
    endtask
    
  endclass

endpackage