all: vcs1 vcs2 vcs3

vcs1: 
	vcs -R -full64 -debug_access+all -sverilog tb.v  huffman.v tsmc13_neg.v +define+FSDB+tb1
vcs2: 
	vcs -R -full64 -debug_access+all -sverilog tb.v  huffman.v tsmc13_neg.v +define+FSDB+tb2
vcs3: 
	vcs -R -full64 -debug_access+all -sverilog tb.v  huffman.v tsmc13_neg.v +define+FSDB+tb3
syn1:
	vcs -R -full64 -debug_access+all -sverilog tb.v  huffman_syn.v tsmc13_neg.v +define+SDF+FSDB+tb1
syn2:
	vcs -R -full64 -debug_access+all -sverilog tb.v  huffman_syn.v tsmc13_neg.v +define+SDF+FSDB+tb2
syn3:
	vcs -R -full64 -debug_access+all -sverilog tb.v  huffman_syn.v tsmc13_neg.v +define+SDF+FSDB+tb3
my_vcs1:
	vcs -R -full64 -debug_access+all -sverilog my_tb.v huffman.v tsmc13_neg.v +define+FSDB+tb1
my_vcs2:
	vcs -R -full64 -debug_access+all -sverilog my_tb.v huffman.v tsmc13_neg.v +define+FSDB+tb2
my_vcs3:
	vcs -R -full64 -debug_access+all -sverilog my_tb.v huffman.v tsmc13_neg.v +define+FSDB+tb3
my_syn1:
	vcs -R -full64 -debug_access+all -sverilog my_tb.v huffman_syn.v tsmc13_neg.v +define+SDF+FSDB+tb1
my_syn2:
	vcs -R -full64 -debug_access+all -sverilog my_tb.v huffman_syn.v tsmc13_neg.v +define+SDF+FSDB+tb2
my_syn3:
	vcs -R -full64 -debug_access+all -sverilog my_tb.v huffman_syn.v tsmc13_neg.v +define+SDF+FSDB+tb3

wave:
	nWave &

clean:
	rm -f *.fsdb