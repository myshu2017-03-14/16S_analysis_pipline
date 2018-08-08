#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-7-30 
#     description: plots box for diff alpha div
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# character logical integer double
spec = matrix(c(
  'input_file', 'i', 1, "character",
  'type', 't', 1, "character",
  'alpha_div_file', 'a', 1, "character", # alpha_div file : Alpha_plots_5725_10/alpha_div_collated/
  'compare_alpha_file', 'c', 1, "character", # compare_alpha file (results of compare_alpha_diversity.py ) : Alpha_out/Type_chao1/Type_stats.txt 
  'alpha_name', 'n', 1, "character",
  'x_size' , 'x' , 2, "integer", # set the x size 
  'x_dirct' , 'd' , 2, "integer", # set the x direction
  'help'  , 'h', 0, "logical",
  'output_dir' , 'o' , 1, "character"
), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
if ( is.null(opt$x_size    ) ) { opt$x_size    = 5    }
if ( is.null(opt$x_dirct    ) ) { opt$x_dirct    = 0     }

library(hash)
group_file <- read.csv(paste(opt$input_file),sep='\t',header=T,check.names=F)
# group_file
# hash 
type = opt$type
type
h = hash(keys = group_file$SampleID, values = group_file[,type])
#h

# open qiime compare alpha results
#print(paste(opt$compare_alpha_file))
qiime_alpha <- read.csv(paste(opt$compare_alpha_file),sep='\t',header=T,check.names=F)
#print(paste(fileDir,"/",opt$compare_alpha_file,sep = ""))
# and get the p <0.05 groups and save to compared_list
compared_list <- list()
c_tag=0
for(q_alpha in 1:nrow(qiime_alpha)){
  # print(qiime_alpha[q_alpha,])
  if(qiime_alpha[q_alpha,"p-value"] < 0.05){
    c_tag = c_tag +1
    compared_list[[c_tag]] <- c(as.character(qiime_alpha[q_alpha,"Group1"]),as.character(qiime_alpha[q_alpha,"Group2"]))
  }
}

#all_alpha <- c("observed_species","shannon","chao1","PD_whole_tree","observed_otus","simpson","goods_coverage")
#for(alpha in all_alpha){
alpha = as.character(opt$alpha_name)

  alpha_class <- read.csv(paste(opt$alpha_div_file),sep='\t',header=T,check.names=F)
#  print(alpha_class)
  # get each sample type
  group<-c()
  for(id in 4:length(colnames(alpha_class))){
    group <-c(group, as.character(h[[colnames(alpha_class)[id]]]))
  }
  # get the box data
  alpha_class_new=t(alpha_class[110,4:ncol(alpha_class)])
  colnames(alpha_class_new) <-alpha
  data <- data.frame(SampleID=colnames(alpha_class)[4:ncol(alpha_class)],Type=alpha_class_new,Group=group)
  # library(reshape)
  # #Plot box
  # pdf(file=paste("D:/program/16S/test_data/Observed_otus_box.pdf", sep=""), height = 8, width = 8)
  # boxplot(alpha ~ Group, data=data, col=rainbow(4), main='OTU distribution', xlab='', ylab='Observed OTUs')
  # dev.off()

  # ggplot box  
  library(ggplot2)
  Group <- "Group"
  
  ############################### ggsignif #####################################
  # library(ggsignif)
  # # compared_list <- list(c("Cluster_1", "Cluster_2"),  c("Cluster_2","Cluster_3"),c("Cluster_1","Cluster_3")) #c("Cluster_1", "Cluster_2"),  c("Cluster_1","Cluster_3"), 
  # ggplot(data, aes_string(x=Group, y=alpha),color=Group) + 
  #   geom_boxplot(aes(fill=factor(Group))) + 
  #   theme(axis.text.x=element_text(angle=50,hjust=0.5, vjust=0.5)) +
  #   theme(legend.position="none")+
  #   # set signif tag
  #   geom_signif(comparisons = compared_list, test = wilcox.test, step_increase = 0.1) #,map_signif_level=TRUE,map_signif_level=c("***"=0.001,"**"=0.01, "*"=0.05, " "=2)
  # ggsave(paste(file,"Alpha_out/",type,"_",alpha,"_ggplot_box.pdf",sep = ""))
  # # ggplot violin
  # ggplot(data, aes_string(x=Group, y=alpha),color=Group) + 
  #   geom_violin(aes(fill=factor(Group))) + 
  #   theme(axis.text.x=element_text(angle=50,hjust=0.5, vjust=0.5)) +
  #   theme(legend.position="none")+
  #   # set signif tag
  #   geom_signif(comparisons = compared_list, test = wilcox.test, step_increase = 0.1)
  # ggsave(paste(file,"Alpha_out/",type,"_",alpha,"_ggplot_violin.pdf",sep = ""))
  # 
  ################################ ggpubr ########################################
  library(ggpubr)
  # box
  ggboxplot(data, x=Group, y=alpha, color = Group
            , palette = c("#00AFBB", "#E7B800", "#FC4E07")
            ,add = "jitter", shape="Group"
            )+#增加了jitter点，点shape由dose映射
    stat_compare_means(comparisons = compared_list) + #不同组间的比较 
    stat_compare_means(label.y = 1)
  ggsave(paste(paste(opt$output_dir),"/",type,"_",alpha,"_ggplot_box.pdf",sep = ""))
  # volin
  ggviolin(data, x=Group, y=alpha, fill = Group
           ,palette = c("#00AFBB", "#E7B800", "#FC4E07")
           ,add = "boxplot", add.params = list(fill="white"))+ 
    stat_compare_means(comparisons = compared_list) + #label这里表示选择显著性标记（星号） , label = "p.signif"
    stat_compare_means(label.y = 1)
  ggsave(paste(paste(opt$output_dir),"/",type,"_",alpha,"_ggplot_violin.pdf",sep = ""))

