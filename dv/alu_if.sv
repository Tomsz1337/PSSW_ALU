interface alu_if();
    logic [15:0] a;
    logic [15:0] b;
    logic [3:0]  opcode;
    logic [15:0] result;
    logic        zero;
    logic        carry;
    logic        overflow;
endinterface