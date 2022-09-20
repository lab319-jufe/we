##########################马尔可夫链################################
library(readxl)
trans_matrix <- read_xlsx('C:\\Users\\lijie\\Desktop\\转移矩阵.xlsx')
trans_matrix <- as.matrix(trans_matrix)

# 蒙特卡罗抽样（知道转移矩阵的情况下）

## 给定一个初始点，假定是均匀分布
start <- matrix(rep(0.1,10),1,10)
colnames(start) <- seq(1,10)
nex <- start %*% trans_matrix
result<- rbind(start,nex)
N <- 500
for (i in 1:N){
  nex <- nex %*% trans_matrix
  result <- rbind(result, nex)
}

#取出最后一行最终达到的一个平衡状态
result[nrow(result),]
1:10/sum(1:10) # 二者非常相似

## 若初始的分布并不是均匀分布的，只需要变动start

## 生成10个随机数
x <- runif(10)
start <- matrix(x/sum(x),1,10)
sum(start)
colnames(start) <- seq(1,10)
nex <- start %*% trans_matrix
result<- rbind(start,nex)
N <- 500
for (i in 1:N){
  nex <- nex %*% trans_matrix
  result <- rbind(result, nex)
}

#取出最后一行最终达到的一个平衡状态
result[nrow(result),]
1:10/sum(1:10) # 二者非常相似

## 发现和初始状态无关

########################MCMC采样######################





##############################Gibbs抽样###############################

使用Gibbs抽样抽取二元正态分布N(μ1,μ2,σ12,σ22,ρ)的随机数 在二元正态分布的条件下，两个分量的一元条件分布依然是正态分布：
f(x1∣x2)∼N(μ1+ρσ1σ2(x2−μ2),(1−ρ2)σ12)
f(x2∣x1)∼N(μ2+ρσ2σ1(x1−μ1),(1−ρ2)σ22)
N <- 5000
N.burn <- 1000 
X <- matrix(0, N, 2)#生成一个5000行两列的全为0的矩阵
rho <- -0.6
mu1 <- 2; mu2 <- 10
sigma1 <- 1; sigma2 <- 2
s1 <- sqrt(1 - rho^2)*sigma1
s2 <- sqrt(1 - rho^2)*sigma2
X[1, ] <- c(mu1, mu2) # 用均值点作为抽样起点
for (i in 2:N) {
  if (i %% 2 == 1) {
    # 奇数步固定x2对x1采样
    x2 <- X[i - 1, 2]
    m1 <- mu1 + rho*(x2 - mu2)*sigma1/sigma2
    X[i, 1] <- rnorm(1, m1, s1)
    X[i, 2] <- x2
  } else {
    # 偶数步固定x1对x2采样
    x1 <- X[i - 1, 1]
    m2 <- mu2 + rho*(x1 - mu1)*sigma2/sigma1
    X[i, 1] <- x1
    X[i, 2] <- rnorm(1, m2, s2)
  }
}
X.samples <- X[(N.burn + 1):N,]                                                                                                  
#绘制采样轨迹                          
library(ggplot2)
X.samples.df <- as.data.frame(X.samples)
names(X.samples.df) <- c('X1', 'X2')
ggplot() + geom_path(data = X.samples.df[1:500,], aes(x = X1, y = X2))

#X.samples.real <- X.samples[seq(1, nrow(X.samples), by = 2),]

#也可以直接进行采样
N <- 5000
N.burn <- 1000
X <- matrix(0, N, 2)
rho <- -0.6
mu1 <- 2
mu2 <- 10
sigma1 <- 1
sigma2 <- 2
s1 <- sqrt(1 - rho^2)*sigma1
s2 <- sqrt(1 - rho^2)*sigma2
X[1, ] <- c(mu1, mu2) # 用均值点作为抽样起点

for (i in 2:N) {
  # 先固定x2对x1采样
  x2 <- X[i - 1, 2]
  m1 <- mu1 + rho*(x2 - mu2)*sigma1/sigma2
  X[i, 1] <- rnorm(1, m1, s1)
  # 再固定x1对x2采样
  x1 <- X[i, 1]
  m2 <- mu2 + rho*(x1 - mu1)*sigma2/sigma1
  X[i, 2] <- rnorm(1, m2, s2)
}

X.samples <- X[(N.burn + 1):N,]


###########################M-H采样###############################################

# 1.计算Rayleigh密度函数在某点的值
f <- function(x,s)
{
  if(x < 0)  return (0)
  stopifnot(s > 0) # if not all true,stop is called
  return((x/s^2)*exp(-x^2/(2*s^2)))
}

N <- 10000
s <- 4
x <- numeric(N)
x[1] <- rchisq(1,df=1) #初始化提议分布
k <- 0
u <- runif(N)
for(i in 2:N)
{
  y <- rchisq(1,df = x[i-1]) #候选点
  num <- f(y,s)*dchisq(x[i-1],df = y) 
  den <- f(x[i-1],s)*dchisq(y,df = x[i-1])
  if (u[i] <= num/den) 
    x[i] <- y
  else {
    x[i] <- x[i-1]
    k <- k+1 #y is rejected
  }  
}
print(k)

# 做样本路径图(trace plot)
index <- 500:1000
y1 <- x[index]
plot(index,y1,type = "l",main = "",ylab = "x")
#在候选点被拒绝的时间点上链没有移动,因此图中有很多短的水平平移

###############################MH采样#################


# 选择的马尔可夫链状态转移矩阵Q(i,j)的条件转移概率是以i为均值,方差5的正态分布在位置j的值。

# 这个例子仅仅用来让大家加深对M-H采样过程的理解。毕竟一个普通的一维正态分布用不着去用M-H采样来获得样本。

N = 10000
x = vector(length = N)
x[1] = 0

# uniform variable: u
u = runif(N)
m_sd = 5


for (i in 2:N)
{
  y = rnorm(1,mean = x[i-1],sd = m_sd)#以正态分布作为提议分布进行采样，候选点
  print(y)
  
  
  p_accept =dnorm(x[i-1],mean = y,sd = abs(2*y+1))
  #print (p_accept)
  
  
  if ((u[i] <= p_accept))
  {
    x[i] = y
    print("accept")
  }
  else
  {
    x[i] = x[i-1]
    print("reject")
  }
}

plot(x,type = 'l')
dev.new()
hist(x)
