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
     Date: 2018-6-4
     Description: plot bar plots for different class for cat taxa table by myshu
---------------------------------------------------------------
USAGE: $0 cat_taxa_abundance_table_prefix map_file top_n_taxa type[can be large then one] output_dir
    or $0 ‐h # show this message
EXAMPLE:
    $0 cat_taxa_abundance.16S mapping_file_for_R.txt 30 Type output
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
cat_prefix=$1
map=$2
top_n_taxa=$3
all_type=$4
out=$5
if [ ! -d "$out" ]; then
  mkdir $out
fi
pro=$(dirname $0)
for i in 1 2 3 4 5 6 7
do 
	for t in $all_type
	do
		Rscript $pro/taxa_bar_plot_for_myshu_cat_out.r -i $cat_prefix.level$i.out -m $map -t $top_n_taxa -c $t -n "level $i" -o $out/level$i\_$t\_bar_plot.pdf -x 6
	done

done
