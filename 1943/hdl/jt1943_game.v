/*  This file is part of JT_GNG.
    JT_GNG program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT_GNG program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT_GNG.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 18-2-2019 */
    
module jt1943_game(
    input           rst,
    input           clk,        // 24   MHz
    input           cen12,      // 12   MHz
    input           cen6,       //  6   MHz
    input           cen3,       //  3   MHz
    input           cen1p5,     //  1.5 MHz
    output   [3:0]  red,
    output   [3:0]  green,
    output   [3:0]  blue,
    output          LHBL,
    output          LVBL,
    output          HS,
    output          VS,
    // cabinet I/O
    input   [ 1:0]  start_button,
    input   [ 1:0]  coin_input,
    input   [ 6:0]  joystick1,
    input   [ 6:0]  joystick2,
    input           enable_fm,
    input           enable_psg,

    // SDRAM interface
    input           downloading,
    input           loop_rst,
    output          autorefresh,
    output          sdram_re,
    output  [21:0]  sdram_addr,
    input   [15:0]  data_read,

    // PROM programming
    input   [21:0]  ioctl_addr,    
    input   [ 3:0]  prog_din,

    // cheat
    input           cheat_invincible,
    // DIP Switch A
    input   [1:0]   dip_planes,
    input   [1:0]   dip_bonus,
    input           dip_upright,
    input   [2:0]   dip_price,
    // DIP Switch B
    input           dip_pause,   // DWB - bit 7
    input   [1:0]   dip_level, // difficulty level
    input           dip_test,
    output          coin_cnt,
    // Sound output
    output  [15:0]  snd,
    output          sample
);

wire [8:0] V;
wire [8:0] H;
wire HINIT;

wire [12:0] cpu_AB;
wire char_cs;
wire flip;
wire [7:0] cpu_dout, char_dout;
wire [ 7:0] chram_dout,scram_dout;
wire rd;
wire rom_ready;

assign sample=1'b1;

wire LHBL_obj, Hsub;
assign H0 = { H[2:0], Hsub } == 4'b0000;

reg rst_game;

always @(negedge clk)
    rst_game <= rst || !rom_ready;

jtgng_timer u_timer(
    .clk       ( clk      ),
    .cen12     ( cen12    ),
    .cen6      ( cen6     ),
    .rst       ( rst      ),
    .V         ( V        ),
    .H         ( H        ),
    .Hsub      ( Hsub     ),
    .Hinit     ( HINIT    ),
    .LHBL      ( LHBL     ),
    .LHBL_obj  ( LHBL_obj ),
    .LVBL      ( LVBL     ),
    .HS        ( HS       ),
    .VS        ( VS       ),
    .Vinit     (          )
);

wire wr_n, rd_n;
// sound
wire sres_b;
wire [7:0] snd_latch;

wire scr_cs, obj_cs;
wire [1:0] scrpos_cs;
wire [2:0] scr_br;

// ROM data
wire  [13:0]  char_addr;
wire  [14:0]  obj_addr;
wire  [15:0]  char_data, obj_data;
wire  [ 7:0]  main_data, snd_data;
wire  [23:0]  scr_data;
wire  [14:0]  scr_addr;
wire  [16:0]  main_addr;
wire  [14:0]  snd_addr;

wire snd_latch0_cs, snd_latch1_cs, snd_int;
wire char_wait_n, scr_wait_n;

wire [9:0] prom_we;
jt1943_prom_we u_prom_we(
    //.clk_rom     ( clk_rom       ),
    .downloading ( downloading   ), 
    //.ioctl_wr    ( ioctl_wr      ),
    //.ioctl_addr  ( ioctl_addr    ),
    //.ioctl_data  ( ioctl_data    ),
    //.prog_data   ( prog_data     ),
    //.prog_mask   ( prog_mask     ),
    //.prog_addr   ( prog_addr     ),
    .romload_addr( ioctl_addr    ),    
    .prom_we     ( prom_we       )
);

wire [7:0] prog_addr = ioctl_addr[7:0];

wire prom_k6_we  = prom_we[0];
wire prom_d1_we  = prom_we[1];
wire prom_d2_we  = prom_we[2];
wire prom_d6_we  = prom_we[3];
wire prom_e8_we  = prom_we[4];
wire prom_e9_we  = prom_we[5];
wire prom_e10_we = prom_we[6];
wire prom_f1_we  = prom_we[7];
wire prom_k3_we  = prom_we[8];
wire prom_m11_we = prom_we[9];

