library(dplyr)
library(furrr)

#Conversion Factors (CF) Power analysis - see WG-SAM-2025/01

#This script builds a monthly dataset which contains CF values,
#for a number of sets and a number of samples in each set.
#CF values are randomly drawn from a Normal distribution for each set.
#That monthly dataset is then multiplied by 1.03 to generate a new dataset,
#and a t-test is executed on these two datasets.

#Normal distributions for Means and SDs
SD_mean=0.07
SD_sd=0.03
Mean_mean=1.625
Mean_sd=0.10


#Part 1 - just a single run
Nsets=30 #Number of sets in a month
Nsamples=50 #Number of samples in each set

#Generate per-set Mean and SD
M_sd=data.frame(
  Mean=rnorm(n=Nsets,mean=Mean_mean,sd=Mean_sd),
  SD=pmax(0,rnorm(n=Nsets,mean=SD_mean,sd=SD_sd))
)

#Generate CF values for each set
CFs=apply(M_sd, 1, function(x) rnorm(Nsamples, mean=x[1], sd=x[2]))
#CFs has a column per set and a row per sample

#Now multiply it by 1.03
CFs_m=CFs*1.03

#Put data in a dataframe for t.test
Dat=data.frame(
  Grp=rep(c(1,2),each=Nsets*Nsamples), #Identify CFs as group 1, and CFs_m as group 2
  CF=c(CFs,CFs_m)
)
# mean(Dat$CF[Dat$Grp==1])*1.03   should equal   mean(Dat$CF[Dat$Grp==2])
 

#Run t-test
Ttest=t.test(CF ~ Grp, data = Dat)
Ttest$p.value





#Part 2 - now run this many times for different combinations of Nsets and Nsamples, in parallel.
#To run in parallel, we put a single run into a function (called Powerruns()), then that function
#will be executed in parallel using future_map_dfr().

Powerruns=function(run){
  Out=NULL #Store output here
  for(nsets in Nsets){ #Number of sets in a month
    for(nsamples in Nsamples){ #Number of samples in each set
      #Generate per-set Mean and SD
      M_sd=data.frame(
        Mean=rnorm(n=nsets,mean=Mean_mean,sd=Mean_sd),
        SD=pmax(0,rnorm(n=nsets,mean=SD_mean,sd=SD_sd)) #We use pmax(0,...) to keep only positive values
      )
      #Generate CF values for each set given the per-set Mean and SD
      CFs=apply(M_sd, 1, function(x) rnorm(nsamples, mean=x[1], sd=x[2]))
      #CFs has a column per set and a row per sample
      #Now multiply it by 1.03
      CFs_m=CFs*1.03
      #Put data in dataframe for t.test
      Dat=data.frame(
        Grp=rep(c(1,2),each=nsets*nsamples), #Identify CFs as group 1 and CFs_m as group 2 > for t-test
        CF=c(CFs,CFs_m)
      )
      #Run t-test
      Ttest=t.test(CF ~ Grp, data = Dat)
      #Store results
      Out=rbind(Out,data.frame(
        Nset=nsets,
        Nsample=nsamples,
        Pval=Ttest$p.value
      ))
    }
  }
  return(Out)
}


#Run in parallel
Ntimes=5000 #Number of iterations
Nsets=seq(2,10,by=1)
Nsamples=seq(5,40,by=1)

plan(multisession, workers= availableCores()-2) #start workers
Out = future_map_dfr(.x=1:Ntimes, .f=Powerruns, .options = furrr_options(seed = TRUE), .progress=T)
plan(sequential) #stop workers


#Compute the % of tests that are <0.05
Out=Out%>%group_by(Nset,Nsample)%>%summarise(P=100*length(which(Pval<0.05))/Ntimes,.groups = 'drop')

# Save output
write.csv(Out,"SimOut.csv",row.names=F)

# Plot results
png(filename="CF_Power_Simulated.png", width = 2000, height = 3000,res=200)
par(mfrow=c(2,1))
par(mai=c(0.8,0.8,0.2,0.1),cex=1.5,lend=1)

