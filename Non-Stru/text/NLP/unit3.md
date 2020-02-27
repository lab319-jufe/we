# 第3章 中文分词技术

## 3.1 中文分词简介
中文自动分词主要归纳为：

+ 规则分词。最早兴起的方法，主要是通过人工设立词库，按照一定方式进行匹配切分，其实现简单高效，但是对新词很难进行处理

+ 统计分词。能够较好的应对新词发现等特殊场景，但是，太过于依赖语料的质量

+ 混合分词。

## 3.2 规则分词

基于规则的分词是一种机械分词方法，主要是通过维护词典，在切分语句时，将语句的每个字符串与词表中的词进行逐一匹配，找到则切分，否则不予以切分。

按照匹配切分的方式，主要有：

+ 正向最大匹配法

+ 逆向最大匹配法

+ 双向最大匹配法

### 3.2.1 正向最大匹配法（Maximum Match Method，MM法）

假定分词词典中的最长词有i个汉字字符，则用被处理文档的当前字串中的前i个字作为匹配字段，查找字典。若字典中存在这样的一个i字词，则匹配成功，匹配字段被作为一个词切分出来。如果词典中找不到这样的一个i字词，则匹配失败，将匹配字段中的最后一个字去掉，对剩下的字串重新进行匹配处理。如此进行下去，直到匹配成功，即切分出一个词或剩余字串的长度为零为止。这样就完成了一轮匹配，然后取下一个i字字串进行匹配处理，直到文档被扫描完为止。

### 3.2.2 逆向最大匹配法（Reverse Maximum Match Method， RMM法）

基本原理和MM法相同，不同的是分词切分的方向与MM法相反，从被处理文档的末端开始匹配扫描。

由于汉语中偏正结果较多，若从后向前匹配，可以适当提高精确度。统计结果表明，单纯使用正向最大匹配的错误率为1/169，单纯使用逆向最大匹配的错误率为1/245。

### 3.2.3 双向最大匹配法（Bi-directction Matching method）

将正向最大匹配法得到的分词结果和逆向最大匹配法得到的结果进行比较，然后按照最大匹配原则，选取词数切分最少的作为结果。



```python
# 逆向最大匹配
class IMM(object):
    def __init__(self, dic_path):
        self.dictionary = set()
        self.maximum = 0
        # 读取词典
        with open(dic_path, 'r', encoding= 'utf8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                self.dictionary.add(line)
                self.maximum = max(len(line),self.maximum)
    def cut(self, text):
        result = []
        index = len(text)
        while index > 0:
            word = None
            for size in range(self.maximum, 0, -1):  #9，8，7
                if index - size < 0:
                    continue
                piece = text[(index - size):index]
                if piece in self.dictionary:
                    word = piece
                    result.append(word)
                    index -= size
                    break
            if word is None:
                index -= 1
        return result[::-1]
def main():
    text = "南京市长江大桥"
    tokenizer = IMM('./data/imm_dic.utf8')
    print(tokenizer.cut(text))

main()        
```

    ['南京市', '长江大桥']
    


```python
# 正向最大匹配
class MM(object):
    def __init__(self, dic_path):
        self.dictionary = set()
        self.maximun = 0
        with open(dic_path, 'r', encoding= 'utf8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                self.dictionary.add(line)
                self.maximun = max(len(line), self.maximun)
    def cut(self, text):
        result = []
        index = len(text)
        str = 0 
        size = 0
        while str + size -1  < 80:
            word = None
            for size in range(self.maximun , 0, -1):
                if index - size < 0:
                    continue
                piece = text[str:str+size]
                if piece in self.dictionary:
                    word = piece
                    result.append(word)
                    str += size
                    break
            if word is None:
                str += 1
        return result[::]
def mi():
    text = "南京市长江大桥"
    tokenizer = MM('./data/imm_dic copy.utf8')
    print(tokenizer.cut(text))

mi()        

```

    ['南京市长', '江', '大桥']
    

## 3.3 统计分词

统计语料中相邻共现的各个字的组合的频度，当组合频度高于某一个临界值时，我们便可认为字组可能会构成一个词语。

基于统计的分词，一般要做如下两步操作：

1）建立统计语言模型

2）对句子进行单词划分，然后对划分结果进行概率计算，获得概率最大的分词方式。这里就用到了统计学校算法，如隐含马尔可夫（HMM)、条件随机场（CRF）等。

### 3.3.1 语言模型



用概率论的专业术语描述语言模型就是：为长度为m的字符串确定其概率分布$P(\omega_1, \omega_2, \dots, \omega_m)$，其中$\omega_1$到$\omega_m$依次表示文本中的各个词语。一般采用链式法则计算其概率值，如下式所示：


\begin{split}
{} & P(\omega_1, \omega_2, \dots, \omega_m) = P(\omega_1)P(\omega_2|\omega_1)P(\omega_3|\omega_1,\omega_2){}\\
	&\dots P(\omega_i|\omega_1,\omega_2, \dots, \omega_(i-1))\dots P(\omega_m|\omega_1, \omega_2, \dots, \omega_(m-1)) 
\end{split} 


简单地说，语言模型就是用来计算一个句子的概率的模型，也就是判断一句话是否是人话的概率。

公式从第三项起的每一项计算难度都很大。为解决该问题，有人提出n元模型（n-gram mmodel）降低该计算难度。_
所谓n元模型就是在估算条件概率时，忽略距离大于等于n的上文词的影响，所以可以简化为：

$$ P(\omega_i|\omega_1, \omega_2, \dots, \omega_(i-1)) \approx P(\omega_i|\omega_1, \omega_(i-(n-1)), \dots, \omega_(i-1)) \tag{3.2}$$

当 n = 1时，称为一元模型（unigram medel），此时整个句子的概率可表示为：$P(\omega_1, \omega_2, \dots, \omega_m) = P(\omega_1)P(\omega_2)\dots P(\omega_m)$，即在一元语言模型中，整个句子的概率等于各个词语概率的乘积，即各个词之间都是相互独立的，损失了句中的语序信息。

当 n = 2时，称为二元模型（bigram model），式（3.2）变为$P(\omega_i|\omega_1, \omega_2, \dots, \omega_(i-1)) = P(\omega_i|\omega_(i-1))$

当 n = 3时，称为三元模型（trigram model），式（3.2）变为$P(\omega_i|\omega_1, \omega_2, \dots, \omega_(i-1)) = P(\omega_i|\omega_(i-2), \omega_(i-1))$

*https://zhuanlan.zhihu.com/p/28080127*

显然当n $\geq$ 2时，该模型是可以保留一定的词序信息的，而且n越大，保留的词序信息约丰富，但计算成本也呈指数级增长。

一般使用频率计数的比例来计算n元条件概率，如式（3.3）所示：





$$ P(\omega_i|\omega_(i-(n-1)), \dots, \omega_(i-1)) = \frac{count(\omega_(i-(n-1)), \omega_(i-1), \omega_i)}{count(\omega_(i-(n-1)),\dots, \omega_(i-1))} \tag{3.3}$$

式子中$count(\omega_(i-(n-1)), \dots, \omega_(i-1))$表示词语$\omega_(i-(n-1)), \dots, \omega_(i-1)$在语料库中出现的总次数。

n越大，模型包含的词序信息约丰富，计算量也越大，同时，长度越长的文本序列出现的次数也会减少。

## 3.4 马尔可夫链

### 3.4.1 定义

马尔可夫链是一组具有马尔可夫性质的离散随机变量的集合。具体地，对概率空间$(\Omega,F,P)$内以一维可数集为指数集（index set） 的随机变量集合 $X=\{X_n:n>0\}$，若随机变量的取值都在可数集内： $X=s_i, s_i \in s $，且随机变量的条件概率满足如下关系：

$$p(X_{t+1}|X_t,\dots,X_1)=p(X_{t+1}|X_t)$$

