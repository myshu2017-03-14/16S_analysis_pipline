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
     Date: 2018-6-6
     Description: Plot alpha div boxplots
---------------------------------------------------------------
USAGE: $0 alpha_div_collated_dir map_file Class(in map file) output_dir map_file_for_R
    or $0 ‐h # show this message
EXAMPLE:
    $0 alpha_div_collated/ mapping_file.txt Type Alpha_out mapping_file_for_R.txt
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
alpha_div=$1
map=$2
t=$3
out=$4
map_for_R=$5
if [ ! -d "$out" ]; then
  mkdir $out
fi
pro=$(dirname $0)
for i in $alpha_div/*.txt
do
	name=$(basename $i .txt)
	# the input alpha diversity data is from collate_alpha.py or alpha_rarefaction.py
	for c in $t
	#Typed_by_PCoA	Subtyped_by_PCoA   Proposed_Class_braycurtis
	do
		# qiime
		compare_alpha_diversity.py -i $i -m $map -c $c -p fdr -o $out/$c\_$name
		# R
		Rscript $pro/R_alpha_div.r -i $map_for_R -t $c -a $i -c $out/$c\_$name/$c\_stats.txt -n $name -o $out

	done
done


