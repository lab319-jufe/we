library(ggplot2)
library(magrittr)
library(stringr)
library(TAM)
library(reshape2)
library(VGAM)
library(dplyr)
library(MASS)

options(stringsAsFactors = FALSE)

load("E:\\华创杯报告\\处理数据\\mydata2.Rdata")

data <- mydata2

rm(mydata2)

#===================================================================
#                         实际在家人数
#===================================================================


pop <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  pop[i] <- sum((apply(data[aa],2,as.numeric)%>%cbind()==1)[i,],na.rm = T)
}

data$实际在家人数 <- pop



#===================================================================
#                           低保人口数
#===================================================================

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  pop1[i] <- sum((apply(data[dd],2,as.numeric)%>%cbind()==1)[i,],na.rm = T)
}

data$低保人数 <- pop1


#===================================================================
#                            有养老金的人数
#===================================================================

aa1 <- paste0('a1',1:8)

data$有养老金的人数 <- apply(data[aa1]>60,1,function(x){sum(x,na.rm = T)})

#===================================================================
#                     收稻谷、经济作物和养禽类的收入
#===================================================================

income  <- rep(NA,nrow(data))

for(i in 1:nrow(data)){
  
  if(is.na(data$d06[i])){
  
    income[i] <- NA
    
  }else{
    
    income[i] <- sum(data$d06[i],na.rm = T)
    
  }
  
}

data$稻谷收入 <- income

income  <- rep(NA,nrow(data))

for(i in 1:nrow(data)){
  
  if(is.na(data$d010[i])){
  
    income[i] <- NA
    
  }else{
    
    income[i] <- sum(data$d010[i],na.rm = T)
    
  }
  
}

data$经济作物收入 <- income

income  <- rep(NA,nrow(data))

for(i in 1:nrow(data)){
  
  if(is.na(data$d014[i])){
  
    income[i] <- NA
    
  }else{
    
    income[i] <- sum(data$d014[i],na.rm = T)
    
  }
  
}

data$养鸡收入 <- income

#===================================================================
#                     收稻谷、经济作物和养禽类的成本
#===================================================================

income  <- rep(NA,nrow(data))

for(i in 1:nrow(data)){
  
  if(is.na(data$d07[i])|is.na(data$d011[i])|is.na(data$d013[i])){
    
    income[i] <- NA
    
  }else{
    
    income[i] <- sum(data$d07[i],data$d011[i],data$d013[i],na.rm = T)
    
  }
  
}

data$稻经鸡成本 <- income


#===================================================================
#                             打工人数
#===================================================================

dd <- c(paste0('e1',1:8),paste0('e2',1:8))

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  pop1[i] <- sum((apply(data[dd],2,as.numeric)%>%cbind()==1)[i,],na.rm = T)
}

data$打工人数 <- pop1

#===================================================================
#                             有医保的人数
#===================================================================

dd <- paste0('f1',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){

    pop1[i] <- sum((apply(data[dd],2,as.numeric)%>%cbind()==1)[i,],na.rm = T)

    }

data$医保人数 <- pop1


#===================================================================
#                     患有需要长期治疗疾病的人数
#===================================================================


dd <- paste0('f3',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  
  pop1[i] <- sum((apply(data[dd],2,as.numeric)%>%cbind()==1)[i,],na.rm = T)
  
}

data$长病人数 <- pop1

#===================================================================
#                     住院人数
#===================================================================


dd <- paste0('f7',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  
  pop1[i] <- sum((apply(data[dd],2,as.numeric)%>%cbind()==1)[i,],na.rm = T)
  
}

data$住院人数 <- pop1

#===================================================================
#                     处于义务教育阶段的人数
#===================================================================


dd <- paste0('h2',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  
  pop1[i] <- sum((apply(data[dd],2,as.numeric)%>%cbind()==1)[i,],na.rm = T)
  
}

data$义务教育人数 <- pop1


#===================================================================
#                         每天工作时长
#===================================================================

dd <- paste0('e5',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  
  if(sum(is.na((apply(data[dd],2,as.numeric)%>%cbind())[i,]))==8){
    pop1[i] <- NA
  }else{
    pop1[i] <- mean((apply(data[dd],2,as.numeric)%>%cbind())[i,],na.rm = T)
  }
  
}


pop1[which(data$打工人数==0)] <- 0

data$工作时长 <- pop1

#===================================================================
#                          打工收入
#===================================================================

