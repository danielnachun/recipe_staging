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

#include <iomanip>
#include <cmath>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <bitset>
#include <cstring>

#include <algorithm>
#include <vector>

#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"
#include "gsl/gsl_linalg.h"
#include "gsl/gsl_blas.h"
#include "gsl/gsl_sf.h"
#include "gsl/gsl_randist.h"
#include "gsl/gsl_cdf.h"
#include "gsl/gsl_roots.h"
#include "gsl/gsl_min.h"
#include "gsl/gsl_integration.h"

#include "param.h"
#include "macau.h"
#include "bmm.h"
#include "pmm.h"
#include "nb.h"


using namespace std;

MACAU::MACAU(void) : version("1.40alpha"), date("08/08/2019")
{
}

void MACAU::PrintHeader(void)
{
  cout << endl;
  cout << "****************************************************************" << endl;
  cout << "  Mixed model Association for Count data via data Augmentation  " << endl;
  cout << "  MACAU Version " << version << ", " << date << "                              " << endl;
  cout << "  Visit http://www.xzlab.org/software.html For Updates          " << endl;
  cout << "  (C) 2015 Xiang Zhou                                     " << endl;
  cout << "  GNU General Public License                                    " << endl;
  cout << "  For Help, Type ./macau -h                                     " << endl;
  cout << "****************************************************************" << endl;
  cout << endl;

  return;
}

void MACAU::PrintLicense(void)
{
  cout << endl;
  cout << "The Software Is Distributed Under GNU General Public License, But May Also Require The Following Notifications." << endl;
  cout << endl;

  cout << "Including Lapack Routines In The Software May Require The Following Notification:" << endl;
  cout << "Copyright (c) 1992-2010 The University of Tennessee and The University of Tennessee Research Foundation.  All rights reserved." << endl;
  cout << "Copyright (c) 2000-2010 The University of California Berkeley. All rights reserved." << endl;
  cout << "Copyright (c) 2006-2010 The University of Colorado Denver.  All rights reserved." << endl;
  cout << endl;

  cout << "$COPYRIGHT$" << endl;
  cout << "Additional copyrights may follow" << endl;
  cout << "$HEADER$" << endl;
  cout << "Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:" << endl;
  cout << "- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer." << endl;
  cout << "- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer listed in this license in the documentation and/or other materials provided with the distribution." << endl;
  cout << "- Neither the name of the copyright holders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission." << endl;
  cout << "The copyright holders provide no reassurances that the source code provided does not infringe any patent, copyright, or any other "
       << "intellectual property rights of third parties.  The copyright holders disclaim any liability to any recipient for claims brought against "
       << "recipient by any third party for infringement of that parties intellectual property rights. " << endl;
  cout << "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT "
       << "LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT "
       << "OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT "
       << "LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY "
       << "THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE "
       << "OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE." << endl;
  cout << endl;

  return;
}

