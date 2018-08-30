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
     Description: Beta diversity analysis and generate PcoA plots
---------------------------------------------------------------
USAGE: $0 otu_table map_file tree output_prefix (can be included dir or will generate results in current dir)
    or $0 ‐h # show this message
EXAMPLE:
    $0 otu_table.biom map.txt rep_set.tre test
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help

# beta diversity
otu_table=$1
map_file=$2
tree=$3
output_prefix=$4
pro=$(dirname $0)
# perform beta diversity, principal coordinate analysis, and generate a preferences file along with 3D PCoA Plots
beta_diversity_through_plots.py -i $otu_table -m $map_file -o $output_prefix\_PCoA_3D -t $tree -f -p $pro/beta_para.txt

otu_table_name=$(basename $otu_table .biom)
if [ ! -d "$output_prefix\_PCoA_2D" ]; then
	mkdir $output_prefix\_PCoA_2D
fi
# perform beta diversity, principal coordinate analysis, and generate a preferences file along with 2D PCoA Plots
make_prefs_file.py -m $map_file -o $output_prefix\_PCoA_2D/prefs.txt 
#--mapping_headers_to_use SampleID,Treatment
beta_diversity.py -i $otu_table -m bray_curtis,unweighted_unifrac,weighted_unifrac -t $tree -o $output_prefix\_beta_div 
for mertrics in weighted_unifrac unweighted_unifrac bray_curtis
do
	# visualize this data in a Principle Coordinate plot (PCoA)
	principal_coordinates.py -i $output_prefix\_beta_div/$mertrics\_$otu_table_name.txt -o $output_prefix\_beta_div/beta_div_coords_$mertrics.txt
	# produce a plot of the PCoA:
	make_2d_plots.py -p $output_prefix\_PCoA_2D/prefs.txt -i $output_prefix\_beta_div/beta_div_coords_$mertrics.txt -m $map_file -o $output_prefix\_PCoA_2D/$mertrics\_2d_continuous
	# 3D plots
	#make_emperor.py -i beta_div/beta_div_coords_$mertrics.txt -m $map_file -o PCoA/$mertrics\_3d
done
