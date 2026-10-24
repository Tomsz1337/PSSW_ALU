import alu_pkg::*;

module alu (
    input  logic [15:0] a,          
    input  logic [15:0] b,          
    input alu_pkg::enum_op_t opcode,    
    output logic [15:0] result,     
    output logic        zero,       
    output logic        parity,     
    output logic        carry,      
    output logic        overflow    
);

logic [16:0] temp_result;

always_comb begin

	temp_result = 17'b0;
    result      = 16'b0;
    carry       = 1'b0;
	parity		= 1'b0;
	zero 		= 1'b0;
    overflow    = 1'b0;

	case (opcode)
		OP_ADD: begin
            temp_result = {1'b0, a} + {1'b0, b};
            result      = temp_result[15:0];
            carry       = temp_result[16];
            overflow    = (a[15] == b[15]) && (result[15] != a[15]);
        end
            
        OP_SUB: begin
            temp_result = {1'b0, a} - {1'b0, b};
            result      = temp_result[15:0];
            carry       = temp_result[16];
            overflow    = (a[15] != b[15]) && (result[15] != a[15]);
        end      
        OP_INC:  result = a + 1'b1;
        OP_DEC:  result = a - 1'b1;    
        OP_AND:  result = a & b;
        OP_OR:   result = a | b;
        OP_XOR:  result = a ^ b;
        OP_NOR:  result = ~(a | b);
        OP_NOT:  result = ~a;
        OP_PASS: result = a;
        OP_LSL:  result = a << 1;
        OP_LSR:  result = a >> 1;
        OP_ASR:  result = $signed(a) >>> 1;
        OP_ROL:  result = {a[14:0], a[15]};
        OP_ROR:  result = {a[0], a[15:1]};
        OP_SLT:  result = (a < b) ? 16'b1 : 16'b0;
        default: result = 16'b0;       
    endcase

    zero = (result == 16'b0);

end


endmodule