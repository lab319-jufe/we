#第六章 过度拟合、正则化和信息法则

## 6.1.1 更多的参数总是提高拟合度

###过度拟合的例子

sppnames <- c("afarensis", "africanus", "habilis", "boisei",
              "rudolfensis", "ergaster", "sapiens")
brainvolcc <- c(438, 452, 612, 521, 752, 871, 1350)#脑容量
masskg <- c(37.0, 35.5, 34.5, 41.5, 55.5, 61.0, 53.5)#体重观测
d <- data.frame(species=sppnames, brain=brainvolcc, mass=masskg)

m6_1 <- lm(brain ~ mass, data = d)
1 - var(resid(m6_1)) / var(d$brain)
summary(m6_1)

m6_2 <- lm(brain ~ mass + I(mass^2), data = d)
m6_3 <- lm(brain ~ mass + I(mass^2) + I(mass^3), data = d)
m6_4 <- lm(brain ~ mass + I(mass^2) + I(mass^3) + I(mass^4), data = d)
m6_5 <- lm(brain ~ mass + I(mass^2) + I(mass^3) + I(mass^4) + I(mass^5), data = d)
m6_6 <- lm(brain ~ mass + I(mass^2) + I(mass^3) + I(mass^4) + I(mass^5) + I(mass^6), data = d)

library(rethinking)
d$mass.s <- (d$mass - mean(d$mass))/sd(d$mass)
m6.8 <- map(
  alist(
    brain ~ dnorm(mu,sigma),
    mu <- a+b*mass.s
    ),
  data = d,
  start  = list(a = mean(d$brain),b=0,sigma = sd(d$brain)),
  method = "Nelder-Mead")
)
theta <- coef(m6.8)

dev <- (-2)*sum(dnorm(
  d$brain,
  mean = theta[1]+theta[2]*d$mass.s,
  sd = theta[3],
  log = TRUE
))
dev

#模拟训练集和测试集的数据
library(rethinking)
N <- 20
kseq <- 1:5
dev <- sapply(kseq, function(k){
  print(k);
  r <- replicate(1e4,sim.train.test(N=N,k=k));
  c(mean(r[1,]),mean(r[2,]),sd(r[1,]),sd(r[2]))
})
plot(1:5,dev[1,],ylim=c(min(dev[1:2,])-5,max(dev[1:2,])+10),
     xlim=c(1,5.1),xlab="number of parameters",ylab="deviance",
     pch=16,col=rangi2)
mtext(concat("N=",N))
points((1:5)+0.1,dev[2,])
for (i in kseq) {
  pts_in <- dev[1,i] + c(-1,+1)*dev[3,i]
  pts_out <- dev[2,i] + c(-1,+1)*dev[4,i]
  lines(c(i,i),pts_in,col=rangi2)
  lines(c(i,i)+0.1,pts_out)  
}
  
#计算WAIC
##1.map简单回归拟合
data(cars)
m <- map(
  alist(
    dist ~ dnorm(mu,sigma),
    mu <- a + b *speed,
    a ~ dnorm(0,100),
    b ~ dnorm(0,10),
    sigma~dunif(0,30)
  ),data = cars)
post <- extract.samples(m,n=1000)
##2.后验样本集s对应的观测i的对数似然
n_samples <- 1000
ll <- sapply(1:n_samples,
             function(s){
               mu <- post$a[s]+post$b[s]*cars$speed
               dnorm(cars$dist,mu,post$sigma[s],log=TRUE)
             })
n_cases <- nrow(cars)
lppd <- sapply(1:n_cases,function(i) log_sum_exp(ll[i,])-log(n_samples))
