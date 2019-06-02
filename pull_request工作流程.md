---
presentation:
  width: 800
  height: 600
---
<!-- slide -->

# Github 上的 Pull request

<!-- slide -->
- 将Github中的工作流程类比成我们中学考试、老师改卷的场景([beepony,2016](https://www.zhihu.com/question/21682976/answer/79489643))

![](https://imgsa.baidu.com/exp/w=480/sign=e511e37fe0cd7b89e96c3b8b3f254291/b151f8198618367aeba29c6828738bd4b31ce558.jpg)

<!-- slide -->
|考试流程|Github流程|
|:--|--:|
|试卷|仓库|
|错题|bug|
|收卷|fork|
|老师批阅试卷|git commit|
|发试卷|pull request|
|修改错题|merge|

<!-- slide data-background-image="http://i2.tiimg.com/611786/4ff2c860b820080b.png" -->

<font color=red size=144>

1. 从其他仓库中fork

</font>

<!-- slide data-background-image="http://i2.tiimg.com/611786/e4bd89c40696c68a.png" -->
<font color=#00dd00 size=144>

fork成功

</font>

<!-- slide -->
2. 在本地使用git clone获取自己账户下所fork的文件夹

![Markdown](http://i1.fuimg.com/611786/a983c3d3cf98a816.png)

<!-- slide -->
3. 照常完成add-commit-push的流程

![Markdown](http://i2.tiimg.com/611786/98f8d41f4119d787.png)

<!-- slide data-background-image="http://i1.fuimg.com/611786/e078889e8ac8d782.png" -->
4. 点进去create pull request就完事了

<!-- slide -->
  
5. 登陆原作者账号就可以确认这个pull request

- ps. 因为我是合作账号，所以直接就有权限更新这个进程，不需要登陆lab319-jufe确认

@import "http://i2.tiimg.com/611786/4df52b24f04dffe2.png"

<!-- slide data-background-image="http://i2.tiimg.com/611786/c56de48074d9b8a7.png" -->

<!-- slide -->
6. fork的库要跟上原始库的进度

- 添加原作者项目的 remote 地址， 然后将代码 fetch 过来 

```bash
git remote add sri https://github.com/lab319-jufe/we
git fetch sri #用于从另一个存储库下载对象和引用
git remote -v #查看本地项目目录
```

- 合并

```bash
git checkout master
git merge sri/master
#git reset –hard sri/master #如果有冲突，放弃本地修改
```

<!-- slide -->

- 此时已经更新到最新进程了，提交

```bash
git push origin
git push sri
```

![push到不同远程库](http://i2.tiimg.com/611786/dcf6bbde0d9a998a.png)