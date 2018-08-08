
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
     Description: Generate OTU table and tree
---------------------------------------------------------------
USAGE: $0 'usearch_output_dir'
    or $0 -h  # show this message

EXAMPLE:
	$0 usearch_output

HELP
	exit 0
#fi
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
dirname=$1
pro=$(dirname $0)
#----------Taxonomic Classification--------------------
##The basic question we will answer: Proportionally（适当地，成比例地）, what microbes are found in each sample community?
##QIIME's assign_taxonomy.py command. Mothur's implementation is a naive Bayesian approach, similar to the popular Ribosomal Database Project (RDP) classifier
assign_taxonomy.py -i $dirname/otus.fa -o $dirname/assigned_taxonomy -m rdp
#assigned_taxonomy/rep_set_relabel_tax_assignments.txt: Taxonomic assignments for each OTU, along with posterior probability (confidence) value.
#---------OTU Table Creation-------------------------
#Download a helpful Python script that converts vsearch .uc files into QIIME-compatible format:
# wget https://github.com/neufeld/MESaS/raw/master/scripts/mesas-uc2clust
python $pro/mesas-uc2clust $dirname/otu_map.uc $dirname/seq_otus.txt
#cluster/seq_otus.txt: Mapping file that relates sequences to the OTU that they belong to.

#QIIME will take the OTU map and taxonomic classifications and create an OTU table:
make_otu_table.py -i $dirname/seq_otus.txt -t $dirname/assigned_taxonomy/otus_tax_assignments.txt -o $dirname/otu_table.biom
#otu_table.biom: BIOM-formatted OTU table. This is a binary file and is not human readable.

#We can use the BIOM toolkit to retrieve OTU table statistics:
biom summarize-table -i $dirname/otu_table.biom -o $dirname/summary.txt

#----------Phylogenetic Tree Construction-------------
#First, the sequences must be aligned. This can be accomplished using PyNast via QIIME:
align_seqs.py -i $dirname/otus.fa -o $dirname/aligned -m pynast
#rep_set_relabel_aligned.fasta: FASTA file containing the aligned OTU consensus sequences.

#Next, we build the tree using FastTree:
make_phylogeny.py -i $dirname/aligned/otus_aligned.fasta -o $dirname/rep_set.tre -t fasttree
#rep_set.tre: Phylogenetic tree in Newick format.


