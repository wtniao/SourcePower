/* Utils.em - a small collection of useful editing macros */
/*-------------------------------------------------------------------------
	checkEnv	Header-------writen 		by 		iBirds	
	E-Mail:wtniao@163.com,  zhihu:ibirds
	
	This macro functions is suitable for most c&c++ code of embeded devices software , in which there is too much
	token like #ifdef 、#elif and #if that programmer could hardly understand what they mean.
	
	This macro helps programmer understand code by turn useless code in to 
	inactive code which looks gray and easy to be ignored.

	Any problem found or in use ,contact my email wtniao@163.com 
-------------------------------------------------------------------------*/ 
macro Min(a,b)
{
	if(a > b)
	{
		return b;
	}
	
	return a;
}

macro Max(a,b)
{
	if(a > b)
	{
		return a;
	}
	
	return b;
}

//取行的名称,例如取"-Dversion=2.6"中的"version"
macro nameOf(str)
{
	pos=0;
	while(pos<strlen (str))
	{
		if(strmid (str,pos, pos+1) == "=")
			break;
		pos = pos + 1;
	}
	if(strlen(str) <= 2)
	{
		return strmid (str,0,pos);
	}
	else if(strmid (str,0,2) == "-D" || strmid (str,0,2) == "-U" )
	{
		return strmid (str,2,pos);
	}
	else
	{
		return strmid (str,0,pos);
	}
}

//取等式的值,例如取"-Dversion=2.6"中的"2.6"
macro valueOf(str)
{
	pos=0;
	while(pos<strlen (str))
	{
		if(strmid (str,pos, pos+1) == "=")
			break;
		pos = pos + 1;
	}

	if(strlen(str) <= 2)
	{
		return 0;
	}
	else if(strmid (str,0,2) == "-D" && strlen(str) == pos)
	{
		return 1;
	}
	else if(strmid (str,0,2) == "-D" && strlen(str) != pos)
	{
		return strmid (str,pos+1,strlen (str));
	}
	else
	{
		return 0;
	}
}

//判断文件是否存在,0代表不存在,1代表存在
macro ifExist(file)
{
	hbuf = OpenBuf(file);
	if(0 == hbuf )
	{
		return 0;
	}
	else
	{
		CloseBuf(hbuf);
		return 1;
	}
}

//返回特定内容在文件中的行序号
macro lineOfFile(file, str)
{
	if(0 == ifExist(file))
	{
		return 0;
	}
	else
	{
		hbuf = OpenBuf (file);
		ln_cnt = GetBufLineCount(hbuf);
		ln = 0;	
		while(ln<ln_cnt)
		{
			if(str == GetBufLine (hbuf, ln))
			{
				CloseBuf(hbuf);
				return ln;
			}	
			ln = ln + 1;
		}
		CloseBuf (hbuf);		
		return 0;

	}
}
macro GetPath(str)
{//倒序查找"\"
	pos = strlen(str) - 1;
	while(pos >= 0)
	{	
		if(strmid (str,pos, pos+1) == "\\")
			return pos;
		pos = pos - 1;
	}
}
macro explorer()
{
	filename = GetBufName (GetCurrentBuf ())
	path = strmid(filename,0,GetPath(filename));
	cmdline = cat(cat("explorer /select,\"",filename),"\"");
	RunCmdLine (cmdline, path, 0);
}

macro diff()
{

	filename = GetBufName (GetCurrentBuf ())
	path = strmid(filename,0,GetPath(filename));
	cmdline = cat(cat("cmd /C \"TortoiseProc.exe /command:diff /path:\"",filename),"\"\"")
	RunCmdLine (cmdline, path, 0);
}

macro log()
{

	filename = GetBufName (GetCurrentBuf ())
	path = strmid(filename,0,GetPath(filename));
	cmdline = cat(cat("cmd /C \"TortoiseProc.exe /command:log /path:\"",filename),"\"\"")
	RunCmdLine (cmdline, path, 0);
}