dd <- paste0('e10',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  if(sum(is.na((apply(data[dd],2,as.numeric)%>%cbind())[i,]))==8){
    pop1[i] <- NA
  }else{
    pop1[i] <- sum((apply(data[dd],2,as.numeric)%>%cbind())[i,],na.rm = T)
  }
}

data$打工收入 <- pop1


#===================================================================
#                          打工收入
#===================================================================

dd <- paste0('e9',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  if(sum(is.na((apply(data[dd],2,as.character)%>%cbind())[i,]))==8){
    pop1[i] <- NA
  }else if(sum((apply(data[dd],2,as.numeric)%>%cbind())[i,]==2,na.rm = T)>0){
    pop1[i] <- 0
  }else{
    pop1[i] <- 1
  }
}

data$安全 <- pop1
#===================================================================
#                           学习情况
#===================================================================

dd <- paste0('h9',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  if(sum(is.na((apply(data[dd],2,as.character)%>%cbind())[i,]))==8){
    pop1[i] <- NA
  }else if(sum((apply(data[dd],2,as.character)%>%cbind())[i,]==1,na.rm = T)>0){
    pop1[i] <- 1
  }
}

pop1[which(data$义务教育人数==0)] <- 0

data$学习成绩 <- pop1

#===================================================================
#                           公立私立
#===================================================================

dd <- paste0('h7',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  if(sum(is.na((apply(data[dd],2,as.character)%>%cbind())[i,]))==8){
    pop1[i] <- NA
  }else if(sum((apply(data[dd],2,as.character)%>%cbind())[i,]=='公立',na.rm = T)>0){
    pop1[i] <- 1
  }
}


pop1[which(data$义务教育人数==0)] <- 0

data$公立学校 <- pop1
#===================================================================
#                           村外上学
#===================================================================

dd <- paste0('h5',1:8)


pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  if(sum(is.na((apply(data[dd],2,as.character)%>%cbind())[i,]))==8){
    pop1[i] <- NA
  }else if(sum((apply(data[dd],2,as.character)%>%cbind())[i,]=='村里',na.rm = T)>0){
    pop1[i] <- 0
  }else if(sum((apply(data[dd],2,as.character)%>%cbind())[i,]!='村里',na.rm = T)>0){
    pop1[i] <- 1
  }
}


pop1[which(data$义务教育人数==0)] <- 0

data$村外上学 <- pop1

#===================================================================
#                             收入情况
#===================================================================

d032 <- as.character(data$d032)
d032[d032=='低'] <- 1
d032[d032=='一样'] <- 2
d032[d032=='高'] <- 3
d032 <- factor(d032,levels = c(1,2,3),labels = c('低','中','高'))
data$d032 <- d032 

f09 <- as.character(data$f09)
f09[f09=='好'] <- 2
f09[f09=='一样'] <- 1
f09[f09=='差'] <- 0
f09 <- factor(f09,levels = c(0,1,2),labels = c('差','一样','好'))
data$f09 <- f09 


#===================================================================
#                             多长时间吃一次
#===================================================================

b5 <- as.character(data$b5)
b5[b5=='因吃不起从来不吃'] <- 0
b5[b5=='隔三差五吃（一周不少于1次）'] <- 3
b5[b5=='有时吃（一个月不少于1次）'] <- 2
b5[b5=='仅逢年过节吃'] <- 1
b5[b5=='想吃随时能吃'] <- 4
b5[b5=='因生活习惯等非经济原因从来不吃'] <- NA

b5 <- factor(b5,levels = c(0,1,2,3,4),labels = c('因吃不起从来不吃','仅逢年过节吃','有时吃（一个月不少于1次）','隔三差五吃（一周不少于1次）','想吃随时能吃'))
data$b5 <- b5

#===================================================================
#                             自己种还是转租
#===================================================================

b4 <- as.character(data$b4)
b4[b4=='转租一部分'] <- 0
b4[b4=='全部转租'] <- 1
b4[b4=='自己种'] <- 2
b4 <- factor(b4,levels = c(0,1,2),labels = c('转租一部分','全部转租','自己种'))
data$b4 <- b4


#===================================================================
#                           住房情况  
#===================================================================

c6 <- as.character(data$c6)
c6[c6=='纯木'] <- 0
c6[c6=='砖混'] <- 2
c6[c6=='砖木'] <- 1
c6 <- factor(c6,levels = c(0,1,2),labels = c('纯木','砖木','砖混'))
data$c6 <- c6


