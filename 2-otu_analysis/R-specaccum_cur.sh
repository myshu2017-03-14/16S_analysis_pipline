#!/bin/bash
#!/usr/bin/env bash 
# echo the help if not input all the options
help()
{
#if [ $# -lt 3 ] ; then
cat <<HELP
---------------------------------------------------------------
     Author: Myshu                                            
     Mail: 1291016966@qq.com                                   
     Version: 1.0                                              
     Date: 2018-8-8
     Description: Plot specaccum cur from otu table
---------------------------------------------------------------
USAGE: $0 otu_table_biom output_pdf
    or $0 -h  # show this message

EXAMPLE:
	$0 otu_table.biom R-specaccum_plot.pdf

HELP
	exit 0
#fi
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
table=$1
out=$2  #0.97 0.99
dir=$(dirname $out)
if [ ! -d "$dirname" ]; then
  mkdir $dirname
fi
pro=$(dirname $0)

name=$(basename $table .biom)
biom convert -i $table -o $dir/$name\_with_taxonomy.txt --to-tsv --header-key taxonomy
sed -i '1d' $dir/$name\_with_taxonomy.txt
perl -i -p -e 's/^#//g' $dir/$name\_with_taxonomy.txt
$pro/R-specaccum_cur.r -i $dir/$name\_with_taxonomy.txt -o $out