void MACAU::PrintHelp(size_t option)
{
  if (option == 0)
  {
    cout << endl;
    cout << " MACAU version " << version << ", released on " << date << endl;
    cout << " implemented by Xiang Zhou" << endl;
    cout << endl;
    cout << " type ./macau -h [num] for detailed helps" << endl;
    cout << " options: " << endl;
    cout << " 1: quick guide" << endl;
    cout << " 2: file I/O related" << endl;
    cout << " 3: fit binomial/Poisson mixed models" << endl;
    cout << " 4: note" << endl;
    cout << endl;
  }

  if (option == 1)
  {
    cout << " QUICK GUIDE" << endl;
    //	cout<<" To quantile normalize the data: "<<endl;
    //	cout<<"         ./macau -g [filename] -qn -o [prefix]"<<endl;
    //	cout<<" To generate residuals: "<<endl;
    //	cout<<"         ./macau -g [filename] -gr -o [prefix]"<<endl;
    //	cout<<" To generate covariance matrix: "<<endl;
    //	cout<<"         ./macau -g [filename] -gv -o [prefix]"<<endl;

    cout << " To fit binomial/Poisson mixed models: " << endl;
    cout << "         ./macau -g [filename] -t [filename] -p [filename] -k [filename] -bmm/pmm/nb -o [prefix]" << endl;
    cout << endl;
  }

  if (option == 2)
  {
    cout << " FILE I/O RELATED OPTIONS" << endl;
    cout << " -g        [filename]     "
         << " specify input read count file name" << endl;
    cout << "          format: site id, individual ID#1, individual ID#2, individual ID#3, ..." << endl;
    cout << "                  siteID#1, expression for individual 1, expression for individual 2, expression for individual 3, ..." << endl;
    cout << "                  siteID#2, expression for individual 1, expression for individual 2, expression for individual 3,  ..." << endl;
    cout << "                  ..." << endl;
    cout << "          missing expression value: NA" << endl;
    cout << " -t        [filename]     "
         << " specify input total read count file (optional); in the same format as above, or contain only one data row" << endl;
    cout << " -p        [filename]     "
         << " specify input: predictor variable file name" << endl;
    cout << "          format: variable for individual 1" << endl;
    cout << "                  variable for individual 2" << endl;
    cout << "                  ..." << endl;
    cout << "          missing predictor variable value: NA" << endl;
    cout << " -n        [filename]     "
         << " specify column number for predictor variable file (optional)" << endl;
    cout << " -k        [filename]     "
         << " specify input kinship/relatedness matrix file name" << endl;
    cout << " -v        [filename]     "
         << " specify input biological variation matrix file name (optional)" << endl;
    cout << " -c        [filename]     "
         << " specify input: covariates file name (optional)" << endl;
    cout << "          format: covariate 1 for individual 1, ... , covariate c for individual 1" << endl;
    cout << "                  covariate 1 for individual 2, ... , covariate c for individual 2" << endl;
    cout << "                  ..." << endl;
    cout << "          missing covariate value: NA" << endl;
    cout << "          note: the intercept needs to be included" << endl;
    cout << " -pace     [num]          "
         << " specify terminal display update pace (default 1000 genes)." << endl;
    cout << " -silence                 "
         << " specify silence terminal output." << endl;
    cout << " -o        [prefix]       "
         << " specify output file prefix (default \"result\")" << endl;
    cout << "          output: prefix.assoc.txt and prefix.log.txt for analysis" << endl;
    cout << endl;
  }

  if (option == 3)
  {
    cout << " Analysis OPTIONS" << endl;
    //cout<<" -pi       [num]          "<<" specify prior probability for beta (default 0.1)" << endl;
    cout << " -vb       [num]          "
         << " specify prior variance for beta (default 1)" << endl;
    cout << " -h	      [min] [max] [num]"
         << " specify prior points for h: h_min, h_max, h_num (default 0.01 0.99 10)" << endl;
    cout << " -hscale   [num]          "
         << " specify proposal, scale for h (default min(2/sqrt(n),1) )" << endl;
    cout << " -sscale   [num]          "
         << " specify proposal, standard deviation for log(sigma_u^2) (default min(4/sqrt(n),1) )" << endl;
    cout << " -w        [num]          "
         << " specify burn-in steps (default 100)" << endl;
    cout << " -s        [num]          "
         << " specify sampling steps (default 1,000)" << endl;
    cout << " -mh       [num]          "
         << " specify number of MH steps in each iteration (default 10)" << endl;
    cout << " -seed     [num]          "
         << " specify random seed" << endl;
  }

  if (option == 4)
  {
    cout << " NOTICE" << endl;
    cout << " 1. No missing data in the gene expression file is allowed." << endl;
    cout << " 2. Individuals with missing predictor variables or covariates will not be analyzed." << endl;
    cout << endl;
  }

  return;
}

