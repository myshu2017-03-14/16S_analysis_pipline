#!/usr/bin/Rscript
#---------------------------------------------------------------+
#     author: Myshu                                             
#     mail:1291016966@qq.com                                    
#     version:1.0                                               
#     date :2018-7-17
#     description:   
#---------------------------------------------------------------+
library(getopt)
spec = matrix(c(
  'input_res_file', 'i', 1, "character",
  'output_file' , 'o' , 1, "character",
  'output_res_file' , 'r' , 1, "character",
  'help'  , 'h', 0, "logical"

), byrow=TRUE, ncol=4);
opt = getopt(spec);

# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) {
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
#if ( is.null(opt$x_size    ) ) { opt$x_size    = 5   }
library(stats)
# 总共5列，第一列biomarker名称，第二列是平均丰度最大的log10的值，如果平均丰度小于10的按照10来计算，第三列是差异基因或物种富集的组名称，第四列是LDA值，第五列是Kruskal-Wallis秩和检验的p值，如果不是biomarker则用“-”表示
res_table <- read.csv(paste(opt$input_res_file),sep='\t',header=F,check.names=F,na.strings = "") # row.names= 1,
#head(res_table)
#res_table[,4]
#head(res_table)
res_table <- res_table[res_table[,5]!="-",]
#res_table[is.na(res_table)] <- c("") 
# remove na values
res_table <- na.omit(res_table)
#res_table

p <- res_table[,5]
p <- as.numeric(as.character(p))
#as.numeric(levels(p))[p]
#p
#length(p)
FDR <- p.adjust(p,method = "BH",n = length(p))
#FDR
out <- data.frame(res_table,fdr=FDR,check.names = F)
out <- out[out$fdr<0.05,]
out_res <- out[1:5]
#out_res
# output the p and fdr table
write.table(out, file = paste(opt$output_file), append = F, quote = FALSE, sep = "\t", row.names = FALSE,
            col.names = FALSE)
# output new res file for downside analysis
write.table(out_res, file = paste(opt$output_res_file), append = F, quote = FALSE, sep = "\t", row.names = FALSE,
            col.names = FALSE)