jt1943_main u_main(
    .rst        ( rst_game      ),
    .clk        ( clk           ),
    .cen6       ( cen6          ),
    .cen3       ( cen3          ),
    .soft_rst   ( soft_rst      ),
    .char_wait_n( char_wait_n   ),
    .scr_wait_n ( scr_wait_n    ),
    .char_dout  ( chram_dout    ),
    .scr_dout   ( scram_dout    ),
    .scr_br     ( scr_br        ),
    // sound
    .sres_b        ( sres_b        ),
    .snd_latch0_cs ( snd_latch0_cs ),
    .snd_latch1_cs ( snd_latch1_cs ),
    .snd_int       ( snd_int       ),
    
    .LHBL       ( LHBL          ),
    .cpu_dout   ( cpu_dout      ),
    .char_cs    ( char_cs       ),
    .scr_cs     ( scr_cs        ),
    .scrpos_cs  ( scrpos_cs     ),
    .obj_cs     ( obj_cs        ),
    .flip       ( flip          ),
    .V          ( V             ),
    .cpu_AB     ( cpu_AB        ),
    .rd_n       ( rd_n          ),
    .wr_n       ( wr_n          ),
    .rom_addr   ( main_addr     ),
    .rom_data   ( main_data     ),
    // Cabinet input
    .start_button( start_button ),
    .coin_input  ( coin_input   ),
    .joystick1   ( joystick1    ),
    .joystick2   ( joystick2    ),   
    // PROM K6
    .prog_addr  ( prog_addr     ),
    .prom_k6_we ( prom_k6_we    ),
    .prog_din   ( prog_din      ),
    // Cheat
    .cheat_invincible( cheat_invincible ),
    // DIP switches
    .dipsw_a    ( {dip_planes, dip_bonus, dip_upright, dip_price } ),
    .dipsw_b    ( {dip_pause, dip_level, 1'b1, dip_test, 3'd7}     ),
    .coin_cnt   ( coin_cnt      )
);

`ifndef NOSOUND
jt1943_sound u_sound (
    .rst            ( rst_game       ),
    .clk            ( clk            ),
    .cen3           ( cen3           ),
    .cen1p5         ( cen1p5         ),
    .sres_b         ( sres_b         ),
    .main_dout      ( cpu_dout       ),
    .main_latch_cs  ( snd_latch_cs   ),
    // sound control
    .enable_psg     ( enable_psg     ),
    .enable_fm      ( enable_fm      ),
    .snd_int        ( V[5]           ),
    .rom_addr       ( snd_addr       ),
    .rom_data       ( snd_data       ),
    .snd            ( snd            ) 
);
`else 
assign snd_addr = 15'd0;
assign snd = 9'd0;
`endif

jt1943_video u_video(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .cen6       ( cen6          ),
    .cen3       ( cen3          ),
    .cpu_AB     ( cpu_AB[10:0]  ),
    .V          ( V[7:0]        ),
    .H          ( H             ),
    .rd_n       ( rd_n          ),
    .wr_n       ( wr_n          ),
    .flip       ( flip          ),
    .cpu_dout   ( cpu_dout      ),
    .pause      ( ~dip_pause    ), //dipsw_a[7]    ),
    // CHAR
    .char_cs    ( char_cs       ),
    .chram_dout ( chram_dout    ),
    .char_addr  ( char_addr     ), // CHAR ROM
    .char_data  ( char_data     ),
    .char_wait_n( char_wait_n   ),
    // SCROLL - ROM
    .scr_cs     ( scr_cs        ),
    .scrpos_cs  ( scrpos_cs     ),    
    .scram_dout ( scram_dout    ),
    .scr_addr   ( scr_addr      ),
    .scrom_data ( scr_data      ),
    .scr_wait_n ( scr_wait_n    ),
    .scr_br     ( scr_br        ),
    // OBJ
    .obj_cs     ( obj_cs        ),
    .HINIT      ( HINIT         ),
    .obj_addr   ( obj_addr      ),
    .objrom_data( obj_data      ),
    // Color Mix
    .LHBL       ( LHBL          ),
    .LHBL_obj   ( LHBL_obj      ),
    .LVBL       ( LVBL          ),
    .red        ( red           ),
    .green      ( green         ),
    .blue       ( blue          ),
    // PROM access
    .prog_addr  ( prog_addr     ),
    .prog_din   ( prog_din      ),
    // color mixer proms
prom_12a_we
prom_13a_we
prom_14a_we
prom_12c_we  
);

jtgng_rom #(
    .snd_offset (22'h0A000),
    .char_offset(22'h0C000),
    .scr_offset (22'h0D000),
    .scr2_offset(22'h04000),
    .obj_offset (22'h15000)
) u_rom (
    .rst         ( rst           ),
    .clk         ( clk           ),
    .cen12       ( cen12         ),
    .H           ( H[2:0]        ),
    .Hsub        ( Hsub          ),
    .LHBL        ( LHBL          ),
    .LVBL        ( LVBL          ),
    .sdram_re    ( sdram_re      ),
    
    .char_addr   ( {1'b0,char_addr} ),
    .main_addr   ( main_addr     ),
    .snd_addr    ( snd_addr      ),
    .obj_addr    ( {1'd0, obj_addr} ), // 15:0 for ROM
    .scr_addr    ( scr_addr      ),

    .char_dout   ( char_data     ),
    .main_dout   ( main_data     ),
    .snd_dout    ( snd_data      ),
    .obj_dout    ( obj_data      ),
    .scr_dout    ( scr_data      ),
    .ready       ( rom_ready     ),
    // SDRAM interface
    .downloading ( downloading   ),
    .loop_rst    ( loop_rst      ),
    .autorefresh ( autorefresh   ),
    .sdram_addr  ( sdram_addr    ),
    .data_read   ( data_read     )
);

endmodule // jtgng