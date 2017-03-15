library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detector_tb is
end entity hazard_detector_tb;

architecture arch of hazard_detector_tb is
    -- test signals

    signal if_id  : std_logic_vector(31 downto 0);
    signal id_ex  : std_logic_vector(31 downto 0);
    signal ex_mem : std_logic_vector(31 downto 0);
    signal mem_wb : std_logic_vector(31 downto 0);
    signal stall  : std_logic;

    constant NOP         : std_logic_vector(31 downto 0) := 6x"0" & 5x"0" & 5x"0" & 5x"0" & 5x"0" & 6x"22"; --R-Type
    constant ADDR1R0R0   : std_logic_vector(31 downto 0) := 6x"0" & 5x"0" & 5x"0" & 5x"1" & 5x"0" & 6x"22"; --R-Type
    constant ADDR0R1R1   : std_logic_vector(31 downto 0) := 6x"0" & 5x"1" & 5x"1" & 5x"0" & 5x"0" & 6x"22"; --R-Type
    constant ADDR0R31R31 : std_logic_vector(31 downto 0) := 6x"0" & 5x"1f" & 5x"1f" & 5x"0" & 5x"0" & 6x"22"; --R-Type
    constant BEQR1R0L0   : std_logic_vector(31 downto 0) := 6x"4" & 5x"1" & 5x"0" & 16x"0"; -- I-Type
    constant JL0         : std_logic_vector(31 downto 0) := 6x"2" & 26x"0"; -- J-Type
    constant JAL0        : std_logic_vector(31 downto 0) := 6x"3" & 26x"0"; -- J-Type
    constant LWR1        : std_logic_vector(31 downto 0) := 6x"23" & 5x"0" & 5x"1" & 16x"4";
    constant SWR1        : std_logic_vector(31 downto 0) := 6x"2B" & 5x"0" & 5x"1" & 16x"4";

    component hazard_detector
        port(
            id_instruction  : in  std_logic_vector(31 downto 0);
            ex_instruction  : in  std_logic_vector(31 downto 0);
            mem_instruction : in  std_logic_vector(31 downto 0);
            wb_instruction : in  std_logic_vector(31 downto 0);
            stall  : out std_logic);
    end component hazard_detector;

    procedure assert_equal(actual, expected : in std_logic_vector(63 downto 0); error_count : inout integer) is
    begin
        if (actual /= expected) then
            error_count := error_count + 1;
        end if;
        assert (actual = expected) report "The data should be " & to_string(expected) & " but was " & to_string(actual) severity error;
    end assert_equal;

    procedure assert_equal_bit(actual, expected : in std_logic; error_count : inout integer) is
    begin
        if (actual /= expected) then
            error_count := error_count + 1;
        end if;
        assert (actual = expected) report "The data should be " & to_string(expected) & " but was " & to_string(actual) severity error;
    end assert_equal_bit;

