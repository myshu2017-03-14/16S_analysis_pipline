# 16S_analysis_pipline
16S rRNA analysis pipline

Contents
[Data filtering and pre-proccessing](#anchor)



## Data filtering and pre-proccessing
> #### count seqs for each samples (optional)
`count_seqs.py -i "*.fastq" -o seq_counts.txt`

The seq_counts.txt just as below:

![seq_couns_results](images/seq_counts_results.png)

> #### Prepare map file and generate combined_seqs.fna
The mapping file format is a Manually edited tab file. You can edit it using excel or other text editor. More about this file's format you can read from this [link](http://qiime.org/documentation/file_formats.html#metadata-mapping-files). My example `mapping_file.txt` just as below:(The  `InputFileName` must be the same as each samples seq file name. )
![map_file_example](images/map_file_example.png)

And notice that the map file for qiime is needed a "#" in the most left item of the header, and the map file for R to plots is not needed.

Then we need to generate a `combined_fasta.fna` for all the samples.

`add_qiime_labels.py -i All_samples_fasta_dir -m mapping_file.txt -c InputFileName -n 1 -o combined_fasta`

Finally, we will get a `combined_fasta/combined_seqs.fna` for the Data filtering.

> #### Data filtering for Full length 16S rRNA from Pacbio sequencing 
(Note: the filter criterion may be different for different data)
We use mothur to filter our data. The command just as below:

`mothur 1-filter/filter.sh > mothur.log`

## OTU analysis (Usearch)
> #### Usearch analysis
First, get the OTUs seqs and re-map raw data to OTUs.

`nohup 2-otu_analysis/usearch.sh usearch_out_0.97_output 0.97 combined_fasta/combined_seqs.fna &`

Then generate the biom table and tree

`nohup 2-otu_analysis/usearch2.sh usearch_out_0.97_output`

The results includes below files:
+ derep.fasta
+ otu_map.uc
+ otu_reps.fa
+ otu_reps.init.fasta
+ otus.fa
+ otu_table.biom
+ otu_table.txt
+ rep_set.tre
+ seq_otus.txt
+ sorted.fasta

其中otu_table.biom和rep_set.tre可以用于下游分析

> #### OTU specaccum cur analysis

## Taxa classification and abundance analysis
> #### barplots of taxa

> #### heatmap of taxa and samples

> ####  Rank Abundance plots

> #### Tree of samples

## Alpha diversity analysis
> #### Alpha rarefaction analysis (QIIME)

`3-alpha_analysis/alpha_div.sh otu_table.biom mapping_file.txt rep_set.tre alpha_plots_921_10 921`

> #### compare alpha diversity analysis (QIIME and R)
Note that you should run alpha rarefaction analysis first. The input dir `alpha_div_collated/` is from  alpha rarefaction analysis results.

`3-alpha_analysis/R_alpha_div/R_alpha_div.sh alpha_div_collated/ mapping_file.txt Type Alpha_out mapping_file_for_R.txt`

`Type` is one of the header of map file.

## Beta diversity analysis

> #### Anosim analysis

> #### MRPP analysis

> #### PCoA analysis (QIIME or R)

> #### PCA analysis

> #### NMDS analysis

> #### UPGMA analysis
UPGMA tree and barplots

## Comparative analysis
> #### Lefse analysis
> #### STAMP analysis
> #### R stats analysis
> #### Spearman correlation coefficient analysis of dominant taxa

## Predict metagenome with 16S data using Picrust

> #### pick_closed_reference_otus using gg_13_5 database (QIIME)

> #### predict metagenome

> #### metagenome contributions analysis (for select KO or modules)

> #### 



