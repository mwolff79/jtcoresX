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
    Date: 19-3-2023 */

module jtngp_main(
    input             rst,
    input             clk,
);

reg  [15:0] din;
wire [23:0] addr;
wire [15:0] dout;
wire [ 1:0] we;
wire [ 2:0] intrq;

jt900h u_cpu(
    .rst        ( rst       ),
    .clk        ( clk       ),
    input             cen,

    .addr       ( addr      ),
    .din        ( din       ),
    .dout       ( dout      ),
    .we         ( we        ),

    .intrq      ( intrq     ),     // interrupt request
    // Register dump
    .dmp_addr   (           ),     // dump
    .dmp_dout   (           )
    `ifdef SIMULATION
    .sim_xix    (           ),
    .sim_xiy    (           ),
    .sim_xiz    (           ),
    .sim_xsp    (           )
    `endif
);

endmodule