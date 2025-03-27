#RTL simulation

root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
apr_dir := ./apr
sim_dir := ./sim
bld_dir := ./build
lib_dir := 

ifeq ($(FSDB), 1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB), 2)
FSDB_DEF := +FSDB_ALL
endif

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

$(apr_dir):
	mkdir -p $(apr_dir)

bulid : cd $(bld_dir);

TA_run: TA_rtl0 TA_rtl1 TA_rtl2 TA_rtl3 TA_rtl4

TA_rtl0:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog -full64 -debug_acc+all -debug_region+cell+encrypt -P \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/verdi.tab \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/pli.a \
	-LDFLAGS -rdynamic \
	+v2k $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data0;
	@$(bld_dir)/simv

TA_rtl1:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog -full64 -debug_acc+all -debug_region+cell+encrypt -P \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/verdi.tab \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/pli.a \
	-LDFLAGS -rdynamic \
	+v2k $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data1;
	@$(bld_dir)/simv

TA_rtl2:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog -full64 -debug_acc+all -debug_region+cell+encrypt -P \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/verdi.tab \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/pli.a \
	-LDFLAGS -rdynamic \
	+v2k $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data2;
	@$(bld_dir)/simv

TA_rtl3:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog -full64 -debug_acc+all -debug_region+cell+encrypt -P \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/verdi.tab \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/pli.a \
	-LDFLAGS -rdynamic \
	+v2k $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data3;
	@$(bld_dir)/simv

TA_rtl4:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog -full64 -debug_acc+all -debug_region+cell+encrypt -P \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/verdi.tab \
	/CAD_tool/SOC_ONECAD/Synopsys/Verdi/2020.03/share/PLI/VCS/LINUX64/pli.a \
	-LDFLAGS -rdynamic \
	+v2k $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data4;
	@$(bld_dir)/simv

rtl_all: rtl0 rtl1 rtl2 rtl3 rtl4

rtl0:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data0;
	@$(bld_dir)/simv

rtl1:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data1;
	@$(bld_dir)/simv


rtl2:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data2;
	@$(bld_dir)/simv

rtl3:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data3;
	@$(bld_dir)/simv

rtl4:
	@mkdir -p $(bld_dir); \
	cd $(bld_dir); \
	vcs -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -debug_region+cell \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF)+data4;
	@$(bld_dir)/simv

nWave:
	cd $(bld_dir); \
	nWave top.fsdb &

# Check file structure
BLUE=\033[1;34m
RED=\033[1;31m
NORMAL=\033[0m

check: clean
	@if [ -f StudentID ]; then \
		STUDENTID=$$(grep -v '^$$' StudentID); \
		if [ -z "$$STUDENTID" ]; then \
			echo -e "$(RED)Student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID_LEN=$$(expr length $$STUDENTID); \
			if [ $$ID_LEN -eq 9 ]; then \
				if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	else \
		echo -e "$(RED)StudentID file is not found$(NORMAL)"; \
		exit 1; \
	fi; \
	if [ $$(basename $(PWD)) != $$STUDENTID ]; then \
		echo -e "$(RED)Main folder name should be \"$$STUDENTID\"$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Main folder name pass$(NORMAL)"; \
	fi

tar: check
	STUDENTID=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$STUDENTID.tar $$STUDENTID

clean:
	rm -rf $(bld_dir);