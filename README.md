# SourcePower(supported minimum-version 3.5065)
Source Insight scripts helping you understanding messy codes.

![Before](https://github.com/wtniao/SourcePower/blob/master/sample/bad.png?raw=true)
![After](https://github.com/wtniao/SourcePower/blob/master/sample/nice.png?raw=true)

This is a source Insight script.It is suitable for most c/c++ codes in which there are too much token like #ifdef、#elif and #if that programmer could hardly understand what the codes mean, or which branch it would go through.

This script  turn the inactive code to gray looking like comments by analyzing macro definition in variable cflags in your makefiles.

And what's more,it offers quick operation for svn differ,svn log, opening the explorer and locating the current file.

Any problem found ,contact me 
# Communication
wtniao@163.com 
ZhiHu:[ibirds](https://www.zhihu.com/people/niao-niao-79/activities "ibirds")


# Installation
This is a source insight script tool,so we got to set up in source insight.

1.Open source insight and open the Base project.

2.download the scripts ,and paste them to utils.em file in your opening base project.

3.Save & close project

4.Open menu Options =》 Menu assignments

5.Type "setEnvironment" in Left “Command” Colume,Select "Project" in Right "Command" Colume,Select "End of menu" in right bottom "Menu contents" colume. And do the same to Macro "clearEnvironment" .And  Press OK.

# Usage
1.Pull the sample project & open it,you'll see four statements that you don't know which will be excuted.

![Bad](https://github.com/wtniao/SourcePower/blob/master/sample/bad.png?raw=true)

2.Click Project=>SetEnvironment ,then instruments will show.And don't press any key.

3.Open you terminal & locate to the build directory of the sample project.

4.Type "make check" in your terminal.

5.Turn back to source insight ,and click the Sure button to go on.

6.Then you'll see like This

![Good](https://github.com/wtniao/SourcePower/blob/master/sample/nice.png?raw=true)
