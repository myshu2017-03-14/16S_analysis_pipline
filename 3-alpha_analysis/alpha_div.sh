
#!/bin/bash
#!/usr/bin/env bash 
# echo the help if not input all the options
help()
{
cat <<HELP
---------------------------------------------------------------
     Author: Myshu                                            
     Mail: 1291016966@qq.com                                   
     Version: 1.0                                              
     Date: 2018-6-1
     Description: Plots alpha rarefaction plots
---------------------------------------------------------------
USAGE: $0 otu_table mapping_file tree_file output_dir even
    or $0 ‐h # show this message
EXAMPLE: otu_table_even_921.biom mapping_file.txt rep_set.tre alpha_plots_921_10 921
    $0 
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
otu_table=$1
map=$2
tree=$3
out=$4
even=$5

alpha_rarefaction.py -i $otu_table -m $map -t $tree -o $out -e $even -n 10 -f -p /analysis/software_han/software/Tools/myshu_scripts/16S_analysis/qiime_para_txt/para_alpha_div.txt
