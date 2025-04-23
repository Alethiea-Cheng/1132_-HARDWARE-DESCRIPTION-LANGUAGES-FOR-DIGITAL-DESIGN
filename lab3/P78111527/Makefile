root_dir := $(PWD)
wv_dir := waveform
sim_dir := sim
src_dir := src
FSDB_DEF :=
ifeq ($(WV),1)
FSDB_DEF := +FSDB
else ifeq ($(WV),2)
FSDB_DEF := +FSDB_ALL
endif

$(wv_dir):
	@mkdir -p $(wv_dir)

vcs: | $(wv_dir)
	@cd $(wv_dir); \
	vcs -R -sverilog $(PWD)/$(sim_dir)/lab3_tb.sv -debug_access+all -full64 -debug_region+cell +memcbk \
	+incdir+$(root_dir)/$(src_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

wave:
	@cd $(wv_dir); \
	nWave &

clean:
	@rm -rf $(wv_dir)


RED=\033[1;31m
BLUE=\033[1;34m


tar: clean
	@read -p "Please enter your student ID: " STUDENTID; \
	if [ "$$(basename $$PWD)" = "$$STUDENTID" ]; then \
		ID_LEN=$$(expr length $$STUDENTID); \
		if [ $$ID_LEN -eq 9 ]; then \
			if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					if [ $$(ls -1 *.docx 2>/dev/null | wc -l) -eq 0 ]; then \
						echo -e "$(RED)Report file is not found$(NORMAL)"; \
						exit 1; \
					elif [ $$(ls -1 *.docx 2>/dev/null | wc -l) -gt 1 ]; then \
						echo -e "$(RED)More than one docx file is found, please delete redundant file(s)$(NORMAL)"; \
						exit 1; \
					elif [ ! -f $${STUDENTID}.docx ]; then \
						echo -e "$(RED)Report file name should be $$STUDENTID.docx$(NORMAL)"; \
						exit 1; \
					else \
						echo -e "$(BLUE)Start compressing your folder...$(NORMAL)"; \
						cd ..; \
						tar -cvf $$STUDENTID.tar $$STUDENTID; \
					fi; \
			else \
				echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
				exit 1; \
			fi \
		else \
			echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
			exit 1; \
		fi \
	else \
		echo -e "$(RED)Your student ID and folder name do not match.$(NORMAL)"; \
		exit 1; \
	fi; \