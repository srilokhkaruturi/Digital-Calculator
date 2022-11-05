module FullAdder(InputA, FeedBack, C, Carry, Sum);
	input InputA;
	input FeedBack;
	input C;
	output Carry;
	output Sum;
	reg Carry;
	reg Sum;
 
	always @(*) 
	  begin
		// the equations below can be derived from the truth table of a full adder
		Sum= InputA^FeedBack^C;
		Carry= ((InputA^FeedBack)&C)|(InputA&FeedBack);  
	  end

endmodule

module SixteenBitFullAdder(InputA, FeedBack, C, Carry, Sum);
input [15:0] InputA;
input [15:0] FeedBack;
input C;

output Carry;
output [15:0] Sum;

wire [14:0] carryWires;

generate
    for(genvar i = 0; i < 16; i = i + 1) begin
        case(i)
            0: FullAdder FA0(InputA[i], FeedBack[i], C, carryWires[i], Sum[i]);
           15: FullAdder FA0(InputA[i], FeedBack[i], carryWires[i-1], Carry, Sum[i]);
           default: FullAdder FA0(InputA[i], FeedBack[i], carryWires[i-1], carryWires[i], Sum[i]);
        endcase
    end
endgenerate

endmodule

module SixteenBitAddSub(InputA, FeedBack, modeSUB, outputADDSUB, Carry, ADDerror);
input [15:0] InputA;
input [15:0] FeedBack;
input modeSUB;

output Carry;
output ADDerror;
output [31:0] outputADDSUB;

// XOR Interfaces: wires b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15
wire [15:0] xorWires;
// Carry Interfaces: wires c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16
wire [16:0] carryWires;

// Mode assigned to the initial carry [0/1]. Mode=0, Addition; Mode=1, Subtraction
assign carryWires[0]= modeSUB;

genvar i; 
generate
    for(i = 0; i < 16; i = i + 1) begin
        assign xorWires[i] = FeedBack[i] ^ modeSUB;
    end

    for(i = 0; i < 16; i = i + 1) begin
        FullAdder FA(InputA[i], xorWires[i], carryWires[i], carryWires[i+1], outputADDSUB[i]);
    end

    for(i = 31; i > 15; i = i - 1) begin
        assign outputADDSUB[i] = outputADDSUB[15];
    end
endgenerate

assign Carry = carryWires[16];
// overflow occurs if the value of the left most 2 bits have different values 
assign ADDerror = carryWires[16]^carryWires[15];

endmodule

module SixteenBitMultiplier(InputA, FeedBack, outputMUL);
input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputMUL;

reg [31:0] outputMUL;

// Local Variables
reg [15:0][15:0] Augends;
reg [15:0][15:0] Adends;

// range [16*16-1:0]
wire[16*16-1:0] Sums; 

// Carry Interfaces: wires c0,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15
wire [15:0] carryWires;

