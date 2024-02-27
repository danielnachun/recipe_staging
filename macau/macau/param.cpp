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
#include <string>
#include <cstring>
#include <sys/stat.h>
#include <cmath>

#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"
#include "gsl/gsl_linalg.h"
#include "gsl/gsl_blas.h"
#include "gsl/gsl_eigen.h"
#include "gsl/gsl_sf.h"

#include "param.h"
#include "io.h"

using namespace std;

PARAM::PARAM(void) : a_mode(1), p_column(1), display_pace(1000),
                     file_out("result"), path_out("./output/"),
                     //pi_beta(0.1),
                     h_min(0.01), h_max(0.99), h_num(10), vb(1), h_scale(-1), sigma_u2_sd(-1), ratio_threshold(0.95),
                     w_step(100), s_step(1000), n_accept(0), n_mh(10),
                     randseed(-1),
                     error(false),
                     n_cvt(1),
                     time_total(0.0), time_eigen(0.0), time_mv(0.0), time_s_z(0.0), time_s_mw(0.0), time_s_h(0.0), time_s_bau(0.0)
{
}

//read files
//obtain ns_total, ng_total, ns_test, ni_test
void PARAM::ReadFiles(void) {
  string file_str;

  if (!file_cvt.empty()) {
    if (ReadFile_cvt(file_cvt, indicator_cvt, cvt, n_cvt) == false) {
      error = true;
    }
  }

  if (ReadFile_column(file_prdt, indicator_idv, prdt, p_column) == false) {
    error = true;
  }

  if (CountFileLines(file_read, ng_total, a_mode) == false) {
    error = true;
  }
  ng_total--;

  if (!file_depth.empty()) {
    if (CountFileLines(file_depth, ng_test, a_mode) == false) {
      error = true;
    }
    ng_test--;
    if (ng_test != 1 && ng_test != ng_total) {
      cout << "The total read count file should either contain one data row or match rows in the read count file." << endl;
      error = true;
    }
  } else {
    ng_test = 1;
  }

  //post-process covariates and phenotypes, obtain ni_test, n_cvt, save all useful covariates
  ProcessCvtPhen();
  ni_total = indicator_idv.size();

  if ((indicator_cvt).size() != (indicator_idv).size()) {
    error = true;
    cout << "error! number of rows in the covariates file do not match that in the predictor file. " << endl;
  }

  //output some information
  cout << "## number of total individuals = " << ni_total << endl;
  cout << "## number of analyzed individuals = " << ni_test << endl;
  cout << "## number of covariates = " << n_cvt << endl;
  cout << "## number of total genes/sites = " << ng_total << endl;

  return;
}// end func

//==================
void PARAM::CheckParam(void) {
  struct stat fileInfo;
  string str;

  //check parameters
  if (a_mode != 1 && a_mode != 2 && a_mode != 3)
  {
    cout << "error! unknown analysis mode: " << a_mode << ". make sure -bmm or -pmm or -nb is sepcified correctly." << endl;
    error = true;
  }
  if (h_max < h_min)
  {
    cout << "error! maximum h value must be larger than the minimal value. current values = " << h_max << " and " << h_min << endl;
    error = true;
  }
  if (h_max > 1.0)
  {
    cout << "error! h value should be bewtween 0 and 1. current values are from " << h_min << " to " << h_max << endl;
    error = true;
  }
  if (h_num == 0)
  {
    cout << "error! h_num value should be above 0. current value = " << h_num << endl;
    error = true;
  }
  if (ratio_threshold > 1)
  {
    cout << "error! ratio threshold should be between 0 and 1. current value = " << ratio_threshold << endl;
    error = true;
  }
  //if (pi_beta>=1.0) {cout<<"error! pi_beta value should be bewtween 0 and 1. current value = "<<pi_beta<<endl; error=true;}

  //set up parameters
  float step = (h_max - h_min) / (float)h_num;
  for (size_t i = 0; i < h_num; i++)
  {
    vec_h.push_back(h_min + step * i);
  }
  if (h_max > h_min)
  {
    vec_h.push_back(h_max);
  }

  /*
  if (vec_sb.size()==0) {
    vec_sb.push_back(0.1*0.1);
    vec_sb.push_back(0.2*0.2);
    vec_sb.push_back(0.4*0.4);
    vec_sb.push_back(0.8*0.8);
    vec_sb.push_back(1.6*1.6);
  }
  */

  //check files
  if (file_read.empty())
  {
    cout << "error! missing read count file. " << endl;
    error = true;
  }
  if (file_prdt.empty())
  {
    cout << "error! missing predictor file. " << endl;
    error = true;
  }

  // for PMM or BMM
  if (a_mode == 1 || a_mode == 2)
  {
    // require kin matrix
    if (file_kin.empty())
    {
      cout << "error! missing relatedness/kinship file. " << endl;
      error = true;
    }
    // check kin matrix
    str = file_kin;
    if (!str.empty() && stat(str.c_str(), &fileInfo) == -1)
    {
      cout << "error! fail to open kinship file: " << str << endl;
      error = true;
    }
  }// end fi

  if (a_mode == 1 && file_depth.empty())
  {
    cout << "error! missing total count file for BMM analysis. " << endl;
    error = true;
  }

  str = file_read;
  if (!str.empty() && stat(str.c_str(), &fileInfo) == -1)
  {
    cout << "error! fail to open read count file: " << str << endl;
    error = true;
  }

  str = file_prdt;
  if (!str.empty() && stat(str.c_str(), &fileInfo) == -1)
  {
    cout << "error! fail to open predictor file: " << str << endl;
    error = true;
  }

  str = file_cvt;
  if (!str.empty() && stat(str.c_str(), &fileInfo) == -1)
  {
    cout << "error! fail to open covariate file: " << str << endl;
    error = true;
  }

  str = file_depth;
  if (!str.empty() && stat(str.c_str(), &fileInfo) == -1)
  {
    cout << "error! fail to open read depth file: " << str << endl;
    error = true;
  }

  str = file_var;
  if (!str.empty() && stat(str.c_str(), &fileInfo) == -1)
  {
    cout << "error! fail to open variance file: " << str << endl;
    error = true;
  }

  return;
}// end func

