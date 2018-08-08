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
     Description: OTU clustering and re-map raw data to OTUs
---------------------------------------------------------------
USAGE: $0 'output_dir' otu_cluster_cutoff clean_data
    or $0 -h  # show this message

EXAMPLE:
	$0 usearch_output 0.97 test.fa

HELP
	exit 0
#fi
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
dirname=$1
cut=$2  #0.97 0.99
data=$3
if [ ! -d "$dirname" ]; then
  mkdir $dirname
fi
pro=$(dirname $0)
#Dereplicate (countdupes)
usearch -derep_fulllength $data -output $dirname/derep.fasta -sizeout
#Remove singletons before creating OTU representatives
usearch -sortbysize $dirname/derep.fasta -output $dirname/sorted.fasta -minsize 2
#OTU clustering
usearch -cluster_otus $dirname/sorted.fasta -otus $dirname/otu_reps.init.fasta
#Reference-­‐based chimera removal
usearch -uchime_ref $dirname/otu_reps.init.fasta -db $pro/gold.fa -strand plus -nonchimeras $dirname/otu_reps.fa

#Label OTU sequences OTU_1, OTU_2,…We will use Robert Edgar's python script (http://drive5.com/python/python_scripts.tar.gz)
python $pro/fasta_number.py $dirname/otu_reps.fa OTU_ > $dirname/otus.fa

#Map reads (including singletons) back to OTUs
usearch -usearch_global $data -db $dirname/otus.fa -strand plus -id $cut -uc $dirname/otu_map.uc

cut -f 1 $dirname/otu_map.uc | sort | uniq -c
# 156849 H
#  33461 N