generate
    for(genvar i = 0; i < 16; i = i + 1) begin
        SixteenBitFullAdder SFA(Augends[i], Adends[i], 1'b0, carryWires[i], Sums[16*i+15:16*i]);    
    end
endgenerate

integer j;

always@(*) begin

    Augends[0]= { 1'b0, ({15{InputA[0]}}&FeedBack[15:1]) };

    //Augends[1]...Augends[15] is initialized inside the for loop
    for(j = 0; j < 15; j = j + 1) begin
        Augends[j+1] = { carryWires[0], Sums[(16*j+1)+:15] };
        Adends[j] = { {16{InputA[j+1]}}&FeedBack };
    end

    outputMUL[0] = InputA[0]&FeedBack[0];
    outputMUL[1+:15] = {
                        Sums[208], Sums[192], Sums[176], Sums[160], Sums[144], Sums[128], Sums[112],
                        Sums[96], Sums[80], Sums[64], Sums[48], Sums[32], Sums[16], Sums[0]
                    };
    outputMUL[15+:16] = Sums[239:224];
    outputMUL[31] = carryWires[14];

end

endmodule

module SixteenBitModulus(InputA,FeedBack,outputMOD,MODerror);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputMOD;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputMOD;

output MODerror;
reg MODerror;

integer i;

always @(InputA,FeedBack) begin
    outputMOD=InputA%FeedBack;

    for(i = 16; i < 32; i = i+1) begin
        outputMOD[i] = outputMOD[15];
    end

    MODerror=(FeedBack == 16'b0000000000000000);

end

endmodule

module SixteenBitDivision(InputA,FeedBack,outputDIV,DIVerror);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputDIV;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputDIV;

output DIVerror;
reg DIVerror;

integer i;

always @(InputA,FeedBack) begin
    outputDIV=InputA/FeedBack;

    for(i = 16; i < 32; i = i+1) begin
        outputDIV[i]= outputDIV[15];
    end

    DIVerror=(FeedBack == 16'b0000000000000000);

end

endmodule

module ANDER(InputA, FeedBack, outputAND);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputAND;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputAND;


always@(*) begin
    outputAND[15:0] = InputA&FeedBack;
    outputAND[31:16] = 16'b0000000000000000;
end

endmodule

module ORER(InputA, FeedBack, outputOR);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputOR;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputOR;

always@(*) begin
    outputOR[15:0] = InputA|FeedBack;
    outputOR[31:16] = 16'b0000000000000000;
end

endmodule

module XORER(InputA, FeedBack, outputXOR);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputXOR;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputXOR;

always@(*) begin
    outputXOR[15:0] = InputA^FeedBack;
    outputXOR[31:16] = 16'b0000000000000000;
end

endmodule

module NANDER(InputA, FeedBack, outputNAND);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputNAND;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputNAND;

always@(*) begin
    outputNAND[15:0] = ~(InputA&FeedBack);
    outputNAND[31:16] = 16'b0000000000000000;
end

endmodule

module NORER(InputA, FeedBack, outputNOR);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputNOR;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputNOR;

always@(*) begin
    outputNOR[15:0] = ~(InputA|FeedBack);
    outputNOR[31:16] = 16'b0000000000000000;
end

endmodule

module XNORER(InputA, FeedBack, outputXNOR);

input [15:0] InputA;
input [15:0] FeedBack;
output [31:0] outputXNOR;

wire [15:0] InputA;
wire [15:0] FeedBack;
reg [31:0] outputXNOR;

always@(*) begin
    outputXNOR[15:0] = ~(InputA^FeedBack);
    outputXNOR[31:16] = 16'b0000000000000000;
end

endmodule

module NOTER(Current, outputNOT);

input [31:0] Current;
output [31:0] outputNOT;

wire [31:0] Current;
reg [31:0] outputNOT;

always@(*) begin
    outputNOT = ~(Current);
end

endmodule

module DFF(Clk, In,Out);
	input   Clk;
	input   In;
	output  Out;
	reg     Out;

    // posedge means the transition from 0 to 1
	always @(posedge Clk)
	Out = In;
endmodule

module Mux16x1(channels, onehot, selected);
input [15:0][31:0] channels; // 16 channels where each of the channels contain 32 bit number
input [15:0] onehot;
output[31:0] selected;

    // A x 1 = A or A x 0 = 0
	assign selected =   ({32{onehot[15]}} & channels[15]) | 
                        ({32{onehot[14]}} & channels[14]) |
			            ({32{onehot[13]}} & channels[13]) |
			            ({32{onehot[12]}} & channels[12]) |
			            ({32{onehot[11]}} & channels[11]) |
			            ({32{onehot[10]}} & channels[10]) |
			            ({32{onehot[ 9]}} & channels[ 9]) | 
			            ({32{onehot[ 8]}} & channels[ 8]) |
			            ({32{onehot[ 7]}} & channels[ 7]) |
			            ({32{onehot[ 6]}} & channels[ 6]) |
			            ({32{onehot[ 5]}} & channels[ 5]) |  
			            ({32{onehot[ 4]}} & channels[ 4]) |  
			            ({32{onehot[ 3]}} & channels[ 3]) |  
			            ({32{onehot[ 2]}} & channels[ 2]) |  
                        ({32{onehot[ 1]}} & channels[ 1]) |  
                        ({32{onehot[ 0]}} & channels[ 0]) ;

endmodule

module Dec4x16(Opcode, onehot);

	input [3:0] Opcode; // opcode
	output [15:0] onehot; // 16 bit hot select being fed into a 16:1 MUX
	
	assign onehot[ 0]=~Opcode[3]&~Opcode[2]&~Opcode[1]&~Opcode[0];
	assign onehot[ 1]=~Opcode[3]&~Opcode[2]&~Opcode[1]& Opcode[0];
	assign onehot[ 2]=~Opcode[3]&~Opcode[2]& Opcode[1]&~Opcode[0];
	assign onehot[ 3]=~Opcode[3]&~Opcode[2]& Opcode[1]& Opcode[0];
	assign onehot[ 4]=~Opcode[3]& Opcode[2]&~Opcode[1]&~Opcode[0];
	assign onehot[ 5]=~Opcode[3]& Opcode[2]&~Opcode[1]& Opcode[0];
	assign onehot[ 6]=~Opcode[3]& Opcode[2]& Opcode[1]&~Opcode[0];
	assign onehot[ 7]=~Opcode[3]& Opcode[2]& Opcode[1]& Opcode[0];
	assign onehot[ 8]= Opcode[3]&~Opcode[2]&~Opcode[1]&~Opcode[0];
	assign onehot[ 9]= Opcode[3]&~Opcode[2]&~Opcode[1]& Opcode[0];
	assign onehot[10]= Opcode[3]&~Opcode[2]& Opcode[1]&~Opcode[0];
	assign onehot[11]= Opcode[3]&~Opcode[2]& Opcode[1]& Opcode[0];
	assign onehot[12]= Opcode[3]& Opcode[2]&~Opcode[1]&~Opcode[0];
	assign onehot[13]= Opcode[3]& Opcode[2]&~Opcode[1]& Opcode[0];
	assign onehot[14]= Opcode[3]& Opcode[2]& Opcode[1]&~Opcode[0];
	assign onehot[15]= Opcode[3]& Opcode[2]& Opcode[1]& Opcode[0];

endmodule

module breadboard(Clk, InputA, Result, OpCode, Error);

input [15:0] InputA;
input [3:0]  OpCode;

wire [15:0] InputA;
wire [3:0]  OpCode;

output [1:0] Error;
reg [1:0] Error;

output [31:0] Result;
reg [31:0] Result;

// Control
wire [15:0][31:0] channels;
wire [15:0] onehot;
wire [31:0] selected;
wire [31:0] unknown;

// Memory Register Related
input Clk; 
wire Clk;
wire [31:0] Current;
reg [15:0] FeedBack;
reg [31:0] Next;

Dec4x16 decoder(OpCode, onehot);
Mux16x1 multiplexer(channels, onehot, selected);

// declare wires carrying the results of each of the arithmetic operations
wire [31:0] outputADDSUB;
wire [31:0] outputMUL;
wire [31:0] outputDIV;
wire [31:0] outputMOD;

// declare wires carrying the results of each of the logical operations
wire [31:0] outputAND;
wire [31:0] outputOR;
wire [31:0] outputXOR;
wire [31:0] outputNAND;
wire [31:0] outputNOR;
wire [31:0] outputXNOR;
wire [31:0] outputNOT;

// declare wires carrying error codes
wire ADDerror;
wire DIVerror;
wire MODerror;

// arithmetic operation modules 
SixteenBitAddSub add(InputA, FeedBack, modeSUB, outputADDSUB, Carry, ADDerror);
SixteenBitMultiplier mult(InputA, FeedBack, outputMUL);
SixteenBitDivision div(InputA, FeedBack, outputDIV, DIVerror);
SixteenBitModulus mod(InputA, FeedBack, outputMOD, MODerror); 

// logical operation modules
ANDER ander(InputA, FeedBack, outputAND);
ORER orer(InputA, FeedBack, outputOR);
XORER xorer(InputA, FeedBack, outputXOR);
NANDER nander(InputA, FeedBack, outputNAND);
NORER norer(InputA, FeedBack, outputNOR);
XNORER xnorer(InputA, FeedBack, outputXNOR);
// NOTE: The cohort decided to invert the current value of the accumulator, not the given input.
NOTER noter(Current, outputNOT);

// 32-bit Memory Register
DFF ACCUMULATOR [31:0] (Clk, Next, Current);

// Error Reporting
reg modeADD;
reg modeSUB;
reg modeDIV;
reg modeMOD;

// Connect the MUX to the OpCodes
assign channels[ 0]=Current;
assign channels[ 1]=0; // RESET
assign channels[ 2]= {32{1'b1}}; // PRESET
assign channels[ 3]=unknown;
assign channels[ 4]=outputADDSUB;
assign channels[ 5]=outputADDSUB;
assign channels[ 6]=outputMUL;
assign channels[ 7]=outputDIV;
assign channels[ 8]=outputMOD;
assign channels[ 9]=outputAND;
assign channels[10]=outputOR;
assign channels[11]=outputXOR;
assign channels[12]=outputNAND;
assign channels[13]=outputNOR;
assign channels[14]=outputXNOR;
assign channels[15]=outputNOT;

always@(*)
begin
    // feedback represents the 16-bit number provided by the memory register [ACC]
    FeedBack = Current[15:0];

    modeADD=~OpCode[3]& OpCode[2]&~OpCode[1]&~OpCode[0];//0100, Channel 4
    modeSUB=~OpCode[3]& OpCode[2]&~OpCode[1]& OpCode[0];//0101, Channel 5
    modeDIV=~OpCode[3]& OpCode[2]& OpCode[1]& OpCode[0];//0111, Channel 7
    modeMOD= OpCode[3]&~OpCode[2]&~OpCode[1]&~OpCode[0];//1000, Channel 8
    // connect the output line of the memory register to the register containing the final output for given operation
    assign Result = Current;
    // connect the output line of the multiplexer to the memory register containing the selected output
    assign Next = selected;
    //Only show overflow if in add or subtract operation
    Error[0]=ADDerror&(modeADD|modeSUB);
    //only show divide by zero if in division or modulus operation
    Error[1]=(DIVerror|MODerror)&(modeDIV|modeMOD);

end

endmodule

module testbench();

    // Local Variables
    reg  [15:0] InputA;
    reg  [3:0] OpCode;
    wire [31:0] Result;
    wire [1:0] Error;

    reg Clk;

    // create breadboard
    breadboard bb32(Clk, InputA, Result, OpCode, Error);
    // Clock Thread
    initial begin 
        forever 
            begin 
                Clk=0; //square wave is low
                #5; //half a wave is 5 time 
                Clk=1;//square wave is high
                #5; //half a wave is 5 time 
                $display("Tick");
            end
    end

    // Display Thread
    initial begin
	forever
        begin

		    case (OpCode)
		        0: $display("%32b       ==> %32b  , NO-OP",bb32.Current,bb32.selected);
                1: $display("%32b       ==> %32b  , RESET",32'b00000000000000000000000000000000,bb32.selected);
                2: $display("%32b       ==> %32b  , PRESET",32'b11111111111111111111111111111111,bb32.selected);
                3: $display("Requested operation is not supported by the system.");
                4: $display("%16b  +   %16b  =  %32b  , ADDITION", InputA, bb32.FeedBack, bb32.selected);
                5: $display("%16b  -   %16b  =  %32b  , SUBSTRACTION", InputA, bb32.FeedBack,bb32.selected);
                6: $display("%16b  x   %16b  =  %32b  , MULTIPLICATION", InputA, bb32.FeedBack, bb32.selected);
                7: $display("%16b  /   %16b  =  %32b  , DIVISION", InputA, bb32.FeedBack, bb32.selected);
                8: $display("%16b  %s   %16b  =  %32b  , MODULUS", InputA, "%", bb32.FeedBack, bb32.selected);
                9: $display("%16b AND  %16b  =  %32b  , AND",InputA, bb32.FeedBack, bb32.selected);
                10: $display("%16b  OR  %16b  =  %32b  , OR",InputA, bb32.FeedBack, bb32.selected);
                11: $display("%16b XOR  %16b  =  %32b  , XOR",InputA, bb32.FeedBack, bb32.selected);
                12: $display("%16b NAND %16b  =  %32b  , NAND",InputA, bb32.FeedBack, bb32.selected);
                13: $display("%16b NOR  %16b  =  %32b  , NOR",InputA, bb32.FeedBack, bb32.selected);
                14: $display("%16b XNOR %16b  =  %32b  , XNOR",InputA, bb32.FeedBack, bb32.selected);
                15: $display("%32b       ==> %32b  , NOT", bb32.Current, bb32.selected);
		 
		    endcase
		 
		 #10;
		 end
    
    end

    // Stimulous Thread
    initial begin
    #6;
    // use #10; between operations to allow enough time for clock to go from 0 to 1
	InputA=16'b0000000000000000; // 0
	OpCode=4'b0000; //NO-OP
    #10;
    InputA=16'b0000000000000000; // 0
	OpCode=4'b0001; //RESET
    #10;
    InputA=16'b0000000011111010; // 250
    OpCode=4'b0100; // ADDITION
    #10;
    InputA=16'b0000000001111010; // 150
    OpCode=4'b0110; // MULTIPLICATION
    #10;
    InputA=16'b0111100100011000; // 31000
    OpCode=4'b0111; // DIVISION
    #10;
    InputA=16'b0000100111000100; // 2500
    OpCode=4'b1010; // OR
    #10;
    OpCode=4'b1111; // NOT
    #10;
    OpCode=4'b0001; // RESET
    #10;
    OpCode=4'b0010; // PRESET
    #10;
    InputA=16'b1111111111111111; // 65535
    OpCode=4'b0101; // SUBSTRACTION
    #10;
    InputA=16'b0000000000000000; // 0
    OpCode=4'b1101; // NOR
    #10;
    InputA=16'b1000001010011010; // 33434
    OpCode=4'b1100; // NAND
    #10;
    InputA=16'b11010011100100; // 13540
    OpCode=4'b1011; // XOR
    #10;
    InputA=16'b0000000101010100; // 340
    OpCode=4'b1001; // AND
    #10;
    InputA=16'b1101010000111101; // 54333
    OpCode=4'b1000; // MODULUS
    #10;
    InputA=16'b0000011001011011; // 1627
    OpCode=4'b1110; // XNOR
    #10;

	$finish;
	end

endmodule