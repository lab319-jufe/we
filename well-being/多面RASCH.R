library(ggplot2)
library(magrittr)
library(stringr)
library(TAM)
library(reshape2)
options(stringsAsFactors = FALSE)

data <- read.csv("E:\\华创杯报告\\处理数据\\清洗后数据.csv")

#===================================================================
#                             编码:好2，接近1，差0
#===================================================================

#收入
#比过去d032，比其他人d033，比付出d034

data$d032[which(data$d032=='高')] <- 2
data$d032[which(data$d032=='一样')] <- 1
data$d032[which(data$d032=='低')] <- 0

data$d033[which(data$d033=='高')] <- 2
data$d033[which(data$d033=='一样')] <- 1
data$d033[which(data$d033=='低')] <- 0

data$d034[which(data$d034=='高')] <- 2
data$d034[which(data$d034=='接近')] <- 1
data$d034[which(data$d034=='低')] <- 0

income <- data.frame(data$d032,data$d033,data$d034)

income <- melt(income,id.vars = c(),variable.name = 'facets',value.name = 'x1')

income$facets <- as.character(income$facets)

income[which(income$facets == 'data.d032'),]$facets <- 'before' 
income[which(income$facets == 'data.d033'),]$facets <- 'other' 
income[which(income$facets == 'data.d034'),]$facets <- 'expense' 

#就业 
#比过去e011，比其他人e012，比付出


data$e011[which(data$e011=='好')] <- 2
data$e011[which(data$e011=='一样')] <- 1
data$e011[which(data$e011=='差')] <- 0

data$e012[which(data$e012=='好')] <- 2
data$e012[which(data$e012=='一样')] <- 1
data$e012[which(data$e012=='差')] <- 0

data$e011 <- as.numeric(data$e011) 

data$e012 <- as.numeric(data$e012)

job <- data.frame(data$e011,data$e012,rep(NA,nrow(data)))

job <- melt(job,id.vars = c(),variable.name = 'facets',value.name = 'x2')

job$facets <- as.character(job$facets)

job[which(job$facets == 'data.e011'),]$facets <- 'before' 
job[which(job$facets == 'rep.NA..nrow.data..'),]$facets <- 'expense' 
job[which(job$facets == 'data.e012'),]$facets <- 'other' 


#医疗
#比过去f09，比其他人，比付出f010

data$f09[which(data$f09=='好')] <- 2
data$f09[which(data$f09=='一样')] <- 1
data$f09[which(data$f09=='差')] <- 0

data$f010[which(data$f010=='值')] <- 2
data$f010[which(data$f010=='差不多')] <- 1
data$f010[which(data$f010=='不值')] <- 0

medical <- data.frame(data$f09,rep(NA,nrow(data)),data$f010)

medical <- melt(medical,id.vars = c(),variable.name = 'facets',value.name = 'x3')

medical$facets <- as.character(medical$facets)

medical[which(medical$facets == 'data.f09'),]$facets <- 'before' 
medical[which(medical$facets == 'rep.NA..nrow.data..'),]$facets <- 'other' 
medical[which(medical$facets == 'data.f010'),]$facets <- 'expense' 


#环境
#比过去g6，比其他人g7，比付出

data$g6[which(data$g6=='好')] <- 2
data$g6[which(data$g6=='一样')] <- 1
data$g6[which(data$g6=='差')] <- 0

data$g7[which(data$g7=='好')] <- 2
data$g7[which(data$g7=='一样')] <- 1
data$g7[which(data$g7=='差')] <- 0

envir <- data.frame(data$g6,data$g7,rep(NA,nrow(data)))

envir <- melt(envir,id.vars = c(),variable.name = 'facets',value.name = 'x4')

envir$facets <- as.character(envir$facets)

envir[which(envir$facets == 'data.g6'),]$facets <- 'before' 
envir[which(envir$facets == 'rep.NA..nrow.data..'),]$facets <- 'expense' 
envir[which(envir$facets == 'data.g7'),]$facets <- 'other' 


#教育
#比过去h16，比其他人h17，比付出h18

data$h16[which(data$h16=='好')] <- 2
data$h16[which(data$h16=='一样')] <- 1
data$h16[which(data$h16=='差')] <- 0

data$h17[which(data$h17=='好')] <- 2
data$h17[which(data$h17=='一样')] <- 1
data$h17[which(data$h17=='差')] <- 0

data$h18[which(data$h18=='值')] <- 2
data$h18[which(data$h18=='差不多')] <- 1
data$h18[which(data$h18=='不值')] <- 0

data$h16 <- as.numeric(data$h16)

data$h17 <- as.numeric(data$h17)

data$h18 <- as.numeric(data$h18)

educat <- data.frame(data$h16,data$h17,data$h18)

educat <- melt(educat,id.vars = c(),variable.name = 'facets',value.name = 'x5')

educat$facets <- as.character(educat$facets)

educat[which(educat$facets == 'data.h16'),]$facets <- 'before' 
educat[which(educat$facets == 'data.h17'),]$facets <- 'other' 
educat[which(educat$facets == 'data.h18'),]$facets <- 'expense' 

#安全
#比过去i3，比其他人i4，比付出
data$i3[which(data$i3=='好')] <- 2
data$i3[which(data$i3=='一样')] <- 1
data$i3[which(data$i3=='差')] <- 0

data$i4[which(data$i4=='好')] <- 2
data$i4[which(data$i4=='一样')] <- 1
data$i4[which(data$i4=='差')] <- 0

secure <- data.frame(data$i3,data$i4,rep(NA,nrow(data)))

secure <- melt(secure,id.vars = c(),variable.name = 'facets',value.name = 'x6')

secure$facets <- as.character(secure$facets)

secure[which(secure$facets == 'data.i3'),]$facets <- 'before' 
secure[which(secure$facets == 'rep.NA..nrow.data..'),]$facets <- 'expense' 
secure[which(secure$facets == 'data.i4'),]$facets <- 'other' 

#===================================================================
#                             合并数据
#===================================================================


moddata <- data.frame(income,job[2],medical[2],envir[2],educat[2],secure[2])


#===================================================================
#                            建立模型  
#===================================================================

resp  <- cbind(moddata$x1,moddata$x2,moddata$x3,moddata$x4,moddata$x5,moddata$x6)

resp <- apply(resp,2,as.numeric)%>%cbind()

facets <- moddata$facets

facets[which(facets=='before')] <- 1

facets[which(facets=='other')] <- 2

facets[which(facets=='expense')] <- 3

facets <- data.frame(fac = as.numeric(facets))

formula <- ~ item+fac+item*fac 

mod <- TAM::tam.mml.mfr(resp=resp, facets=facets,formulaA=formula)

write.xlsx(data.frame(mod$xsi.facets),'E:\\华创杯报告\\处理数据\\RASCH模型参数.csv')

summary(mod)
