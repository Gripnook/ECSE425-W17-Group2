# MIPS Pipelined Processor

This project implements a MIPS processor using a basic 5-stage pipeline comprised of the IF (Instruction Fetch), ID (Instruction Decode), EX (Execute), MEM (Memory Access), and WB (Write Back) stages. The various components are described here.

## Pipeline Registers, Stalls and Flushes

The pipeline registers between each stage were equipped with an enable input and a synchronous, enabled reset. The PC register was also equipped with an enable input. This allows for a simple implementation of stalls and flushes. For example, a stall in ID is implemented by disabling the PC and IF/ID pipeline registers, and resetting the ID/EX pipeline register. This inserts a no-op into the EX stage in the next cycle and freezes the contents of IF and ID. When multiple stalls are required concurrently (for example when a data hazard is detected at the same time as a cache miss), this design gives priority to the later stall in the pipeline. It does so through the enabled reset input. If a pipeline register is disabled, asserting the enabled reset signal does nothing, preventing a stall in ID from wiping the instruction in EX when we are also stalling in MEM.

## Branch Resolution

Branch resolution is implemented in the ID stage. A simple predict not-taken architecture is used, where the next PC is fetched in IF even if a branch is resolving in ID. If we take the branch, the IF/ID register is flushed on the next clock cycle, preserving program integrity.

## Data Hazard Detection

Data hazard detection is implemented through the use of instruction decoding procedures. These procedures identify two inputs and one output for each instruction, assigning the register $0 to unused parameters. It also identifies the consumption stages for the inputs and the production stage for the output. Using this information, a simple combinational block then computes the number of cycles left until the inputs of the instruction in ID are consumed, and the number of cycles left until the outputs of the instructions in each of EX, MEM, and WB are produced. The inputs in ID are then compared to the outputs in EX, MEM, and WB, and a stall is generated if there is a match and the number of cycles left to consumption is less than the number of cycles left to production. The register $0 is ignored when checking for data hazards.

## Data Forwarding

Data forwarding is implemented through the use of the same instruction decoding procedures used by data hazard detection. The production stage of the instructions in EX, MEM, and WB is used to verify if the outputs are ready at the current time. These ready signals control a set of multiplexers in the ID, EX, and MEM stages. The inputs in these stages are compared to the outputs in each of the subsequent stages, and if the input matches the output and the output is ready then the multiplexer forwards the value. Priority is given to later instructions, as these may overwrite the values written by previous instructions. The register $0 is ignored when forwarding data.

The performance benefits of data forwarding can be seen in the following table:

| Benchmark  | Data Hazards (no forwarding) | Data Hazards (with forwarding) |
| ---------- | ---------------------------: | -----------------------------: |
| bitwise    |                           21 |                              0 |
| fib        |                           45 |                              4 |
| primes     |                          502 |                            163 |
| edge-cases |                            8 |                              0 |
| exp        |                           28 |                              7 |
| gcd        |                           72 |                             13 |
| sqrt       |                           60 |                              8 |

## Memory Accesses

Memory accesses occur on the falling edge of the clock in order to allow them to occur between pipeline stages. For data memory accesses, the waitrequest signal is used to stall the pipeline in the MEM stage until the access completes. For instruction memory accesses, the pipeline is stalled in the ID stage. The reason we are not stalling in IF is that branch hazards can occur at the same time as an instruction memory stall. If we were stalling in IF, the branch resolution would flush the IF/ID pipeline register and attempt to branch, but the IF stall would prevent the PC from being updated. Hence we would lose a branch. To prevent this, the ID stage is stalled as well.

The default memory implementation does not have cache misses. However, a constant in the memory implementation file can be set to enable random cache misses in order to simulate memory access stalls.

## Register File

The register file was designed to perform reads on the falling edge and writes on the rising edge. This was done to allow for reads between pipeline stages. In addition, the HI and LO registers were included in the EX stage, which prevents data hazards as MFHI/MFLO read from these registers in EX and MULT/DIV write to them in EX as well.

## Optimizations
Coming soon...
