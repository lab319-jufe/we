prob.one <- function(n,N){
  samples <- trunc(runif(n*N,1,366))#随机生成n*N个数据，trunc截取整数部分
  samples[samples == 366] <- 365
  birdays <- matrix(samples,ncol = n)
  onedayrate <- apply(birdays,1,function(x){
    return(n-length(unique(x)))})
  nonday <- sum(onedayrate == 0)
  par(mfrow = c(1,2))
  hist(onedayrate,breaks =10,xlab = "",main = "生日在同一天的人数",col = "pink")
  pie(table(as.integer(onedayrate != 0)),main = paste("没有人同一天的概率：",nonday/N),
      labels = c('无重叠','有重叠'),col = c('orangered','cornflowerblue'),border = NA)
}
prob.one(60,10000)

####################拒绝接受####################
a <- 2
b <- 7
xmax <- (a-1)/(a+b-2)
dmax <- xmax^(a-1)*(1-xmax)^(b-1)*gamma(a+b)/(gamma(a)*gamma(b))
y <- runif(1000)
x <- na.omit(ifelse(runif(1000) <= dbeta(y,a,b)/dmax,y,NA))

z <- x[1:323]
ks.test(z,"pbeta",2,7)
#接受域图
plot(dbeta(x,2,7)~x,type = "l")

#1.MCMC
# 给定一个二项分布，服从B(20,0.7)

size <- 20
prob <- 0.7

# 求解目标分布的密度
dbinom_dist_prob <- function(x){
  binom_den <- dbinom(x, size, prob)
  return(binom_den)
}

t <- 5000 #采样次数
start <- 14 
result <- rep(start,t) # 保存采样结果，这里设置为14，是因为目标分布均值就是14,当然也可以设置成其他值
sigma <- 10 #转移矩阵的参数
for (i in 2:t){
  result_star <- round(rnorm(1,mean = result[i-1],
                             sd = sigma))
  alpha = dbinom_dist_prob(result_star)
  u = runif(1,0, 1)
  if(u < alpha)
    result[i] = result_star              # 接受
  else
    result[i] = result[i - 1]               # 拒绝
}

table(result)
# 将结果进行可视化，展示抽样的结果
plot(result,dbinom_dist_prob(result))

hist(result)

