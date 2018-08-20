#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-6-13
#     description: plot bar plots for otu_table
#---------------------------------------------------------------+
library(getopt)
# get options, using the spec as defined by the enclosed list.
# character logical integer double
spec = matrix(c(
  'input_file', 'i', 1, "character",
  'help'  , 'h', 0, "logical",
  'min' , 'n', 1, "integer",
  'max' , 'm', 1, "integer",
  'step' , 's', 1 ,"integer",
  'output_file' , 'o' , 1, "character"
), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}

library(ggplot2)
data <- read.table(paste(opt$input_file),sep='\t',header=F)

min_raw <- opt$min
max_raw <- opt$max
step <- opt$step

m<-seq(0,min_raw,by=min_raw)   
min <-data.frame(table(cut(data$V2,m,dig.lab = 4)) )
min$Var1 <- paste("<=",min_raw,sep = "")

m<-seq(min_raw,max_raw,by=step) 
med<-data.frame(table(cut(data$V2,m,dig.lab = 4)) )  

max <- max(data$V2)
len <- max-max_raw
m<-seq(max_raw,max,by=len)   
max <-data.frame(table(cut(data$V2,m,dig.lab = 4)) )
max$Var1<- paste(">",max_raw,sep = "")

t <- rbind(min,med,max)

ggplot(t,aes(x = Var1,y = Freq )) + geom_bar(stat = "identity",fill="skyblue") +
  scale_x_discrete(limits=t$Var1)+
  theme(axis.text.x = element_text(angle = 30,hjust = .5, vjust = .5)) +
  xlab("Read Length")

ggsave(paste(opt$output_file))
