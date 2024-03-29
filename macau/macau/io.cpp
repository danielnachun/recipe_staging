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
#include <string>
#include <iomanip>
#include <bitset>
#include <vector>
#include <map>
#include <set>
#include <cstring>
#include <cmath>
#include <stdio.h>
#include <stdlib.h>

#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"
#include "gsl/gsl_linalg.h"
#include "gsl/gsl_blas.h"
#include "gsl/gsl_cdf.h"

#include "gzstream.h"
#include "io.h"

using namespace std;



//Print process bar
void ProgressBar (string str, double p, double total)
{
  double progress = (100.0 * p / total);
  int barsize = (int) (progress / 2.0);
  char bar[51];

  cout<<str;
  for (int i = 0; i <50; i++) {
    if (i<barsize) {bar[i] = '=';}
    else {bar[i]=' ';}
    cout<<bar[i];
  }
  cout<<setprecision(2)<<fixed<<progress<<"%\r"<<flush;

  return;
}



// in case files are ended with "\r" or "\r\n"
std::istream& safeGetline(std::istream& is, std::string& t)
{
    t.clear();

    // The characters in the stream are read one-by-one using a std::streambuf.
    // That is faster than reading them one-by-one using the std::istream.
    // Code that uses streambuf this way must be guarded by a sentry object.
    // The sentry object performs various tasks,
    // such as thread synchronization and updating the stream state.

    std::istream::sentry se(is, true);
    std::streambuf* sb = is.rdbuf();

    for(;;) {
        int c = sb->sbumpc();
        switch (c) {
        case '\n':
            return is;
        case '\r':
            if(sb->sgetc() == '\n')
                sb->sbumpc();
            return is;
        case EOF:
            // Also handle the case when the last line has no line ending
            if(t.empty())
                is.setstate(std::ios::eofbit);
            return is;
        default:
            t += (char)c;
        }
    }
}




//read one column of phenotype
bool ReadFile_column (const string &file_pheno, vector<int> &indicator_idv, vector<double> &pheno, const int &p_column)
{
  indicator_idv.clear();
  pheno.clear();

  igzstream infile (file_pheno.c_str(), igzstream::in);
  //	ifstream infile (file_pheno.c_str(), ifstream::in);
  if (!infile) {cout<<"error! fail to open phenotype file: "<<file_pheno<<endl; return false;}

  string line;
  char *ch_ptr;

  string id;
  double p;
  while (!safeGetline(infile, line).eof()) {
    ch_ptr=strtok ((char *)line.c_str(), " , \t");
    for (int i=0; i<(p_column-1); ++i) {
      ch_ptr=strtok (NULL, " , \t");
    }
    if (strcmp(ch_ptr, "NA")==0) {indicator_idv.push_back(0); pheno.push_back(-9);}		//pheno is different from pimass2
    else {p=atof(ch_ptr); indicator_idv.push_back(1); pheno.push_back(p);}
  }

  infile.close();
  infile.clear();

  return true;
}




//read covariates
bool ReadFile_cvt (const string &file_cvt, vector<int> &indicator_cvt, vector<vector<double> > &cvt, size_t &n_cvt) {
  indicator_cvt.clear();

  ifstream infile (file_cvt.c_str(), ifstream::in);
  if (!infile) {cout<<"error! fail to open covariates file: "<<file_cvt<<endl; return false;}

  string line;
  char *ch_ptr;
  double d;

  int flag_na=0;

  while (!safeGetline(infile, line).eof()) {
    vector<double> v_d; flag_na=0;
    ch_ptr=strtok ((char *)line.c_str(), " , \t");
    while (ch_ptr!=NULL) {
      if (strcmp(ch_ptr, "NA")==0) {flag_na=1; d=-9;}
      else {d=atof(ch_ptr);}

      v_d.push_back(d);
      ch_ptr=strtok (NULL, " , \t");
    }
    if (flag_na==0) {indicator_cvt.push_back(1);} else {indicator_cvt.push_back(0);}
    cvt.push_back(v_d);
  }

  if (indicator_cvt.empty()) {n_cvt=0;}
  else {
    flag_na=0;
    for (vector<int>::size_type i=0; i<indicator_cvt.size(); ++i) {
      if (indicator_cvt[i]==0) {continue;}

      if (flag_na==0) {flag_na=1; n_cvt=cvt[i].size();}
      if (flag_na!=0 && n_cvt!=cvt[i].size()) {cout<<"error! number of covariates in row "<<i<<" do not match other rows."<<endl; return false;}
    }
  }

  infile.close();
  infile.clear();

  return true;
}// end func 



