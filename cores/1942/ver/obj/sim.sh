#!/bin/bash
iverilog test.v $MODULES/jtgng_timer.v $JTFRAME/hdl/clocking/jtframe_cen48.v \
    $CORES/1942/hdl/jt1942_objtiming.v \
    -s test -o sim -DSIMULATION && sim -lxt
rm -f sim