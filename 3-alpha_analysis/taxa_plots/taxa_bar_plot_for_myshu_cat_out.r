#!/usr/bin/Rscript
library(getopt)
# get options, using the spec as defined by the enclosed list.
# we read the options from the default: commandArgs(TRUE).
# 一般就是4列，第一列为字符串，第二列为简写，第三列值分别为0（无参数后面可以不跟参数）、1（后面需要跟参数）、2（可选可不选），第四列为数据类型
# character logical integer double
spec = matrix(c(
  'input_table_file', 'i', 1, "character",
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
if ( is.null(opt$legend_size    ) ) { opt$legend_size    = 7.5}
if ( is.null(opt$x_size    ) ) { opt$x_size    = 5     }
if ( is.null(opt$x_dirct    ) ) { opt$x_dirct    = 90     }
if ( is.null(opt$group_size    ) ) { opt$group_size    = 1.5    }
# set some reasonable defaults for the options that are needed,
# but were not specified.
# if ( is.null(opt$output_file) ) { opt$output_file = opt$input_file }

library(ggplot2)
library(reshape)
#增加分组信息(genus)
data<- read.table(paste(opt$input_table_file),sep='\t',header=T,check.names=F)
#print(data)
#colnames(data[,-1])
max=as.numeric(opt$top_n_taxa)
#class(max)
nrow=nrow(data)
norm = t(t(data[,-1])/colSums(data[,-1],na=T)) * 100 # normalization to total 100
data<-data.frame(taxonomy=data[,1],norm,check.names =F)
#print(data)
if(nrow<max){
 row=nrow 
}else{
  if(nrow<max){
    row=nrow 
  }else{
    row=max+1
    sum=data.frame(data,rowSums(data[,-1]),check.names=F)
    col=ncol(sum)
    sum=sum[order(sum[,col],decreasing = T),]
    sum<-sum[,-col]
    # if the first 20 include "Others", save to "Others_tmp" and remove the row
    if("Others" %in% sum$taxonomy[1:max]){
      # print("1")
      other_tmp=sum[sum$taxonomy=="Others",]
      sum <- sum[!(sum$taxonomy == "Others"),]
      # low to 21 and is defined to "others"
      others <-rbind(sum[row:(nrow-1),-1],as.numeric(other_tmp[,-1]))
      others=colSums(others)
    }else{
      # low to 21 and is defined to "others"
      others <-sum[row:(nrow-1),-1]
      others=colSums(others)
    }
    # others=c("Others",others)
    data<-rbind(sum[1:max,-1],others)
#    print(as.character(sum[1:max,1]))
    data<-data.frame(taxonomy=c(as.character(sum[1:max,1]),"Others"),data,check.names=F)
  }
}
#print(data)
# save the table
table<-rbind(as.character(colnames(data)[-1]),data[,-1])
#print(table)
table<-data.frame(taxonomy=c("taxonomy",as.character(data$taxonomy)),table,check.names=F)
#print(table)
write.table(table, file = paste(opt$output_file,"_first_",max,".txt",sep=""),quote = FALSE ,row.names = FALSE, col.names = F,sep="\t")


#print(group)
#group <-c(rep(1,row*17),rep(2,row*28),rep(3,row*30),rep(4,row*28))
design = read.table(paste(opt$input_map_file), header=T, sep="\t",check.names=F) #row.names= 1, 
#print(design)
idx = design$SampleID %in% colnames(data[,-1]) 
sub_design = design[idx,]
#print(sub_design$SampleID)
#colnames(data[,-1])

c <-  quote(paste(opt$class))
group<-c()
#print(colnames(data[,-1]))
#for(class in sub_design[,eval(c)]){
for(sampleid in colnames(data[,-1])){
  class<- as.character(sub_design[, eval(c)][which(sub_design[, 'SampleID'] == sampleid)])
#  print(sampleid)
  group <- c(group,rep(class,row))	
}
#print(sub_design$SampleID)
#print(group)

rank <-data$taxonomy
group_rank <- unique(group)
#print(rank)
#print(colnames(data))
data <-melt.data.frame(data,id="taxonomy")
#print(nrow(data))
#print(group)
data <- cbind(data,group)
#print(data$group)
#设置固定的tax_name顺序
data$taxonomy = factor(data$taxonomy, levels=rank)
data$group=factor(data$group, levels=group_rank)
cols<-c("#FF0000", "#0000FF", "#F27304", "#008000", "#91278D", "#FFFF00", "#7CECF4", "#F49AC2", "#5DA09E", "#6B440B", 
        "#808080", "#02F40E", "#F79679", "#7DA9D8", "#FCC688", "#80C99B", "#A287BF", "#FFF899", "#C0C0C0", "#ED008A", 
        "#00B6FF", "#C49C6B", "#808000", "#8C3FFF", "#BC828D", "#008080", "#800000", "#2B4200", "#A54700","#CD5C5C", "#8B8989")
#设置背景模板
theme_set(theme_bw())
#print(data)
ggplot(data, aes(x = variable,y=value,fill=taxonomy) )+ geom_bar(stat = "identity",colour="black",size=0.2) +#geom_histogram(binwidth=10)
  #scale_fill_brewer(palette="Blues")+ #Greens
  theme(axis.text.x = element_text(angle = as.numeric(opt$x_dirct),hjust = .5, vjust = .5,size = as.numeric(opt$x_size))) +
  facet_grid(. ~ group,scales = "free_x",space = "free_x")+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank(),
        strip.text = element_text(face = "bold",size = rel(as.numeric(opt$group_size))),strip.background = element_rect(fill = "lightblue",colour = "black",size=0.5 ))+
  ggtitle(paste(opt$plot_name))+theme(plot.title = element_text(hjust = 0.5))+
  xlab("Samples")+ylab("Relative Abundance(%)")+
  scale_fill_manual(limits=as.character(data$taxonomy[1:row]),values = cols)+
  #scale_fill_hue()+
  # change the legend font
  theme(legend.text = element_text( size = as.integer(opt$legend_size)),legend.key.size=unit(0.2,'cm'))+
  theme(legend.position="bottom")
#  theme(legend.position="none") 
ggsave(paste(opt$output_file),width=8,height=8)

## output the legend only (没有解决)
#dir <- dirname(paste(opt$output_file))
#filename <-paste(opt$plot_name)
#legend <- file.path(dir,"legend.pdf")
#require(grid)
#g <- ggplot_gtable(ggplot_build(p))$grobs
#dev.new()
#pdf(legend, width=6, height=3)
##g
#pushViewport(plotViewport(rep(1, 4)))
#grid.draw(g[[24]])
#dev.off()

