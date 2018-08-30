#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-8-30
#     description: Anosim analysis for otu table   
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# we read the options from the default: commandArgs(TRUE).
# character logical integer double
spec = matrix(c(
  'input_table_file', 'i', 1, "character",
  'input_map_file', 'm', 1, "character",
  'if_2_group_compare', 'l', 1, "character",
  'help'  , 'h', 0, "logical",
  'class' , 'c', 1, "character", # 指出选择哪一列用于分类（map file）
  'plot_name' , 'n', 1, "character", # you must point the name of the plot
  'output_file' , 'o' , 1, "character"

), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
if ( is.null(opt$if_2_group_compare   ) ) { opt$if_2_group_compare    = "n"}
#if ( is.null(opt$x_size    ) ) { opt$x_size    = 5     }
#if ( is.null(opt$x_dirct    ) ) { opt$x_dirct    = 90     }
#if ( is.null(opt$group_size    ) ) { opt$group_size    = 1.5    }

#Load vegan library
library(vegan)

# 读入实验设计 
design = read.table(paste(opt$input_map_file), header=T, sep="\t") #row.names= 1, 

# 读取OTU表
# D:/work/菌群分析/4-项目/妊娠糖尿病-16S-pacbio-103/103_16S_samples_output-myshu/picrust-test/metagenome_predictions.txt
otu_table = read.delim(paste(opt$input_table_file),row.names= 1, header=T,check.names=F, sep="\t")

# 过滤数据并排序
idx = design$SampleID %in% colnames(otu_table) 
sub_design = design[idx,]


#count = otu_table[, rownames(sub_design)]
count = otu_table[, as.character(sub_design$SampleID)]
data <-data.frame(t(count))
c <-  quote(paste(opt$class))
Treatment <- sub_design[,eval(c)]
class(Treatment)
#head(data)

if(opt$if_2_group_compare == "n"){
# 计算距离
	data.dist <- vegdist(data, method="bray")
	# # distance :  "manhattan", "euclidean", "canberra", "bray", "kulczynski", "jaccard", "gower", "altGower", "morisita", "horn", "mountford", "raup" , "binomial", "chao", "cao" or "mahalanobis".
	data.ano <- anosim(data.dist, Treatment)
	#summary(data.ano)
	ncol <- length(levels(Treatment))+1
	pdf(paste(opt$output_file),width=8,height=8)
	plot(data.ano,col = rainbow(ncol), lwd = 1,main = paste(opt$plot_name), ylab="Distance")
	#data.ano
	#text(x=,y=-1,labels=levels(Treatment),srt=45, adj=1, xpd=TRUE)
	dev.off()
}else{
	data <- cbind(data, Treatment)
	#print(data)
	all_class <- unique(Treatment)
	all_group <- combn(all_class,2)
	ngroup = ncol(all_group)
	for(i in 1:ngroup){
		sub_class = all_group[,i]
		sub_data <- data[data$Treatment %in% sub_class,]
		#print(sub_data)
		sub_data$Treatment <- factor(sub_data$Treatment, levels=sub_class)
		print(class(sub_data))
		data.dist <- vegdist(sub_data[,-which(names(sub_data)%in% c("Treatment"))], method="bray")
		data.ano <- anosim(data.dist, sub_data$Treatment)
		#print(data.ano)
		pdf(paste(opt$output_file,"_",sub_class[1],"_",sub_class[2],".pdf",sep = ""),width=8,height=8)
		plot(data.ano,col = rainbow(2), lwd = 1,main = paste(opt$plot_name), ylab="Distance")
		dev.off()
	}
}