begin
    dut : hazard_detector
        port map(
            id_instruction  => if_id,
            ex_instruction  => id_ex,
            mem_instruction => ex_mem,
            wb_instruction => mem_wb,
            stall  => stall
        );

    test_process : process
        variable error_count : integer := 0;
    begin
        -------------- Data hazards ---------------
        report "Testing data hazards";

        -----------------------------------------------------
        ---------------------Test#1: NOP---------------------
        report "Test#1: NOP";
        if_id  <= NOP;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-1: ALU/ALU---------------------
        report "Test#2-1: ALU/ALU";
        if_id  <= ADDR0R1R1;
        id_ex  <= ADDR1R0R0;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-2: ALU/ALU---------------------
        report "Test#2-2: ALU/ALU";
        if_id  <= ADDR0R1R1;
        id_ex  <= NOP;
        ex_mem <= ADDR1R0R0;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-3: ALU/ALU---------------------
        report "Test#2-3: ALU/ALU";
        if_id  <= ADDR0R1R1;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= ADDR1R0R0;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -------------- Control hazards ---------------
        report "Testing control hazards";

        -----------------------------------------------------
        ---------------------Test#3-1: BEQ---------------------
        report "Test#3-1: BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-2: BEQ/ALU---------------------
        report "Test#3-2: BEQ/ALU";
        if_id  <= ADDR1R0R0;
        id_ex  <= BEQR1R0L0;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-3: BEQ/ALU---------------------
        --This test performs BEQ
        report "Test#3-3: BEQ/ALU";
        if_id  <= ADDR0R1R1;
        id_ex  <= BEQR1R0L0;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-4: BEQ---------------------
        report "Test#3-4: ALU/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= ADDR1R0R0;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '1', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-5: ALU/BEQ---------------------
        report "Test#3-5: ALU/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= NOP;
        ex_mem <= ADDR1R0R0;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-6: ALU/BEQ---------------
        report "Test#3-6: ALU/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= ADDR1R0R0;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-1: JAL/ALU---------------
        report "Test#4-1: JAL/ALU";
        if_id  <= ADDR0R31R31;
        id_ex  <= JAL0;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-2: JAL/ALU-------------------
        report "Test#4-2: JAL/ALU";
        if_id  <= ADDR0R31R31;
        id_ex  <= NOP;
        ex_mem <= JAL0;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-3: JAL/ALU--------------------
        report "Test#4-3: JAL/ALU";
        if_id  <= ADDR0R31R31;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= JAL0;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-4: JAL/BEQ---------------------
        report "Test#4-4: JAL/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= JAL0;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-5: JAL/BEQ---------------------
        report "Test#4-5: JAL/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= NOP;
        ex_mem <= JAL0;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-6: JAL/BEQ---------------------
        report "Test#4-6: JAL/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= JAL0;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-1: LW/ALU---------------------
        report "Test#5-1: LW/ALU";
        if_id  <= ADDR1R0R0;
        id_ex  <= LWR1;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-2: LW/ALU---------------------
        report "Test#5-2: LW/ALU";
        if_id  <= ADDR1R0R0;
        id_ex  <= NOP;
        ex_mem <= LWR1;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-3: LW/ALU---------------------
        report "Test#5-3: LW/ALU";
        if_id  <= ADDR1R0R0;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= LWR1;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-4: LW---------------------
        report "Test#5-4: LW";
        if_id  <= LWR1;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-5: LW/SW---------------------
        report "Test#5-5: LW/SW";
        if_id  <= LWR1;
        id_ex  <= SWR1;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-6: LW/SW---------------------
        report "Test#5-6: LW/SW";
        if_id  <= LWR1;
        id_ex  <= NOP;
        ex_mem <= SWR1;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-7: LW/SW---------------------
        report "Test#5-7: LW/SW";
        if_id  <= LWR1;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= SWR1;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ------------------Test#5-8: LW/BEQ-------------------
        report "Test#5-8: LW/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= LWR1;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '1', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ----------------Test#5-9: LW/BEQ---------------------
        report "Test#5-9: LW/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= NOP;
        ex_mem <= LWR1;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '1', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ----------------Test#5-10: LW/BEQ--------------------
        report "Test#5-10: LW/BEQ";
        if_id  <= BEQR1R0L0;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= LWR1;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-11: SW-------------------
        report "Test#5-11: SW";
        if_id  <= SWR1;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5-12: SW/LW-----------------
        report "Test#5-12: SW/LW";
        if_id  <= SWR1;
        id_ex  <= LWR1;
        ex_mem <= NOP;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ------------------Test#5-13: SW/LW-------------------
        report "Test#5-13: SW/LW";
        if_id  <= SWR1;
        id_ex  <= NOP;
        ex_mem <= LWR1;
        mem_wb <= NOP;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        --------------------Test#5-14: SW/LW-----------------
        report "Test#5-14: SW/LW";
        if_id  <= SWR1;
        id_ex  <= NOP;
        ex_mem <= NOP;
        mem_wb <= LWR1;

        wait for 1 ns;

        assert_equal_bit(stall, '0', error_count);
        -----------------------------------------------------

        report "Done. Found " & integer'image(error_count) & " error(s).";

        wait;
    end process;

end architecture arch;
