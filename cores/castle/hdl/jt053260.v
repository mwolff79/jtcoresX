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
    input        [ 7:0] mdb_din,
    output       [ 7:0] mdb_dout,

    // ROM Address and Data bus
    output       [20:0] rom_addr,
    input        [ 7:0] rom_data,

    // YM2151
    input        [ 7:0] db_din,
    output       [ 7:0] db_dout,

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

wire      sm_a, sm_b;
wire      ms_a, ms_b;

wire   [ 7:0] key_on, mode, loop_en;
wire   [ 7:0] ch_st;

// 4 channels for register of 8 bit
wire   [12:0] ch0_pith   = { ch_mmr[1][3:0], ch_mmr[0] };
wire   [15:0] ch0_length = { ch_mmr[3], ch_mmr[3] };
wire   [20:0] ch0_start  = { ch_mmr[6][4:0], ch_mmr[5], ch_mmr[4] };
wire   [12:0] ch0_volume = { ch_mmr[7][6:0]};
wire          ch0_run,
              ch0_act;
       assign ch0_key = key_on[0];

wire   [12:0] ch1_pith   = { ch_mmr[9][3:0], ch_mmr[8] };
wire   [15:0] ch1_length = { ch_mmr[11], ch_mmr[10] };
wire   [20:0] ch1_start  = { ch_mmr[14][4:0], ch_mmr[13], ch_mmr[12] };
wire   [12:0] ch1_volume = { ch_mmr[15][6:0]};
wire          ch0_run,
              ch0_act;
       assign ch1_key = key_on[1];

wire   [12:0] ch2_pith   = { ch_mmr[17][3:0], ch_mmr[16] };
wire   [15:0] ch2_length = { ch_mmr[19], ch_mmr[18] };
wire   [20:0] ch2_start  = { ch_mmr[22][4:0], ch_mmr[21], ch_mmr[20] };
wire   [12:0] ch2_volume = { ch_mmr[23][6:0]};
wire          ch2_run,
              ch2_act;
       assign ch2_key = key_on[2];

wire   [12:0] ch3_pith   = { ch_mmr[25][3:0], ch_mmr[24] };
wire   [15:0] ch3_length = { ch_mmr[27], ch_mmr[26] };
wire   [20:0] ch3_start  = { ch_mmr[30][4:0], ch_mmr[29], ch_mmr[28] };
wire   [12:0] ch3_volume = { ch_mmr[31][6:0]};
wire          ch3_run,
              ch3_act;
       assign ch3_key = key_on[3];


reg    [15:0] adpcm

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

// initial begin

//     adpcm[ 0] =  7'd0;
//     adpcm[ 1] =  7'd1;
//     adpcm[ 2] =  7'd2;
//     adpcm[ 3] =  7'd4;
//     adpcm[ 4] =  7'd8;
//     adpcm[ 5] =  7'd16;
//     adpcm[ 6] =  7'd32;
//     adpcm[ 7] =  7'd64;
//     adpcm[ 8] = -7'd128;
//     adpcm[ 9] = -7'd64;
//     adpcm[10] = -7'd32;
//     adpcm[11] = -7'd16;
//     adpcm[12] = -7'd8;
//     adpcm[13] = -7'd4;
//     adpcm[14] = -7'd2;
//     adpcm[15] = -7'd1;

// end



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



    end
end

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        rom_addr <= 0;
        ch0_start <= 0;
        ch1_start <= 0;
        ch2_start <= 0;
        ch3_start <= 0;
    end else begin
        if( ch0_start ) begin
            rom_addr[ ]<= ch0_start + cnt;
        end else begin
            rom_addr[ ] <= ch1_start + 1'd1;
            rom_addr[ ] <= ch2_start + 1'd1;
            rom_addr[ ] <= ch3_start + 1'd1;
        end
    end
end


endmodule