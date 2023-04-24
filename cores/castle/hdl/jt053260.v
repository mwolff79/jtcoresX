/*  This file is part of JTKCPU.
    JTKCPU program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTKCPU program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTKCPU.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 14-4-2023 */

module jt053260 (

    input               rst,
    input               clk,
    input               cen,
    input        [ 5:0] addr,

    // Main CPU Address
    input               ma0,
    // Main CPU control
    input               mrw,
    input               mcs,
    // Sub CPU control
    input               rw,
    input               cs,
    // input YM2151
    input               stb1,
    input               aux1,

    // Main CPU data bus
    input        [ 7:0] mdb_in,
    output       [ 7:0] mdb_out,

    // ROM Address and Data bus
    output       [20:0] r_addr,
    input        [ 7:0] r_data,

    // YM2151
    input        [ 7:0] db_in,
    output       [ 7:0] db_out,

    // output bus YM-3012
    output              so,
    output              sy,
    output              sh1,
    output              sh2

    // slots disconnected
    // input               st1,
    // input               st2,
    // input               aux2,
    // output              rwp,
    // output              tim2,
    // output              ne,     // M6809 clock
    // output              nq,     // M6809 clock

);


reg [7:0] ch_mmr[0:31];

wire          sm_a, sm_b;
wire          ms_a, ms_b;

wire   [ 7:0] key_on, mode,
wire   [ 3:0] ch_st; adpcm, loop_en;
wire

// 4 channels for register of 8 bit
wire   [12:0] ch0_pitch  = { ch_mmr[1][3:0], ch_mmr[0] };
wire   [15:0] ch0_length = { ch_mmr[3], ch_mmr[2] };
wire   [20:0] ch0_start  = { ch_mmr[6][4:0], ch_mmr[5], ch_mmr[4] };
wire   [ 6:0] ch0_volume = { ch_mmr[7][6:0] };
wire          ch0_pan;
wire          ch0_run;
wire          ch0_key  = key_on[0];
wire          ch0_loop = loop_en[0];

wire   [12:0] ch1_pith   = { ch_mmr[9][3:0], ch_mmr[8] };
wire   [15:0] ch1_length = { ch_mmr[11], ch_mmr[10] };
wire   [20:0] ch1_start  = { ch_mmr[14][4:0], ch_mmr[13], ch_mmr[12] };
wire   [ 6:0] ch1_volume = { ch_mmr[15][6:0] };
wire          ch1_pan;
wire          ch1_run;
       assign ch1_key  = key_on[1];
       assign ch1_loop = loop_en[1];

wire   [12:0] ch2_pith   = { ch_mmr[17][3:0], ch_mmr[16] };
wire   [15:0] ch2_length = { ch_mmr[19], ch_mmr[18] };
wire   [20:0] ch2_start  = { ch_mmr[22][4:0], ch_mmr[21], ch_mmr[20] };
wire   [ 6:0] ch2_volume = { ch_mmr[23][6:0] };
wire          ch2_pan,
wire          ch2_run,
              ch2_act;
       assign ch2_key  = key_on[2];
       assign ch2_loop = loop_en[2];

wire   [12:0] ch3_pith   = { ch_mmr[25][3:0], ch_mmr[24] };
wire   [15:0] ch3_length = { ch_mmr[27], ch_mmr[26] };
wire   [20:0] ch3_start  = { ch_mmr[30][4:0], ch_mmr[29], ch_mmr[28] };
wire   [ 6:0] ch3_volume = { ch_mmr[31][6:0] };
wire          ch3_pan;
wire          ch3_run;
       assign ch3_key  = key_on[3];
       assign ch3_loop = loop_en[3];



always @* begin
    case ( regop )
        8'h00 :
        8'h01 :
        8'h02 :
        8'h03 : portdata [ addr ] = db_in
        8'h28 : key_on = db_in;
        //8'h29 :
        8'h2A : begin
                    loop  = db_in[3:0];
                    adpcm = db_in[7:4];
                end
        //8'h2B :
        8'h2C : begin
                    ch0_pan = db_in[3:0];
                    ch1_pan = db_in[7:4];
                end
        8'h2D : begin
                    ch2_pan = db_in[3:0];
                    ch3_pan = db_in[7:4];
                end
        8'h2E : begin
                    if ( mode[0] )
                        rom_data = r_data;
                end
        8'h2F : mode = db_in;
        default : /* default */;
    endcase

end


always @(posedge clk, posedge rst) begin
    if( rst ) begin
        ch_mmr[0] <= 0; ch_mmr[ 8] <= 0; ch_mmr[16] <= 0; ch_mmr[24] <= 0;
        ch_mmr[1] <= 0; ch_mmr[ 9] <= 0; ch_mmr[17] <= 0; ch_mmr[25] <= 0;
        ch_mmr[2] <= 0; ch_mmr[10] <= 0; ch_mmr[18] <= 0; ch_mmr[26] <= 0;
        ch_mmr[3] <= 0; ch_mmr[11] <= 0; ch_mmr[19] <= 0; ch_mmr[27] <= 0;
        ch_mmr[4] <= 0; ch_mmr[12] <= 0; ch_mmr[20] <= 0; ch_mmr[28] <= 0;
        ch_mmr[5] <= 0; ch_mmr[13] <= 0; ch_mmr[21] <= 0; ch_mmr[29] <= 0;
        ch_mmr[6] <= 0; ch_mmr[14] <= 0; ch_mmr[22] <= 0; ch_mmr[30] <= 0;
        ch_mmr[7] <= 0; ch_mmr[15] <= 0; ch_mmr[23] <= 0; ch_mmr[31] <= 0;
        ch0_run <= 0;
        ch1_run <= 0;
        ch2_run <= 0;
        ch3_run <= 0;
    end else begin

        if ( rw ) begin
            ch_mmr[ addr ] <= db_din;
        end
        ch0_run <= addr ==  4;
        ch1_run <= addr == 12;
        ch2_run <= addr == 20;
        ch3_run <= addr == 28;

    end
