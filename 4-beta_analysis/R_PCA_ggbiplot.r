#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu 
#     mail:1291016966@qq.com
#     version:1.0 
#     date :2018-6-6
#     description:  
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# character logical integer double
spec = matrix(c(
  'input_file', 'i', 1, "character",
  'map_file', 'm', 1, "character",
  'class', 'c', 1, "character",
  'output_txt_file' , 't' , 1, "character",
  'output_file' , 'o' , 1, "character",
  'help'  , 'h', 0, "logical"
), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
#if ( is.null(opt$mean    ) ) { opt$mean    = 0     }
#if ( is.null(opt$sd      ) ) { opt$sd      = 1     }
#if ( is.null(opt$count   ) ) { opt$count   = 10    }
#if ( is.null(opt$verbose ) ) { opt$verbose = FALSE }

library(ggbiplot)

#------------------------------- for each levels -----------------------------------

group_file <- paste(opt$map_file)
design = read.csv(group_file,sep='\t',header=T,check.names=F)
#for(level in c(2:7)){
  otu_table_file <-paste(opt$input_file) # cat_taxa_abundance_level6.out
  otu_table = read.delim(otu_table_file, row.names= 1,  header=T, sep="\t")
  #idx = rownames(design) %in% colnames(otu_table) 
  idx = design$SampleID %in% colnames(otu_table) 
  sub_design = design[idx,]
  #count = otu_table[, rownames(sub_design)]
  count = otu_table[, as.character(sub_design$SampleID)]
  
  # 转换原始数据为百分比
  norm = t(t(count)/colSums(count,na=T)) * 100 # normalization to total 100
  
  # 筛选mad值大于0.5的OTU(中位数绝对偏差)
  mad.5 = norm[apply(norm,1,mad)>0.5,]
  # 另一种方法：按mad值排序取前6波动最大的OTUs
  mad.5 = head(norm[order(apply(norm,1,mad), decreasing=T),],n=6)
  first_6_otu<- otu_table[rownames(mad.5),]
  write.table(first_6_otu,paste(opt$output_txt_file))
  # 计算PCA和菌与菌轴的相关性
  # names
  otu.pca <- prcomp(t(mad.5))
  type = as.character(opt$class)
#  for(type in colnames(sub_design)[4:18]){
    ggbiplot(otu.pca, obs.scale = 1, var.scale = 1,
             labels = colnames(mad.5),labels.size = 2,
             groups = sub_design[,type], ellipse = FALSE,var.axes = T,
             varname.size = 2,varname.adjust = 1.05)
    
    # ggsave(paste(file,"/R_PCA_plots/ggbiplots/ggbiplot_samplename_",type,"_level",level,".pdf",sep = ""))
    ggsave(paste(opt$output_file))
    
#  }
#}