则$X$被称为马尔可夫链，可数集$s\in Z$被称为状态空间（state space），马尔可夫链在状态空间内的取值称为状态。这里定义的马尔可夫链是离散时间马尔可夫链（Discrete-Time MC, DTMC），其具有连续指数集的情形虽然被称为连续时间马尔可夫链（Continuous-Time MC, CTMC），但在本质上是马尔可夫过程（Markov process）。常见地，马尔可夫链的指数集被称为“步”或“时间步（time-step）”。

上式在定义马尔可夫链的同时定义了马尔可夫性质，该性质也被称为“无记忆性（memorylessness）”，即t+1步的随机变量在给定第t步随机变量后与其余的随机变量条件独立（conditionally independent）：$X_{t+1}\coprod (x_{t-1},x_0)|X_t$。在此基础上，马尔可夫链具有强马尔可夫性（strong Markov property），即对任意的停时（ stopping time）（停止时间是一种特殊的随机变量，表示一个随机的时刻。），马尔可夫链在停时前后的状态相互独立。

解释性例子：

马尔科夫链的一个常见例子是简化的股票涨跌模型：若一天中某股票上涨，则明天该股票有概率p开始下跌，1-p继续上涨；若一天中该股票下跌，则明天该股票有概率q开始上涨，1-q继续下跌。该股票的涨跌情况是一个马尔可夫链，且定义中各个概念在例子中有如下对应：

+ 随机变量：第t天该股票的状态；状态空间：“上涨”和“下跌”；指数集：天数。

+ 条件概率关系：按定义，即便已知该股票的所有历史状态，其在某天的涨跌也仅与前一天的状态有关。

+ 无记忆性：该股票当天的表现仅与前一天有关，与其他历史状态无关（定义条件概率关系的同时定义了无记忆性）。

+ 停时前后状态相互独立：取出该股票的涨跌记录，然后从中截取一段，我们无法知道截取的是哪一段，因为截取点，即停时t前后的记录（t-1和t+1）没有依赖关系。


### 3.4.2 理论与性质


#### 3.4.2.1转移理论

马尔可夫链中随机变量的状态随时间步的变化被称为演变（evolution）或转移（transition）。

马尔可夫链中随机变量间的条件概率可定义为如下形式的（单步）转移概率和n-步转移概率：

$$P_{i_n,i_{n+1}}=p(X_{n+1}=s_{i_{n+1}}|X_n=s_{i_n})$$

$$p^{(n)}_{i_0,i_n}=p(X_n=s_{i_n}|X_0=s_{i_0})$$


式中下标$i_n$表示第$n$步的转移。由马尔可夫性质可知，在给定初始概率 $\alpha=p(X_0)$后，转移概率的连续乘法可以表示马尔可夫链的有限维分布（finite-dimensional distribution）：

式中的$A_n=\{X_n=s_{i_n},X_{n-1}=s_{i_{n-1}},\dots,X_0=s_{i_0} \}$为样本轨道（sample path），即马尔可夫链每步的取值。对n-步转移概率，由Chapman–Kolmogorov等式可知，其值为所有样本轨道的总和：

$$p^{(n)}_{i_0,i_n}=\sum _{{i_0,i_m,i_n}\in s} P^{(k)}_{i_0,i_m} P^{(n-k)}_{i_m,i_n} = \sum _{{i_0,\dots,i_n} \in s} \alpha_{i_0}P_{i_0,i_1}\dots P_{i_{n-1},i_n}$$

上式表明，马尔可夫链直接演变n步等价于其先演变n-k步，再演变k步（k处于该马尔可夫链的状态空间内）。n-步转移概率与初始概率的乘积被称为该状态的绝对概率。

$$p(A_n)=\alpha P_{i_0,i_1} \dots P_{i_{n-2},i_{n-1}} P_{i_{n-1},i_n}$$

$$p(X_{n+1}=s_{i_{n+1}}|A_n)=P_{i_n,i_{n+1}}$$

$$p(A_{n+1})=p(A_n)P_{i_n,i_{n+1}}$$

若一个马尔可夫链的状态空间是有限的，则可在单步演变中将所有状态的转移概率按矩阵排列，得到转移矩阵:

$$P_{n,{n+1}}=(P_{i_n,i_{n+1}})= \begin{bmatrix} P_{0,0} & P_{0,1} & P_{0,2} & \dots \\ P_{1,0} & P_{1,1} & P_{1,2} & \dots \\ P_{2,0} & P_{2,1} & p_{2,2} & \dots \\ \dots & \dots & \dots & \dots \\ \dots & \dots & \dots & \dots \\ \end{bmatrix}\quad$$

马尔可夫链的转移矩阵是右随机矩阵（right stochastic matrix），矩阵的第$i_n$行表示 $X_n = s_{i_n}$时 $X_{n+1}$取所有可能状态的概率（离散分布），因此马尔可夫链完全决定转移矩阵，转移矩阵也完全决定马尔可夫链。由概率分布的性质可得，转移矩阵是一个正定矩阵，且每行元素之和等于1：

$$\forall i,j: P_{i,j}>0,\forall i: \sum _j P_{i,j}=1$$

#### 3.4.2.2 转移图（transition graph）


1.可达（accessible）与连通（communicate）


马尔可夫链的演变可以按图（graph）结构，表示为转移图（transition graph），图中的每条边都被赋予一个转移概率。通过转移图可引入“可达”和“连通”的概念：


若对马尔可夫链中的状态$s_i,s_j$有：$p_{i,k_1}p_{k_1,j}\dots p_{k_n,j}>0$，，即采样路径上的所有转移概率不为0，则状态 $s_j$ 是状态 $s_i$的可达状态，在转移图中表示为有向连接：$s_i \rightarrow s_j $。如果 $s_i,s_j$互为可达状态，则二者是连通的，在转移图中形成闭合回路，记为$s_i \leftrightarrow s_j $。由定义，可达与连通可以是间接的，即不必在单个时间步完成。


连通是一组等价关系，因此可以构建等价类（equivalence classes），在马尔可夫链中，包含尽可能多状态的等价类被称为连通类（communicating class）。


2.闭合集（closed set）与吸收态（absorbing state）

给定状态空间的一个子集，若马尔可夫链进入该子集后无法离开： $\forall s_i \in C :\sum_{s_j \in C} p_{i,j}=1$，则该子集是闭合的，称为闭合集，一个闭合集外部的所有状态都不是其可达状态。若闭合集中只有一个状态，则该状态是吸收态，在转移图中是一个概率为1的自环。一个闭合集可以包括一个或多个连通类。马尔可夫链从任意状态出发最终都会进入吸收态，这类马尔可夫链被称为吸收马尔可夫链（absorbing Markov chain）。


#### 3.4.2.3 性质

这里对马尔可夫链的4个性质：不可约性、重现性、周期性和遍历性进行定义。与马尔可夫性质不同，这些性质不是马尔可夫链必然拥有的性质，而是其在转移过程中对其状态表现出的性质。


1.不可约性（irreducibility）

如果一个马尔可夫链的状态空间仅有一个连通类，即状态空间的全体成员，则该马尔可夫链是不可约的，否则马尔可夫链具有可约性（reducibility）。马尔可夫链的不可约性意味着在其演变过程中，随机变量可以在任意状态间转移。

2.重现性（recurrence）

若马尔可夫链在到达一个状态后，在演变中能反复回到该状态，则该状态具有重现性，或该马尔可夫链具有（局部）重现性，反之则具有瞬变性（transience）的。此外，若状态$s_i \in s$具有重现性，则可计算其平均重现时间（mean recurrence time）：

$$E(T_i)= \sum^\infty _{n=1} n·p(T_i=n)$$


若平均重现时间$E(T_i)< \infty $， ，该状态是“正重现的（positive recurrent）”，否则为“零重现的”。若一个状态是零重现的，那意味着马尔可夫链两次访问该状态的时间间隔的期望是正无穷。

由上述瞬变性和重现性的定义可有如下推论：

推论1：对有限个状态的马尔可夫链，其至少有一个状态是可重现的，且所有可重现状态都是正可重现的。

推论2：若有限个状态的马尔可夫链是不可约的，则其所有状态是正重现的。

推论3：若状态A是可重现的，且状态B是A的可达状态，则A与B是连通的，且B是可重现的。

