library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_encoding.all;

entity processor is
    port(clock : in std_logic;
         reset : in std_logic);
end processor;

architecture arch of processor is

    -- components

    component memory is
        generic(
            ram_size     : integer := 32768
        );
        port(
            clock       : in  std_logic;
            writedata   : in  std_logic_vector(31 downto 0) := (others => '0');
            address     : in  integer range 0 to ram_size - 1;
            memwrite    : in  std_logic := '0';
            memread     : in  std_logic;
            readdata    : out std_logic_vector(31 downto 0);
            waitrequest : out std_logic
        );
    end component;

    component registers
      port (clock         : in  std_logic;
            regWrite      : in  std_logic;
            rs_adr        : in  std_logic_vector(4 downto 0);
            rt_adr        : in  std_logic_vector(4 downto 0);
            instruction   : in  std_logic_vector(31 downto 0);
            wb_data       : in  std_logic_vector(31 downto 0);
            id_rs         : out std_logic_vector(31 downto 0);
            id_rt         : out std_logic_vector(31 downto 0)
            );
    end component registers;

    component alu
        port(
            a      : in  std_logic_vector(31 downto 0);
            b      : in  std_logic_vector(31 downto 0);
            opcode : in  std_logic_vector(5 downto 0);
            shamt  : in  std_logic_vector(4 downto 0);
            funct  : in  std_logic_vector(5 downto 0);
            output : out std_logic_vector(63 downto 0));
    end component alu;

    -- pc
    signal pc        : std_logic_vector(31 downto 0);
    signal pc_enable : std_logic;

    -- if
    signal if_instruction : std_logic_vector(31 downto 0);
    signal if_npc         : std_logic_vector(31 downto 0);
    signal if_address     : integer;
    signal if_read_en     : std_logic;
    signal if_waitrequest : std_logic;

    -- if/id
    signal if_id_reset, if_id_enable : std_logic;

    -- id
    signal id_instruction   : std_logic_vector(31 downto 0);
    signal id_opcode        : std_logic_vector(5 downto 0);
    signal id_funct         : std_logic_vector(5 downto 0);
    signal id_target        : std_logic_vector(25 downto 0);
    signal id_npc           : std_logic_vector(31 downto 0);
    signal id_rs            : std_logic_vector(31 downto 0);
    signal id_rt            : std_logic_vector(31 downto 0);
    signal id_immediate     : std_logic_vector(31 downto 0);
    signal id_branch_taken  : std_logic;
    signal id_branch_target : std_logic_vector(31 downto 0);

    -- id/ex
    signal id_ex_reset, id_ex_enable : std_logic;

    -- ex
    signal ex_instruction : std_logic_vector(31 downto 0);
    signal ex_opcode      : std_logic_vector(5 downto 0);
    signal ex_funct       : std_logic_vector(5 downto 0);
    signal ex_shamt       : std_logic_vector(4 downto 0);
    signal ex_rs          : std_logic_vector(31 downto 0);
    signal ex_rt          : std_logic_vector(31 downto 0);
    signal ex_immediate   : std_logic_vector(31 downto 0);
    signal ex_alu_result  : std_logic_vector(63 downto 0); -- 64 bit for mult and div results
    signal ex_a, ex_b     : std_logic_vector(31 downto 0);
    signal ex_output      : std_logic_vector(31 downto 0); 

    signal hi, lo : std_logic_vector(31 downto 0);

    -- ex/mem
    signal ex_mem_reset, ex_mem_enable : std_logic;

    -- mem
    signal mem_instruction : std_logic_vector(31 downto 0);
    signal mem_rt          : std_logic_vector(31 downto 0);
    signal mem_alu_result  : std_logic_vector(31 downto 0);
    signal mem_memory_load : std_logic_vector(31 downto 0);

    -- mem/wb
    signal mem_wb_reset, mem_wb_enable : std_logic;

    -- wb
    signal wb_instruction : std_logic_vector(31 downto 0);
    signal wb_alu_result  : std_logic_vector(31 downto 0);
    signal wb_memory_load : std_logic_vector(31 downto 0);
    signal wb_data        : std_logic_vector(31 downto 0);
    signal wb_regWrite    : std_logic;