end

// Kadpcm_table
// IN - OUT
//  0 :  0
//  1 :  1
//  2 :  2
//  3 :  4
//  4 :  8
//  5 :  16
//  6 :  32
//  7 :  64
//  8 : -128
//  9 : -64
//  A : -32
//  B : -16
//  C : -8
//  D : -4
//  E : -2
//  F : -1

jt053260_channel u_ch0(
    .rst      ( rst ),
    .clk      ( clk ),
    .cen      ( cen ),

    .pitch    ( ch0_pitch   ),
    .length   ( ch0_length  ),
    .start    ( ch0_start   ),
    .volume   ( ch0_volumen ),
    .run      ( ch0_run     ),
    .key_on   ( ch0_key     ),
    .loop_en  ( ch0_loop    ),

    .rom_addr ( rom_addr    ),
    .rom_data ( rom_data    )
);

jt053260_channel u_ch1(
    .rst      ( rst ),
    .clk      ( clk ),
    .cen      ( cen ),

    .pitch    ( ch1_pitch   ),
    .length   ( ch1_length  ),
    .start    ( ch1_start   ),
    .volume   ( ch1_volumen ),
    .run      ( ch1_run     ),
    .key_on   ( ch1_key     ),
    .loop_en  ( ch1_loop    ),

    .rom_addr ( rom_addr    ),
    .rom_data ( rom_data    )
);

jt053260_channel u_ch2(
    .rst      ( rst ),
    .clk      ( clk ),
    .cen      ( cen ),

    .pitch    ( ch2_pitch   ),
    .length   ( ch2_length  ),
    .start    ( ch2_start   ),
    .volume   ( ch2_volumen ),
    .run      ( ch2_run     ),
    .key_on   ( ch2_key     ),
    .loop_en  ( ch2_loop    ),

    .rom_addr ( rom_addr    ),
    .rom_data ( rom_data    )
);

jt053260_channel u_ch3(
    .rst      ( rst ),
    .clk      ( clk ),
    .cen      ( cen ),

    .pitch    ( ch3_pitch   ),
    .length   ( ch3_length  ),
    .start    ( ch3_start   ),
    .volume   ( ch3_volumen ),
    .run      ( ch3_run     ),
    .key_on   ( ch3_key     ),
    .loop_en  ( ch3_loop    ),

    .rom_addr ( rom_addr    ),
    .rom_data ( rom_data    )
);

endmodule


module jt053260_channel(

    input               rst,
    input               clk,
    input               cen,

    input        [20:0] start,
    input        [15:0] length,
    input        [12:0] pitch,
    input        [ 6:0] volume,
    input        [ 7:0] key_on,
    input        [ 7:0] loop_en,
    input               run,
    input               pan,

    input        [ 7:0] rom_data
    output       [ 7:0] db_out,
    output  reg  [20:0] rom_addr

);

wire   [15:0] cnt;
wire   [15:0] inc;

reg assign [6:0] kadpcm[0:15];
reg assign [3:0] pan_vol[0:7];

initial begin
    kadpcm[ 0] =  7'd0;
    kadpcm[ 1] =  7'd1;
    kadpcm[ 2] =  7'd2;
    kadpcm[ 3] =  7'd4;
    kadpcm[ 4] =  7'd8;
    kadpcm[ 5] =  7'd16;
    kadpcm[ 6] =  7'd32;
    kadpcm[ 4] =  7'd64;
    kadpcm[ 8] = -7'd128;
    kadpcm[ 9] = -7'd64;
    kadpcm[10] = -7'd32;
    kadpcm[11] = -7'd16;
    kadpcm[12] = -7'd8;
    kadpcm[13] = -7'd4;
    kadpcm[14] = -7'd2;
    kadpcm[15] = -7'd1;
end

initial begin
    pan_vol[0] = 0;
    pan_vol[1] = 15;
    pan_vol[2] = ;
    pan_vol[3] = ;
    pan_vol[4] = ;
    pan_vol[5] = ;
    pan_vol[6] = ;
    pan_vol[7] = ;
end

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        rom_addr <= 0;
        inc      <= 0;
        adpcm    <= 0;
        run      <= 0;
        pan_vol  <= 0;
    end else begin
        if( key_on[0] ) begin
            rom_addr <= start;
            pan_vol  <= db_in;
            cnt    <= length;
            db_out <= 0;
            run    <= 1;
        end else begin
            // addr start incrementa y cnt decrementa
            rom_addr[15: 0] <= start[15: 0] + cnt[15:0];
            rom_addr[20:16] <= start[20:16];
        end

        // match_n <= ~&(db_in ^~ length[7:0]) | ~&(db_in ^~ length[15:8]);
        inc <= m_kadpcm ? (cnt + 1'd1) >> 1 : cnt + 1'd1 >> 0;
        if ( inc > length ) begin
            if( loop_en ) begin
                cnt    <= 0;
                db_out <= 0;
                inc    <= 0;
            end else begin
                run <= 0;
            end
        end

        if ( adpcm ) begin
            if ( cnt )begin
                rom_data <= 4;
            end
            db_out <= kadpcm[rom_data] + 1'd1;

        end else begin
            db_out <= rom_data;
        end
        if ( run ) begin

        end

    end
end

endmodule