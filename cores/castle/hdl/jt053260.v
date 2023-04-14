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

    input               cs,
    input        [20:0] addr,
    input        [ 7:0] din,

    output              s0,
    output              sy,
    output              sh1,
    output              sh2,
    output       [ 7:0] dout

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

endmodule