#Top panel
YL=c(0,100)
XL=range(Out$Nsample)
#Smallest number of sets
plot(Out$Nsample[Out$Nset==Nsets[1]],Out$P[Out$Nset==Nsets[1]],
     type="l",xlim=XL,ylim=YL,xlab="",
     ylab="",col="red",lwd=3,axes=F)
iok=which(Out$P>=80 & Out$Nset==Nsets[1])[1]
text(Out$Nsample[iok],YL[1],Out$Nsample[iok],col="red",cex=1.5,xpd=T,adj=c(0.5,1))
segments(x0=Out$Nsample[iok],
         y0=YL[1],
         x1=Out$Nsample[iok],
         y1=Out$P[iok],lty=2,lwd=0.5,col="grey")

#Medium number of sets
par(new=T)
plot(Out$Nsample[Out$Nset==Nsets[round(length(Nsets)/2)]],
     Out$P[Out$Nset==Nsets[round(length(Nsets)/2)]],
     type="l",xlim=XL,ylim=YL,xlab="",ylab="",col="green",lwd=3,axes=F)
iok=which(Out$P>=80 & Out$Nset==Nsets[round(length(Nsets)/2)])[1]
text(Out$Nsample[iok],YL[1],Out$Nsample[iok],col="green",cex=1.5,xpd=T,adj=c(0.5,1))
segments(x0=Out$Nsample[iok],
         y0=YL[1],
         x1=Out$Nsample[iok],
         y1=Out$P[iok],lty=2,lwd=0.5,col="grey")

#largest number of sets
par(new=T)
plot(Out$Nsample[Out$Nset==Nsets[length(Nsets)]],Out$P[Out$Nset==Nsets[length(Nsets)]],
     type="l",xlim=XL,ylim=YL,xlab="",ylab="",col="blue",lwd=3,axes=F)
iok=which(Out$P>=80 & Out$Nset==Nsets[length(Nsets)])[1]
text(Out$Nsample[iok],YL[1],Out$Nsample[iok],col="blue",cex=1.5,xpd=T,adj=c(0.5,1))
segments(x0=Out$Nsample[iok],
         y0=YL[1],
         x1=Out$Nsample[iok],
         y1=Out$P[iok],lty=2,lwd=0.5,col="grey")

axis(1,pos=YL[1],tcl=-0.3)
axis(2,pos=XL[1],las=1,tcl=-0.3)

text(mean(XL),YL[2],"Simulated data",xpd=T,adj=c(0.5,-0.5),cex=1.5)
text(mean(XL),YL[1],"Number of samples per set",xpd=T,adj=c(0.5,5))
text(XL[1],mean(YL),"Power (% tests with p-value<0.05)",xpd=T,adj=c(0.5,-4.5),srt=90)

abline(h=80,lty=2)
legend("bottomright",inset=c(0.05,0.1),
       legend=c(Nsets[1],Nsets[round(length(Nsets)/2)],Nsets[length(Nsets)]),
       col=c("red","green","blue"),lwd=3,title="Number of sets per month:",bty="n")


#Bottom panel
Curv=Out%>%group_by(Nset)%>%summarise(Nok=Nsample[which(P>=80)[1]],.groups = 'drop')

XL=range(Nsets)
YL=range(Nsamples)
plot(Curv$Nset,Curv$Nok,type="l",lwd=3,col="black",
     xlab="",
     ylab="",
     xlim=XL,ylim=YL,axes=F)
polygon(x=c(Curv$Nset,XL[c(2,1)],Curv$Nset[1]),
        y=c(Curv$Nok,YL[c(1,1)],Curv$Nok[1]),
        col="grey",border=NA)
axis(1,pos=YL[1],tcl=-0.3)
axis(2,pos=XL[1],las=1,tcl=-0.3)

text(XL[1],YL[1],"Power<80%",adj=c(-0.05,-0.4))

text(mean(XL),YL[1],"Number of sets per month",xpd=T,adj=c(0.5,5))
text(XL[1],mean(YL),"Number of samples per set",xpd=T,adj=c(0.5,-4.5),srt=90)


dev.off()