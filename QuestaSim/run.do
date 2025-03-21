vlib work
vlog reg.v DSP.v DSP_tb.v
vsim -voptargs=+acc work.DSP48A1_TB
add wave *
run -all
#quit -sim
