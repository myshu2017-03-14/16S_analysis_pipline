
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
USAGE: $0 otu_table mapping_file output_dir even tree_file
    or $0 ‐h # show this message
EXAMPLE: otu_table_even_921.biom mapping_file.txt alpha_plots_921_10 921 rep_set.tre
    $0 
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
otu_table=$1
map=$2
out=$3
even=$4
tree=$5
echo $tree
if [ x$5 = x  ] ;then
	alpha_rarefaction.py -i $otu_table -m $map -o $out -e $even -n 10 -f -p /analysis/software_han/software/Tools/myshu_scripts/16S_analysis/qiime_para_txt/para_alpha_div_notree.txt

else
	alpha_rarefaction.py -i $otu_table -m $map -t $tree -o $out -e $even -n 10 -f -p /analysis/software_han/software/Tools/myshu_scripts/16S_analysis/qiime_para_txt/para_alpha_div.txt

fi
