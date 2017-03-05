library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture arch of alu_tb is
    -- test signals

    signal a          : std_logic_vector(31 downto 0);
    signal b          : std_logic_vector(31 downto 0);
    signal opcode     : std_logic_vector(5 downto 0);
    signal shamt      : std_logic_vector(4 downto 0);
    signal funct      : std_logic_vector(5 downto 0);
    signal alu_output : std_logic_vector(63 downto 0);

    component alu is
        port(a      : in  std_logic_vector(31 downto 0);
             b      : in  std_logic_vector(31 downto 0);
             opcode : in  std_logic_vector(5 downto 0);
             shamt  : in  std_logic_vector(4 downto 0);
             funct  : in  std_logic_vector(5 downto 0);
             output : out std_logic_vector(63 downto 0));
    end component alu;

    procedure assert_equal(actual, expected : in std_logic_vector(63 downto 0); error_count : inout integer) is
    begin
        if (actual /= expected) then
            error_count := error_count + 1;
        end if;
        assert (actual = expected) report "The data should be " & to_string(expected) & " but was " & to_string(actual) severity error;
    end assert_equal;

begin
    dut : alu
        port map(
            a      => a,
            b      => b,
            opcode => opcode,
            shamt  => shamt,
            funct  => funct,
            output => alu_output
        );

    test_process : process
        variable error_count : integer := 0;
    begin
        -------------- Arithmetic instructions---------------
        report "Testing arithmetic instructions";

        -----------------------------------------------------
        ---------------------Test#1-1: add---------------------
        --This test performs the add operation on the alu
        report "Test#1-1: add";
        a      <= std_logic_vector(to_signed(55, 32));
        b      <= std_logic_vector(to_signed(34, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"20";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(89, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#1-2: add---------------------
        --This test performs the add operation on the alu
        report "Test#1-2: add";
        a      <= std_logic_vector(to_signed(2147478597, 32));
        b      <= std_logic_vector(to_signed(5050, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"20";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(2147483647, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#1-3: add---------------------
        --This test performs the add operation on the alu
        report "Test#1-3: add";
        a      <= std_logic_vector(to_signed(2147478597, 32));
        b      <= std_logic_vector(to_signed(5051, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"20";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-2147483648, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#1-4: add---------------------
        --This test performs the add operation on the alu
        report "Test#1-4: add";
        a      <= std_logic_vector(to_signed(-2147478597, 32));
        b      <= std_logic_vector(to_signed(-5051, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"20";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-2147483648, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#1-5: add---------------------
        --This test performs the add operation on the alu
        report "Test#1-5: add";
        a      <= std_logic_vector(to_signed(-2147478597, 32));
        b      <= std_logic_vector(to_signed(-5052, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"20";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(2147483647, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#1-6: add---------------------
        --This test performs the add operation on the alu
        report "Test#1-6: add";
        a      <= std_logic_vector(to_signed(-806540, 32));
        b      <= std_logic_vector(to_signed(-5051, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"20";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-811591, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-1: sub---------------------
        --This test performs the sub operation on the alu
        report "Test#2-1: sub";
        a      <= std_logic_vector(to_signed(53435, 32));
        b      <= std_logic_vector(to_signed(334324, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"22";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-280889, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-2: sub---------------------
        --This test performs the sub operation on the alu
        report "Test#2-2: sub";
        a      <= std_logic_vector(to_signed(30, 32));
        b      <= std_logic_vector(to_signed(50, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"22";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-20, 32)), error_count);
        -----------------------------------------------------


        -----------------------------------------------------
        ---------------------Test#2-3: sub---------------------
        --This test performs the sub operation on the alu
        report "Test#2-3: sub";
        a      <= std_logic_vector(to_signed(2147478597, 32));
        b      <= std_logic_vector(to_signed(-5050, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"22";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(2147483647, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-4: sub---------------------
        --This test performs the sub operation on the alu
        report "Test#2-4: sub";
        a      <= std_logic_vector(to_signed(2147478597, 32));
        b      <= std_logic_vector(to_signed(-5051, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"22";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-2147483648, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-5: sub---------------------
        --This test performs the sub operation on the alu
        report "Test#2-5: sub";
        a      <= std_logic_vector(to_signed(-2147478597, 32));
        b      <= std_logic_vector(to_signed(5052, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"22";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(2147483647, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-6: sub---------------------
        --This test performs the sub operation on the alu
        report "Test#2-6: sub";
        a      <= std_logic_vector(to_signed(-2147478597, 32));
        b      <= std_logic_vector(to_signed(5051, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"22";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-2147483648, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#2-7: sub---------------------
        --This test performs the sub operation on the alu
        report "Test#2-7: sub";
        a      <= std_logic_vector(to_signed(-806540, 32));
        b      <= std_logic_vector(to_signed(5051, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"22";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-811591, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-1: addi---------------------
        --This test performs the addi operation on the alu
        report "Test#3-1: addi";
        a      <= std_logic_vector(to_signed(55, 32));
        b      <= std_logic_vector(to_signed(34, 32));
        opcode <= 6x"8";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(89, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-2: addi---------------------
        --This test performs the addi operation on the alu
        report "Test#3-2: addi";
        a      <= std_logic_vector(to_signed(2147478597, 32));
        b      <= std_logic_vector(to_signed(5050, 32));
        opcode <= 6x"8";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(2147483647, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-3: addi---------------------
        --This test performs the addi operation on the alu
        report "Test#3-3: addi";
        a      <= std_logic_vector(to_signed(2147478597, 32));
        b      <= std_logic_vector(to_signed(5051, 32));
        opcode <= 6x"8";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-2147483648, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-4: addi---------------------
        --This test performs the addi operation on the alu
        report "Test#3-4: addi";
        a      <= std_logic_vector(to_signed(-2147478597, 32));
        b      <= std_logic_vector(to_signed(-5051, 32));
        opcode <= 6x"8";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-2147483648, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-5: addi---------------------
        --This test performs the addi operation on the alu
        report "Test#3-5: addi";
        a      <= std_logic_vector(to_signed(-2147478597, 32));
        b      <= std_logic_vector(to_signed(-5052, 32));
        opcode <= 6x"8";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(2147483647, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#3-6: addi---------------------
        --This test performs the addi operation on the alu
        report "Test#3-4: addi";
        a      <= std_logic_vector(to_signed(-806540, 32));
        b      <= std_logic_vector(to_signed(-5051, 32));
        opcode <= 6x"8";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(32x"0" & to_signed(-811591, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-1: mult---------------------
        --This test performs the mult operation on the alu
        report "Test#4-1: mult";
        a      <= std_logic_vector(to_signed(-806540, 32));
        b      <= std_logic_vector(to_signed(454, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"18";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(-366169160, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-2: mult---------------------
        --This test performs the mult operation on the alu
        report "Test#4-2: mult";
        a      <= std_logic_vector(to_signed(806540, 32));
        b      <= std_logic_vector(to_signed(454, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"18";

        wait for 1 ns;

        assert_equal(alu_output, 32x"0" & std_logic_vector(to_signed(366169160, 32)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-3: mult---------------------
        --This test performs the mult operation on the alu
        report "Test#4-3: mult";
        a      <= std_logic_vector(to_signed(3976821, 32));
        b      <= std_logic_vector(to_signed(540, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"18";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(2147483340, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-4: mult---------------------
        --This test performs the mult operation on the alu
        report "Test#4-4: mult";
        a      <= std_logic_vector(to_signed(1073741823, 32));
        b      <= std_logic_vector(to_signed(2, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"18";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(2147483646, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#4-5: mult---------------------
        --This test performs the mult operation on the alu
        report "Test#4-5: mult";
        a      <= std_logic_vector(to_signed(1073741823, 32));
        b      <= std_logic_vector(to_signed(-2, 32));
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"18";

        wait for 1 ns;

        assert_equal(alu_output, std_logic_vector(to_signed(-2147483646, 64)), error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#5: div---------------------
        --This test performs the div operation on the alu
        report "Test#5: div";
        a      <= (others => '1');
        b      <= 32x"1";
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"1a";

        wait for 1 ns;

        assert_equal(alu_output, x"00000000FFFFFFFF", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#6: slt---------------------
        --This test performs the slt operation on the alu
        report "Test#6: slt";
        a      <= 32x"0";
        b      <= 32x"1";
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"2a";

        wait for 1 ns;

        assert_equal(alu_output, 64x"1", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#7: slti---------------------
        --This test performs the slti operation on the alu
        report "Test#7: slti";
        a      <= 32x"0";
        b      <= 32x"1";
        opcode <= 6x"a";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, 64x"1", error_count);
        -----------------------------------------------------

        ----------------- Logical instructions---------------
        report "Testing logical instructions";

        -----------------------------------------------------
        ---------------------Test#8: and---------------------
        --This test performs the and operation on the alu
        report "Test#8: and";
        a      <= (others => '1');
        b      <= 32x"1";
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"24";

        wait for 1 ns;

        assert_equal(alu_output, 64x"1", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#9: or---------------------
        --This test performs the or operation on the alu
        report "Test#9: or";
        a      <= (others => '1');
        b      <= 32x"1";
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"25";

        wait for 1 ns;

        assert_equal(alu_output, x"00000000FFFFFFFF", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#10: nor---------------------
        --This test performs the nor operation on the alu
        report "Test#10: nor";
        a      <= (others => '1');
        b      <= 32x"1";
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"27";

        wait for 1 ns;

        assert_equal(alu_output, 64x"0", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#11: xor---------------------
        --This test performs the xor operation on the alu
        report "Test#11: xor";
        a      <= (others => '1');
        b      <= 32x"0";
        opcode <= 6x"0";
        shamt  <= 5x"0";
        funct  <= 6x"26";

        wait for 1 ns;

        assert_equal(alu_output, x"00000000FFFFFFFF", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#12: andi---------------------
        --This test performs the andi operation on the alu
        report "Test#12: andi";
        a      <= (others => '1');
        b      <= 32x"0";
        opcode <= 6x"c";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, 64x"0", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#13: ori---------------------
        --This test performs the ori operation on the alu
        report "Test#13: ori";
        a      <= (others => '1');
        b      <= 32x"0";
        opcode <= 6x"d";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, x"00000000FFFFFFFF", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#14: xori---------------------
        --This test performs the xori operation on the alu
        report "Test#14: xori";
        a      <= (others => '1');
        b      <= 32x"0";
        opcode <= 6x"e";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, x"00000000FFFFFFFF", error_count);
        -----------------------------------------------------

        ----------------- Transfer instructions--------------
        report "Testing transfer instructions";

        -----------------------------------------------------
        ---------------------Test#15: lui---------------------
        --This test performs the lui operation on the alu
        report "Test#15: lui";
        b      <= 32x"1";
        opcode <= 6x"f";
        shamt  <= 5x"0";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, x"0000000000010000", error_count);
        -----------------------------------------------------

        ----------------- Shift instructions-----------------
        report "Testing shift instructions";

        -----------------------------------------------------
        ---------------------Test#16: sll---------------------
        --This test performs the sll operation on the alu
        report "Test#16: sll";
        b      <= 32x"4";
        opcode <= 6x"0";
        shamt  <= 5x"1";
        funct  <= 6x"0";

        wait for 1 ns;

        assert_equal(alu_output, 64x"8", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#17: srl---------------------
        --This test performs the srl operation on the alu
        report "Test#17: srl";
        b      <= 32x"4";
        opcode <= 6x"0";
        shamt  <= 5x"1";
        funct  <= 6x"2";

        wait for 1 ns;

        assert_equal(alu_output, 64x"2", error_count);
        -----------------------------------------------------

        -----------------------------------------------------
        ---------------------Test#18: sra---------------------
        --This test performs the sra operation on the alu
        report "Test#18: sra";
        b      <= 32x"4";
        opcode <= 6x"0";
        shamt  <= 5x"1";
        funct  <= 6x"3";

        wait for 1 ns;

        assert_equal(alu_output, 64x"2", error_count);
        -----------------------------------------------------

        ----------------- Memory instructions----------------
        report "Testing memory instructions";

        ----------------- Control-flow instructions----------------
        report "Testing control-flow instructions";

        report "Done. Found " & integer'image(error_count) & " error(s).";

        wait;
    end process;

end architecture arch;