begin

    -- pc

    pc_register : process(clock, reset)
    begin
        if (reset = '1') then
            pc <= (others => '0');
        elsif (rising_edge(clock)) then
            if (pc_enable = '1') then
                pc <= if_npc;
            end if;
        end if;
    end process;

    -- if

    instruction_cache : memory
    generic map(ram_size => 1024)
    port map(clock => clock,
             address => if_address,
             memread => if_read_en,
             readdata => if_instruction,
             waitrequest => if_waitrequest);
    if_address <= to_integer(unsigned(pc));

    with id_branch_taken select if_npc <=
        std_logic_vector(unsigned(pc) + 4) when '0', -- predict taken
        id_branch_target when others;

    -- if/id

    if_id_pipeline_register : process(clock, reset)
    begin
        if (reset = '1') then
            id_instruction <= (others => '0');
            id_npc         <= (others => '0');
        elsif (rising_edge(clock)) then
            if (if_id_enable = '1') then
                if (if_id_reset = '1') then
                    id_instruction <= (others => '0');
                    id_npc         <= (others => '0');
                else
                    id_instruction <= if_instruction;
                    id_npc         <= if_npc;
                end if;
            end if;
        end if;
    end process;

    -- id

    id_opcode <= id_instruction(31 downto 26);
    id_funct <= id_instruction(5 downto 0);
    id_target <= id_instruction(25 downto 0);

    registers1 : registers port map(  clock => clock,
                                      regWrite => wb_regWrite,
                                      rs_adr => id_instruction(25 downto 21),
                                      rt_adr => id_instruction(20 downto 16),
                                      instruction => wb_instruction,
                                      wb_data => wb_data,
                                      id_rs => id_rs,
                                      id_rt => id_rt);

    id_immediate <= std_logic_vector(resize(signed(id_instruction(15 downto 0)), 32)); --sign extend

    branch_resolution : process(id_opcode, id_funct, id_target, id_npc, id_rs, id_rt, id_immediate)
    begin
        id_branch_taken <= '0';
        id_branch_target <= (others => '0');
        case id_opcode is
            when OP_R_TYPE =>
                if (id_funct = FUNCT_JR) then
                    id_branch_taken <= '1';
                    id_branch_target <= id_rs;
                end if;
            when OP_J =>
                id_branch_taken <= '1';
                id_branch_target <= id_npc(31 downto 28) & id_target & "00";
            when OP_JAL =>
                id_branch_taken <= '1';
                id_branch_target <= id_npc(31 downto 28) & id_target & "00";
            when OP_BEQ =>
                if (id_rs = id_rt) then
                    id_branch_taken <= '1';
                    id_branch_target <= std_logic_vector(signed(id_npc) + signed(id_immediate));
                end if;
            when OP_BNE =>
                if (id_rs /= id_rt) then
                    id_branch_taken <= '1';
                    id_branch_target <= std_logic_vector(signed(id_npc) + signed(id_immediate));
                end if;
            when others =>
                null;
        end case;
    end process;

    -- id/ex

    id_ex_pipeline_register : process(clock, reset)
    begin
        if (reset = '1') then
            ex_instruction <= (others => '0');
            ex_rs          <= (others => '0');
            ex_rt          <= (others => '0');
            ex_immediate   <= (others => '0');
        elsif (rising_edge(clock)) then
            if (id_ex_enable = '1') then
                if (id_ex_reset = '1') then
                    ex_instruction <= (others => '0');
                    ex_rs          <= (others => '0');
                    ex_rt          <= (others => '0');
                    ex_immediate   <= (others => '0');
                else
                    ex_instruction <= id_instruction;
                    ex_rs          <= id_rs;
                    ex_rt          <= id_rt;
                    ex_immediate   <= id_immediate;
                end if;
            end if;
        end if;
    end process;
    
    --ex

    ex_opcode <= ex_instruction(31 downto 26);
    ex_funct  <= ex_instruction(5 downto 0);
    ex_shamt  <= ex_instruction(10 downto 6);

    alu_input_1 : process(ex_rs)
    begin
        ex_a <= ex_rs;
    end process;
    alu_input_2 : process(ex_opcode, ex_rt, ex_immediate)
    begin
    	case ex_opcode is
    		when OP_R_TYPE =>
                ex_b <= ex_rt;
    		when others =>
                ex_b <= ex_immediate;
    	end case;
    end process;

    ex_alu : alu
    port map(a => ex_a,
             b => ex_b,
             opcode => ex_opcode,
             shamt => ex_shamt,
             funct => ex_funct,
             output => ex_alu_result);
    
    hi_lo_registers : process(clock, reset)
    begin
        if (reset = '1') then
            hi <= (others => '0');
            lo <= (others => '0');
        elsif (rising_edge(clock)) then
            if (ex_opcode = OP_R_TYPE) then
                if ((ex_funct = FUNCT_MULT) or (ex_funct = FUNCT_DIV)) then
                    hi <= ex_alu_result(63 downto 32);
                    lo <= ex_alu_result(31 downto 0);
                end if;
            end if;
        end if;
    end process;

    ex_output_mux : process(ex_opcode, ex_funct, ex_alu_result, hi, lo)
    begin
        ex_output <= ex_alu_result(31 downto 0);
        if (ex_opcode = OP_R_TYPE) then
            if (ex_funct = FUNCT_MFHI) then
                ex_output <= hi;
            elsif (ex_funct = FUNCT_MFLO) then
                ex_output <= lo;
            end if;
        end if;
    end process;

    -- ex/mem

    ex_mem_pipeline_register : process(clock, reset)
    begin
        if (reset = '1') then
            mem_instruction <= (others => '0');
            mem_rt          <= (others => '0');
            mem_alu_result  <= (others => '0');
        elsif (rising_edge(clock)) then
            if (ex_mem_enable = '1') then
                if (ex_mem_reset = '1') then
                    mem_instruction <= (others => '0');
                    mem_rt          <= (others => '0');
                    mem_alu_result  <= (others => '0');
                else
                    mem_instruction <= ex_instruction;
                    mem_rt          <= ex_rt;
                    mem_alu_result  <= ex_output;
                end if;
            end if;
        end if;
    end process;

    -- mem


    -- mem/wb

    mem_wb_pipeline_register : process(clock, reset)
    begin
        if (reset = '1') then
            wb_instruction <= (others => '0');
            wb_alu_result  <= (others => '0');
            wb_memory_load <= (others => '0');
        elsif (rising_edge(clock)) then
            if (mem_wb_enable = '1') then
                if (mem_wb_reset = '1') then
                    wb_instruction <= (others => '0');
                    wb_alu_result  <= (others => '0');
                    wb_memory_load <= (others => '0');
                else
                    wb_instruction <= mem_instruction;
                    wb_alu_result  <= mem_alu_result;
                    wb_memory_load <= mem_memory_load;
                end if;
            end if;
        end if;
    end process;

    -- wb

    -- stalls and flushes

    pc_enable     <= not if_waitrequest;
    if_id_enable  <= not if_waitrequest;
    if_id_reset   <= id_branch_taken;
    id_ex_enable  <= '1';
    id_ex_reset   <= if_waitrequest;
    ex_mem_enable <= '1';
    ex_mem_reset  <= '0';
    mem_wb_enable <= '1';
    mem_wb_reset  <= '0';

end architecture;
