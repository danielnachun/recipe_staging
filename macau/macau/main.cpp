/*
    Mixed model Association for Count data via data AUgmentation (MACAU)
    Copyright (C) 2015  Xiang Zhou

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <iostream>
#include <fstream>
#include <sstream>
#include <sys/stat.h>
#include <sys/types.h>

#include "param.h"
#include "macau.h"


using namespace std;


int main(int argc, char * argv[])
{ 	
  MACAU cMacau;	
  PARAM cPar;
  
  if (argc <= 1) {
    cMacau.PrintHeader(); 
    return EXIT_SUCCESS;
  }
  if (argc==2 && argv[1][0] == '-' && argv[1][1] == 'h') {
    cMacau.PrintHelp(0);
    return EXIT_SUCCESS;
  }
  if (argc==3 && argv[1][0] == '-' && argv[1][1] == 'h') {
    string str;
    str.assign(argv[2]);
    cMacau.PrintHelp(atoi(str.c_str()));
    return EXIT_SUCCESS;
  }
  if (argc==2 && argv[1][0] == '-' && argv[1][1] == 'l') {
    cMacau.PrintLicense();
    return EXIT_SUCCESS;
  }	
	
  cMacau.Assign(argc, argv, cPar); 
  
  ifstream check_dir((cPar.path_out).c_str());
  if (!check_dir) {
    mkdir((cPar.path_out).c_str(), S_IRWXU|S_IRGRP|S_IROTH);
  }	
		
  if (cPar.error==true) {return EXIT_FAILURE;}
  
  if (cPar.mode_silence) {stringstream ss; cout.rdbuf (ss.rdbuf());}
  
  cPar.CheckParam();
  
  if (cPar.error==true) {return EXIT_FAILURE;}
  
  cMacau.BatchRun(cPar);
  
  if (cPar.error==true) {return EXIT_FAILURE;}
  
  cMacau.WriteLog(argc, argv, cPar);
  
  cMacau.WriteAssoc(cPar);
	
  return EXIT_SUCCESS;                                                          
}



/*
int main(int argc, char * argv[])
{ 	
	PARAM cPar;	

	if (argc <= 1) {
		cPar.PrintHeader(); 
		return 1;
	}
	if (argc==2 && argv[1][0] == '-' && argv[1][1] == 'h') {
		cPar.PrintHelp();
		return 1;
	}
	if (argc==2 && argv[1][0] == '-' && argv[1][1] == 'l') {
		cPar.PrintLicense();
		return 1;
	}
	
	ifstream check_dir("output/");
	if (!check_dir) {
		mkdir("output", S_IRWXU);
	}
	
	
	MODEL_DATA cMD;	
	
	cPar.Assign(argc, argv, cMD); 			
	
	if (cMD.error==true) {return 1;}
	if (cPar.CheckError(cMD)==true) {return 1;}
	
	cPar.BatchRun(cMD);
		
    return EXIT_SUCCESS;                                                          
}
*/

 
