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

#ifndef __MACAU_H__                
#define __MACAU_H__

#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"
#include <gsl/gsl_rng.h>
#include <vector>
#include <map>

using namespace std;


class MACAU {

public:			
	//parameters
	string version;
	string date;
	
	//constructor
	MACAU(void);
	
	//functions
	void PrintHeader (void);
	void PrintHelp (size_t option);
	void PrintLicense (void);
	void Assign (int argc, char **argv, PARAM &cPar);
	void BatchRun (PARAM &cPar);
	void WriteLog (int argc, char **argv, PARAM &cPar);
	void WriteAssoc (PARAM &cPar);
};



#endif


