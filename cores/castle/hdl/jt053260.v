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
    output       [ 7:0] rom_dout,
    input        [ 7:0] rom_din,

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


// 4 channels for register of 8 bit
// reg    [7:0] ch0,
//        [7:0] ch1,
//        [7:0] ch2,
//        [7:0] ch3;
// reg          acc_adpcm;

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

wire    data;
reg     pan,
        loop,
        start,
        pitch,
        key_on,
        length,
        volume;

always @(posedge clk, posedge rst) begin
    if(rst) begin
        pan    <= 0;
        loop   <= 0;
        start  <= 0;
        pitch  <= 0;
        length <= 0;
        volume <= 0;
    end else begin

    end
end

always @* begin
    case (offset)
        2'd0: pitch <= {pitch[], data[]};
        2'd1: pitch <= {data[], pitch[]};
        2'd2: length <= {length[], data[]};
        2'd3: length <= {data[], length[]};
        2'd4: start <= {start[], data[]};
        2'd5: start <= {start[], data[], start[]};
        2'd6: start <= {data[], start[]};
        2'd7: volume <= data[];
        default:;
    endcase


    case (offset)
        2'h28: key_on[3:0] <= data;
        2'h29: ;
        2'h2A: loop[3:0] <= data;
        2'h2B: ;
        2'h2C: ;
        2'h2D: ;
        2'h2E: ;
        2'h2F: ;
        default:;
    endcase

end


endmodule