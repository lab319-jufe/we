#离散状态下的MCMC采样

#1.pi：平稳分布(相对于连续中的f(x))
pi <-  array(c(0.5,0.2,0.3))

#2.Q任意一个马尔可夫状态转移矩阵
q1 <- runif(3)
q2 <- runif(3)
q3 <- runif(3)
Q <- matrix(c(q1/sum(q1),
              q2/sum(q2),
              q3/sum(q3)),nrow = 3,byrow = TRUE)
apply(Q,1,sum)

#3.构造循环
N <- 1000 #设定状态转移次数
Nlmax <-  100000 #需要的样本数量
T <- N + Nlmax 

mcmc <- function(pi,Q){
  x0 <- sample(1:length(pi),1)#初始状态值
  result <- rep(x0,T)
  t <- 1
  while(t < T){
    t <- t + 1
    #从多项式分布中任意采集一个样本(相对于从g(x)中抽取样本)
    x_cur <- which.max(rmultinom(1, size = 1, 
                                         prob = Q[result[t - 1],]))
    acc <- pi[x_cur] * Q[x_cur,result[t - 1]]#计算接收概率
    u <- runif(1)
    if(u < acc){
      result[t] <- x_cur
    }
    else{
      result[t] <- result[t-1]
    }
  }
  return(result)
}

a <- mcmc(pi,Q)[0:N]
plot(a)
prop.table(table(a))

#抽取到的样本服从Pi分布
result_mcmc <- mcmc(pi,Q)[N + 1:T]
prop.table(table(result_mcmc))