macro setEnvironment()
{
	//版本判断,3.5065以下程序不支持
	ProVer = GetProgramInfo ();
	if(ProVer.versionMinor < 50 || ProVer.versionBuild < 60)
	{
		Msg("您的Source Insight版本太低，如需使用此工具，请安装3.50.0060及以上版。");
		stop
	}

	//获得代码所在目录，不论工程建在哪里
	hProj = GetCurrentProj ();
	dir_proj = GetCodeDir(hProj);

	//查找makefile,生产makelist.txt文件
	cmdline = cat("cmd /C \"dir ", "makefile /S /B > makeList.txt\"");
	RunCmdLine(cmdline, dir_proj, 1);

	ListFile = cat (dir_proj,"\\makeList.txt");

	//根据makeList.txt的信息，为每一个makefile都添加命令
	hbuf = OpenBuf (ListFile)
	count = 	GetBufLineCount (hbuf)
	if(count == 0 || count == 1 && strlen(GetBufLine(hbuf, 0)) == 0)
	{
		CloseBuf (hbuf);
		pos = strlen(dir_proj) - 1;
		while(pos >= 0)
		{
			if(strmid(dir_proj, pos, pos + 1) == "\\")
			{
				break;			
			}
			pos = pos - 1;
		}
		dir_proj = strmid(dir_proj, 0, pos);
		RunCmdLine(cmdline, dir_proj, 1);
		ListFile = cat (dir_proj,"\\makeList.txt");

		hbuf = OpenBuf (ListFile)
		count = GetBufLineCount (hbuf)

		if(count == 0 || count == 1 && strlen(GetBufLine(hbuf, 0)) == 0)
		{
			CloseBuf (hbuf);
			cmdline = "notepad @ListFile@";
			RunCmdLine(cmdline, dir_proj, 0);
			Msg("请在@ListFile@内添加makefile路径,如有多个makefile,则每个路径一行,完成后点确定。如第一行为c:\\code\\makefile");
			hbuf = OpenBuf (ListFile);
			count = GetBufLineCount (hbuf);
			if(count <= 0 )
			{
				CloseBuf (hbuf);
				Msg("未在makeList.txt中指明makefile路径,将退出!");
				stop;
			}				
		}
	}

	ln = 0;
	while(ln < count)
	{
		makefile = GetBufLine (hbuf, ln);
		initGlobal(dir_proj, makefile);//需要修改，生产相对路径的,在dir_proj下直接产生defined.*文件。
		//向makefile文件写入命令					
		writeMakeFile(makefile)
		ln = ln + 1;
	}
	CloseBuf (hbuf)	
	
	Msg("请在您的编译路径里键入编译命令，并加上check参数。如:make OEM_VENDOR=HoneyWell check");

	//向工程添加环境变量

	con_file = cat(dir_proj, "\\defined.all");
	setCondition(hProj, con_file);

	con_file = cat(dir_proj, "\\defined");
	setCondition(hProj, con_file);

	hbuf = OpenBuf (ListFile)
	count = 	GetBufLineCount (hbuf)
	ln = 0;
	while(ln < count)
	{
		makefile = GetBufLine (hbuf, ln);		
		//从makefile里清除命令			
		restoreMakeFile(makefile)
		ln = ln + 1;
	}
	CloseBuf (hbuf)	

	con_file = cat(dir_proj, "\\defined");
	if(0 != ifExist(con_file))
	{
		SyncProjEx (hProj, 0, 1, 0);
					
		Msg("环境变量已经设定。");			
	}
	else
	{
		Msg("未检测到临时文件defined和defined.all是否编译路径有误?");
	}	
}

