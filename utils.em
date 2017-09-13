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

//Return the key of a key-value string.For example, return "version" from "-Dversion=2.6"
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

//Return the value of a key-value string.For example, return "2.6" from "-Dversion=2.6"
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

//Check file existence
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

//Return the line NO of the perticular string in the given file
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
{//return the position of '\' in str reversely
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
	//Check the version of source insight,because version under 3.5065 is lack of some interface
	ProVer = GetProgramInfo ();
	if(ProVer.versionMinor < 50 || ProVer.versionBuild < 60)
	{
		Msg("您的Source Insight版本太低，如需使用此工具，请安装3.50.0060及以上版。");
		stop
	}

	//Get the directory of source code
	hProj = GetCurrentProj ();
	dir_proj = GetCodeDir(hProj);

	//Finding makefiles,append them  to makelist.txt
	cmdline = cat("cmd /C \"dir ", "makefile /S /B > makeList.txt\"");
	RunCmdLine(cmdline, dir_proj, 1);

	ListFile = cat (dir_proj,"\\makeList.txt");

	//With respect to every entries in makeList.txt，proccess every makefile by inserting extra codes
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
		initGlobal(dir_proj, makefile);//TODO
		//set up makefile					
		writeMakeFile(makefile)
		ln = ln + 1;
	}
	CloseBuf (hbuf)	
	
	Msg("请在您的编译路径里键入编译命令，并加上check参数。如:make OEM_VENDOR=HoneyWell check");

	//set up project

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
		//restore makefile		
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
	//version check
	ProVer = GetProgramInfo ();
	if(ProVer.versionMinor < 50 || ProVer.versionBuild < 60)
	{
		Msg("您的Source Insight版本太低，如需使用此工具，请安装3.50.0060及以上版。");
		stop
	}

	hProj = GetCurrentProj ();
	dir_proj = GetCodeDir(hProj);
	
	//Restore the project
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
	
	//Clear temperary files
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
		}
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

//Prepare contents to be written to makefile
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

	if(pos >= len)
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
	PutEnv("cmd_count", "5");

	putEnv("cmd_str0","check:");	
	putEnv("cmd_str1","\t-\@echo 'Collecting condition variables......';find @dir_relative@ -name *.c* -exec grep -E '^\\s*#if|^\\s*#elif' {} \\; > @dir_relative@tmp ;");	
	putEnv("cmd_str2","\t-\@cat @dir_relative@tmp| grep -E '^\\s*#[^\\/]+' -o | sed -r 's/\\|\\||&&/\\n/g' | sed -r 's/#[a-z]+|defined|\\(|\\)|\s+|!|[0-9]*\\s*(>|<|=|<=|>=|==)\\s*[0-9]*|\\s*|\"//g' > @dir_relative@tmp1;");
	putEnv("cmd_str3","\t-\@cat @dir_relative@tmp1| sed -r '/^(0|1)?$$/d' | sort -u | sed -r 's/(.*)/-U\\1/g' > @dir_relative@defined.all");	
	putEnv("cmd_str4","\t-\@echo $(CFLAGS)|sed -r 's/(-[a-zA-Z])/\\n\\1/g' | grep -E '(-D|-U).*' -o | sed -r 's/=.*|\\s+//g' > @dir_relative@defined;rm @dir_relative@tmp*;");
} 

//Restore makefile
macro restoreMakeFile(depend_file)
{
	str = GetEnv("cmd_str0");
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

//Setup makefile
macro writeMakeFile(depend_file)
{
	str = GetEnv("cmd_str0");
	ln = lineOfFile(depend_file,str);

	cmdLnCnt = GetEnv("cmd_count");
	if(0 == ln)//Find none
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

//Set up Project
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

//Restore project
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
