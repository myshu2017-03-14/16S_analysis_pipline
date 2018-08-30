# ============================================================
# Tutorial on drawing an NMDS plot using ggplot2
# by Umer Zeeshan Ijaz (http://userweb.eng.gla.ac.uk/umer.ijaz)
# =============================================================
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
#if ( is.null(opt$legend_size    ) ) { opt$legend_size    = 7.5}
#if ( is.null(opt$x_size    ) ) { opt$x_size    = 5     }
#if ( is.null(opt$x_dirct    ) ) { opt$x_dirct    = 90     }
#if ( is.null(opt$group_size    ) ) { opt$group_size    = 1.5    }
#

# abund_table<-read.csv("SPE_pitlatrine.csv",row.names=1,check.names=FALSE)
# #Transpose the data to have sample names on rows
# abund_table<-t(abund_table)
# otu_table_with_taxonomy_for_R.txt
otu_table = read.delim(paste(opt$input_table_file), row.names= 1,  header=T, sep="\t")
abund_table <- otu_table[,-ncol(otu_table)]
abund_table <-t(abund_table)

# meta_table<-read.csv("ENV_pitlatrine.csv",row.names=1,check.names=FALSE)
# #Just a check to ensure that the samples in meta_table are in the same order as in abund_table
# meta_table<-meta_table[rownames(abund_table),]

#Get grouping information
#grouping_info<-data.frame(row.names=rownames(abund_table),t(as.data.frame(strsplit(rownames(abund_table),"_"))))
# > head(grouping_info)
# X1 X2 X3
# T_2_1   T  2  1
# T_2_10  T  2 10
# T_2_12  T  2 12
# T_2_2   T  2  2
# T_2_3   T  2  3
# T_2_6   T  2  6
design = read.table(paste(opt$input_map_file), header=T, sep="\t") #row.names= 1,
c<-quote(paste(opt$class))
grouping_info <- data.frame(SampleID=design$SampleID,Treatment=design[,eval(c)])

# 过滤数据并排序
#idx = rownames(design) %in% colnames(otu_table) 
idx = design$SampleID %in% rownames(abund_table) 
grouping_info = grouping_info[idx,]


#Load vegan library
library(vegan)
#Get MDS stats
sol<-metaMDS(abund_table,distance = "bray", k = 2, trymax = 50)
# distance : "manhattan", "euclidean", "canberra", "bray", "kulczynski", "jaccard", "gower", "altGower", "morisita", "horn", "mountford", "raup" , "binomial", "chao", "cao" or "mahalanobis"
# K : Number of dimensions.
# try, trymax	: Minimum and maximum numbers of random starts in search of stable solution

#Make a new data frame, and put country, latrine, and depth information there, to be useful for coloring, and shape of points
#NMDS=data.frame(x=sol$point[,1],y=sol$point[,2],Country=as.factor(grouping_info[,1]),Latrine=as.factor(grouping_info[,2]),Depth=as.factor(grouping_info[,3]))
NMDS=data.frame(x=sol$point[,1],y=sol$point[,2],SampleID=as.factor(grouping_info[,1]),Treatment=as.factor(grouping_info[,2]))

#Get spread of points based on Treatments
plot.new()
ord<-ordiellipse(sol, as.factor(grouping_info[,2]) ,display = "sites", kind ="sd", conf = 0.95, label = T)
# ordiellipse(ord, groups, display="sites", kind = c("sd","se", "ehull"),
#              conf, draw = c("lines","polygon", "none"),
#              w = weights(ord, display), col = NULL, alpha = 127, show.groups,
#              label = FALSE, border = NULL, lty = NULL, lwd=NULL, ...)
# kind : standard deviations of points (sd), standard errors (se) or ellipsoid hulls that enclose all points in the group (ehull).
# conf : Confidence limit for ellipses
dev.off()


#Reference: http://stackoverflow.com/questions/13794419/plotting-ordiellipse-function-from-vegan-package-onto-nmds-plot-created-in-ggplo
#Data frame df_ell contains values to show ellipses. It is calculated with function veganCovEllipse which is hidden in vegan package. This function is applied to each level of NMDS (group) and it uses also function cov.wt to calculate covariance matrix.
veganCovEllipse<-function (cov, center = c(0, 0), scale = 1, npoints = 100)
{
  theta <- (0:npoints) * 2 * pi/npoints
  Circle <- cbind(cos(theta), sin(theta))
  t(center + scale * t(Circle %*% chol(cov))) #,pivot=TRUE
}

#Generate ellipse points
df_ell <- data.frame()
for(g in levels(NMDS$Treatment)){
  if(g!="" && (g %in% names(ord))){

    df_ell <- rbind(df_ell, cbind(as.data.frame(with(NMDS[NMDS$Treatment==g,], 
                                                     veganCovEllipse(ord[[g]]$cov,ord[[g]]$center,ord[[g]]$scale))),
                                  Treatment=g))
  }
}

# > head(df_ell)
# NMDS1      NMDS2 Country
# 1 1.497379 -0.7389216       T
# 2 1.493876 -0.6800680       T
# 3 1.483383 -0.6196981       T
# 4 1.465941 -0.5580502       T
# 5 1.441619 -0.4953674       T
# 6 1.410512 -0.4318972       T

#设置每个分组的标签
#Generate mean values from NMDS plot grouped on Treatment or even sample ID
NMDS.mean=aggregate(NMDS[,1:2],list(group=NMDS$Treatment),mean)

# > NMDS.mean
# group          x          y
# 1     T -0.2774564 -0.2958445
# 2     V  0.1547353  0.1649902

#Now do the actual plotting
library(ggplot2)

#可以自定义形状
#shape_values<-seq(1,82)

p<-ggplot(data=NMDS,aes(x,y,colour=Treatment))
p<-p+ annotate("text",x=NMDS.mean$x,y=NMDS.mean$y,label=NMDS.mean$group,size=4)
p<-p+ geom_path(data=df_ell, aes(x=NMDS1, y=NMDS2), size=1, linetype=2)
p<-p + geom_point(aes(color=Treatment,shape=Treatment))+theme_bw()  #+scale_shape_manual(values=shape_values)
pdf(paste(opt$output_file),width=8,height=8)
print(p)
dev.off()