void PARAM::LoadData(gsl_matrix *Read, gsl_matrix *Depth, gsl_matrix *K, gsl_matrix *B, gsl_matrix *W, gsl_vector *x) {
  if (ReadFile_gene(file_read, indicator_idv, gene_id, Read) == false) {
    error = true;
  }

  if (!file_depth.empty()) {
    if (ReadFile_gene(file_depth, indicator_idv, gene_id2, Depth) == false)  {
      error = true;
    }

    bool is_equal = false;
    if (gene_id.size() == gene_id2.size())  {
      is_equal = equal(gene_id.begin(), gene_id.end(), gene_id2.begin());
      if (!is_equal)  {
        cout << "gene ids in the read count file and read depth file are not consistent! analysis is continued ignoring this error." << endl;
      }
    }
  } else {
    gsl_matrix_set_zero(Depth);
    gsl_vector_view Depth_row = gsl_matrix_row(Depth, 0);
    for (size_t i = 0; i < Read->size1; i++)  {
      gsl_vector_view Read_row = gsl_matrix_row(Read, i);
      gsl_vector_add(&Depth_row.vector, &Read_row.vector);
    }
  }

  ReadFile_kin(file_kin, indicator_idv, error, K);
  if (!file_var.empty()) {
    ReadFile_kin(file_var, indicator_idv, error, B);
  } else {
    gsl_matrix_set_identity(B);
  }

  CopyCvtPhen(W, x, 0);

  if (h_scale == -1) {
    h_scale = min(1.0, 2.0 / sqrt((double)ni_test));
  }
  if (sigma_u2_sd == -1) {
    sigma_u2_sd = min(1.0, 4.0 / sqrt((double)ni_test));
  }

  return;
}

//post-process phentoypes, covariates
void PARAM::ProcessCvtPhen() {
  //remove individuals with missing covariates
  if ((indicator_cvt).size() != 0) {
    for (vector<int>::size_type i = 0; i < (indicator_idv).size(); ++i) {
      indicator_idv[i] *= indicator_cvt[i];
    }
  }

  //obtain ni_test
  ni_test = 0;
  for (vector<int>::size_type i = 0; i < (indicator_idv).size(); ++i) {
    if (indicator_idv[i] == 0)  {
      continue;
    }
    ni_test++;
  }

  //check ni_test
  if (ni_test == 0) {
    error = true;
    cout << "error! number of analyzed individuals equals 0. " << endl;
    return;
  }

  //check covariates to see if they are correlated with each other, and to see if the intercept term is included
  //after getting ni_test
  //add or remove covariates
  if (indicator_cvt.size() != 0) {
    CheckCvt();
  } else {
    vector<double> cvt_row;
    cvt_row.push_back(1);

    for (vector<int>::size_type i = 0; i < (indicator_idv).size(); ++i) {
      indicator_cvt.push_back(1);

      cvt.push_back(cvt_row);
    }
  }

  return;
} // end func

