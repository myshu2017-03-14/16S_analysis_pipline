perl -i -p -e 's/# Constructed from biom file//g' otu_table_even_1707.tsv
perl -i -p -e 's/#//g' otu_table_even_1707.tsv

perl -i -p -e 's/; p__; c__; o__; f__; g__; s__//g' otu_table_even_1707.tsv
perl -i -p -e 's/; c__; o__; f__; g__; s__//g' otu_table_even_1707.tsv
perl -i -p -e 's/; o__; f__; g__; s__//g' otu_table_even_1707.tsv
perl -i -p -e 's/; f__; g__; s__//g' otu_table_even_1707.tsv
perl -i -p -e 's/; g__; s__//g' otu_table_even_1707.tsv
perl -i -p -e 's/; s__//g' otu_table_even_1707.tsv

Rscript sum_taxa_from_biom_tsv.R -i otu_table_even_1707.tsv -o otu_table_even_1707.sum.tsv
