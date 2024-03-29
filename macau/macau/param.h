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

#ifndef __PARAM_H__
#define __PARAM_H__

#include <vector>
#include <map>
#include <set>
#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"

using namespace std;


class HYPPAR {
public:
	size_t h_id;
	size_t sb_id;
	double sigma_u2;
	double sigma_b2;
	size_t gamma;
};


class POSTMEAN {
public:
	double h;
	double h_se;
	double h_025;
	double h_500;
	double h_975;
	double sigma_u2;
	double sigma_u2_se;
	double sigma_u2_025;
	double sigma_u2_500;
	double sigma_u2_975;
	double beta;
	double beta_se;
	double beta_025;
	double beta_500;
	double beta_975;
	double gamma;
	double acc_rate;
	double bf;
	double pvalue;
	vector<double> alpha;
	vector<double> alpha_se;
	size_t n;

	void initial(const size_t n_cvt);
};


class PARAM {

public:
  bool mode_silence;
	int a_mode;	       //analysis mode: 1: poisson mixed effects model 2: linear mixed model
	int p_column;			//which p column in the predictor variable file needs analysis
	int display_pace;		//display pace

	string file_read;		//gene expression or methylation file file
	string file_depth;              //expression depth or total methylation read count file
	string file_prdt;		//predictor variable file
	string file_cvt;		//covariate file, optional
	string file_kin;		//kinship file
	string file_var;		//biological variation matrix; typically an identity matrix
	string file_out;
	string path_out;

	//MCMC related parameters
	//double pi_beta;
	double h_min, h_max;
	size_t h_num;
	vector<double> vec_h;
	//vector<double> vec_sb;//prior beta variance
	double vb;

	double h_scale;
	double sigma_u2_sd;
	double ratio_threshold;

	size_t w_step;					//number of warm up/burn in iterations
	size_t s_step;					//number of sampling iterations
	size_t n_accept;				//number of acceptance
	size_t n_mh;					//number of MH steps within each iteration
	long int randseed;				//random seed number

	//variance for x
	double s_x;

	// Other parameters
	bool error;
	size_t ni_total, ng_total;	//number of total individuals and genes
	size_t ni_test, ng_test;	//number of individuals and genes used for analysis
	size_t n_cvt;			//number of covariates
	double time_total;		//record total time
	double time_eigen;		//time spent on eigen-decomposition
	double time_mv;			//time spent on calculating UX and Uy
	double time_s_z, time_s_mw, time_s_h, time_s_bau;

	vector<double> prdt;				//a vector record all predictor, NA replaced with -9
	vector<vector<double> > cvt;				//a vector record all covariates, NA replaced with -9

	vector<int> indicator_idv;				//indicator for individuals, 0 missing, 1 available for analysis
	vector<int> indicator_cvt;				//indicator for covariates, 0 missing, 1 available for analysis
	vector<int> indicator_gene;				//indicator for analyzed genes, 0 missing, 1 available for analysis

	vector<string> gene_id, gene_id2;					//gene ID
	vector<string> individual_id;			//individual ID
	//	map<string, int> mapID2num;		//map small ID number to number, from 0 to n_phen-1

	vector<POSTMEAN> sumPost;				//posterior mean

	//constructor
	PARAM();

	//functions
	void ReadFiles ();
	void CheckParam ();
	void LoadData (gsl_matrix *Read, gsl_matrix *Depth, gsl_matrix *K, gsl_matrix *B, gsl_matrix *W, gsl_vector *x);
	void LoadData (gsl_matrix *Read, gsl_matrix *Depth, gsl_matrix *B, gsl_matrix *W, gsl_vector *x);
	void CheckCvt ();
	void ProcessCvtPhen();
	void CopyCvtPhen (gsl_matrix *W, gsl_vector *y, size_t flag);
};

void NormalMixture(const size_t &nu, gsl_vector *weight, gsl_vector *mean, double &sigma2);
double calc_var (const gsl_vector *x);
double calcSD(const vector<double> vec_d);

#endif






