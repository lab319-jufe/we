## 如何配置双账号的GIT

### 生成第一个密钥

具体过程不解释，请看b站视频；

### 生成第二个密钥

#### 输入ssh-keygen -t rsa -C "yourmail@gmail.com"

#### 出现：

> Generating public/private rsa key pair.
Enter file in which to save the key (/c/Users/Gary/.ssh/id_rsa): 

#### 这里不要一路回车，自己在冒号后手动填写保存路径：

> /c/Users/Gary/.ssh/id_rsa_github

#### 完成之后，我们可以看到~/.ssh目录下多了两个文件，变成：

> id_rsa

> id_ras.pub

> id_rsa_github

> id_rsa_github.pub

> known_hosts

### 添加Host  
#### 在~/.ssh/下新建config文件，名字为config，没有后缀，用记事本打开，编辑：

  

> #Default github user(first@mail.com)  
Host github.com  
HostName github.com  
User git  
IdentityFile C:/Users/Administrator/.ssh/id_rsa

> #second user(second@mail.com)  
#建一个github别名，新建的帐号使用这个别名做克隆和更新  
Host github2  
HostName github.com  
User git  
IdentityFile C:/Users/Administrator/.ssh/id_rsa_github  


#### 其实就是往这个config中添加一个Host：
其规则就是：从上至下读取config的内容，在每个Host下寻找对应的私钥。这里将GitHub SSH仓库地址中的git@github.com替换成新建的Host别名如：github2，那么原地址是：git@github.com:funpeng/Mywork.git，替换后应该是：github2:funpeng/Mywork.git.


#### 测试一下：

> $ ssh -T git@github.com  
Hi BeginMan! You've successfully authenticated, but GitHub does not provide shel
l access.

> $ ssh -T github2  
Hi funpeng! You've successfully authenticated, but GitHub does not provide shell
 access.
 
### 克隆
> $ git clone github2:funpeng/Mywork.git

 
### 其他的过程就和单账户建仓是一样的。

  
***

##### 参考链接：

+ https://www.awaimai.com/2200.html
+ https://jingyan.baidu.com/article/ab69b2708d09382ca7189f9b.html
+ http://www.cnblogs.com/BeginMan/p/3548139.html



***


## 还有一种多人合作的方式，更简单：
https://blog.csdn.net/catshitone/article/details/45969775

  



