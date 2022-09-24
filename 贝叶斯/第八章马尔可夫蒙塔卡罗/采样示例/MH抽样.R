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
  alpha = min(1, (dbinom_dist_prob(result_star) / 
                    dbinom_dist_prob(result[i - 1])))
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

