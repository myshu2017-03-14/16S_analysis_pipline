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
     Date: 2018-6-7
     Description: Lefse analysis
---------------------------------------------------------------
USAGE: $0 otu_table_biom map_file_for_lefse Class(in map file) level(1-7) output_dir
    or $0 ‐h # show this message
EXAMPLE:
    $0 
NOTE: map file should have a col that is the same,and the colname is All
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
otu_table=$1
map_file=$2  # map file should have a col that is the same,and the colname is All
class=$3
level=$4
out=$5
pro=$(dirname $0)
if [ ! -d "$out" ]; then
  mkdir $out
fi
for c in $class
do
	koeken.py --input $otu_table --output $out/koeken_output_$c --map $map_file --level $level --class $c --split All --clade
		
	for txt in $out/koeken_output_$c/lefse_output/run_lefse/*.txt
	do
		name=$(basename $txt .txt)
		# FDR res FDR<0.05
		Rscript	$pro/lefse_FDR.R -i $txt -o $out/koeken_output_$c/lefse_output/run_lefse/$name.res.txt -r $out/koeken_output_$c/lefse_output/run_lefse/$name.res
		new_txt=$out/koeken_output_$c/lefse_output/run_lefse/$name.res
	  #plots
		plot_cladogram.py $new_txt $out/koeken_output_$c/lefse_output/run_lefse/$name.cladogram.pdf --format pdf		
		plot_res.py --format pdf $new_txt $out/koeken_output_$c/lefse_output/run_lefse/$name.pdf
		if [  -d "$out/koeken_output_$c/lefse_output/run_lefse/biomarkers_raw_images" ]; then
			rm -r $out/koeken_output_$c/lefse_output/run_lefse/biomarkers_raw_images
		fi
		mkdir $out/koeken_output_$c/lefse_output/run_lefse/biomarkers_raw_images 
		plot_features.py --format pdf $out/koeken_output_$c/lefse_output/format_lefse/$name\_format.txt $new_txt $out/koeken_output_$c/lefse_output/run_lefse/biomarkers_raw_images/
	done
	#  
done
tar -zcvf $out/koeken_output.tar.gz $out/koeken_output_*