void PARAM::LoadData(gsl_matrix *Read, gsl_matrix *Depth, gsl_matrix *B, gsl_matrix *W, gsl_vector *x) {
  
  // reading gene expression matrix
  if (ReadFile_gene(file_read, indicator_idv, gene_id, Read) == false) {
    error = true;
  }// end fi

  // reading read depth
  if (!file_depth.empty()) {
    if (ReadFile_gene(file_depth, indicator_idv, gene_id2, Depth) == false) {
      error = true;
    }

    bool is_equal = false;
    if (gene_id.size() == gene_id2.size()) {
      is_equal = equal(gene_id.begin(), gene_id.end(), gene_id2.begin());
      if (!is_equal) {
        cout << "gene ids in the read count file and read depth file are not consistent! analysis is continued ignoring this error." << endl;
      }
    }
  } else { // compute the Depth for RNAseq study, sum values across whole genes
    gsl_matrix_set_zero(Depth);
    gsl_vector_view Depth_row = gsl_matrix_row(Depth, 0);
    for (size_t i = 0; i < Read->size1; i++) {
      gsl_vector_view Read_row = gsl_matrix_row(Read, i);
      gsl_vector_add(&Depth_row.vector, &Read_row.vector);
    }
  } // end fi

  //cout<<"after load annot"<<endl;
  // read identity matrix B or weight matrix to account for heterogeneity
  if (!file_var.empty()) {
    ReadFile_kin(file_var, indicator_idv, error, B);
  } else {
    gsl_matrix_set_identity(B);
  } // end fi

  CopyCvtPhen(W, x, 0);

  if (h_scale == -1) {
    h_scale = min(1.0, 2.0 / sqrt((double)ni_test));
  }

  if (sigma_u2_sd == -1) {
    sigma_u2_sd = min(1.0, 4.0 / sqrt((double)ni_test));
  }

  return;
} // end func



void PARAM::CheckCvt() {
  if (indicator_cvt.size() == 0)
  {
    return;
  }

  size_t ci_test = 0;

  gsl_matrix *W = gsl_matrix_alloc(ni_test, n_cvt);

  for (vector<int>::size_type i = 0; i < indicator_idv.size(); ++i)
  {
    if (indicator_idv[i] == 0 || indicator_cvt[i] == 0)
    {
      continue;
    }
    for (size_t j = 0; j < n_cvt; ++j)
    {
      gsl_matrix_set(W, ci_test, j, (cvt)[i][j]);
    }
    ci_test++;
  }

  size_t flag_ipt = 0;
  double v_min, v_max;
  set<size_t> set_remove;

  //check if any columns is an intercept
  for (size_t i = 0; i < W->size2; i++)
  {
    gsl_vector_view w_col = gsl_matrix_column(W, i);
    gsl_vector_minmax(&w_col.vector, &v_min, &v_max);
    if (v_min == v_max)
    {
      flag_ipt = 1;
      set_remove.insert(i);
    }
  }

  //add an intecept term if needed
  if (n_cvt == set_remove.size())
  {
    //    indicator_cvt.clear();
    n_cvt = 1;
  }
  else if (flag_ipt == 0)
  {
    cout << "no intecept term is found in the cvt file. a column of 1s is added." << endl;
    for (vector<int>::size_type i = 0; i < indicator_idv.size(); ++i)
    {
      if (indicator_idv[i] == 0 || indicator_cvt[i] == 0)
      {
        continue;
      }
      cvt[i].push_back(1.0);
    }

    n_cvt++;
  }
  else
  {
  }

  gsl_matrix_free(W);

  return;
}

void PARAM::CopyCvtPhen(gsl_matrix *W, gsl_vector *y, size_t flag) {
  size_t ci_test = 0;

  for (vector<int>::size_type i = 0; i < indicator_idv.size(); ++i)
  {
    if (flag == 0)
    {
      if (indicator_idv[i] == 0)
      {
        continue;
      }
    }
    else
    {
      if (indicator_cvt[i] == 0)
      {
        continue;
      }
    }

    gsl_vector_set(y, ci_test, (prdt)[i]);

    for (size_t j = 0; j < n_cvt; ++j)
    {
      gsl_matrix_set(W, ci_test, j, (cvt)[i][j]);
    }
    ci_test++;
  }

  return;
}

