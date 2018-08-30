#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             |
#     mail:1291016966@qq.com                                    |
#     version:1.0                                               |
#     date :2018-6-6                                            |
#     description:  Plot heatmap for beta div tre               |
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# character logical integer double
spec = matrix(c(
  'beta_file', 'i', 1, "character",
  'beta_name', 'b', 1, "character",
  'map_file', 'm', 1, "character",
  'class', 'c', 1, "character",
  'legend_x_posion' , 'x', 1, "integer",
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
if ( is.null(opt$legend_x_posion    ) ) { opt$legend_x_posion    = 0.03     }
#if ( is.null(opt$sd      ) ) { opt$sd      = 1     }
#if ( is.null(opt$count   ) ) { opt$count   = 10    }
#if ( is.null(opt$verbose ) ) { opt$verbose = FALSE }


# 读入实验设计 
design = read.table(paste(opt$map_file), header=T, sep="\t") #row.names= 1, 

# 读入矩阵
dist = read.table(paste(opt$beta_file), header=T, sep="\t",row.names= 1,check.names = F) # 

# 过滤数据并排序
#idx = rownames(design) %in% colnames(otu_table) 
idx = design$SampleID %in% colnames(dist) 
sub_design = design[idx,]

# 使用热图可视化，并保存为8x8英寸的PDF
library("gplots")
library("RColorBrewer")
# 将样本名称按照分组转换成颜色信息
type = as.character(opt$class)
a <- as.character(sub_design[,eval(type)])
names(a) <-sub_design$SampleID
# dist_weigtht
cols=c()
for(j in 1:ncol(dist)) cols <- c(cols,a[[colnames(dist)[j]]])
colors<-setNames(rainbow(length(unique(a))),unique(a))
#colors
for(m in 1:ncol(dist)) cols[m] <- colors[cols[m]]

pdf(file=paste(paste(opt$output_dir),"/heatmap_",as.character(opt$beta_name),"_samples.pdf", sep=""), height = 8, width = 8)
# 想预览，跳过上面Pdf行直接运行heatmap.2
# 保留聚类树  dendrogram=c("both","row","column","none")
heatmap.2(data.matrix(dist), Rowv=TRUE, Colv=TRUE, dendrogram='both', trace='none', margins=c(6,6), ColSideColors=cols,RowSideColors=cols ,col=rev(colorRampPalette(brewer.pal(11, "RdYlGn"))(256)),density.info="none",cexCol=0.5,cexRow=0.5) 
legend(y=0.80,x=opt$legend_x_posion, xpd = TRUE,
       legend = unique(a),
       #col = colors, 
       fill =  colors,
       cex=.7
)
dev.off()

