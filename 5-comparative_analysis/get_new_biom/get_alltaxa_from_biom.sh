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
     Date: 2018-7-4
     Description: Deal with the biom table
---------------------------------------------------------------
USAGE: $0 otu_table.biom out_name out_dir
    or $0 ‐h # show this message
EXAMPLE:
    $0 otu_table.biom even_1701 .
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
otu_table=$1
name=$2
out=$3
if [ ! -d "$out" ]; then
  mkdir $out
fi
pro=$(dirname $0)
# 首先生成tsv
biom convert -i $otu_table -o $out/$name\_with_taxonomy.tsv --to-tsv  --header-key taxonomy
#然后根据tsv进行处理优化
#kindom
perl -i -p -e 's/(\t(k__\S+))?; p__; c__; o__; f__; g__; s__$/$1; p__norank_$2; c__norank_$2; o__norank_$2; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
perl -i -p -e 's/(\t(k__\S+))$/$1; p__norank_$2; c__norank_$2; o__norank_$2; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
# p
perl -i -p -e 's/(; (p__\S+))?; c__; o__; f__; g__; s__$/$1; c__norank_$2; o__norank_$2; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
perl -i -p -e 's/(; (p__\S+))$/$1; c__norank_$2; o__norank_$2; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
# c
perl -i -p -e 's/(; (c__\S+))?; o__; f__; g__; s__$/$1; o__norank_$2; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
perl -i -p -e 's/(; (c__\S+))$/$1; o__norank_$2; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
# o
perl -i -p -e 's/(; (o__\S+))?; f__; g__; s__$/$1; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
perl -i -p -e 's/(; (o__\S+))$/$1; f__norank_$2; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
# f
perl -i -p -e 's/(; (f__\S+))?; g__; s__$/$1; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
perl -i -p -e 's/(; (f__\S+))$/$1; g__norank_$2; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
# g
perl -i -p -e 's/(; (g__\S+))?; s__$/$1; s__norank_$2/g' $out/$name\_with_taxonomy.tsv
perl -i -p -e 's/(; (g__\S+))$/$1; s__norank_$2/g' $out/$name\_with_taxonomy.tsv

# get the new table and convert to new otu table
cp $out/$name\_with_taxonomy.tsv $out/$name\_with_taxonomy.txt
 biom convert -i $out/$name\_with_taxonomy.txt -o $out/$name\_with_taxonomy.new.biom --to-hdf5 --table-type="OTU table" --process-obs-metadata taxonomy

perl -i -p -e 's/# Constructed from biom file//g' $out/$name\_with_taxonomy.tsv
perl -i -p -e 's/#//g' $out/$name\_with_taxonomy.tsv
# 最后利用R脚本将相同的分类进行合并
Rscript $pro/sum_taxa_from_biom_tsv.R -i $out/$name\_with_taxonomy.tsv -o $out/$name\_with_taxonomy.sum.tsv
