create_project -in_memory -part xc7a35tcsg324-1

add_files -fileset sim_1 {
    dv/logger_pkg.sv
    dv/alu_pkg.sv
    dv/alu_if.sv
    dv/alu_driver_pkg.sv
    dv/alu_monitor_pkg.sv
    dv/alu_scoreboard_pkg.sv
    rtl/alu.sv
    dv/tb_top.sv
}

set_property include_dirs {rtl dv} [get_filesets sim_1]

set_property top tb_top [get_filesets sim_1]

update_compile_order -fileset sim_1
launch_simulation -simset sim_1

add_wave /tb_top/vif/clk
add_wave /tb_top/vif/opcode
add_wave -radix hex /tb_top/vif/a
add_wave -radix hex /tb_top/vif/b
add_wave -radix hex /tb_top/vif/result
add_wave /tb_top/vif/zero
add_wave /tb_top/vif/carry
add_wave /tb_top/vif/overflow

run all