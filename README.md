# SourcePower(supported minimum-version 3.5065)
Source Insight scripts helping you dealing with coding and reading code.

![Bad](https://github.com/wtniao/SourcePower/blob/master/sample/bad.png?raw=true)

This is source Insight script.It is suitable for most c& c++ codes in which there are too much token like #ifdef、#elif and #if that programmer could hardly understand what the codes mean, or which branch it would go through.

This script  turn the inactive code to gray looking like commets by analyzing macro definition in variable cflags in your makefiles.

And what's more,it offers quick operation for svn differ,svn log, opening the explorer and locating the current file.

Any problem found ,contact me 
# Communication
wtniao@163.com ZhiHu:ibirds

# Installation
This is a source insight script tool,so we got to set it up in source insight.

1.Open source insight and open the source insight Base project.

2.download the scripts in this repo,and paste them to utils.em file in base project.

3.Save & close project

4.Open menu Options =》 Menu assignments

5.Type "setEnvironment" in Left “Command” Colume,Select "Project" in Right "Command" Colume,Select "End of menu" in right bottom "Menu contents" colume. And do the same with Macro "clearEnvironment" .And  OK.

# Usage
1.Pull the sample project & open it,you'll see four statements the you don't which will be excuted.

![Bad](https://github.com/wtniao/SourcePower/blob/master/sample/bad.png?raw=true)

2.Click Project=>SetEnvironment ,you'll see what to do.

3.open you terminal & locate to the build directory of this sample project.

4.Type make check in your terminal.

5.Turn back to source insight ,and click the Sure button to go on.

6.Then you'll see like This

![Bad](https://github.com/wtniao/SourcePower/blob/master/sample/nice.png?raw=true)
