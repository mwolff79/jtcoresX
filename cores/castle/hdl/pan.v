module test;
	wire [2:0] pan;

	integer k;

	assign pan=k[2:0];

	initial begin
		$dumpfile("test.lxt");
		$dumpvars;
		$dumpon;
	end

	initial begin
		pan=0;
		for( k=0; k<8; k=k+1 ) begin
			#100;
			//imprimir todas la puertas
			$display("%d -> %d %d %d %d ...", pan, aw33_y,...);
		end
	end

	nand ar48( pan[0], ~pan[1], ~pan[2], ar48_y );
	// ... crear las demas puertas
	nand aw33( ar48_y, ar58_y, aw33_y );
endmodule