//read kinship matrix
void ReadFile_kin (const string &file_kin, vector<int> &indicator_idv, bool &error, gsl_matrix *G) {
  igzstream infile (file_kin.c_str(), igzstream::in);
  //	ifstream infile (file_kin.c_str(), ifstream::in);
  if (!infile) {cout<<"error! fail to open kinship file: "<<file_kin<<endl; error=true; return;}

  size_t ni_total=indicator_idv.size();

  gsl_matrix_set_zero (G);

  string line;
  char *ch_ptr;
  double d;

  //  if (k_mode==1) {
    size_t i_test=0, i_total=0, j_test=0, j_total=0;
    while (getline(infile, line)) {
      if (i_total==ni_total) {cout<<"error! number of rows in the kinship file is larger than the number of phentypes."<<endl; error=true;}

      if (indicator_idv[i_total]==0) {i_total++; continue;}

      j_total=0; j_test=0;
      ch_ptr=strtok ((char *)line.c_str(), " , \t");
      while (ch_ptr!=NULL) {
	if (j_total==ni_total) {cout<<"error! number of columns in the kinship file is larger than the number of phentypes for row = "<<i_total<<endl; error=true;}

	d=atof(ch_ptr);
	if (indicator_idv[j_total]==1) {gsl_matrix_set (G, i_test, j_test, d); j_test++;}
	j_total++;

	ch_ptr=strtok (NULL, " , \t");
      }
      if (j_total!=ni_total) {cout<<"error! number of columns in the kinship file do not match the number of phentypes for row = "<<i_total<<endl; error=true;}
      i_total++; i_test++;
    }
    if (i_total!=ni_total) {cout<<"error! number of rows in the kinship file do not match the number of phentypes."<<endl; error=true;}
    //  }

  infile.close();
  infile.clear();

  return;
}




bool CountFileLines (const string &file_input, size_t &n_lines, int a_mode) {
  igzstream infile (file_input.c_str(), igzstream::in);
  //ifstream infile (file_input.c_str(), ifstream::in);
  if (!infile) {cout<<"error! fail to open file: "<<file_input<<endl; return false;}

  if(a_mode==1){// for BMM
    string line;
    n_lines=0;
    while (!safeGetline(infile, line).eof()) { n_lines++; }
  }else if(a_mode==2 || a_mode==3){// for PMM
    n_lines=count(istreambuf_iterator<char>(infile), istreambuf_iterator<char>(), '\n');
    infile.seekg (0, ios::beg);
  }// end fi

  return true;
}// end func



//Read read count file; record read depth in depth, and the count matrix in G; header is skipped
bool ReadFile_gene (const string &file_gene, vector<int> &indicator_idv, vector<string> &gene_id, gsl_matrix *G) {
  size_t ni_total=indicator_idv.size();

  igzstream infile (file_gene.c_str(), igzstream::in);
  if (!infile) {cout<<"error! fail to open read count file: "<<file_gene<<endl; return false;}

  string line;
  char *ch_ptr;
  string rs;

  size_t t_col=0, c_col=0, c_row=0;

  //header
  getline(infile, line);

  while (getline(infile, line)) {
    ch_ptr=strtok ((char *)line.c_str(), " , \t");
    rs=ch_ptr;

    ch_ptr=strtok (NULL, " , \t");

    t_col=0; c_col=0;
    while (ch_ptr!=NULL) {
      if (indicator_idv[t_col]==1) {
	gsl_matrix_set (G, c_row, c_col, atof(ch_ptr));
	c_col++;
      }
      t_col++;
      ch_ptr=strtok (NULL, " , \t");
    }

    if (t_col!=ni_total) {cout<<"error! number of individuals in the count file does not match that in the other files, at row = "<<c_row+2<<endl; return false;}

    gene_id.push_back(rs);

    c_row++;
  }

  infile.close();
  infile.clear();

  return true;
}// end func











