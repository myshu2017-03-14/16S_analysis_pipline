#!/usr/bin/Rscript
library(getopt)
# get options, using the spec as defined by the enclosed list.
# we read the options from the default: commandArgs(TRUE).
# character logical integer double
spec = matrix(c(
  'input_table_file_with_taxa', 'i', 1, "character",
  'help'  , 'h', 0, "logical",
  'output_file' , 'o' , 1, "character"

), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
#if ( is.null(opt$legend_size    ) ) { opt$legend_size    = 7.5}
#if ( is.null(opt$x_size    ) ) { opt$x_size    = 5     }
#if ( is.null(opt$x_dirct    ) ) { opt$x_dirct    = 90     }
#if ( is.null(opt$group_size    ) ) { opt$group_size    = 1.5    }

#Load vegan library
library(vegan)

# 读取OTU表
#otu_table_file <-"D:/program/16S/test_data/otu_table_with_taxonomy.txt"
otu_table = read.delim(opt$input_table_file_with_taxa, row.names= 1,  header=T, sep="\t",check.names = F)
# data <-t(otu_table)
data <- t(otu_table[,-ncol(otu_table)])
# plot
pdf(paste(opt$output_file))
sp1 <- specaccum(data, method="random")
plot(sp1, ci.type="poly", col="blue", lwd=2, ci.lty=0, ci.col="lightblue",xlab = "number of samples",ylab = "OTUs detected")
boxplot(sp1, col="yellow", add=TRUE, pch="+")
dev.off()