void NormalMixture(const size_t &nu, gsl_vector *weight, gsl_vector *mean, double &sigma2) {
  gsl_vector_set_zero(weight);
  gsl_vector_set_zero(mean);

  double w1, w2, w3, m1, m2, m3, f;
  if (nu == 0)
  {
    sigma2 = 1.0;
    return;
  }

  if (nu == 1)
  {
    gsl_vector_set(weight, 0, 0.292358335);
    gsl_vector_set(mean, 0, -0.81407937);
    gsl_vector_set(weight, 1, 0.282811058);
    gsl_vector_set(mean, 1, 0.02214491);
    gsl_vector_set(weight, 2, 0.162485949);
    gsl_vector_set(mean, 2, 0.84072302);
    gsl_vector_set(weight, 3, 0.096969182);
    gsl_vector_set(mean, 3, -0.75539318);
    gsl_vector_set(weight, 4, 0.080531328);
    gsl_vector_set(mean, 4, -0.18499734);
    gsl_vector_set(weight, 5, 0.059489424);
    gsl_vector_set(mean, 5, 1.75310327);
    gsl_vector_set(weight, 6, 0.018806548);
    gsl_vector_set(mean, 6, 2.74704191);
    gsl_vector_set(weight, 7, 0.005167303);
    gsl_vector_set(mean, 7, 3.85691571);
    gsl_vector_set(weight, 8, 0.001194558);
    gsl_vector_set(mean, 8, 5.16828644);
    gsl_vector_set(weight, 9, 0.000186315);
    gsl_vector_set(mean, 9, 6.96441954);
    sigma2 = 0.1904524;
  }
  else if (nu == 2)
  {
    gsl_vector_set(weight, 0, 0.3959849068);
    gsl_vector_set(mean, 0, -0.78481601);
    gsl_vector_set(weight, 1, 0.3893476342);
    gsl_vector_set(mean, 1, 0.06357148);
    gsl_vector_set(weight, 2, 0.1639825783);
    gsl_vector_set(mean, 2, 1.02272971);
    gsl_vector_set(weight, 3, 0.0429866586);
    gsl_vector_set(mean, 3, 2.12556590);
    gsl_vector_set(weight, 4, 0.0070591073);
    gsl_vector_set(mean, 4, 3.45978363);
    gsl_vector_set(weight, 5, 0.0006391149);
    gsl_vector_set(mean, 5, 5.24872311);
    sigma2 = 0.2891942;
  }
  else if (nu == 3)
  {
    gsl_vector_set(weight, 0, 0.486217000);
    gsl_vector_set(mean, 0, -0.6673118);
    gsl_vector_set(weight, 1, 0.388199895);
    gsl_vector_set(mean, 1, 0.3083583);
    gsl_vector_set(weight, 2, 0.109300389);
    gsl_vector_set(mean, 2, 1.4434138);
    gsl_vector_set(weight, 3, 0.015268602);
    gsl_vector_set(mean, 3, 2.7787517);
    gsl_vector_set(weight, 4, 0.001014113);
    gsl_vector_set(mean, 4, 4.4961998);
    sigma2 = 0.3804526;
  }
  else if (nu == 4)
  {
    gsl_vector_set(weight, 0, 0.5861155);
    gsl_vector_set(mean, 0, -0.5422216);
    gsl_vector_set(weight, 1, 0.3502742);
    gsl_vector_set(mean, 1, 0.5501263);
    gsl_vector_set(weight, 2, 0.06010099);
    gsl_vector_set(mean, 2, 1.872814);
    gsl_vector_set(weight, 3, 0.003509278);
    gsl_vector_set(mean, 3, 3.577721);
    sigma2 = 0.4659689;
  }
  else if (nu == 5)
  {
    gsl_vector_set(weight, 0, 0.5616998);
    gsl_vector_set(mean, 0, -0.5582241);
    gsl_vector_set(weight, 1, 0.3695824);
    gsl_vector_set(mean, 1, 0.5012684);
    gsl_vector_set(weight, 2, 0.06518514);
    gsl_vector_set(mean, 2, 1.783957);
    gsl_vector_set(weight, 3, 0.003532618);
    gsl_vector_set(mean, 3, 3.438903);
    sigma2 = 0.4829331;
  }
  else if (nu >= 6 && nu <= 15)
  {
    f = (double)nu;
    w1 = (-0.65831069 + 0.07464502 * f + 0.18842462 * f * f) / (-0.03083496 - 0.29297239 * f + 0.30670205 * f * f);
    w2 = (1.5859091 - 0.7518891 * f + 0.3534794 * f * f) / (0.2642839 + 0.1614150 * f + 0.9698179 * f * f);
    w3 = (1.347659e-02 + 1.274155e-03 * f - 3.837054e-05 * f * f) / (8.799315e-01 + 4.313589e-02 * f - 1.551848e-03 * f * f);
    m1 = (-0.369593806 - 0.006705784 * f - 0.009308217 * f * f) / (1.034304617 + 0.003362558 * f + 0.024026594 * f * f);
    m2 = (-0.83033915 + 0.39064249 * f + 0.09007709 * f * f) / (0.13183363 - 0.09863663 * f + 0.16825970 * f * f);
    m3 = (-1.18261679 + 0.03989375 * f + 0.45588239 * f * f) / (1.26188708 - 0.70453493 * f + 0.25493832 * f * f);

    gsl_vector_set(weight, 0, w1);
    gsl_vector_set(mean, 0, m1);
    gsl_vector_set(weight, 1, w2);
    gsl_vector_set(mean, 1, m2);
    gsl_vector_set(weight, 2, w3);
    gsl_vector_set(mean, 2, m3);
    sigma2 = (0.06108196 + 0.66337653 * f + 0.08888924 * f * f) / (0.37019133 + 1.31863493 * f + 0.11449459 * f * f);
  }
  else if (nu >= 16 && nu <= 170)
  {
    f = (double)nu;
    w1 = (6.928372e-01 + 3.790557e-02 * f + 7.142027e-05 * f * f) / (7.754127e-01 + 4.535478e-02 * f + 8.904638e-05 * f * f);
    w2 = (0.826334908 + 0.152895406 * f + 0.001124454 * f * f) / (8.827352339 + 0.997776856 * f + 0.006042693 * f * f);
    m1 = (-0.8917004769 - 0.1854619719 * f - 0.0009083656 * f * f) / (4.1917882614 + 0.9940278547 * f + 0.0070331831 * f * f);
    m2 = (1.0756481792 + 0.0725966379 * f + 0.0002470306 * f * f) / (0.5983138465 + 0.0756419686 * f + 0.000456120 * f * f);

    gsl_vector_set(weight, 0, w1);
    gsl_vector_set(mean, 0, m1);
    gsl_vector_set(weight, 1, w2);
    gsl_vector_set(mean, 1, m2);
    sigma2 = (5.994944e-01 + 3.781757e-02 * f + 1.488570e-05 * f * f) / (8.663770e-01 + 4.283849e-02 * f + 1.131634e-05 * f * f);
  }
  else
  {
    gsl_vector_set(weight, 0, 1.0);
    gsl_vector_set(mean, 0, 0.0);
    sigma2 = 1.0;
  }

  f = 0.0;
  for (size_t i = 0; i < weight->size; i++)
  {
    f += gsl_vector_get(weight, i);
  }
  for (size_t i = 0; i < weight->size; i++)
  {
    gsl_vector_set(weight, i, gsl_vector_get(weight, i) / f);
  }

  for (size_t i = 0; i < mean->size; i++)
  {
    f = gsl_vector_get(mean, i);
    f = f * sqrt(gsl_sf_psi_1_int(nu)) - gsl_sf_psi_int(nu);
    gsl_vector_set(mean, i, f);
  }

  sigma2 *= gsl_sf_psi_1_int(nu);

  return;
}

double calc_var(const gsl_vector *x) {
  double m2 = 0.0, m = 0.0, f;
  for (size_t i = 0; i < x->size; i++)
  {
    f = gsl_vector_get(x, i);
    m += f;
    m2 += f * f;
  }
  m2 /= (double)x->size;
  m /= (double)x->size;

  return m2 - m * m;
}

double calcSD(const vector<double> vec_d) {
  double m = 0.0, v = 0.0;
  for (size_t i = 0; i < vec_d.size(); i++)
  {
    m += vec_d[i];
    v += vec_d[i] * vec_d[i];
  }
  m /= (double)vec_d.size();
  v /= (double)vec_d.size();

  v -= m * m;
  return sqrt(v);
}

void POSTMEAN::initial(const size_t n_cvt) {
  h = 0.0;
  sigma_u2 = 0.0;
  beta = 0.0;
  gamma = 0.0;
  alpha.clear();
  alpha_se.clear();
  for (size_t i = 0; i < n_cvt; i++)
  {
    alpha.push_back(0.0);
    alpha_se.push_back(0.0);
  }
  return;
}
