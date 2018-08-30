#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-8-30
#     description: UPGMA plot using R  
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# we read the options from the default: commandArgs(TRUE).
# character logical integer double
spec = matrix(c(
  'input_tree_file', 'i', 1, "character",
  'input_map_file', 'm', 1, "character",
  'help'  , 'h', 0, "logical",
  'class' , 'c', 1, "character", # 指出选择哪一列用于分类（map file）
  'top_n_taxa' , 't' , 1, "integer", # show the top n taxa
  'plot_name' , 'n', 1, "character", # you must point the name of the plot
  'output_file' , 'o' , 1, "character",
  'legend_size' , 'ls' , 2, "integer", # show the top n taxa
  'x_size' , 'x' , 2, "integer", # show the top n taxa
  'x_dirct' , 'd' , 2, "integer", # show the top n taxa
  'group_size' , 'g' , 2, "integer" # show the top n taxa

), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}

library(phytools)
# input data
#--------A tree
#tree <-  read.tree("D:/program/16S/test_data/weighted_unifrac_UPGMA.tre")
tree <-  read.tree(paste(opt$input_tree_file))
## 
## Phylogenetic tree with 26 tips and 25 internal nodes.
## 
## Tip labels:
##  A, B, C, D, E, F, ...
## 
## Rooted; includes branch lengths.
#--------A table
# 读入实验设计 
design = read.csv(paste(opt$input_map_file),sep='\t',header=T,check.names=F)
# get the color data
c <-  quote(paste(opt$class))
a <- as.character(design[,eval(c)])
names(a) <-design$SampleID

b<-fastBM(tree)
for(j in 1:length(b)) b[j] <- a[names(b[j])]
## first color the tip edges
for(i in 1:length(b)) tree<-paintSubTree(tree,node=i,state=b[i],stem=TRUE)
ncol = length(unique(design[,eval(c)]))
colors <- setNames(c("black",rainbow(ncol)),c(1,levels(design[,eval(c)])))
#c(1,levels(design[,eval(c)]))
#colors
# plot (without bar)
pdf(paste(opt$output_file),width=8,height=8)
plotSimmap(tree,type="phylogram",colors=colors,fsize=0.4)
add.simmap.legend(colors=colors[2:5],prompt=FALSE,x=0.95*par()$usr[1],y=0.95*par()$usr[4])
dev.off()
