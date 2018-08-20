#!/bin/bash
#!/usr/bin/env bash 
# echo the help if not input all the options
help()
{
cat <<HELP
USAGE: $0 input_dir(must includes *_final_out/) output_dir select_order_file
    or $0 ‐h # show this message
EXAMPLE:
    $0 "split_otu_table/*_final_out/" . select_order
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help


in=$1
out=$2
se=$3
pro_dir=$(dirname $0)
	for n in 1 2 3 4 5 6 7
	do
		j=1
		for s in `cat $se`
		#$in/*_L$n.final.out
		do
			echo $in/*$s\___L$n.final.out
			i=$in/*$s\___L$n.final.out
			if [ $j == 1 ]
			then
				t=$i
				((j++));
				continue
			fi
			name=$(basename $i .out)
			echo "$i	$t"
			perl $pro_dir/cat_taxa_abundance.pl -in $i -old $t -out tmp.out
			t="tmp.txt"
			rm $t
			cat /dev/null > $t
			cat tmp.out > $t	
		done	
		cat tmp.out > $out/cat_taxa_abundance.16S.level$n.out		
		rm tmp.out
	done
rm tmp.txt
