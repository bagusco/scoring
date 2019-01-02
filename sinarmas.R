alamat<-"E:/STATISTIKA/190103-04 Training Sinarmas/"
scoring<-read.csv(paste0(alamat,"datascoring.csv"))
scoring1<-rbind(scoring,scoring,scoring,scoring,scoring,scoring,scoring)[1:15857,]
n1<-nrow(scoring1)
p<-.1
set.seed(2019)
#
scoring1$Age<-scoring1$Age+sample(-2:2,n1,replace=T)
#
idx3<-sample(1:n1,p*n1)
scoring1$Gender[idx3]<-ifelse(scoring1$Gender[idx3]=="MALE","FEMALE","MALE")
#
idx4<-sample(1:n1,p*n1); RO<-rep(NA,length(idx4))
res<-c("RENT","OTHERS","PARENTS","OWNED")
for (i in 1:4){
  idx4a<-which(scoring1$Residence.Ownership[idx4]==res[i])
  RO[idx4a]<-sample(res[-i],length(idx4a),replace=T)
  # RO[idx4a]<-sample(res[c(i-1,i+1)][!is.na(res[c(i-1,i+1)])],length(idx4a),replace=T)
  # if (i==1) {RO[idx4a]<-rep(res[2],length(idx4a))
  # } else if (i==4) {RO[idx4a]<-rep(res[3],length(idx4a))
  # } else RO[idx4a]<-sample(res[c(i-1,i+1)],length(idx4a),replace=T)
}; scoring1$Residence.Ownership[idx4]<-RO
#
idx5<-sample(1:n1,p*n1); NOD<-rep(NA,length(idx5))
for (i in 1:6){
  idx5a<-which(scoring1$number.of.dependants[idx5]==(0:5)[i])
  NOD[idx5a]<-sample((0:5)[-i],length(idx5a),replace=T)
  # NOD[idx5a]<-sample((0:5)[c(i-1,i+1)][!is.na((0:5)[c(i-1,i+1)])],length(idx5a),replace=T)
  # if (i==1) {NOD[idx5a]<-rep(1,length(idx5a))
  # } else if (i==6) {NOD[idx5a]<-rep(4,length(idx5a))
  # } else NOD[idx5a]<-sample((0:5)[c(i-1,i+1)],length(idx5a),replace=T)
}; scoring1$number.of.dependants[idx5]<-NOD
#table(scoring1$number.of.dependants)
#
scoring1<-scoring1[sample(1:n1),]
scoring1$ID<-1:n1
#
write.csv(scoring1,file=paste0(alamat,"scoringtest.csv"),row.names = F,quote=F)
