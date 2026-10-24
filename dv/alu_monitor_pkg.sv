package alu_monitor_pkg;

    import logger_pkg::*;
    import alu_pkg::*;

    class alu_monitor;

        virtual interface alu_if        vif;
        mailbox #(alu_transaction)      out_mbox;

        function new(virtual interface alu_if vif, mailbox #(alu_transaction) out_mbox);
            this.vif = vif;
            this.out_mbox = out_mbox;
        endfunction

        task run();
            alu_transaction tx;

            forever begin 
                @(posedge vif.clk);
                
                tx = new();
              
                tx.a      = vif.a;
                tx.b      = vif.b;
                tx.opcode = alu_pkg::enum_op_t'(vif.opcode); 

                @(posedge vif.clk);
                
                tx.result   = vif.result;
                tx.zero     = vif.zero;
                tx.carry    = vif.carry;
                tx.overflow = vif.overflow;

                `log_info($sformatf("Monitor: Monitored ALU transaction -> %s", tx.convert2string()));

                out_mbox.put(tx);
            end
        endtask

    endclass
endpackage