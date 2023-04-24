/*  This file is part of JTCORES.
    JTCORES program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTCORES program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTCORES.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 22-3-2022 */

module jtngp_game(
    `include "jtframe_game_ports.inc" // see $JTFRAME/hdl/inc/jtframe_game_ports.inc
);

wire [12:1] cpu_addr=0;
wire [15:0] cha_dout, obj_dout, scr1_dout, scr2_dout, regs_dout;
wire [15:0] cpu_dout=0;
wire [ 1:0] dsn=3;
wire        chram_cs=0, obj_cs=0, scr1_cs=0, scr2_cs=0, regs_cs=0;
wire        cpu_cen, snd_cen;
wire        hirq, virq;

assign debug_view = 0;
assign snd = 0;
assign sample = 0;
assign prog_rd = 0;
assign prog_we = 0;
assign prog_mask = 0;
assign prog_data = 0;
assign prog_addr = 0;
assign sdram_addr = 0;
assign sdram_req = 0;
assign dwnld_busy = downloading;
assign game_led  = 0;

jtngp_video u_video(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .clk24      ( clk24     ),
    .pxl_cen    ( pxl_cen   ),
    .pxl2_cen   ( pxl2_cen  ),

    .status     ( status    ),
    .cpu_cen    ( cpu_cen   ),
    .snd_cen    ( snd_cen   ),

    // CPU
    .cpu_addr   ( cpu_addr  ),
    .cpu_dout   ( cpu_dout  ),
    .dsn        ( dsn       ),

    .chram_cs   ( chram_cs  ),
    .obj_cs     ( obj_cs    ),
    .scr1_cs    ( scr1_cs   ),
    .scr2_cs    ( scr2_cs   ),
    .regs_cs    ( regs_cs   ),

    .regs_dout  ( regs_dout ),
    .cha_dout   ( cha_dout  ),
    .obj_dout   ( obj_dout  ),
    .scr1_dout  ( scr1_dout ),
    .scr2_dout  ( scr2_dout ),

    .hirq       ( hirq      ),
    .virq       ( virq      ),

    .HS         ( HS        ),
    .VS         ( VS        ),
    .LHBL_dly   ( LHBL_dly  ),
    .LVBL_dly   ( LVBL_dly  ),
    .red        ( red       ),
    .green      ( green     ),
    .blue       ( blue      ),
    .gfx_en     ( gfx_en    )
);

endmodule