macro clearEnvironment()
{
	//版本判断,3.5065以下程序不支持
	ProVer = GetProgramInfo ();
	if(ProVer.versionMinor < 50 || ProVer.versionBuild < 60)
	{
		Msg("您的Source Insight版本太低，如需使用此工具，请安装3.50.0060及以上版。");
		stop
	}

	hProj = GetCurrentProj ();
	dir_proj = GetCodeDir(hProj);
	
	//根据宏名列表文件,清除已经存在的环境变量
	con_file = cat(dir_proj, "\\defined.all");
	if(0 == ifExist(con_file))
	{
		pos = strlen(dir_proj) - 1;
		while(pos >= 0)
		{
			if(strmid(dir_proj, pos, pos + 1) == "\\")
			{
				break;			
			}
			pos = pos - 1;
		}
		if(pos < 2)
		{
			stop;
		}
		dir_proj = strmid(dir_proj, 0, pos);
		con_file = cat(dir_proj, "\\defined.all");
	}
	
	clearCondition(hProj,con_file);

	con_file = cat(dir_proj, "\\defined");
	clearCondition(hProj,con_file);

	SyncProjEx (hProj, 0, 1, 0);
	
	//清理中间文件,避免对下次产生干扰，用于清理环境变量			
	com_str = cat("cmd /C \"del ",cat(dir_proj, "\\defined.all\""));
	RunCmdLine (com_str, dir_proj, 1);		
	
	com_str = cat("cmd /C \"del ",cat(dir_proj, "\\defined\""));
	RunCmdLine (com_str, dir_proj, 1);

	Msg("已完成清理已有的宏!");	
}

macro GetCodeDir(hProj)
{
	filename = GetProjFileName (hProj, 0);
	hbuf = OpenBuf (filename);
	fullname = GetBufName (hbuf);
	CloseBuf (hbuf);
	if(strlen(fullname) > strlen(filename))
	{
		return strmid (fullname, 0, strlen(fullname) - strlen(filename) - 1);
	}
	else
	{
		//搜索全部,提取公共的前缀，不包含最后的'\'
		iCount = GetProjFileCount (hProj);
		iFile = 1;
		while(iFile < iCount)
		{
			fullname = GetProjFileName (hProj, iFile);
			pos = 0;
			len = Min(strlen(filename), strlen(fullname));
			while(pos < len)
			{
				if(strmid (filename, pos, pos + 1) != strmid (fullname, pos, pos + 1))
				{
					filename = strmid(filename, 0, pos);
					break;
				}
				pos = pos + 1;
			}
			iFile = iFile + 1;
		}//需要再回溯一下,但需要和原路径比较一下后面的字符是否为\,不能出现D:\\linux\bu这样的情况
		if(strmid(filename, strlen(filename) - 1, strlen(filename)) == "\\")
		{
			filename = strmid(filename, 0, strlen(filename) - 1);
		}
		else
		{
			pos = strlen(filename) - 1;
			while(pos >= 0)
			{
				if(strmid(filename, pos , pos + 1) == "\\")
				{
					filename = strmid(filename, pos - 1, pos);
					break;
				}
				pos = pos - 1;
			}
		}
		return filename;
	}
}


//把要写进depend文件的命令写入系统的环境变量里，
//当做全局变量使用,便于以后更改程序
macro initGlobal(code_dir, makefile)
{
	dir_relative = "";
	pos = 0;
	len = Min(strlen(code_dir), strlen(makefile));
	while(pos < len)
	{
		if(strmid (code_dir, pos, pos + 1) != strmid (makefile, pos, pos + 1))
		{
			break;
		}
		pos = pos + 1;
	}

	if(pos >= len)//makefile在code_dir的子目录
	{
		pos = pos + 1;
		len = strlen(makefile);
		while(pos < len)
		{
			if(strmid (makefile, pos, pos + 1) == "\\")
			{
				dir_relative = cat("../", dir_relative);
			}
			pos = pos + 1;
		}
	}
	else
	{
		while(pos > 0)
		{
			if(strmid (code_dir, pos, pos + 1) == "\\")
			{
				pos = pos + 1;
				break;
			}
			pos = pos - 1;
		}
		dir_after = cat(strmid(code_dir, pos, strlen(code_dir)),"/");
		len = strlen(makefile);
		while(pos < len)
		{
			if(strmid (makefile, pos, pos + 1) == "\\")
			{
				dir_relative = cat("../", dir_relative);
			}
			pos = pos + 1;
		}
		dir_relative = cat(dir_relative, dir_after);
	}
	PutEnv("cmd_count", "5");//需要插入的命令行数

	putEnv("cmd_str0","check:");	
	putEnv("cmd_str1","\t-\@echo 'Collecting condition variables......';find @dir_relative@ -name *.c* -exec grep -E '^\\s*#if|^\\s*#elif' {} \\; > @dir_relative@tmp ;");	
	putEnv("cmd_str2","\t-\@cat @dir_relative@tmp| grep -E '^\\s*#[^\\/]+' -o | sed -r 's/\\|\\||&&/\\n/g' | sed -r 's/#[a-z]+|defined|\\(|\\)|\s+|!|[0-9]*\\s*(>|<|=|<=|>=|==)\\s*[0-9]*|\\s*|\"//g' > @dir_relative@tmp1;");
	putEnv("cmd_str3","\t-\@cat @dir_relative@tmp1| sed -r '/^(0|1)?$$/d' | sort -u | sed -r 's/(.*)/-U\\1/g' > @dir_relative@defined.all");	
	putEnv("cmd_str4","\t-\@echo $(CFLAGS)|sed -r 's/(-[a-zA-Z])/\\n\\1/g' | grep -E '(-D|-U).*' -o | sed -r 's/=.*|\\s+//g' > @dir_relative@defined;rm @dir_relative@tmp*;");
} 

