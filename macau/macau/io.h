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

#ifndef __IO_H__
#define __IO_H__


#include <vector>
#include <map>
#include <algorithm>
#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"

#include "gzstream.h"
#include "param.h"


using namespace std;

void ProgressBar (string str, double p, double total);
bool ReadFile_column (const string &file_pheno, vector<int> &indicator_idv, vector<double> &pheno, const int &p_column);
bool ReadFile_cvt (const string &file_cvt, vector<int> &indicator_cvt, vector<vector<double> > &cvt, size_t &n_cvt);
void ReadFile_kin (const string &file_kin, vector<int> &indicator_idv, bool &error, gsl_matrix *G);
bool CountFileLines (const string &file_input, size_t &n_lines, int a_mode);
bool ReadFile_gene (const string &file_gene, vector<int> &indicator_idv, vector<string> &gene_id, gsl_matrix *G);


#endif







