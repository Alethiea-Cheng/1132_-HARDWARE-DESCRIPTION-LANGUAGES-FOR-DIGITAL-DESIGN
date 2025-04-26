##################################
#     Set Up Design Compiler     #
##################################
source .synopsys_dc.setup

#######################
#     Read Design     #
#######################
read_file huffman.v

#######################
# source sdc 
#######################
source huffman.sdc

###################
#     Compile     #
###################
compile
#compile_ultra
#########################
#     Output            #
#########################
write -format verilog -hierarchy -output huffman_syn.v
write -format ddc -hierarchy -output huffman_syn.ddc
write_sdf -version 2.1 huffman_syn.sdf
