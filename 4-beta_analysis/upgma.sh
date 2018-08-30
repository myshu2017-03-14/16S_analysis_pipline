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
     Date: 2018-8-30
     Description: Beta diversity analysis and generate UPGMA plots
---------------------------------------------------------------
USAGE: $0 beta_div_dir out_dir map_file_for_R class(in map file) Top_n_taxa
        or $0 -h  # show this message

EXAMPLE:
　$0 

HELP
        exit 0
#fi
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
# INPUT
IN=$1 # unweighted_unifrac_dm.txt or weighted_unifrac_dm.txt dir(beta_div dir)
out_dir=$2
map_for_R=$3
class=$4
top_n_taxa=$5

pro=$(dirname $0)
if [ ! -d "$out_dir" ]; then
  mkdir $out_dir
fi
for dist in `ls $IN/unweighted_unifrac*.txt $IN/weighted_unifrac*.txt $IN/bray_curtis*.txt`
do
	echo $dist
	name=$(basename $dist .txt)
	upgma_cluster.py -i $dist -o $out_dir/upgma_beta_div_$name\_cluster.tre
	Rscript $pro/R-upgma.r -i $out_dir/upgma_beta_div_$name\_cluster.tre -m $map_for_R -c $class -t $top_n_taxa -n $dist -o $out_dir/$name\_cluster_upgma.pdf
done
