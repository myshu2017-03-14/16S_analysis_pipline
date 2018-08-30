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
     Description: MRPP analysis (Input is the beta_div txt)
---------------------------------------------------------------
USAGE: $0 beta_div_dir map_file mrpp_out_dir class
        or $0 -h  # show this message

EXAMPLE:
　$0 beta_div/ mapping_file.txt mrpp_out Class

HELP
        exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
# INPUT
in=$1 # unweighted_unifrac_dm.txt or weighted_unifrac_dm.txt dir(beta_div dir)
map_file=$2 # Mapping file including detail group information
out=$3
class=$4
if [ ! -d "$out" ]; then
  mkdir $out
fi
# mrpp for whole otu_table
for dist in `ls $in/unweighted_unifrac*.txt $in/weighted_unifrac*.txt $in/bray_curtis*.txt`
do
	name=$(basename $dist .txt)
#	echo $name
	compare_categories.py --method mrpp -i $dist -m $map_file -c $class -o $out/$class\_mrpp_out_$name -n 999
done