c7 <- as.character(data$c7)
c7[c7=='木材'] <- 0
c7[c7=='红砖'] <- 1
c7[c7=='刷白'] <- 2
c7[c7=='水泥'] <- 3
c7[c7=='刷墙漆'] <- 4
c7[c7=='瓷砖'] <- 5
c7 <- factor(c7,levels = c(0,1,2,3,4,5),labels = c('木材','红砖','刷白','水泥','刷墙漆','瓷砖'))
data$c7 <- c7


c8 <- as.character(data$c8)
c8[c8=='泥土'] <- 0
c8[c8=='水泥'] <- 1
c8[c8=='水磨石'] <- 2
c8[c8=='木地板'] <- 3
c8[c8=='瓷砖'] <- 4
c8 <- factor(c8,levels = c(0,1,2,3,4),labels = c('泥土','水泥','水磨石','木地板','瓷砖'))
data$c8 <- c8



#===================================================================
#                           耐用品情况  
#===================================================================

c10家里有耐用消费品冰箱 <- as.character(data$c10家里有耐用消费品冰箱)

c10家里有耐用消费品冰箱[!is.na(c10家里有耐用消费品冰箱)] <- 1

c10家里有耐用消费品冰箱[is.na(c10家里有耐用消费品冰箱)] <- 0

data$c10家里有耐用消费品冰箱 <- factor(as.character(c10家里有耐用消费品冰箱),levels = c(0,1),labels = c('无','有'))



#===================================================================
#                             收入模型1
#===================================================================

moddata1 <- na.omit(data.frame(data$a6,data$a9,data$d032,data$稻谷收入,data$经济作物收入,data$养鸡收入,data$打工人数,data$b4,data$d019,data$d02))

moddata1$生产性收入 <- moddata1$data.稻谷收入+moddata1$data.经济作物收入+moddata1$data.养鸡收入

moddata1$生产性收入[moddata1$生产性收入!=0] <- log(moddata1$生产性收入[moddata1$生产性收入!=0])

# om <- vglm(moddata1$data.d032 ~  moddata1$data.a6 + moddata1$data.a9 + moddata1$data.打工人数 + moddata1$生产性收入   + moddata1$data.b4 + moddata1$data.d019  + moddata1$data.d02  ,family=cumulative(parallel = T))
# 
# om1 <- vglm(moddata1$data.d032 ~  moddata1$data.a6 + moddata1$data.a9 + moddata1$data.打工人数 + moddata1$生产性收入   + moddata1$data.b4 + moddata1$data.d019  + moddata1$data.d02  ,family=cumulative(parallel = F))
# 
# lrtest(om,om1)

om <- polr(moddata1$data.d032 ~  moddata1$data.a6 + moddata1$data.a9 + moddata1$data.打工人数 + moddata1$生产性收入   + moddata1$data.b4 + moddata1$data.d019  + moddata1$data.d02  ,method = 'logistic',Hess=TRUE)

ctable <- coef(summary(om))

p <- pnorm(abs(ctable[, "t value"]), lower.tail = FALSE) * 2



pp <- predict(om,type = 'class')

moddata1$pre <- pp

sum(diag(matrix(table(moddata1$data.d032,moddata1$pre),3,3)))/sum(matrix(table(moddata1$data.d032,moddata1$pre),3,3))

exp(coef(om))

cbind(,exp(coef(om)))



#===================================================================
#                             收入模型2
#===================================================================
# 
# data$d033[which(data$d033=='高')] <- 3
# data$d033[which(data$d033=='一样')] <- 2
# data$d033[which(data$d033=='低')] <- 1
# 

# moddata1 <- na.omit(data.frame(as.numeric(data$d033),data$a6,data$b5,data$低保人数,data$有养老金的人数,data$d7,data$经济作物收入,data$养鸡收入,data$稻谷收入,data$打工人数))
# 
# om <- vglm(moddata1$as.numeric.data.d032. ~  moddata1$data.a6 +  moddata1$data.b5 + moddata1$data.低保人数 + moddata1$data.有养老金的人数 + moddata1$data.d7 + moddata1$data.经济作物收入+moddata1$data.养鸡收入+moddata1$data.稻谷收入+moddata1$data.打工人数,family = cumulative(parallel = T))
# 
# 
# pp <- predict(om,type = 'response')
# 
# moddata1$pre <- max.col(pp)
# 
# table(moddata1$as.numeric.data.d033.,moddata1$pre)
# 