void MACAU::Assign(int argc, char **argv, PARAM &cPar) {
  string str;

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-silence") == 0)  {
      cPar.mode_silence = true;
    } else if (strcmp(argv[i], "-g") == 0)  {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-')  {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.file_read = str;
    } else if (strcmp(argv[i], "-t") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-')  {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.file_depth = str;
    } else if (strcmp(argv[i], "-p") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-')  {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.file_prdt = str;
    } else if (strcmp(argv[i], "-n") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.p_column = atoi(str.c_str());
    } else if (strcmp(argv[i], "-k") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.file_kin = str;
    } else if (strcmp(argv[i], "-v") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.file_var = str;
    } else if (strcmp(argv[i], "-c") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.file_cvt = str;
    } else if (strcmp(argv[i], "-pace") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.display_pace = atoi(str.c_str());
    } else if (strcmp(argv[i], "-o") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.file_out = str;
    } else if (strcmp(argv[i], "-ratio") == 0)  {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.ratio_threshold = atof(str.c_str());
    } else if (strcmp(argv[i], "-outdir") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.path_out = str;
    } else if (strcmp(argv[i], "-bmm") == 0) {
      cPar.a_mode = 1;
    } else if (strcmp(argv[i], "-pmm") == 0) {
      if (cPar.file_kin.empty()) {// without relatedness/kinship matrix
        cPar.a_mode = 3;
      } else {
        cPar.a_mode = 2;
      }
    }
    /*
    else if (strcmp(argv[i], "-pi")==0) {
      if(argv[i+1] == NULL || argv[i+1][0] == '-') {continue;}
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.pi_beta=atof(str.c_str());
    }
    else if (strcmp(argv[i], "-sb")==0) {
      cPar.vec_sb.clear();
      while (argv[i+1] != NULL && argv[i+1][0] != '-') {
	++i;
	str.clear();
	str.assign(argv[i]);
	cPar.vec_sb.push_back(atof(str.c_str()));
      }
    }
    */
    else if (strcmp(argv[i], "-vb") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.vb = atof(str.c_str());
    } else if (strcmp(argv[i], "-h") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.h_min = atof(str.c_str());
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.h_max = atof(str.c_str());
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.h_num = atoi(str.c_str());
    } else if (strcmp(argv[i], "-hscale") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.h_scale = atof(str.c_str());
    } else if (strcmp(argv[i], "-sscale") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-')
      {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.sigma_u2_sd = atof(str.c_str());
    } else if (strcmp(argv[i], "-w") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.w_step = atoi(str.c_str());
    } else if (strcmp(argv[i], "-s") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-')
      {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.s_step = atoi(str.c_str());
    } else if (strcmp(argv[i], "-mh") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-')
      {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.n_mh = atoi(str.c_str());
    } else if (strcmp(argv[i], "-seed") == 0) {
      if (argv[i + 1] == NULL || argv[i + 1][0] == '-') {
        continue;
      }
      ++i;
      str.clear();
      str.assign(argv[i]);
      cPar.randseed = atol(str.c_str());
    } else {
      cout << "error! unrecognized option: " << argv[i][0] << argv[i][1] << endl;
      cPar.error = true;
      continue;
    }
  }

  return;
}

void MACAU::BatchRun(PARAM &cPar) {
  clock_t time_begin;
  time_begin = clock();

  //Association analysis
  if (cPar.a_mode == 1) { // BMM
    //Read Files
    cout << "Reading Files ... " << endl;
    cPar.ReadFiles();
    if (cPar.error == true) {
      cout << "error! fail to read files. " << endl;
      return;
    }

    //Set up matrices and vectors
    gsl_matrix *Read = gsl_matrix_alloc(cPar.ng_total, cPar.ni_test);
    gsl_matrix *Depth = gsl_matrix_alloc(cPar.ng_test, cPar.ni_test); //Depth may be a vector
    gsl_matrix *K = gsl_matrix_alloc(cPar.ni_test, cPar.ni_test);     // kinship matrix
    gsl_matrix *B = gsl_matrix_alloc(cPar.ni_test, cPar.ni_test);
    gsl_matrix *W = gsl_matrix_alloc(cPar.ni_test, cPar.n_cvt);
    gsl_vector *x = gsl_vector_alloc(cPar.ni_test);

    //Load data
    cPar.LoadData(Read, Depth, K, B, W, x);
    if (cPar.error == true) {
      cout << "error! fail to check data. " << endl;
      return;
    }

    BMM cBmm;
    cBmm.CopyFromParam(cPar);
    cBmm.Analysis(Read, Depth, K, B, W, x);
    cBmm.CopyToParam(cPar);

    gsl_matrix_free(Read);
    gsl_matrix_free(Depth);
    gsl_matrix_free(K);
    gsl_matrix_free(B);
    gsl_matrix_free(W);
    gsl_vector_free(x);
  } else if (cPar.a_mode == 2) { // PMM
    //Read Files
    cout << "Reading Files ... " << endl;
    cPar.ReadFiles();
    if (cPar.error == true) {
      cout << "error! fail to read files. " << endl;
      return;
    }

    //Set up matrices and vectors
    gsl_matrix *Read = gsl_matrix_alloc(cPar.ng_total, cPar.ni_test);
    gsl_matrix *Depth = gsl_matrix_alloc(cPar.ng_test, cPar.ni_test); //Depth may be a vector
    gsl_matrix *K = gsl_matrix_alloc(cPar.ni_test, cPar.ni_test);     // kinship matrix
    gsl_matrix *B = gsl_matrix_alloc(cPar.ni_test, cPar.ni_test);
    gsl_matrix *W = gsl_matrix_alloc(cPar.ni_test, cPar.n_cvt);
    gsl_vector *x = gsl_vector_alloc(cPar.ni_test);

    //Load data
    cPar.LoadData(Read, Depth, K, B, W, x);
    if (cPar.error == true) {
      cout << "error! fail to check data. " << endl;
      return;
    }

    PMM cPmm;
    cPmm.CopyFromParam(cPar);
    cPmm.Analysis(Read, Depth, K, B, W, x);
    cPmm.CopyToParam(cPar);

    gsl_matrix_free(Read);
    gsl_matrix_free(Depth);
    gsl_matrix_free(K);
    gsl_matrix_free(B);
    gsl_matrix_free(W);
    gsl_vector_free(x);
  } else if (cPar.a_mode == 3) { // Poisson mixed model without relatedness matrix = negative binomial
    //Read Files
    cout << "Reading Files ... " << endl;
    cPar.ReadFiles();

    if (cPar.error == true) {
      cout << "error! fail to read files. " << endl;
      return;
    }

    //cout <<"num ng_total" <<cPar.ng_total<<endl;
    //cout <<"num ng_test" <<cPar.ng_test<<endl;
    //cout <<"num ni_test" <<cPar.ni_test<<endl;

    //Set up matrices and vectors  no relatedness/kinship matrix compared with PMM 
    gsl_matrix *Read = gsl_matrix_alloc(cPar.ng_total, cPar.ni_test);
    gsl_matrix *Depth = gsl_matrix_alloc(cPar.ng_test, cPar.ni_test); //Depth be a vector
    gsl_matrix *B = gsl_matrix_alloc(cPar.ni_test, cPar.ni_test);
    gsl_matrix *W = gsl_matrix_alloc(cPar.ni_test, cPar.n_cvt);
    gsl_vector *x = gsl_vector_alloc(cPar.ni_test);

    cPar.LoadData(Read, Depth, B, W, x);

    // run main function
    NB cNb;
    cNb.CopyFromParam(cPar);
    cNb.Analysis(Read, Depth, B, W, x);
    cNb.CopyToParam(cPar);

    gsl_matrix_free(Read);
    gsl_matrix_free(Depth);
    gsl_matrix_free(B);
    gsl_matrix_free(W);
    gsl_vector_free(x);
  }// end else
  cPar.time_total = (clock() - time_begin) / (double(CLOCKS_PER_SEC) * 60.0);

  return;
}// end func

/*
void MACAU::BatchRun (PARAM &cPar) {
  clock_t time_begin;
  time_begin=clock();

  //Read Files
  cout<<"Reading Files ... "<<endl;
  cPar.ReadFiles();
  if (cPar.error==true) {cout<<"error! fail to read files. "<<endl; return;}

  //Set up matrices and vectors
  gsl_matrix *Read=gsl_matrix_alloc (cPar.ng_total, cPar.ni_test);
  gsl_matrix *Depth=gsl_matrix_alloc (cPar.ng_test, cPar.ni_test); //Depth may be a vector
  gsl_matrix *K=gsl_matrix_alloc (cPar.ni_test, cPar.ni_test);
  gsl_matrix *B=gsl_matrix_alloc (cPar.ni_test, cPar.ni_test);
  gsl_matrix *W=gsl_matrix_alloc (cPar.ni_test, cPar.n_cvt);
  gsl_vector *x=gsl_vector_alloc (cPar.ni_test);

  //Load data
  cPar.LoadData(Read, Depth, K, B, W, x);
  if (cPar.error==true) {cout<<"error! fail to check data. "<<endl; return;}

  //Association analysis
  if (cPar.a_mode==1) {
    BMM cBmm;
    cBmm.CopyFromParam(cPar);
    cBmm.Analysis(Read, Depth, K, B, W, x);
    cBmm.CopyToParam(cPar);
  } else if (cPar.a_mode==2) {
    PMM cPmm;
    cPmm.CopyFromParam(cPar);
    cPmm.Analysis(Read, Depth, K, B, W, x);
    cPmm.CopyToParam(cPar);
  }
  cPar.time_total=(clock()-time_begin)/(double(CLOCKS_PER_SEC)*60.0);

  gsl_matrix_free(Read);
  gsl_matrix_free(Depth);
  gsl_matrix_free(K);
  gsl_matrix_free(B);
  gsl_matrix_free(W);
  gsl_vector_free(x);

  return;
}
*/

void MACAU::WriteLog(int argc, char **argv, PARAM &cPar) {
  string file_str;
  file_str = cPar.path_out + "/" + cPar.file_out;
  file_str += ".log.txt";

  ofstream outfile(file_str.c_str(), ofstream::out);
  if (!outfile)
  {
    cout << "error writing log file: " << file_str.c_str() << endl;
    return;
  }

  outfile << "##" << endl;
  outfile << "## MACAU Version = " << version << endl;

  outfile << "##" << endl;
  outfile << "## Command Line Input = ";
  for (int i = 0; i < argc; i++)
  {
    outfile << argv[i] << " ";
  }
  outfile << endl;

  outfile << "##" << endl;
  time_t rawtime;
  time(&rawtime);
  tm *ptm = localtime(&rawtime);

  outfile << "## Date = " << asctime(ptm);
  outfile << "##" << endl;

  outfile << "## Summary Statistics:" << endl;
  outfile << "## number of total individuals = " << cPar.ni_total << endl;
  outfile << "## number of analyzed individuals = " << cPar.ni_test << endl;
  outfile << "## number of total genes/sites = " << cPar.ng_total << endl;
  outfile << "## number of analyzed genes/sites = " << cPar.ng_test << endl;
  outfile << "## number of covariates = " << cPar.n_cvt << endl;
  outfile << "##" << endl;

  outfile << "## Computation time:" << endl;
  outfile << "## total computation time = " << cPar.time_total << " min " << endl;
  outfile << "## computation time break down: " << endl;
  outfile << "##      time on eigen-decomposition = " << cPar.time_eigen << " min " << endl;
  outfile << "##      time on calculating matrix-vector multiplication = " << cPar.time_mv << " min " << endl;
  outfile << "##      time on sampling Z = " << cPar.time_s_z << " min " << endl;
  outfile << "##      time on sampling MW = " << cPar.time_s_mw << " min " << endl;
  outfile << "##      time on sampling Hyperparameters = " << cPar.time_s_h << " min " << endl;
  outfile << "##      time on sampling BAU = " << cPar.time_s_bau << " min " << endl;
  outfile << "##" << endl;

  return;
}

void MACAU::WriteAssoc(PARAM &cPar) {
  string file_str;
  file_str = cPar.path_out + "/" + cPar.file_out;
  file_str += ".assoc.txt";

  ofstream outfile(file_str.c_str(), ofstream::out);
  if (!outfile) {
    cout << "error writing file: " << file_str.c_str() << endl;
    return;
  }

  double beta, se_beta, pvalue;

  outfile << "id"
          << "\t";

  outfile << "n"
          << "\t"
          << "acpt_rate"
          << "\t"
          << "beta"
          << "\t"
          << "se_beta"
          << "\t"
          << "pvalue"
          << "\t";
  if (cPar.a_mode == 1 || cPar.a_mode == 2) {
    outfile << "h"
          << "\t"
          << "se_h"
          << "\t";
  }// end fi
  
  outfile << "sigma2"
          << "\t"
          << "se_sigma2";

  for (size_t i = 0; i < cPar.n_cvt; i++) {
    outfile << "\t"
            << "alpha" << i << "\t"
            << "se_alpha" << i;
  }
  outfile << endl;

  for (vector<POSTMEAN>::size_type t = 0; t < cPar.sumPost.size(); ++t) {
    if (cPar.indicator_gene[t] == 1)
    {
      /*
      if (sumPost[t].gamma==1) {
	sumPost[t].bf=((double)s_step-1.0)*(1-pi_beta)/pi_beta;
      } else {
	sumPost[t].bf=sumPost[t].gamma/(1-sumPost[t].gamma)*(1-pi_beta)/pi_beta;
      }
      */
      if (cPar.sumPost[t].beta_se * cPar.sumPost[t].beta_se / cPar.vb > cPar.ratio_threshold) {
        continue;
      }

      beta = cPar.vb * cPar.sumPost[t].beta / (cPar.vb - cPar.sumPost[t].beta_se * cPar.sumPost[t].beta_se);
      se_beta = cPar.sumPost[t].beta_se * sqrt(cPar.vb / (cPar.vb - cPar.sumPost[t].beta_se * cPar.sumPost[t].beta_se));
      pvalue = gsl_cdf_chisq_Q(beta * beta / (se_beta * se_beta), 1);

      outfile << cPar.gene_id[t] << "\t" 
              << cPar.sumPost[t].n << "\t" << scientific << setprecision(3) 
              << cPar.sumPost[t].acc_rate << "\t" << beta << "\t" << se_beta << "\t" << pvalue << "\t";
      if (cPar.a_mode == 1 || cPar.a_mode == 2) {
        outfile << cPar.sumPost[t].h << "\t" << cPar.sumPost[t].h_se << "\t";
      }// end fi
      outfile << cPar.sumPost[t].sigma_u2 << "\t" << cPar.sumPost[t].sigma_u2_se;

      for (size_t i = 0; i < cPar.n_cvt; i++) {
        outfile << "\t" << cPar.sumPost[t].alpha[i] << "\t" << cPar.sumPost[t].alpha_se[i];
      }
      outfile << endl;
    }
  }// end for

  outfile.close();
  outfile.clear();
  return;
}// end func
