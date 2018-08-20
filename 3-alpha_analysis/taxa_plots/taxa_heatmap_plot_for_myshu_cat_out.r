#!/usr/bin/Rscript
library(getopt)
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-6-13
#     description: plot taxa bar plots for otu_table
#---------------------------------------------------------------+
# get options, using the spec as defined by the enclosed list.
# we read the options from the default: commandArgs(TRUE).
# character logical integer double
spec = matrix(c(
  'input_table_file', 'i', 1, "character",
  'input_map_file', 'm', 1, "character",
  'class' , 'c', 1, "character", # 指出选择哪一列用于分类（map file）
  'top_n_taxa' , 't' , 2, "integer", # show the top n taxa
  'min1_star'   , 's', 2, "double",
  'min2_plus'   , 'p', 2, "double",

#  'plot_name' , 'n', 1, "character", # you must point the name of the plot
  'output_file' , 'o' , 1, "character",
  'legend_size' , 'l' , 2, "double", # show the top n taxa
#  'x_size' , 'x' , 2, "integer", # show the top n taxa
#  'x_dirct' , 'd' , 2, "integer", # show the top n taxa
  'help'  , 'h', 0, "logical"

), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
if ( is.null(opt$legend_size    ) ) { opt$legend_size    = 0.7 }
if ( is.null(opt$min1_star    ) ) { opt$min1_star    = 0.1  }
if ( is.null(opt$min2_plus    ) ) { opt$min2_plus    = 0.01 }
#if ( is.null(opt$x_size    ) ) { opt$x_size    = 5     }
#if ( is.null(opt$x_dirct    ) ) { opt$x_dirct    = 90     }

library("gplots")
library("RColorBrewer")
design <- read.csv(paste(opt$input_map_file),sep='\t',header=T,check.names=F) #map_add_type_for_R.txt

data <- read.table(paste(opt$input_table_file),header=T,dec=".", sep="\t") # row.names=1,

norm = t(t(data[,-1])/colSums(data[,-1],na=T)) * 100 # normalization to total 100
data<-data.frame(taxonomy=data[,1],norm,check.names = F) #,sum=rowSums(norm)
sum=data.frame(data,rowSums(data[,-1]))
col=ncol(sum)
sum=sum[order(sum[,col],decreasing = T),]
sum <- sum[,-col]
if ( is.null(opt$top_n_taxa ) || opt$top_n_taxa > nrow(sum)) { opt$top_n_taxa  = nrow(sum)  }
top_n_taxa = opt$top_n_taxa
sum <- sum[1:top_n_taxa,]

plot_data <- t(sum)
colnames(plot_data) <-plot_data[1,]
plot_data <- plot_data[-1,]
class(plot_data) <-  "numeric" 
plot_data <- t(plot_data)
# rank <- rownames(plot_data)
# rownames(plot_data) <- factor(rownames(plot_data),levels = rank)

# set group color
type<- as.character(opt$class)
idx = design$SampleID %in% colnames(plot_data) 
sub_design = design[idx,]
a <- as.character(sub_design[,eval(type)])
names(a) <-sub_design$SampleID
group_num= length(unique(a))

cols=c()
for(j in 1:ncol(plot_data)) cols <- c(cols,a[[colnames(plot_data)[j]]])

colors<-setNames(rainbow(group_num),unique(a))

for(m in 1:ncol(plot_data)) cols[m] <- colors[cols[m]]

# 标记热图
note=matrix(0,nrow(plot_data),ncol(plot_data))
for(i in 1:nrow(plot_data)){
  for (j in 1:ncol(plot_data)){
    if(plot_data[i,j]> opt$min1_star) note[i,j]="*" else if(plot_data[i,j]> opt$min2_plus) note[i,j]="+" else note[i,j]=""
    # print(note)
  }  
}  

pdf(file=paste(opt$output_file), height = 12, width = 16)
col = colorRampPalette(c("lightblue", "yellow", "orange", "red"),bias=3)(3000)
# lmat = rbind(c(4,4),c(0,3),c(2,1),c(0,5))
# lhei = c(0.5,0.2,4,0.5) #修改高度比例
# lwid = c(1,3)
heatmap.2(plot_data,dendrogram="row", Colv = FALSE,#margins=c(2,2), #lmat = lmat(position matrix),lhei=lhei,lwid=lwid,, column height, column width
          ColSideColors=cols,
          col=col,scale='none',trace="none",
          #col=rev(colorRampPalette(brewer.pal(11, "RdYlGn"))(256)), cexCol=1,keysize=1,density.info="none",main=NULL,trace="none",
          cellnote=note, notecol='black',notecex=1, #色块标记设置及标记的颜色和大小
          # colsep=c(1:ncol(t(plot_data))),rowsep=c(1:nrow(t(plot_data))),sepcolor="black",sepwidth=c(0.01, 0.01),  #设置色块之间的间隔及颜色
          key.title=NA, keysize=1,key.xlab="Relative abundance"
          )
legend(y=0.80,x=0.03, xpd = TRUE,
       legend = unique(a),
       #col = colors, 
       fill =  colors,
       cex=opt$legend_size
)
dev.off()

