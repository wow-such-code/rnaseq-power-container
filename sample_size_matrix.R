library(RnaSeqSampleSize)
library(heatmap3)
#library(RColorBrewer)

#colors <- colorRampPalette(brewer.pal(9,"Blues"))(100)

colors = matlab::jet.colors(1000)

args <- commandArgs(trailingOnly = TRUE)
print(args)

mode <- args[1] # mode: data, tcga, none
m <- as.numeric(args[2]) # number of genes
m1 <- as.numeric(args[3]) # expected number of DE genes
f <- as.numeric(args[4]) # FDR
main = "test" # needed, otherwise 'm' screws up the results

if(mode=="none") {
  phi0 <- as.numeric(args[5]) # dispersion
  lambda0 <- as.numeric(args[6]) # avg. read count/gene
  result_file <- args[7]
  result<-optimize_parameter(fun=sample_size,main=main,opt1="rho", opt2="power",opt1Value=c(1.5,2,3,4), opt2Value=c(0.5,0.6,0.7,0.8,0.9,0.95), lambda0=lambda0, m=m, m1=m1, phi0=phi0, f=f)
}
if(mode=="data") {
  counts_file_path <- args[5]
  tab = read.table(counts_file_path, header=TRUE, sep="\t")
  # only keep read counts
  tab = tab[sapply(tab, is.numeric)]
  counts <- as.matrix(tab[-1,-1])
  dim(counts)
  # if there are less than 1000 genes we need to create more data, as RNASeqSampleSize doesn't work otherwise...
  if(nrow(counts) < 1000) {
    copies <- ceiling(1000/nrow(counts))
    counts <- do.call(rbind, replicate(copies, counts, simplify=FALSE))
  }
  distrObject <- est_count_dispersion(counts)
  
}
if(mode=="tcga") {
  distrObject <- args[5]
  #data(list = distrObject)
}
if(mode=="tcga" || mode=="data") {
  result_file <- args[6]
  result<-optimize_parameter(fun=sample_size_distribution,main=main,opt1="rho", opt2="power",opt1Value=c(1.5,2,3,4), opt2Value=c(0.5,0.7,0.9,0.95),distributionObject=distrObject, m=m, m1=m1,f=f)  
}
print(result)
pdf(result_file)
heatmap3(result, Colv = NA, Rowv = NA, xlab = "Log fold change", ylab = "Sensitivity (power)", scale = "n", col = colors, cexCol = 1, cexRow = 1, lasCol = 1, lasRow = 1, main = "Minimum sample size (per group)")
dev.off()
