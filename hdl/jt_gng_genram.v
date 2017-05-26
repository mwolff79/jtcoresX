`timescale 1ns/1ps

/*

	Generic RAM

*/

module jt_gng_genram #(parameter addrw=12, dataw=8, id=0)(
	input [addrw-1:0] A,
	inout [dataw-1:0] D,
	input cs_b,
	input rd_b,
	input wr_b
);

reg [dataw-1:0] ram [0:(2**addrw-1)];
reg [dataw-1:0] dread;

wire READ = !cs_b && !rd_b && wr_b;
wire WRITE= !cs_b && !wr_b;

assign D= READ ? dread : 8'hzz;

`ifdef RAM_INFO
always @(READ)
	if(READ)
		$display("RAM #%1D read %X from %X",id,dread, A);
`endif

always @(A) begin
	dread=ram[A];
end

integer i;
initial for(i=0;i<(2**addrw-1);i=i+1) ram[i]=0;

always @(WRITE,A,D)
	if(WRITE) begin
		`ifdef RAM_INFO
		$display("RAM #%1D write %X into %X",id,D, A);
		`endif
		ram[A]=D;
	end


endmodule // jt_gng_ram