# 16S_analysis_pipline
16S rRNA analysis pipline

Contents
[Data filtering and pre-proccessing](#anchor)



## Data filtering and pre-proccessing
> #### count seqs for each samples (optional)
`count_seqs.py -i "*.fastq" -o seq_counts.txt`

The seq_counts.txt just as below:

![seq_couns_results](images/seq_counts_results.png)

> #### Prepare map file and generate combined_fasta.fna 
The mapping file format is a Manually edited tab file. You can edit it using excel or other text editor. More about this file's format you can read from this [link](http://qiime.org/documentation/file_formats.html#metadata-mapping-files). My example map file just as below:
![map_file_example](images/map_file_example.png)


And notice that the map file for qiime is needed a "#" in the most left item of the header, and the map file for R to plots is not needed.



> #### 

## OTU analysis

## Alpha diversity analysis

## Beta diversity analysis

## Comparative analysis


## Predict metagenome with 16S data using Picrust

