# interdg


R package interdg allows to perform over-representative analysis on a vector of genes with drug database DGldb v3 comprising interactions between 12498 drugs and 4187 genes



## Script used in the package

> library(interdg)

### import data

> data(custom)

### or transform limma results in gene vector

> custom<-geneqvectordg(limma_res,updown="up",thres=0.5,q=0.05)


### compute of over-representative analysis on custum vector of genes

> res<-computedrugs(custom)


### plot barplot of the analysis

> plotdrugs(res, n=10, font=14, label=5)

![barplots](https://github.com/cdesterke/interdg/blob/main/barplots.png)


### plot heatmap of jaccard index between significant drugs

> df<-jaccarddrugs(custom,res,nb=10, xmarg=22,ymarg=22)

![heatmap](https://github.com/cdesterke/interdg/blob/main/heatmap.png)

### perform alluvial plot for drugs and genes set during jaccarddrugs analysis

> alluvialdruggs(df,font=18)

![alluvial](https://github.com/cdesterke/interdg/blob/main/alluvial.png)