#===================================================================
#                             收入模型3
#===================================================================


# data$d034[which(data$d034=='高')] <- 3
# data$d034[which(data$d034=='接近')] <- 2
# data$d034[which(data$d034=='低')] <- 1
# 
# moddata1 <- na.omit(data.frame(as.numeric(data$d034),data$b1,data$稻经鸡成本,data$d020,data$医保人数,data$长病人数,data$住院人数,data$义务教育人数))
# 
# om <- vglm(moddata1$as.numeric.data.d034. ~   moddata1$data.b1 +  moddata1$data.稻经鸡成本 + moddata1$data.医保人数 + moddata1$data.长病人数  + moddata1$data.住院人数 + moddata1$data.义务教育人数,family = cumulative(parallel = T))
# 
# om1 <- vglm(moddata1$as.numeric.data.d034. ~   moddata1$data.b1 +  moddata1$data.稻经鸡成本 + moddata1$data.医保人数 + moddata1$data.长病人数  + moddata1$data.住院人数 + moddata1$data.义务教育人数,family = cumulative(parallel = F))
# 
# lrtest(om,om1)
# 
# pp <- predict(om,type = 'response')
# 
# moddata1$pre <- max.col(pp)
# 
# table(moddata1$as.numeric.data.d034.,moddata1$pre)

#===================================================================
#                             就业模型1
#===================================================================


moddata1 <- na.omit(data.frame(data$e011,data$a6,data$工作时长,data$安全))

om <- polr(moddata1$data.e011 ~ moddata1$data.a6 +moddata1$data.工作时长+moddata1$data.安全,data = moddata1,method = 'logistic',Hess=TRUE)

summary(om)

pp <- predict(om,type = 'class')

moddata1$pre <- pp

table(moddata1$data.e011,moddata1$pre)

exp(coef(om))

#===================================================================
#                             就业模型2
#===================================================================

# data$e012[which(data$e012=='好')] <- 3
# data$e012[which(data$e012=='一样')] <- 2
# data$e012[which(data$e012=='差')] <- 1
# 



#===================================================================
#                             教育模型1
#===================================================================

moddata1 <- na.omit(data.frame(data$h16,data$a6,data$义务教育人数,data$学习成绩,data$公立学校,data$村外上学))

om <- polr(moddata1$data.h16 ~ moddata1$data.a6 +moddata1$data.义务教育人数+moddata1$data.公立学校+moddata1$data.学习成绩+moddata1$data.村外上学,data = moddata1,method = 'logistic',Hess=TRUE)

summary(om)

pp <- predict(om,type = 'class')

moddata1$pre <- pp

table(moddata1$data.h16,moddata1$pre)

exp(coef(om))




#===================================================================
#                   ordinal - logit 预测目前生活状况
#===================================================================

# 基本信息: 是否在家实际居住（a4，多久吃肉（b5）
# 收入：低保人口数，有养老金的人数，赡养费（d7），稻经鸡收入，债务（d020）,现在收入比以前高
# 就业：打工人数，打工总收入，
# 医保：医保人数，长病人数，住院人数，
# 环境：
# 教育：
# 安全：村子治安




moddata1 <- na.omit(data.frame(ordered(data$k1),data$i3,data$b1,data$打工收入,
        data$d7,data$长病人数,data$稻谷收入,data$经济作物收入,data$养鸡收入,data$打工人数,data$义务教育人数,data$d020))



om <- vglm(ordered.data.k1.~ .,data = moddata1,family = cumulative(parallel = T))

om1 <- vglm(ordered.data.k1.~ .,data = moddata1,family = cumulative(parallel = F))

lrtest(om,om1)

summary(om)

pp <- predict(om,type = 'response')

moddata1$pre <- max.col(pp)

table(moddata1$ordered.data.k1.,moddata1$pre)


#=============================================================================================================

#===================================================================
#                           学习情况
#===================================================================

dd <- paste0('h9',1:8)

pop1 <- rep(0,nrow(data))

for(i in 1:nrow(data)){
  if(sum(is.na((apply(data[dd],2,as.character)%>%cbind())[i,]))==8){
    pop1[i] <- NA
  }else if(sum((apply(data[dd],2,as.character)%>%cbind())[i,]==1,na.rm = T)>0){
    pop1[i] <- 1
  }
}

