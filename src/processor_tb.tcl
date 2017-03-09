proc AddWaves {} {
    ;#Add waves we're interested in to the Wave window
    add wave -position end sim:/processor_tb/clock
    add wave -position end sim:/processor_tb/reset
    add wave -position end sim:/processor_tb/dut/pc
    add wave -position end sim:/processor_tb/dut/if_npc
    add wave -position end sim:/processor_tb/dut/id_opcode
    add wave -position end sim:/processor_tb/dut/id_funct
    add wave -position end sim:/processor_tb/dut/id_target
    add wave -position end sim:/processor_tb/dut/id_rs_addr
    add wave -position end sim:/processor_tb/dut/id_rt_addr
    add wave -position end sim:/processor_tb/dut/id_immediate
    add wave -position end sim:/processor_tb/dut/id_branch_taken
    add wave -position end sim:/processor_tb/dut/id_branch_target
    # Performance counters
    add wave -position end -radix 10 sim:/processor_tb/dut/memory_access_stall_count
    add wave -position end -radix 10 sim:/processor_tb/dut/data_hazard_stall_count
    add wave -position end -radix 10 sim:/processor_tb/dut/branch_hazard_stall_count
}

vlib work

;# Compile components
vcom -2008 MIPS_encoding.vhd
vcom -2008 memory.vhd
vcom -2008 registers.vhd
vcom -2008 alu.vhd
vcom -2008 hazard_detector.vhd
vcom -2008 processor.vhd
vcom -2008 processor_tb.vhd

;# Start simulation
vsim -t ps processor_tb

;# Load program.txt into the instruction memory
mem load -infile program.txt -format bin -filldata 0 /processor_tb/dut/instruction_cache/ram_block

;# Initialize data memory with zeros
mem load -filldata 0 /processor_tb/dut/data_cache/ram_block

;# Generate a clock with 1 ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run
run 1024.5ns

;# Save the memory and register file to files
mem save -outfile memory.txt -format bin -wordsperline 1 -noaddress /processor_tb/dut/data_cache/ram_block
mem save -outfile register_file.txt -format bin -wordsperline 1 -noaddress /processor_tb/dut/register_file/registers
