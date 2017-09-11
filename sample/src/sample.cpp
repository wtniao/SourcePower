#include <stdio.h>
#include <stdlib.h>

int main(int argc,char *argv[])
{
	#ifdef WIN32
	printf("this is win32\n");
	#elif LINUX
	printf("THis is Linux\n");
	#elif MAC
	printf("This is MAC\n");
	#else
	printf("This is else\n");
	#endif
	
	return 0;
}