推论4：若状态B是A的可达状态，且状态B是吸收态，则B是可重现状态，A是瞬变状态。

推论5：由正可重现状态组成的集合是闭合集，但闭合集中的状态未必是可重现状态。



3.周期性（periodicity）

一个正重现的马尔可夫链可能具有周期性，即在其演变中，马尔可夫链能够按大于1的周期重现其状态。正式地，给定具有正重现性的状态$s_i \in s$，其重现周期按如下方式计算：

$$d = gcd | \{n>0:p(x_n=s_i|X_0 = s_i)>0 \}$$

式中$gcd|\{·\}$表示取集合元素的最大公约素。举例说明，若在转移图中，一个马尔可夫链重现某状态需要的步数为$\{3,6,9,12,\dots\}$，则其周期是3，即重现该状态所需的最小步数。若按上式计算得到$d>1$，该状态具有周期性，若$d=1$，该状态具有非周期性（aperiodicity）。由周期性的定义可有如下推论：

推论1：吸收态是非周期性状态。

推论2：若状态A与状态B连通，则A与B周期相同。

推论3：若不可约的马尔可夫链有周期性状态A，则该马尔可夫链的所有状态为周期性状态。

4.遍历性（ergodicity）

若马尔可夫链的一个状态是正重现的和非周期的，则该状态具有遍历性。若一个马尔可夫链是不可还原的，且有某个状态是遍历的，则该马尔可夫链的所有状态都是遍历的，被称为遍历链。由上述定义，遍历性有如下推论：

推论1：若状态A是吸收态，且A是状态B的可达状态，则A是遍历的，B不是遍历的。

推论2：若多个状态的马尔可夫链包含吸收态，则该马尔可夫链不是遍历链。

推论3：若多个状态的马尔可夫链形成有向无环图，或单个闭环，则该马尔可夫链不是遍历链。

遍历链是非周期的平稳马尔可夫链。

#### 3.4.2.4 稳态分析

平稳分布（stationary distribution）


给定一个马尔可夫链，若在其状态空间存在概率分布 $\pi=\pi(s)$，且该分布满足以下条件：

$$\forall s_j \in s: \pi(s_j)= \sum_{s_i \in s} \pi(s_i)P_{i,} \rightarrow \pi=\pi P,0< \pi (s_i) <1,||\pi||=1$$ 


则$\pi$是该马尔可夫链的平稳分布。式中$P=(P_{i,j})$是转移矩阵和转移概率，等价符号右侧的线性方程组被称为平衡方程（balance equation）。进一步地，若马尔可夫链的平稳分布存在，且其初始分布是平稳分布，则该马尔可夫链处于稳态（steady state）。

极限分布（limiting distribution）

若一个马尔可夫链的状态空间存在概率分布 $\pi$ 并满足如下关系：

$$\lim _{n \to \infty} p(X_n=s_i)=\pi(s_I)$$

则该分布是马尔可夫链的极限分布。注意到极限分布的定义与初始分布无关，即对任意的初始分布，当时间步趋于无穷时，随机变量的概率分布趋于极限分布。按定义，极限分布一定是平稳分布，但反之不成立，例如周期性的马尔可夫链可能具有平稳分布，但周期性马尔可夫链不收敛于任何分布，其平稳分布不是极限分布。


1.极限定理（limiting theorem）

两个独立的非周期平稳马尔可夫链，即遍历链如果有相同的转移矩阵，那么当时间步趋于无穷时，两者极限分布间的差异趋于0。对状态空间相同的遍历链$\{X_n\},\{Y_n\}$，给定任意初始分布后有:

$$\lim_{n \to \infty } sup_{s_i}|p(X_n=s_i)-p(Y_n=s_i)|=0$$

式中sup表示上确界（supremum）。考虑平稳分布的性质，该结论有推论：对遍历链 $\{X_n\}$，当时间步趋于无穷时，其极限分布趋于平稳分布：

$$\lim_{n \to \infty } sup_{s_i}|p(X_n=s_i)-\pi(s_i)|=0$$

该结论有时被称为马尔可夫链的极限定理（limit theorem of Markov chain），表明若马尔可夫链是遍历的，则其极限分布是平稳分布。

2. 遍历定理（ergodic theorem）

若一个马尔可夫链为遍历链，则由遍历定理，其对某一状态的访问次数与时间步的比值，在时间步趋于无穷时趋近于平均重现时间的倒数，即该状态的平稳分布或极限分布：

$$\lim_{n \to \infty} \frac{1}{n} \sum ^{\infty}_{n=1}p(X_n=s_i|X_0=s_i)=\frac {1}{E(s_i)}=\pi(s_i)$$

遍历定理的证明依赖于强大数定律（Strong Law of Large Numbers, SLLN），表明遍历链无论初始分布如何，在经过足够长的演变后，对其中一个随机变量进行多次观测（极限定理）和对多个随机变量进行一次观测（上式左侧）都可以得到极限分布的近似。


平稳马尔可夫链（stationary Markov chain）

若一个马尔可夫链拥有唯一的平稳分布且极限分布收敛于平稳分布，则按定义等价于，该马尔可夫链是平稳马尔可夫链 。平稳马尔可夫链是严格平稳随机过程，其演变与时间顺序无关：

$$P_{i_n,i_{n+1}}=p(X_{i_{n+1}}=s_{n+1}|X_{i_{n}=s_n})=p(X_{i_n}|X_{i_{n-1}}=s_{n-1})$$

平稳马尔可夫链也被称为齐次马尔可夫链（time-homogeneous Markov chain）。

若平稳马尔可夫链对其任意两个状态满足细致平衡（detailed balance）条件，则其具有可逆性，被称为可逆马尔可夫链（reversible Markov chain）：

$$\pi(s_i)p(X_{n+1}=s_j|X_n=s_i)=\pi(s_j)p(X_{n+1}=s_i|X_n=s_j)$$

马尔可夫链的可逆性是更严格的不可约性，即其不仅可以在任意状态间转移，且向各状态转移的概率是相等的，因此可逆马尔可夫链是平稳马尔可夫链的充分非必要条件。





```python
# 二元模型
import jieba
from _overlapped import NULL
def reform(sentence):
    #如果是以“。”结束的则将“。”删掉
    if sentence.endswith("。"):
        sentence=sentence[:-1]
    #添加起始符BOS和终止符EOS   
    sentence_modify1=sentence.replace("。", "EOSBOS")
    sentence_modify2="BOS"+sentence_modify1+"EOS"
    return sentence_modify2


#分词并统计词频
def segmentation(sentence,lists,dicts=NULL):
    jieba.suggest_freq("BOS", True)
    jieba.suggest_freq("EOS", True)
    sentence = jieba.cut(sentence,HMM=False)
    format_sentence=",".join(sentence)
    #将词按","分割后依次填入数组word_list[]
    lists=format_sentence.split(",")
    #统计词频，如果词在字典word_dir{}中出现过则+1，未出现则=1
    if dicts!=NULL:
        for word in lists:
            if word not in dicts:
                dicts[word]=1
            else:
                dicts[word]+=1               
    return lists


#比较两个数列，二元语法
def compareList(ori_list,test_list):
    #申请空间
    count_list=[0]*(len(test_list))
    #遍历测试的字符串
    for i in range(0,len(test_list)-1):
        #遍历语料字符串，且因为是二元语法，不用比较语料字符串的最后一个字符
        for j in range(0,len(ori_list)-2):                
            #如果测试的第一个词和语料的第一个词相等则比较第二个词
            if test_list[i]==ori_list[j]:
                if test_list[i+1]==ori_list[j+1]:
                    count_list[i]+=1
    return count_list


#计算概率    
def probability(test_list,count_list,ori_dict):
    flag=0
    #概率值为p
    p=1
    for key in test_list: 
        #数据平滑处理：加1法
        p*=(float(count_list[flag]+1)/float(ori_dict[key]+1))
        flag+=1
    return p


if __name__ == "__main__":

    #语料句子
    sentence_ori="研究生物很有意思。他大学时代是研究生物的。生物专业是他的首选目标。他是研究生。"
    ori_list=[]
    ori_dict={}
    sentence_ori_temp=""

    #测试句子
    sentence_test="他是研究生物的"
    sentence_test_temp="" 
    test_list=[]
    count_list=[]
    p=0

    #分词并将结果存入一个list，词频统计结果存入字典
    sentence_ori_temp=reform(sentence_ori)
    ori_list=segmentation(sentence_ori_temp,ori_list,ori_dict)

    sentence_test_temp=reform(sentence_test)
    test_list=segmentation(sentence_test_temp,test_list)

    count_list=compareList(ori_list, test_list)
    p=probability(test_list,count_list,ori_dict)
    print(p)
```

    Building prefix dict from the default dictionary ...
    Loading model from cache C:\Users\62318\AppData\Local\Temp\jieba.cache
    Loading model cost 1.779 seconds.
    Prefix dict has been built successfully.
    0.01
    

