##setting work directory##
## setwd("C:/Users/Vivekr/Desktop/slug injection/Nilgiris26-27Aug") 

## reading all files from the diectory##
Nilgiris = list.files(pattern="*.csv")
for (i in 1:length(Nilgiris)) assign(Nilgiris[i], read.csv(Nilgiris[i]))

## an import function that makes vectors of each header in the file and drops NA's ##
import<-function(Nilgiris)
{
  for (i in 1:length(Nilgiris))
    dataraw<- read.csv(Nilgiris[i],skip=5, stringsAsFactors = F) 
  data <- lapply(as.list(dataraw), function(x){x[!is.na(x)]}) 
}

##Applying the import function to object Nilgiris##
dataList <-lapply( Nilgiris, FUN = import) 

##For calculating discharge for each trial##

discharge<-NULL

SaltSluginjection<-                                   
  function(data=dataList)
  {
    for(i in 1:length(dataList)){
      conc<-seq(0,0,7)
      conc[1]<-0/980
      conc[2]<-(dataList[[i]]$standardgm*10*1000)/(980+10)
      conc[3]<-(dataList[[i]]$standardgm*20*1000)/(980+20)
      conc[4]<-(dataList[[i]]$standardgm*30*1000)/(980+30)
      conc[5]<-(dataList[[i]]$standardgm*40*1000)/(980+40)
      conc[6]<-(dataList[[i]]$standardgm*50*1000)/(980+50)
      conc[7]<-(dataList[[i]]$standardgm*60*1000)/(980+60)
      mod1<-lm(conc~dataList[[i]]$eccalib)
      k<-mod1$coef[2]
      ec0<-dataList[[i]]$ecdata[1]
      discharge[i]<-(dataList[[i]]$saltgm)/(sum((dataList[[i]]$ecdata-ec0)*5*k))
    }
    return(discharge)
  }


Discharge<-SaltSluginjection(dataList)

##For time-series EC-plots for each trial##

pdf("test_Nilgiris_26Aug_ECplots.pdf",width=11,height=8,paper="a4r")
par(mfcol=c(3,3))
ECplot<-(data=dataList)
{
  for(i in 1:length(dataList)) 
    plot.ts(dataList[[i]]$ecdata, main=Nilgiris[i], sub=Discharge[i], xlab = "Time", ylab = "Electrical Conductivity")
}
dev.off()

##creating a data frame and file for further analysis##
Nilgiris_name<-"WLR"
Discharge_name<-"discharge"
Output <- data.frame(Nilgiris,Discharge)
names(Output) <- c(Nilgiris_name,Discharge_name)
print(Output)
write.table(Output,"Output.txt",row.names=F,quote=FALSE)


rm(list=ls())