/*
//Read gene expression file
void ReadFile_gene ()
{
  ifstream infile (file_gene.c_str(), ifstream::in);
  if (!infile) {cout<<"error! fail to open gene expression file: "<<file_gene<<endl; error=true; return;}

  string line;
  char *ch_ptr;

  string id_i, id_g;
  size_t g;
  vector<size_t> vec_g;
  size_t n_idv=0, n_gene=0;

  vec_N.clear();

  while (getline(infile, line)) {
    ch_ptr=strtok ((char *)line.c_str(), " , \t");
    id_g=ch_ptr;

    vec_g.clear();
    ch_ptr=strtok (NULL, " , \t");
    while (ch_ptr!=NULL) {
      if (n_gene==0) {
	id_i=ch_ptr;
	if (mapID2num.count(id_i)==0) {mapID2num[id_i]=n_idv; n_idv++; indicator_idv.push_back(1);}
	else {cout<<"error! duplicated id: "<<id_i<<endl; error=true;}

	individual_id.push_back(id_i);
	vec_N.push_back(0.0);
			}
      else {
	g=atoi(ch_ptr);
	if (g<0) {cout<<"error! negative expression level in row: "<<n_gene<<endl; error=true;}
	vec_g.push_back(g);
      }

      ch_ptr=strtok (NULL, " , \t");
    }

    if (n_gene!=0) {
      if (vec_g.size()!=n_idv) {cout<<"error! number of columns doesn't match the number of individuals in row: "<<n_gene<<endl; error=true;}
      gene_id.push_back(id_g);
      //			genelevel.push_back(vec_g);
      for (size_t i=0; i<vec_N.size(); i++) {
	vec_N[i]=vec_N[i]+vec_g[i];
      }
    }
    n_gene++;
  }

  ng_total=n_gene-1; //-header

  infile.close();
  infile.clear();

  return;
}


//Read predictor variable file
void ReadFile_predictor ()
{
  ifstream infile (file_pred.c_str(), ifstream::in);
  if (!infile) {cout<<"error! fail to open predictor variable file: "<<file_pred<<endl; error=true; return;}

  string line;
  char *ch_ptr;

  double f;

  predictor.clear();

  while (getline(infile, line)) {
    ch_ptr=strtok ((char *)line.c_str(), " , \t");
    for (int i=0; i<(p_column-1); ++i) {
      ch_ptr=strtok (NULL, " , \t");
    }
    if (strcmp(ch_ptr, "NA")==0) {indicator_pred.push_back(0); predictor.push_back(-9);}		//pheno is different from pimass2
    else {f=atof(ch_ptr); indicator_pred.push_back(1); predictor.push_back(f);}
  }

  infile.close();
  infile.clear();

  return;
}


//Read total gene count file
void ReadFile_depth ()
{
	ifstream infile (file_N.c_str(), ifstream::in);
	if (!infile) {cout<<"error! fail to open total gene count file: "<<file_N<<endl; error=true; return;}

	string line;
	char *ch_ptr;

	int i;
	vec_N.clear();

	while (getline(infile, line)) {
		ch_ptr=strtok ((char *)line.c_str(), " , \t");

		if (strcmp(ch_ptr, "NA")==0) {
			indicator_N.push_back(0);
			vec_N.push_back(0);
		}
		else {
			i=atoi(ch_ptr);
			if (i<0) {cout<<"error! negative total gene count value: "<<i<<endl; error=true;}
			indicator_N.push_back(1);
			vec_N.push_back(i);
		}
	}

	infile.close();
	infile.clear();

	return;
}



//Read total gene count file 2; when the file is a n by ng_total matrix; no NA is allowed
void MODEL_DATA::ReadTotal2 ()
{
	ifstream infile (file_N.c_str(), ifstream::in);
	if (!infile) {cout<<"error! fail to open total gene count file: "<<file_N<<endl; error=true; return;}

	string line;
	char *ch_ptr;

	int i;
	vector<double> vec_temp;
	mat_N.clear();

	while (getline(infile, line)) {
		ch_ptr=strtok ((char *)line.c_str(), " , \t");

		vec_temp.clear();

		while (ch_ptr!=NULL) {
			i=atoi(ch_ptr);
			vec_temp.push_back(i);

			ch_ptr=strtok (NULL, " , \t");
		}
		if (vec_temp.size()!=ng_total) {cout<<"error! N file column number does not match the gene expression file: "<<vec_temp.size()<<" vs "<<ng_total<<endl; error=true;}
		mat_N.push_back(vec_temp);
		indicator_N.push_back(1);
	}

	infile.close();
	infile.clear();

	return;
}




void MODEL_DATA::ReadKin (gsl_matrix *K, const string &file_in, const int mode) {
	ifstream infile (file_in.c_str(), ifstream::in);
	if (!infile) {cout<<"error! fail to open kinship file: "<<file_in<<endl; error=true; return;}

	gsl_matrix_set_zero (K);

	string line;
	char *ch_ptr;
	double f;

	if (mode==1) {
		size_t i_test=0, i_total=0, j_test=0, j_total=0;
		while (getline(infile, line)) {
			if (i_total==ni_total) {cout<<"error! number of rows in the kinship file is larger than the number of phentypes."<<endl; error=true;}

			if (indicator_idv[i_total]==0) {i_total++; continue;}

			j_total=0; j_test=0;
			ch_ptr=strtok ((char *)line.c_str(), " , \t");
			while (ch_ptr!=NULL) {
				if (j_total==ni_total) {cout<<"error! number of columns in the kinship file is larger than the number of phentypes for row = "<<i_total<<endl; error=true;}

				f=atof(ch_ptr);
				if (indicator_idv[j_total]==1) {gsl_matrix_set (K, i_test, j_test, f); j_test++;}
				j_total++;

				ch_ptr=strtok (NULL, " , \t");
			}
			if (j_total!=ni_total) {cout<<"error! number of columns in the kinship file do not match the number of phentypes for row = "<<i_total<<endl; error=true;}
			i_total++; i_test++;
		}
		if (i_total!=ni_total) {cout<<"error! number of rows in the kinship file do not match the number of phentypes."<<endl; error=true;}
	}
	else if (mode==2) {
		string id1, id2;
		double Cov_d;

		while (getline(infile, line)) {
			ch_ptr=strtok ((char *)line.c_str(), " , \t");
			id1=ch_ptr;
			ch_ptr=strtok (NULL, " , \t");
			id2=ch_ptr;
			ch_ptr=strtok (NULL, " , \t");
			f=atof(ch_ptr);
			if (mapID2num.count(id1)==0 || mapID2num.count(id2)==0) {continue;}

			Cov_d=gsl_matrix_get(K, mapID2num[id1], mapID2num[id2]);
			if (Cov_d!=0 && Cov_d!=f) {cout<<"error! redundant and unequal terms in the kinship file, for id1 = "<<id1<<" and id2 = "<<id2<<endl;}
			else {
				gsl_matrix_set(K, mapID2num[id1], mapID2num[id2], f);
				gsl_matrix_set(K, mapID2num[id2], mapID2num[id1], f);
			}
		}
	}
	else {
		cout<<"error! mode is not 1 or 2 in ReadKin()."<<endl; error=true;
	}

	infile.close();
	infile.clear();

	return;
}

*/
































