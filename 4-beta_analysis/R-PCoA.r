#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-8-30
#     description:  R PCOA plots
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# we read the options from the default: commandArgs(TRUE).
# character logical integer double
spec = matrix(c(
  'input_otu_file', 'i', 1, "character",
  'input_map_file', 'm', 1, "character",
  'input_dist_file', 'd', 1, "character",
  'class' , 'c', 1, "character", # 指出选择哪一列用于分类（map file）
  'if_continue' , 't', 1, "character", # 指出选择哪一列用于分类（map file）
#  'top_n_taxa' , 't' , 1, "integer", # show the top n taxa
  'output_file' , 'o' , 1, "character",
#  'legend_size' , 'ls' , 2, "integer", # show the top n taxa
#  'x_size' , 'x' , 2, "integer", # show the top n taxa
#  'x_dirct' , 'd' , 2, "integer", # show the top n taxa
#  'group_size' , 'g' , 2, "integer", # show the top n taxa
  'help'  , 'h', 0, "logical"

), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}


data=read.table(paste(opt$input_otu_file),
	header=T, row.names=1, dec=".", sep="\t")
data = data.frame(t(t(data)/colSums(data,na=T)) * 100) # normalization to total 100
data <- data[-match("Others",rownames(data)),]
data.dist = as.dist(read.table(paste(opt$input_dist_file),header=T, row.names=1, dec=".", sep="\t"))
#print(data.dist)

library(ape)
library(ggplot2)
# set group
# 读入实验设计 
design = read.csv(paste(opt$input_map_file),sep='\t',header=T,check.names=F)
type = opt$class
idx = design$SampleID %in% colnames(data) 
sub_design = design[idx,]
rownames(sub_design)=sub_design$SampleID
#print(sub_design)
# Plot PCoA
#obs.pcoa=dudi.pco(data.dist, scannf=F, nf=3)
PCOA=pcoa(data.dist, correction="none", rn=NULL)
result <-PCOA$values[,"Relative_eig"]
#result
pro1 = as.numeric(sprintf("%.3f",result[1]))*100
pro2 = as.numeric(sprintf("%.3f",result[2]))*100
x = PCOA$vectors
#x
sample_names = rownames(x)
pc = as.data.frame(PCOA$vectors)
pc$names = sample_names
#sample_names
Group = sub_design[sample_names,eval(type)]
#Group
group = Group
#group
pc$group = group


#shape <- c("A" =16,"B" =17,"C" =16) #定义点形状
#color <- c("A" ='#CCFF33',"B" ='#CCFF33',"C" ='#CCFF33') #定义点颜色
#shape <- setNames(rainbow(group_num),unique(Group))
qiime_color <- c("#FF0000", "#0000FF", "#F27304", "#008000", "#91278D", "#FFFF00", "#7CECF4", "#F49AC2", "#5DA09E", "#6B440B", 
        "#808080", "#02F40E", "#F79679", "#7DA9D8", "#FCC688", "#80C99B", "#A287BF", "#FFF899", "#C0C0C0", "#ED008A", 
        "#00B6FF", "#C49C6B", "#808000", "#8C3FFF", "#BC828D", "#008080", "#800000", "#2B4200", "#A54700","#CD5C5C", "#8B8989")
color <- setNames(qiime_color[1:length(unique(Group))],unique(Group))
#color

xlab=paste("PCOA1(",pro1,"%)",sep="") 
ylab=paste("PCOA2(",pro2,"%)",sep="")
#pc

legend_title = type
pdf(paste(opt$output_file))
Pcoa=ggplot(pc,aes(Axis.1,Axis.2)) + #用ggplot作图
  #geom_point(size=3,aes(color=group,shape=group)) + 
  geom_point(size=3,aes(color=group)) + 
  #  geom_text(aes(label=names),size=4,vjust=-1) +
  #labs(x=xlab,y=ylab,title="PCOA",color=legend_title,shape=legend_title) + 
  labs(x=xlab,y=ylab,title="PCOA",color=legend_title) + 
  geom_hline(yintercept=0,linetype=4,color="grey") + 
  geom_vline(xintercept=0,linetype=4,color="grey") + 
  theme_bw()
#  scale_shape_manual(values=shape) +
if( opt$if_continue == "n" ){
Pcoa + scale_color_manual(values=color)
}
Pcoa
dev.off()