## 3.5 HMM模型

### 3.5.1 HMM模型简介
隐含马尔可夫模型（HMM）是将分词作为字，在字串中的序列标注任务来实现的。

思路：每个字在构造一个特定的词语时都占据着一个确定的构词位置（即词位），现规定每个字最多只有四个构词位置：即B（词首）、M（词中）、E（词尾）、S（单独成词）。
例子：

1）中文/分词/是/文本处理/不可或缺/的/一步！

2）中/B 文/E 分/B 词/E 是/S 文/B 本/M 处/M 理/E 不/B 可/M 或/M 缺/E 的/S 一/B 步/E ！/S




是关于时序的概率模型，描述了由隐藏的马尔科夫链随机生成一个不可观测的状态随机序列，再由各个状态生成一个可观测的随机序列的过程，模型由以下5个参数确定：

**Status Set**: 状态值集合 V={$v_1$,$v_2$,...,$v_M$}，是所有可能的隐藏状态的集合
**Observed Set**: 观测值集合 Q={$q_1$,$q_2$,...,$q_N$}，是所有可能的观测状态的集合
**TransProb Matrix**: 转移概率矩阵 A

$$
\begin{bmatrix}
a_{11} & a_{12} &\cdots&a_{1j} \\
a_{21} & a_{22} &\cdots&a_{2j} \\
\vdots & \vdots & &\vdots \\
a_{i1} & a_{i2} &\cdots&a_{ij}\\
\end{bmatrix}
$$

**EmitProbMatrix**: 发射概率矩阵 B

$$
\begin{bmatrix}
b_{11} & b_{12} &\cdots&b_{1n} \\
b_{21} & b_{22} &\cdots&b_{2n} \\
\vdots & \vdots & &\vdots \\
b_{m1} & b_{m2} &\cdots&b_{mn}\\
\end{bmatrix}
$$
**Init Status**: 初始状态分布 $\pi$=($\pi_1$,$\pi_2$,$\cdots$,$\pi_i$)

**这里增加两个定义：**
**观察值序列**：O={$o_1,o_2,..,o_T$},其中，$o$可以取Q集合中的任何值
**状态值序列**：$I$={$i_1,i_2,...,i_T$},其中，$i$可以取V集合中的任何值

**举个例子，更好地描述隐马尔可夫模型的应用：**
A和B是好朋友，每天打电话聊天。已知B所在的地方天气不太好，下雨天多过晴天，天气会影响B当天做什么事。通话时，A只知道B每天做了什么事，不知道B所在地的天气，如果A想通过B对日常事务的描述推断出B所在地的天气，就可以使用HMM模型来解决。
为简化模型，我们假设B所在地的天气只有两种——rainy、sunny，B只会做三件事——walk,shop,clean，此时观测结果O(日常事务)是实际隐藏状态Q(B地天气)的概率函数，可以用隐马尔可夫模型来进行建模分析。


