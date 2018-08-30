#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-8-15
#     description: R ade4 packages PCA plots   
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# character logical integer double
spec = matrix(c(
  'input_file', 'i', 1, "character", # taxa table
  'level' , 'l', 1, "integer",       # level of taxa (2-7)
  'input_map_file', 'm', 1, "character",
  'class', 'c', 1, "character",   # group infor in map files
  'filter_percent' , 'f', 1, "double",  # filter percent
  'pc1' , 'a', 1, "integer",  # choose which pc to show as pc1, you can choose 3,4 
  'pc2' , 'b', 1, "integer",  # choose which pc to show as pc2, you can choose 3,4
  'output_dir' , 'o' , 1, "character",
  'help'  , 'h', 0, "logical"
), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
if ( is.null(opt$filter_percent  ) ) { opt$filter_percent    = 0.01     }
if ( is.null(opt$pc1 ) ) { opt$pc1   = 1    }
if ( is.null(opt$pc2 ) ) { opt$pc2   = 2 }

library("ade4")
library(ggplot2)
# genera with very low abundance were removed to decrease the noise, 
# if their average abundance across all samples was below 0.01%
noise.removal <- function(dataframe, percent=0.01, top=NULL){
  dataframe->Matrix
  bigones <- rowSums(Matrix)*100/(sum(rowSums(Matrix))) > percent
  Matrix_1 <- Matrix[bigones,]
  print(percent)
  return(Matrix_1)
}

#file <- "D:/work/菌群分析/4-项目/妊娠糖尿病-16S-pacbio-103/myshu测试结果整理/new_test/even_1707_rm_5_samples/"
design = read.table(paste(opt$input_map_file), header=T, sep="\t") #row.names= 1, 
#print(design$SampleID)
i=opt$level
data = read.table(paste(opt$input_file),
                  header=T, row.names=1, dec=".", sep="\t",check.names=F)
  
data = data.frame(t(t(data)/colSums(data,na=T)) * 100) # normalization to total 100
# rm Others
data <- data[-match("Others",rownames(data)),]
# filter data
data.denoized=noise.removal(data, percent=opt$filter_percent)
data <-data.denoized

# PCA analysis
pca = dudi.pca(data.frame(t(data.denoized)), scannf=F, nf=10)

PC1 = pca$li[,opt$pc1]
PC2 = pca$li[,opt$pc2]

# set group orders
idx = design$SampleID %in% colnames(data) 
sub_design = design[idx,]
c <- as.character(paste(opt$class))
#print(c)
group<-c()
for(sampleid in rownames(pca$li)){
  # sampleid="HM.2.9"
  class<- as.character(sub_design[, eval(c)][which(sub_design[, 'SampleID'] == sampleid)])
  #  print(class(class))
  group <- c(group,class)	
}

#构建一个作图用的数据框，第一列是样品名，第二，三列是PC1和PC2的值，第四列为分组信息
plotdata <- data.frame(rownames(pca$li),PC1,PC2,group)
#将这个数据框的列名进行修改，方便理解列的意义
colnames(plotdata) <-c("sampleID","PC1","PC2","group")

pc1 <-floor(pca$eig[opt$pc1]*10000/sum(pca$eig))/100
pc2 <-floor(pca$eig[opt$pc2]*10000/sum(pca$eig))/100

P<-ggplot(plotdata, aes(PC1, PC2))
P+geom_point(aes(colour=group,shape=group),size=4)+labs(title="PCA Plot",x=paste("PC",opt$pc1,"(",pc1,"%)"),y=paste("PC",opt$pc2,"(",pc2,"%)"))+
  geom_vline(aes(xintercept=0),linetype="dotted")+geom_hline(aes(yintercept=0),linetype="dotted")
ggsave(paste(opt$output_dir,"/level",i,"_",c,"_PC",opt$pc1,"-PC",opt$pc2,"_PCA_plots.pdf",sep = ""))

