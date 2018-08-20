# example : nohup ../../program/even_sample.sh otus_even_1992 1992 ./otu_table.biom &
# echo the help if not input all the options
help()
{
#if [ $# -lt 3 ] ; then
cat <<HELP

USAGE: $0 'output_dir' 'even_number' otu_table_file
	or $0 -h  # show this message

EXAMPLE:
　even_sample.sh otus_even_1992 1992 ./otu_table.biom

HELP
	exit 0
#fi
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help
dirname=$1
even=$2
data=$3 #otu table biom
# get all the reads according the otu map
#filter_fasta.py -f ../filtered_otus_rm_3.11_3.9/combined_seqs_sfiltered.fasta -o otu_map_filtered_seqs.fasta -m seq_otus.txt
if [ ! -d "$dirname" ]; then
  mkdir $dirname
fi
# even the data 
#multiple_rarefactions_even_depth.py -i otu_table.biom -o rarefied_otu_tables/ -d 1994 -n 1
#biom summarize-table -i rarefaction_1994_0.biom -o summary.txt
# add the taxa info
#multiple_rarefactions_even_depth.py -i otu_table.biom -o rarefied_otu_tables_add_taxa/ -d 1994 -n 1 --lineages_included
name=$(basename $data .biom)
single_rarefaction.py -i $data -o $dirname/$name\_even_$even.biom -d $even --lineages_included=LINEAGES_INCLUDED
biom summarize-table -i $dirname/$name\_even_$even.biom -o $dirname/$name.summary.txt 