![Markdown](http://i2.tiimg.com/611786/8a98587d8085884a.png)

### 3.5.2 什么样的问题需要用HMM模型解决:
**使用HMM模型时，我们的问题一般有这两个特征：**
1.问题是基于序列的，比如时间序列，或者状态序列。状态序列，简称状态序列。
在这里观测序列是B的日常事务————下楼散步、出门采购、打扫房间，隐藏状态序列是B所在地的天气
2.问题中有两类数据，一类序列数据是可以观测到的，即观测序列；而另一类数据是不能观察到的，即隐藏

### 3.5.3 HMM模型做了两个很重要的假设:
1.观测独立性假设。假设任意时刻的观测只依赖于当前时刻的隐藏的马尔科夫链的状态，与其他观测及状态无关，即$o_t$由$i_t$决定。这也是一个为了简化模型的假设，也就是说，B每天选择散步、采购还是打扫卫生只依赖于当天的天气如何。

2.齐次马尔科夫链假设。假设隐藏的马尔科夫链在任意时刻t的状态只依赖于它前一个时刻的隐藏状态，即$i_t$由$i_{t-1}$决定。。

### 3.5.4 HMM要解决的三个基本问题:
1.评估问题。已知模型$\lambda$=(A,B,$\pi$)和观测序列O={$o_1$,$o_2$,...,$o_T$}，那么该模型下观测序列O出现的概率P(O|$\lambda$)？
2.学习问题。已知观测序列O={$o_1$,$o_2$,...,$o_T$}，估计模型$\lambda$=(A,B,$\pi$)，使得在该模型下观测序列概率P(O|$\lambda$)最大
3.预测问题，也称解码问题。已知模型$\lambda$=(A,B,$\pi$)和观测序列O={$o_1$,$o_2$,...,$o_T$}，求该给定观测序列下，最有可能的对应状态序列？

**对应三个基本问题，有三个算法能分别解决三个基本问题**

### 3.5.5 评估问题算法
#### 3.5.5.1 前向算法
首先,定义前向概率$\alpha(i)$=P($o_1$, $o_2$, $\cdots$ ,$o_t$ ,$i_t$=$q_i$|$\lambda$)

输入：隐马尔可夫模型$\lambda$，观测序列O

输出：观测序列的概率P(O|$\lambda$)

步骤：

(1)初值   $\alpha_1(i)$=P($o_1$,$i_t$=$q_i$|$\lambda$)

![Markdown](http://i1.fuimg.com/611786/ba4c300cb5681756.png)

我们要求的观测序列O出现的条件概率可利用前向概率得到：
$P(O|\lambda)=\sum_{i=1}^{N} P(O,i_t=q_i|\lambda)=\sum_{i=1}^{N}\alpha_T(i)$

(2)递推得到$\alpha_t(j)$，对于t=1,2,...,T-1,

$\alpha_{t+1}(i)=P(o_1,o_2,\cdots,o_t,o_{t+1},i_{t+1}=q_j|\lambda)$
$=\sum_{i=1}^{N}P(o_1,o_2,\cdots,o_t,o_{t+1},i_t=q_i,i_{t+1}=q_j|\lambda)$
$=\sum_{i=1}^{N}P(o_{t+1}|o_1,o_2,\cdots,o_t,i_t=q_i,i_{t+1}=q_j,\lambda)P(o_1,o_2,\cdots,o_t,i_t=q_i,i_{t+1}=q_j|\lambda)$
$=\sum_{i=1}^{N}P(o_{t+1}|i_{t+1}=q_j）P(o_1,o_2,\cdots,o_t,i_t=q_j|\lambda)$
$=\sum_{i=1}^{N}P(o_{t+1}|i_{t+1}=q_j)P(i_{t+1}=q_j|o_1,o_2,\cdots,o_t,i_t=q_i,\lambda)P(o_1,o_2,\cdots,o_t,i_t=q_j|\lambda)$
$=\sum_{i=1}^{N}P(o_{t+1}|i_{t+1}=q_j)P(i_{t+1}=q_j|i_t=q_j)\alpha_t(i)$
$=\sum_{i=1}^Nb_j(o_{t+1})a_{ij}\alpha_t(i)$
即 $\alpha_{t+1}(i)=b_j(o_{t+1})[ \sum_{i=1}^Na_{ij}\alpha_t(i) ]$              

(3)终止  P(O|$\lambda$)=$\sum_{i=1}^N\alpha_T(i)$



#### 3.5.5.2 后向算法
与前向算法类似，可观测序列取的是($o_{t+1}$,$o_{t+2}$,...,$o_T$)
![Markdown](http://i2.tiimg.com/611786/79e7f3f92d701087.png)
### 3.5.6 学习问题算法
#### 3.5.6.1 监督学习方法
用极大似然估计法来估计HMM的参数，具体方法为：
（1）转移概率$a_{ij}$的估计

$\hat{a}_{ij}$=$\frac{A_{ij}}{{\sum_{j=1}^N}A_{ij}}$

其中，i=1,2,...,N；j=1,2,...,N；$A_{ij}$为样本中时刻t处于状态i，时刻t+1转移到状态j的频数

（2）观测概率$b_j(k)$的估计

$\hat{b}_j(k)$=$\frac{B_{jk}}{{\sum_{k=1}^M}B_{jk}}$

其中，j=1,2,...,N；k=1,2,...,M；$B_{jk}$是样本中状态为j并观测为k的频数

（3）初始状态概率$\pi_i$的估计为样本中初始状态为$q_i$的频率

**由于该方法需要使用训练数据，而人工标注训练数据的代价过高**

#### 3.5.6.2 Baum-Welch算法
Baum-Welch算法其实是EM算法在隐马尔可夫模型学习中的具体实现,我们需要在E步求出联合分布$P(O,I|\lambda)$基于条件概率$P(O,I|\bar{\lambda})$的期望，其中$\bar{\lambda}$为当前的模型参数，然后在M步中最大化这个期望，得到更新的模型参数$\lambda$，接着不断地重复E步和M步的迭代，直到$\bar{\lambda}$收敛为止。

（1）EM算法的E步：求Q函数
将EM算法中的Q函数
![Markdown](http://i1.fuimg.com/611786/7ce04f1707a09605.png)
对应进HMM模型中，其中，Y$\rightarrow$观测序列O，Z$\rightarrow$隐藏状态I，$\theta\rightarrow$参数$\lambda$，且I为离散序列，可得出Q函数
Q($\lambda$,$\bar{\lambda}$)=$\sum_IlogP(O,I|\lambda)P(O,I|\bar{\lambda})$
（2）EM算法的M步：极大化Q函数Q($\lambda$,$\bar{\lambda}$)，求极大化时的模型参数A,B,$\pi$（用拉格朗日乘子法，写出拉格朗日函数，对其求偏导并令为0）

### 3.5.7 预测问题算法
#### 3.5.7.1 近似算法
在每个时刻t选择在该时刻最有可能出现的状态$i_t^*$,从而得到一个状态序列$I^*=(i_1^*,i_2^*,..,i_t^*)$,将它作为预测的结果。这个算法的优点是计算简单，但是却不能保证预测的状态序列的整体是最可能的状态序列，因为预测的状态序列中某些相邻的隐藏状态可能存在转移概率为0的情况。

#### 3.5.7.2 维比特算法
![Markdown](http://i2.tiimg.com/611786/db3d9375c6cd1299.png)
![Markdown](http://i1.fuimg.com/611786/2d4e8279fd4f6cec.png)
#### 3.5.7.3 维比特算法在中文分词里的应用

#### 针对中文分词，直接给HMM模型的五元组参数赋予具体含义： ####
**状态值集合V**={$v_1$,$v_2$,$v_3$,$v_4$},其中，$v_1$为B，$v_2$为M，$v_3$为E，$v_4$为S，即V={B, M, E, S}，分别代表每个状态代表的是该字在词语中的位置，B代表该字是词语中的起始字(begin)，M代表是词语中的中间字(middle)，E代表是词语中的结束字(end)，S则代表是单字成词(single)。

**观察值集合Q**为所有汉字(东南西北你我他…)，甚至包括标点符号所组成的集合。

在HMM模型中文分词中，我们的输入是一个句子(也就是观察值序列)，输出是这个句子中每个字的状态值。比如，输入观察值序列———我爱中国，这个序列中得每个字，观察值集合中都有，输出的状态序列为BMS。
根据这个状态序列我们可以进行切词:B/M/S ，切词结果:我/爱/中国

**初始状态概率分布$\pi$** 是输入的句子的第一个字属于{B,E,M,S}这四种状态的概率，容易理解，开头的第一个字只可能是词语的首字(B)，或者是单字成词(S)，E和M的概率都是0。

**转移概率矩阵 A**  矩阵的横坐标和纵坐标顺序是BEMS x BEMS，比如A[0][2]代表的含义就是从状态B转移到状态M的概率。由状态各自的含义可知，状态B后面只能接M和E，状态M后面只能接M和E，状态E后面只能接B和S，状态S后面只能接B和S。

**发射概率矩阵 B**  矩阵中的发射概率$b_{ij}$其实一个条件概率，观测值完全依赖于当前的状态值（观测独立性假设）

**HMM模型里所需的三个概率都是通过对指定语料库里的分词语料进行训练得出的**

##### HMM中文分词之Viterbi算法 
输入样例: 我爱北京
Viterbi算法计算过程如下： 
**1.通过初始概率、转移概率、发射概率，计算出二维数组weight[4][4]**，4是状态数(0:B,1:E,2:M,3:S)，4是输入句子的字数。例如 weight[0][2] 代表 状态B的条件下，出现’北’这个字的可能性。

![Markdown](http://i2.tiimg.com/611786/f590e171cfc612f7.png)
![Markdown](http://i2.tiimg.com/611786/5b040ab4493790c5.png)

**2.在weight里取最大概率，计算得到二维数组path**，4是状态数(0:B,1:E,2:M,3:S)，4是输入句子的字数。例如 path[0][2] 代表 weight[0][2]取到最大时，前一个字的状态，比如 path[0][2] = 1, 则代表 weight[0][2]取到最大时，前一个字(也就是爱)的状态是E。

![Markdown](http://i1.fuimg.com/611786/71ca686d4b51d61f.png)
**3.从最后一个字向前回溯**：
能得出“京”字最大的概率为E状态下的0.00192，所以最优路径下，“京”字是在E的位置；再往前推，“京”的E状态下的0.00192是由前一个字“北”的第三条路线得到的，所以最优路径经过“北”的第三个位置，即最优路径下，“北”应为M状态；而“北”能在M状态达到最大概率是由于前一个字“爱”的第三条路线得出的，所以在最优路径下，“爱”的位置为M；再向前推，“爱”在M状态室友“我”的第一条路线得出的，所以在最优路径下，“我”的位置为B。所以最优路径为“B-M-M-E”。


```python
# 未启用 HMM
seg_list = jieba.cut("他来到了网易杭研大厦", HMM=False) #默认精确模式和启用 HMM
print("【未启用 HMM】：" + "/ ".join(seg_list))

# 识别新词
seg_list = jieba.cut("他来到了网易杭研大厦") #默认精确模式和启用 HMM
print("【识别新词启用 HMM】：" + "/ ".join(seg_list)) 
```

    【未启用 HMM】：他/ 来到/ 了/ 网易/ 杭/ 研/ 大厦
    【识别新词】：他/ 来到/ 了/ 网易/ 杭研/ 大厦
    


```python
class HMM(object):
    def __init__(self):
        pass
    
    def try_load_model(self, trained):
        pass
    
    def train(self, path):
        pass
    
    def viterbi(self, text, states, start_p, emit_p):
        pass
    
    def cut(self, text):
        pass
        
```

_init_主要是初始化一些全局信息，用于初始化一些成员变量。


```python
class HMM(object):
    def __init__(self):
        import os

        # 主要是用于存取算法中间结果，不用每次都训练模型
        self.model_file = 'learning-nlp/chapter-3/data/hmm_model.pkl'

        # 状态值集合
        self.state_list = ['B', 'M', 'E', 'S']
        # 参数加载,用于判断是否需要重新加载model_file
        self.load_para = False

    # 用于加载已计算的中间结果，当需要重新训练时，需初始化清空结果
    def try_load_model(self, trained):
        if trained:
            import pickle
            with open(self.model_file, 'rb') as f:
                self.A_dic = pickle.load(f)
                self.B_dic = pickle.load(f)
                self.Pi_dic = pickle.load(f)
                self.load_para = True

        else:
            # 状态转移概率（状态->状态的条件概率）
            self.A_dic = {}
            # 发射概率（状态->词语的条件概率）
            self.B_dic = {}
            # 状态的初始概率
            self.Pi_dic = {}
            self.load_para = False

    # 计算转移概率、发射概率以及初始概率
    def train(self, path):

        # 重置几个概率矩阵
        self.try_load_model(False)

        # 统计状态出现次数，求p(o)
        Count_dic = {}

        # 初始化参数
        def init_parameters():
            for state in self.state_list:
                self.A_dic[state] = {s: 0.0 for s in self.state_list}
                self.Pi_dic[state] = 0.0
                self.B_dic[state] = {}

                Count_dic[state] = 0

        def makeLabel(text):
            out_text = []
            if len(text) == 1:
                out_text.append('S')
            else:
                out_text += ['B'] + ['M'] * (len(text) - 2) + ['E']

            return out_text

        init_parameters()
        line_num = -1
        # 观察者集合，主要是字以及标点等
        words = set()
        with open(path, encoding='utf8') as f:
            for line in f:
                line_num += 1

                line = line.strip()
                if not line:
                    continue

                word_list = [i for i in line if i != ' ']
                words |= set(word_list)  # 更新字的集合

                linelist = line.split()

                line_state = []
                for w in linelist:
                    line_state.extend(makeLabel(w))
                
                assert len(word_list) == len(line_state) #用来让程序测试这个condition，如果condition为false，那么raise一个AssertionError出来

                for k, v in enumerate(line_state): # 函数用于将一个可遍历的数据对象(如列表、元组或字符串)组合为一个索引序列，同时列出数据和数据下标
                    Count_dic[v] += 1
                    if k == 0:
                        self.Pi_dic[v] += 1  # 每个句子的第一个字的状态，用于计算初始状态概率
                    else:
                        self.A_dic[line_state[k - 1]][v] += 1  # 计算转移概率
                        self.B_dic[line_state[k]][word_list[k]] = \
                            self.B_dic[line_state[k]].get(word_list[k], 0) + 1.0  # 计算发射概率
        
        self.Pi_dic = {k: v * 1.0 / line_num for k, v in self.Pi_dic.items()}
        self.A_dic = {k: {k1: v1 / Count_dic[k] for k1, v1 in v.items()}
                      for k, v in self.A_dic.items()}
        #加1平滑
        self.B_dic = {k: {k1: (v1 + 1) / Count_dic[k] for k1, v1 in v.items()}
                      for k, v in self.B_dic.items()}
        #序列化
        import pickle
        with open(self.model_file, 'wb') as f:
            pickle.dump(self.A_dic, f)
            pickle.dump(self.B_dic, f)
            pickle.dump(self.Pi_dic, f)

        return self

    def viterbi(self, text, states, start_p, trans_p, emit_p):
        V = [{}]
        path = {}
        for y in states:
            V[0][y] = start_p[y] * emit_p[y].get(text[0], 0)
            path[y] = [y]
        for t in range(1, len(text)):
            V.append({})
            newpath = {}
            
            #检验训练的发射概率矩阵中是否有该字
            neverSeen = text[t] not in emit_p['S'].keys() and \
                text[t] not in emit_p['M'].keys() and \
                text[t] not in emit_p['E'].keys() and \
                text[t] not in emit_p['B'].keys()
            for y in states:
                emitP = emit_p[y].get(text[t], 0) if not neverSeen else 1.0 #设置未知字单独成词
                (prob, state) = max(
                    [(V[t - 1][y0] * trans_p[y0].get(y, 0) *
                      emitP, y0)
                     for y0 in states if V[t - 1][y0] > 0])
                V[t][y] = prob
                newpath[y] = path[state] + [y]
            path = newpath
            
        if emit_p['M'].get(text[-1], 0)> emit_p['S'].get(text[-1], 0):
            (prob, state) = max([(V[len(text) - 1][y], y) for y in ('E','M')])
        else:
            (prob, state) = max([(V[len(text) - 1][y], y) for y in states])
        
        return (prob, path[state])

    def cut(self, text):
        import os
        if not self.load_para:
            self.try_load_model(os.path.exists(self.model_file))
        prob, pos_list = self.viterbi(text, self.state_list, self.Pi_dic, self.A_dic, self.B_dic)      
        begin, next = 0, 0    
        for i, char in enumerate(text): # 函数用于将一个可遍历的数据对象(如列表、元组或字符串)组合为一个索引序列，同时列出数据和数据下标
            pos = pos_list[i]
            if pos == 'B':
                begin = i
            elif pos == 'E':
                yield text[begin: i+1]
                next = i+1
            elif pos == 'S':
                yield char
                next = i+1
        if next < len(text):
            yield text[next:]
```


```python
hmm = HMM()

hmm.train('learning-nlp/chapter-3/data/trainCorpus.txt_utf8')

text = '这是一个非常棒的方案！'
res = hmm.cut(text)
print(text)
print(str(list(res)))
```

    这是一个非常棒的方案！
    ['这是', '一个', '非常', '棒', '的', '方案', '！']
    

### 3.5.8 其他统计分词算法

条件随机场（CRF），也是一种基于马尔可夫思想的统计模型。该算法使得每个状态不止与他前面的状态有关，还与他后面的状态有关。

## 3.6 混合分词

事实上，目前不管是基于规则的算法、还是基于HMM、CRF或者deep learning等的方法，其分词效果在具体任务中，差距并没有那么明显。在实际应用中，最常用的方式就是先基于词典的方式进行分词，然后再用统计分词方法进行辅助。


## 3.7 中文分词工具——jieba
jieba分词官网地址是*https://github.com/fxsjy/jieba*

jiaba字典和其他常用字典*https://github.com/fighting41love/funNLP*

### 3.7.1 jieba的三种分词模式

+ 精确模式：试图将句子最精确地切开，适合文本分析

+ 全模式：把句子中所以可以成词的词语都扫描出来，速度非常快，但是不能解决歧义。

+ 搜索引擎模式：在精确模式的基础上，对长词再次切分，提高召回率，适合用于搜索引擎分词。

可使用 jieba.cut 和 jieba.cut_for_search 方法进行分词，两者所返回的结构都是一个可迭代的 generator，或者直接使用 jieba.lcut 以及 jieba.lcut_for_search 直接返回 list。




```python
import jieba 
sent = '中文分词是文本处理不可缺少的一步！'
seg_list = jieba.cut(sent, cut_all = True)
print('全模式：', '/'.join(seg_list))
type(seg_list)

seg_llist = jieba.lcut(sent, cut_all = True)
print('全模式(返回列表): {0}'.format(seg_llist))


seg_list = jieba.cut(sent, cut_all= False)
print('精确模式：', '/'.join(seg_list))

seg_list = jieba.cut(sent)
print('默认精确模式：', '/'.join(seg_list))

seg_list = jieba.cut_for_search(sent)
print('搜索引擎模式：', '/'.join(seg_list))
```

    Building prefix dict from the default dictionary ...
    Loading model from cache C:\Users\62318\AppData\Local\Temp\jieba.cache
    Loading model cost 1.339 seconds.
    Prefix dict has been built successfully.
    全模式： 中文/分词/是/文本/文本处理/本处/处理/不可/缺少/的/一步/！
    全模式(返回列表): ['中文', '分词', '是', '文本', '文本处理', '本处', '处理', '不可', '缺少', '的', '一步', '！']
    精确模式： 中文/分词/是/文本处理/不可/缺少/的/一步/！
    默认精确模式： 中文/分词/是/文本处理/不可/缺少/的/一步/！
    搜索引擎模式： 中文/分词/是/文本/本处/处理/文本处理/不可/缺少/的/一步/！
    

在 jieba 中，对于未登录到词库的词，使用了基于汉字成词能力的 HMM 模型和 Viterbi 算法，其大致原理是：采用四个隐含状态，分别表示为单字成词，词组的开头，词组的中间，词组的结尾。通过标注好的分词训练集，可以得到 HMM 的各个参数，然后使用 Viterbi 算法来解释测试集，得到分词结果。

### 3.7.2 添加自定义词典

开发者可以指定自定义词典，以便包含 jieba 词库里没有的词，词典格式如下：

词语 词频（可省略） 词性（可省略）

例如：

创新办 3 i

云计算 5

凱特琳 nz

虽然 jieba 有新词识别能力，但自行添加新词可以保证更高的正确率














### 3.7.3 载入词典

使用 jieba.load_userdict(file_name) 即可载入词典。






```python
#示例 文本
sample_text = "周大福是创新办主任也是云计算方面的专家"
# 未加载词典
print("【未加载词典】：" + '/ '.join(jieba.cut(sample_text)))

# 载入词典
jieba.load_userdict("./userdict.txt")

# 加载词典后
print("【加载词典后】：" + '/ '.join(jieba.cut(sample_text)))


```

    【未加载词典】：周大福/ 是/ 创新/ 办/ 主任/ 也/ 是/ 云/ 计算/ 方面/ 的/ 专家
    【加载词典后】：周大福/ 是/ 创新办/ 主任/ 也/ 是/ 云计算/ 方面/ 的/ 专家
    

### 3.7.4 调整词典

使用 add_word(word, freq=None, tag=None) 和 del_word(word) 可在程序中动态修改词典。



```python
jieba.add_word('石墨烯') #增加自定义词语
jieba.add_word('凱特琳', freq=42, tag='nz') #设置词频和词性 
jieba.del_word('自定义词') #删除自定义词语 
# 调节词频前
print("【调节词频前】：" + '/'.join(jieba.cut('如果放到post中将出错。', HMM=False)))

# 调节词频
jieba.suggest_freq(('中', '将'), True)
# 调节词频后
print("【调节词频后】：" + '/'.join(jieba.cut('如果放到post中将出错。', HMM=False)))
```

    【调节词频前】：如果/放到/post/中将/出错/。
    【调节词频后】：如果/放到/post/中/将/出错/。
    

### 3.7.5 关键词提取
jieba 提供了两种关键词提取方法，分别基于 TF-IDF 算法和 TextRank 算法。


#### 3.7.5.1基于 TF-IDF 算法的关键词提取
TF-IDF(Term Frequency-Inverse Document Frequency, 词频-逆文件频率)是一种统计方法，用以评估一个词语对于一个文件集或一个语料库中的一份文件的重要程度，其原理可概括为：

一个词语在一篇文章中出现次数越多，同时在所有文档中出现次数越少，越能够代表该文章。

计算公式：TF-IDF = TF * IDF，其中：

+ TF(term frequency, TF)：词频，某一个给定的词语在该文件中出现的次数，计算公式：$$ TF_\omega = \frac{在某类中词条\omega 出现的次数}{该类所有的词条数目}$$或$$ TF = \frac{某个词在文章中出现次数}{文章的总词数}$$

+ IDF(inverse document frequency, IDF)：逆文件频率，如果包含词条的文件越少，则说明词条具有很好的类别区分能力，计算公式：$$ IDF = log(\frac{语料库的文档总数}{包含词条\omega的文档数+1}) $$

如果一个词越常见，那么分母就越大，逆文档频率就越小越接近0。分母之所以要加1，是为了避免分母为0（即所有文档都不包含该词）








通过 jieba.analyse.extract_tags 方法可以基于 TF-IDF 算法进行关键词提取，该方法共有 4 个参数：

+ sentence：为待提取的文本

+ topK：根据tf-idf值对词频词典中的词进行降序排序，然后输出topK个词作为关键词，默认值为 20

+ withWeight：是否一并返回关键词权重值，默认值为 False

+ allowPOS：仅包括指定词性的词，默认值为空

#### 词性对照表（allowPOS可选值）
##### 名词 (1个一类，7个二类，5个三类)
名词分为以下子类：
n 名词
nr 人名
nr1 汉语姓氏
nr2 汉语名字
nrj 日语人名
nrf 音译人名
ns 地名
nsf 音译地名
nt 机构团体名
nz 其它专名
nl 名词性惯用语
ng 名词性语素

##### 时间词(1个一类，1个二类)
t 时间词
tg 时间词性语素

##### 处所词(1个一类)
s 处所词

##### 方位词(1个一类)
f 方位词

##### 动词(1个一类，9个二类)
v 动词
vd 副动词
vn 名动词
vshi 动词“是”
vyou 动词“有”
vf 趋向动词
vx 形式动词
vi 不及物动词（内动词）
vl 动词性惯用语
vg 动词性语素

##### 形容词(1个一类，4个二类)
a 形容词
ad 副形词
an 名形词
ag 形容词性语素
al 形容词性惯用语

#####  区别词(1个一类，2个二类)
b 区别词
bl 区别词性惯用语

##### 状态词(1个一类)
z 状态词

##### 代词(1个一类，4个二类，6个三类)
r 代词
rr 人称代词
rz 指示代词
rzt 时间指示代词
rzs 处所指示代词
rzv 谓词性指示代词
ry 疑问代词
ryt 时间疑问代词
rys 处所疑问代词
ryv 谓词性疑问代词
rg 代词性语素

##### 数词(1个一类，1个二类)
m 数词
mq 数量词

##### 量词(1个一类，2个二类)
q 量词
qv 动量词
qt 时量词

##### 副词(1个一类)
d 副词

##### 介词(1个一类，2个二类)
p 介词
pba 介词“把”
pbei 介词“被”

##### 连词(1个一类，1个二类)
c 连词
cc 并列连词

##### 助词(1个一类，15个二类)
u 助词
uzhe 着
ule 了 喽
uguo 过
ude1 的 底
ude2 地
ude3 得
usuo 所
udeng 等 等等 云云
uyy 一样 一般 似的 般
udh 的话
uls 来讲 来说 而言 说来
uzhi 之
ulian 连 （“连小学生都会”）

##### 叹词(1个一类)
e 叹词

##### 语气词(1个一类)
y 语气词(delete yg)

##### 拟声词(1个一类)
o 拟声词
前缀(1个一类)

h 前缀
##### 后缀(1个一类)
k 后缀

##### 字符串(1个一类，2个二类)
x 字符串
xx 非语素字
xu 网址URL

##### 标点符号(1个一类，16个二类)
w 标点符号
wkz 左括号，全角：（ 〔 ［ ｛ 《 【 〖 〈 半角：( \[ { <
wky 右括号，全角：） 〕 ］ ｝ 》 】 〗 〉 半角： ) \] { >
wyz 左引号，全角：“ ‘ 『
wyy 右引号，全角：” ’ 』
wj 句号，全角：。
ww 问号，全角：？ 半角：?
wt 叹号，全角：！ 半角：!
wd 逗号，全角：， 半角：,
wf 分号，全角：； 半角： ;
wn 顿号，全角：、
wm 冒号，全角：： 半角： :
ws 省略号，全角：…… …
wp 破折号，全角：—— －－ ——－ 半角：— —-
wb 百分号千分号，全角：％ ‰ 半角：%
wh 单位符号，全角：￥ ＄ ￡ ° ℃ 半角：$

版权声明：本文为CSDN博主「apriaaaa」的原创文章，遵循 CC 4.0 BY-SA 版权协议

原文链接：*https://blog.csdn.net/apriaaaa/article/details/90261723*



```python
import jieba

import jieba.analyse as anls
s = "此外，公司拟对全资子公司吉林欧亚置业有限公司增资4.3亿元，增资后，吉林欧亚置业注册资本由7000万元增加到5亿元。吉林欧亚置业主要经营范围为房地产开发及百货零售等业务。目前在建吉林欧亚城市商业综合体项目。2013年，实现营业收入0万元，实现净利润-139.13万元。"

for x, w in anls.extract_tags(s, topK=20, withWeight=True):
    print('%s %s' % (x, w))


```

    欧亚 0.7300142700289363
    吉林 0.659038184373617
    置业 0.4887134522112766
    万元 0.3392722481859574
    增资 0.33582401985234045
    4.3 0.25435675538085106
    7000 0.25435675538085106
    2013 0.25435675538085106
    139.13 0.25435675538085106
    实现 0.19900979900382978
    综合体 0.19480309624702127
    经营范围 0.19389757253595744
    亿元 0.1914421623587234
    在建 0.17541884768425534
    全资 0.17180164988510638
    注册资本 0.1712441526
    百货 0.16734460041382979
    零售 0.1475057117057447
    子公司 0.14596045237787234
    营业 0.13920178509021275
    

#### 3.7.5.2 基于 TextRank 算法的关键词提取

TextRank 是另一种关键词提取算法，基于大名鼎鼎的 PageRank，以词为节点，以共现关系建立起节点之间的链接。TextRank实际上是依据位置与词频来计算词的权重的。

通过 jieba.analyse.textrank 方法可以使用基于 TextRank 算法的关键词提取，其与 'jieba.analyse.extract_tags' 有一样的参数，但前者默认过滤词性（allowPOS=('ns', 'n', 'vn', 'v')）。


##### PageRank算法
PageRank可以定义在任意有向图上，后来被应用到社会影响力分析、文本摘要等多个问题。

###### 基本想法：

在有向图上定义一个随机游走模型，即一阶马尔可夫链，描述随机游走者沿着有向图随机访问各个结点的行为。

在一定条件下，极限情况访问每个结点的概率收敛到平稳分布，各个结点的平稳分布概率值就是其PageRank值，表示结点的重要度。

PageRank值越高，网页就越重要。

假设浏览者在每个网页依照连接出去的超链接以等概率跳转到下一个网页，并在网上持续不断进行这样的随机跳转，这个过程形成一阶马尔可夫链。

![Markdown](http://i1.fuimg.com/611786/054bef7100fd2126.png)

![Markdown](http://i1.fuimg.com/611786/5f84e2e696ccecaf.png)

图片来源：*https://blog.csdn.net/qq_38842357/article/details/80872480*



先假设一个初始分布，通过迭代，不断计算所有网页的PageRank值，直到收敛为止。

在有向图上的随机游走形成马尔可夫链。即下一个时刻的状态只依赖于当前的状态，与过去无关。

###### PageRank的核心思想：

+ 如果一个网页被很多其他网页链接到的话说明这个网页比较重要，也就是PageRank值会相对较高

+ 如果一个PageRank值很高的网页链接到一个其他的网页，那么被链接到的网页的PageRank值会相应地因此而提高






$$ S(V_i) = (1 - d) + d * \sum_{j \varepsilon In(V_i)} \frac{1}{|Out(V_j)|} S(V_j) $$

In(Vi)表示网页Vi的所有入链的集合Vi表示某个网页，Vj表示链接到Vi的网页（即Vi的入链），S(Vi)表示网页Vi的PR值，Out(Vj)表示$V_j$指向的链接，d表示阻尼系数，是用来克服这个公式中“d *”后面的部分的固有缺陷用的：如果仅仅有求和的部分，那么该公式将无法处理没有入链的网页的PR值，因为这时，根据该公式这些网页的PR值为0，但实际情况却不是这样，根据实验的结果，在0.85的阻尼系数下，大约100多次迭代PR值就能收敛到一个稳定的值，而当阻尼系数接近1时，需要的迭代次数会陡然增加很多，且排序不稳定。


###### TextRank算法的基本思想
将文档看作一个词的网络，该网络中的链接表示词与词之间的语义关系。以词为节点，以共现关系建立起节点之间的链接，需要强调的是，PageRank中是有向边，而TextRank中是无向边，或者说是双向边

$$ S(V_i) = (1 - d) + d * \sum_{j \varepsilon In(V_i)} \frac{\omega_{ij}}{\sum_{V_j \varepsilon Out(V_j) }\omega_{ij} } WS(V_j) $$

可以看出，该公式仅仅比PageRank多了一个权重项Wji，用来表示两个节点之间的边连接有不同的重要程度。

###### TextRank用于关键词提取的算法如下:

1. 把给定的文本T按照完整句子进行分割，$T=[S_1,S_2,......,S_m]$，

2. 对于每个句子，进行分词和词性标注处理，并过滤掉停用词，只保留指定词性的单词，如名词、动词、形容词，即，Si=$[pi_1，pi_2，...，pi_n]$

3. 构建候选关键词图G = (V,E)，其中V为节点集，由2生成的候选关键词组成，然后采用共现关系（co-occurrence）构造任两点之间的边，两个节点之间存在边仅当它们对应的词汇在长度为K的窗口中共现，即：$[p_1,p_2,...,p_k][p_2,p_3,...,p_{k+1}]$等都是一个个的窗口，在一个窗口中如果两个单词同时出现，则认为对应单词节点间存在一个边，

4. 根据PageRank原理中的衡量重要性的公式，初始化各节点的权重，然后迭代计算各节点的权重，直至收敛，

5. 对节点权重进行倒序排序，从而得到最重要的T个单词，作为候选关键词，

6. 由（5）得到最重要的T个单词，在原始文本中进行标记，若形成相邻词组，则组合成多词关键词。例如，文本中有句子“Matlab code for plotting ambiguity function”，如果“Matlab”和“code”均属于候选关键词，则组合成“Matlab code”加入关键词序列。

 例如：

 \['有','媒体', '曝光','高圆圆', '和', '赵又廷','现身', '台北', '桃园','机场','的', '照片'\]

 对于‘媒体‘这个单词，就有（'媒体', '曝光'）、（'媒体', '圆'）、（'媒体', '和'）、（'媒体', '赵又廷'）4条边，且每条边权值为1，当这条边在之后再次出现时，权值再在基础上加1。

 有了这些数据后，我们就可以构建出候选关键词图G = (V,E)

 




```python
for x, w in anls.textrank(s, withWeight=True):
    print('%s %s' % (x, w))
```

    吉林 1.0
    欧亚 0.9966893354178172
    置业 0.6434360313092776
    实现 0.5898606692859626
    收入 0.43677859947991454
    增资 0.4099900531283276
    子公司 0.35678295947672795
    城市 0.34971383667403655
    商业 0.34817220716026936
    业务 0.3092230992619838
    在建 0.3077929164033088
    营业 0.3035777049319588
    全资 0.303540981053475
    综合体 0.29580869172394825
    注册资本 0.29000519464085045
    有限公司 0.2807830798576574
    零售 0.27883620861218145
    百货 0.2781657628445476
    开发 0.2693488779295851
    经营范围 0.2642762173558316
    

### 3.7.6 自定义语料库
关键词提取所使用逆向文件频率（IDF）文本语料库和停止词（Stop Words）文本语料库可以切换成自定义语料库的路径。



### 3.7.7 词性标注

jieba.posseg.POSTokenizer(tokenizer=None) 新建自定义分词器。

+ tokenizer 参数可指定内部使用的 jieba.Tokenizer 分词器。jieba.posseg.dt 为默认词性标注分词器。




```python
jieba.analyse.set_stop_words("userdict.txt")
jieba.analyse.set_idf_path("idf.txt.big")
for x, w in anls.extract_tags(s, topK=20, withWeight=True):
    print('%s %s' % (x, w))
```

    吉林 1.0174270215234043
    欧亚 1.0174270215234043
    置业 0.7630702661425532
    万元 0.7630702661425532
    增资 0.5087135107617021
    亿元 0.5087135107617021
    实现 0.5087135107617021
    此外 0.25435675538085106
    公司 0.25435675538085106
    全资 0.25435675538085106
    子公司 0.25435675538085106
    有限公司 0.25435675538085106
    4.3 0.25435675538085106
    注册资本 0.25435675538085106
    7000 0.25435675538085106
    增加 0.25435675538085106
    主要 0.25435675538085106
    经营范围 0.25435675538085106
    房地产 0.25435675538085106
    开发 0.25435675538085106
    


```python
import jieba.posseg as pseg
words = pseg.cut("他改变了中国")
for word, flag in words:
    print("{0} {1}".format(word, flag))
```

    他 r
    改变 v
    了 ul
    中国 ns
    
