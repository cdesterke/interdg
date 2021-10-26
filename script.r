library(data.table)
db<-fread("db.csv",sep=";")
library(data.table)
interactions<-fread("interactions.csv",sep=";")

#db<-read.table("db.txt",sep="\t",h=T)
library(dplyr)

dbu %>% count(.,drug_name,gene_name, sort = TRUE) %>% filter(complete.cases(.))->count

library(tidyr)
db$value<-1
db%>%unique()->dbu
dbu %>%  pivot_wider(names_from = gene_name , values_from = value, values_fill = 0)-> large




# list conversion


list<-apply(large,1,function(x) which(x==1))
names(list)<-large$drug_name

custom<-c("CYP3A4","KCNH2","PLAU","ABCC1","ABCB1","SLC6A4","TYMS","ADRA1A","ADRA1B","ADRA1D")

### essai intersect  : intersect(custom,names(list$VERAPAMIL))

##start analysis
computedrugs<-function(custom){
	
	if(!require(dplyr)){
    		install.packages("dplyr")
    		library(dplyr)}

	#data(large)
	#data(list)
	#data(interactions)

	drugs <- large$drug_name
	drugs <- as.data.frame(drugs)

	for(i in 1:length(list)){
		drugs$intersect[i]<-length(intersect(custom,names(list[[i]])))}
	drugs$input<-length(custom)
	for(i in 1:length(list)){
		drugs$perturbagens[i]<-length(names(list[[i]]))}
	drugs$totaldb<-length(unique(unlist(names(list))))


	drugs<-drugs[(drugs$intersect != "0"),]
	df<-drugs[with(drugs,order(-intersect)),]

	row.names(df)<-df$drugs
	df$drugs<-NULL


	res1 <- NULL
	for (i in 1:nrow(df)){
  		table <- matrix(c(df[i,1], df[i,2], df[i,3], df[i,4]), ncol = 2, byrow = TRUE)
  		o <- fisher.test(table, alternative="two.sided")$estimate
  		# save all odds in a vector
  		res1 <- c(res1,o)
		}
	df$ES <- res1



	res2 <- NULL
	for (i in 1:nrow(df)){
  		table <- matrix(c(df[i,1], df[i,2], df[i,3], df[i,4]), ncol = 2, byrow = TRUE)
  	p <- fisher.test(table, alternative="two.sided")$p.value
  	# save all p values in a vector
  	res2 <- c(res2,p)
	}
	df$pvalues <- res2


	df$qvalues<-p.adjust(df$pvalues,method="fdr")
	df<-df[with(df,order(qvalues)),]
	df2<-df[(df$intersect > 1),]

	##annotations (84 classes interactions)

	interactions%>%distinct(drug_name,.keep_all=T)->interactions
	df2$drug_name<-row.names(df2)

	interactions%>%right_join(df2,by="drug_name")->df2
	
	df2$interaction_types[is.na(df2$interaction_types)] <- "undefined"

	df2<-df2[with(df2,order(pvalues)),]
	write.table(df2,file="drugsresults.tsv",sep="\t",row.names=F)
	df2
}




#graph

library(ggplot2)
library(pals)

p=ggplot(data=df2,aes(x=reorder(drug_name,-log(pvalues)),y=-log(pvalues),fill=interaction_types))+geom_bar(stat="identity")+
coord_flip()+theme_minimal()
p
p +  xlab("Genesets") + ylab("Enrichment score")
p + scale_fill_manual(values=cols25())+
geom_text(aes(label=round(ES,2)),hjust=0, vjust=0.5,color="black",position= position_dodge(0),size=6,angle=0)+
xlab("Gene sets") + ylab("Enrichment score")+
ggtitle("Enriched Drugs") +theme(text = element_text(size = 16))