//从文件中删除行,包括ln所在行以及之后的count行,返回删除掉的行数
macro restoreMakeFile(depend_file)
{
	str = GetEnv("cmd_str0");//标志内容
	ln = lineOfFile(depend_file,str);
	count = GetEnv("cmd_count");// 4; 
	
	if(0 == ifExist(depend_file) || ln == 0)
	{
		return 0;
	}
	else
	{
		hbuf = OpenBuf(depend_file);
		ln  = GetBufLineCount (hbuf) ;	
		
		i = ln;
		while(i > ln - count)
		{
			DelBufLine (hbuf, i - 1);
			i = i - 1;
		}
		SaveBuf (hbuf);	

		CloseBuf(hbuf);
		return count;
	}
}

//向depend文件写入linux命令(用于提取宏以及处理),返回插入命令的行数
macro writeMakeFile(depend_file)
{
	str = GetEnv("cmd_str0");//标志内容
	ln = lineOfFile(depend_file,str);

	cmdLnCnt = GetEnv("cmd_count");// 4;
	if(0 == ln)//文件中无命令
	{								
		if(0 == depend_file )
		{
			return 0;
		}
		else if(0 == ifExist(depend_file))
		{
			return 0;
		}
		else
		{			
			hbuf = OpenBuf (depend_file);			
			ln  = GetBufLineCount (hbuf) ;		
			
			i = cmdLnCnt - 1;
			while(i >= 0)
			{
				InsBufLine (hbuf, ln, GetEnv(cat("cmd_str",i)));
				i = i - 1;
			}
			
			SaveBuf (hbuf);	
			CloseBuf (hbuf);

			return cmdLnCnt;
		}
	}
	else
	{
		return cmdLnCnt;
	}
}

//根据file的内容，向hProj添加环境变量
macro setCondition(hProj, con_file)
{	
	ln = 0;
	
	if(ifExist(con_file))
	{
		hbuf = OpenBuf(con_file);
		
		ln_cnt = GetBufLineCount(hbuf);
		while(ln<ln_cnt)
		{
			str = GetBufLine(hbuf, ln);

			if(str != " ")
			{ 
				DeleteConditionVariable(hProj, nameOf(str));
				AddConditionVariable(hProj, nameOf(str), valueOf(str));
			}	
			ln = ln + 1;
		}

		CloseBuf (hbuf);
	}

	return ln;
}

//清除工程内，file文件指定的环境变量,返回删除掉的变量数
macro clearCondition(hProj,file)
{
	if(0 == ifExist(file))
	{
		return 0;
	}
	else
	{
		hbuf = OpenBuf(file);
		ln_cnt = GetBufLineCount (hbuf);
		ln = 0;
		while(ln<ln_cnt)
		{
			str = GetBufLine(hbuf, ln);
			DeleteConditionVariable(hProj ,nameOf(str));
			ln = ln + 1;
		}
		
		CloseBuf (hbuf);

		return ln;
	}
}
