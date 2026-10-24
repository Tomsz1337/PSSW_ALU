package alu_pkg;

  typedef enum logic [3:0] {
      OP_ADD  = 4'b0000,
      OP_SUB  = 4'b0001,
      OP_INC  = 4'b0010,
      OP_DEC  = 4'b0011,
      OP_AND  = 4'b0100,
      OP_OR   = 4'b0101,
      OP_XOR  = 4'b0110,
      OP_NOR  = 4'b0111,
      OP_NOT  = 4'b1000,
      OP_PASS = 4'b1001,
      OP_LSL  = 4'b1010,
      OP_LSR  = 4'b1011,
      OP_ASR  = 4'b1100,
      OP_ROL  = 4'b1101,
      OP_ROR  = 4'b1110,
      OP_SLT  = 4'b1111
  } enum_op_t;

    class alu_transaction;
      rand logic [15:0] a;
      rand logic [15:0] b;
      rand enum_op_t    opcode;

      logic [15:0] result; 
      logic        zero;
      logic        carry;
      logic        overflow;
      
      function string convert2string();
          return $sformatf("Op: %s, A: 0x%0h, B: 0x%0h -> Res: 0x%0h (Z:%b, C:%b, V:%b)", 
                           opcode.name(), a, b, result, zero, carry, overflow);
      endfunction

      
      function alu_transaction copy();
          alu_transaction dst = new();
          dst.a        = this.a;
          dst.b        = this.b;
          dst.opcode   = this.opcode;
          dst.result   = this.result;
          dst.zero     = this.zero;
          dst.carry    = this.carry;
          dst.overflow = this.overflow;
          return dst;
      endfunction
    endclass

endpackage;