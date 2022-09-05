module Breadboard(w,x,y,z,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9);
input w,x,y,z;                          
output r0, r1, r2, r3,r4, r5, r6, r7, r8, r9;                     
reg r0, r1, r2, r3,r4, r5, r6, r7, r8, r9;                         
wire w,x,y,z;

always @ ( w,x,y,z,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9) begin
    // Minterm form of the equations pulled from the truth table
    r0 = (~w&~x&y&~z) | (~w&~x&y&z) | (~w&x&~y&~z) | (~w&x&~y&z) | (~w&x&y&~z) | (w&~x&~y&~z) |
        (w&~x&~y&z) | (w&~x&y&~z) | (w&x&~y&~z) | (w&x&~y&z) | (w&x&y&~z);

    r1 = (~w&~x&~y&z) | (~w&~x&y&z) | (~w&x&~y&~ z) | (~w&x&y&~z) | 
        (~w&x&y&z) | (w&~x&~y&z) | (w&x&~y&~z) | (w&x&y&z);

    r2 = (~w&~x&~y&~z) | (~w&~x&y&~z) | (~w&~x&y&z) | (~w&x&~y&z) | (~w&x&y&~z) |
        (w&~x&~y&~z) | (w&~x&~y&z) | (w&~x&y&~z) | (w&x&y&z);
    
    r3 = (~w&~x&~y&z) | (~w&~x&y&~z) | (~w&~x&y&z) | (~w&x&~y&~z) | (~w&x&~y&z) | 
        (w&~x&~y&~z) | (w&~x&y&z) | (w&x&~y&~z) | (w&x&~y&z) | (w&x&y&~z);

    r4 = (~w&~x&~y&z) | (~w&~x&y&~z) | (~w&x&~y&~z) | (~w&x&y&~z) | (w&~x&~y&~z) | 
        (w&~x&~y&z) | (w&~x&y&~z) | (w&~x&y&z) | (w&x&~y&~z) | (w&x&y&~z) | (w&x&y&z);
    
    r5 = (~w&~x&~y&~z) | (~w&~x&~y&z) | (~w&x&~y&~z) | 
        (~w&x&y&~z) | (~w&x&y&z) | (w&~x&y&z) | (w&x&y&z);
    
    r6 = (~w&~x&~y&~z) | (~w&~x&y&~z) | (~w&~x&y&z) | (~w&x&~y&z) | 
        (w&~x&y&~z) | (w&~x&y&z) | (w&x&~y&z) | (w&x&y&z);

    r7 = (~w&~x&~y&z) | (~w&~x&y&z) | (~w&x&~y&~z) | (~w&x&~y&z) | (~w&x&y&z) | 
        (w&~x&~y&~z) | (w&~x&~y&z) | (w&x&~y&z) | (w&x&y&~z) | (w&x&y&z);
    
    r8 = (~w&~x&~y&~z) | (~w&~x&~y&z) | (~w&x&~y&z) | (~w&x&y&z) |
        (w&~x&y&~z) | (w&~x&y&z) | (w&x&~y&~z) | (w&x&y&~z) | (w&x&y&z);
    
    r9 =(~w&x&y&~z) | (~w&x&y&z) | (w&~x&~y&~z) | (w&~x&~y&z) |
        (w&~x&y&~z) | (w&~x&y&z) | (w&x&~y&~z) | (w&x&~y&z);

end

endmodule

module testbench();
  reg [4:0] i; 
  reg  a;//Value of 2^3
  reg  b;//Value of 2^2
  reg  c;//Value of 2^1
  reg  d;//Value of 2^0
  
  wire  f0,f1,f2,f3,f4,f5,f6,f7,f8,f9;
  
  Breadboard zap(a,b,c,d,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9);
 
  initial begin
   	
  $display ("|##|A|B|C|D|F0|F1|F2|F3|F4|F5|F6|F7|F8|F9|");
  $display ("|==+=+=+=+=+==+==+==+==+==+==+==+==+==+==|");
  
	for (i = 0; i < 16; i = i + 1) 
	begin
		a=(i/8)%2;//High bit
		b=(i/4)%2;
		c=(i/2)%2;
		d=(i/1)%2;//Low bit	
		 
    #12; // Wait for 12 time units
		 	
		$display ("|%2d|%1d|%1d|%1d|%1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d|",i,a,b,c,d,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9);
		if(i%4==3) 
		 $write ("|--+-+-+-+-+--+--+--+--+--+--+--+--+--+--|\n");

	end
 
	#10;
	$finish;
  end
  
endmodule