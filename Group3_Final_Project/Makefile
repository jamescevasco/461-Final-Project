#====================================================================================================
# Description:                 MakeFile                       
# Version:                     1.10
#
# Rev History:  
#       <Author>        <Date>        <Hardware>     <Version>        <Description>
#     Dengxue Yan   01-19-2017 20:00      --            1.00             Create
#     Huifeng Zhu   09-08-2020 20:00      --            1.10 
#====================================================================================================
src = mac.v rom_8_128_freepdk45.v  tanh.v  processor_tb.v processor.v sram_8_64_freepdk45.v

vcs_flag = -full64 -PP +lint=all,noVCDE +v2k -timescale=1ns/10ps

all: simv

simv: $(src)
	vcs $(vcs_flag) $^

run: simv
	./simv +verbose=1

debug: $(src)
	vcs -lca -debug_access+all $^
	./simv -gui &

.PHONY: clean
clean : 
	rm -rf csrc
	rm -f simv
	rm -rf simv.daidir
	rm -f *.vcd
	rm -f ucli.key
