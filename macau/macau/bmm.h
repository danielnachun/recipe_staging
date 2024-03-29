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

#ifndef __BMM_H__
#define __BMM_H__

#include <vector>
#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"

using namespace std;

class BMM {

public:
	// IO related parameters
	int display_pace;		//display pace
	size_t ng_test, n_cvt;
	vector<int> indicator_gene;				//indicator for analyzed genes, 0 missing, 1 available for analysis

	// BMM MCMC related parameters
	vector<double> vec_h;
	//vector<double> vec_sb;
	double vb;

	double h_scale;
	double sigma_u2_sd;

	size_t w_step;					//number of warm up/burn in iterations
	size_t s_step;					//number of sampling iterations
	size_t n_accept;				//number of acceptance
	size_t n_mh;					//number of MH steps within each iteration
	long int randseed;				//random seed number

	double time_eigen;		//time spent on eigen-decomposition
	double time_mv;			//time spent on calculating UX and Uy
	double time_s_z, time_s_mw, time_s_h, time_s_bau;

	vector<POSTMEAN> sumPost;

	// Not included in PARAM
	gsl_rng *gsl_r;

	// Main Functions
	void CopyFromParam (PARAM &cPar);
	void CopyToParam (PARAM &cPar);
	double ProposeHyper (const class HYPPAR &cHyp_old, class HYPPAR &cHyp_new);
	void MCMCInitial (const vector<size_t> &y, const gsl_vector *log_N, class HYPPAR &cHyp, gsl_vector *log_lambda);
	double CalcPosteriorBMM (const gsl_vector *H_eval, const gsl_matrix *Pab, const class HYPPAR &cHyp);
	void UpdateUabBMM (const size_t h_id, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *U_mat, const gsl_vector *z, gsl_matrix *Utz, gsl_matrix *Uab);
	void UpdatePabBMM (const class HYPPAR &cHyp, const gsl_matrix *Uab, const gsl_vector *eval, const gsl_vector *ab, gsl_vector *H_eval, gsl_vector *Hi_eval, gsl_matrix *Pab);
	void EigenProcBMM (const gsl_matrix *K, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *Di, gsl_matrix *Uh_mat, gsl_matrix *Eval_h, gsl_matrix *UtW, gsl_matrix *Utx);
	void SampleZBMM (const vector<size_t> &N, const vector<size_t> &y, const gsl_vector *log_lambda, gsl_vector *z);
	void SampleMWBMM (const vector<size_t> &N, const gsl_vector *log_lambda, const gsl_matrix *weight, const gsl_matrix *mean, const gsl_vector *sigmasq, gsl_vector *z);
	void SampleHyperBMM (const gsl_matrix *Eval_h, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *U_mat, const gsl_vector *z, const gsl_vector *ab, gsl_matrix *Utz, gsl_matrix *Uab, gsl_matrix *Pab, class HYPPAR &cHyp);
	void SampleBAUBMM (const class HYPPAR &cHyp, const gsl_matrix *Eval_h, const gsl_matrix *Pab, const gsl_matrix *Uh_mat, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *Utz, double &beta, vector<double> &alpha, gsl_vector *u);
	void MCMCRunBMM (const vector<size_t> &N, const vector<size_t> &y, const gsl_matrix *K, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *Di, const gsl_matrix *weight, const gsl_matrix *mean, const gsl_vector *sigmasq, gsl_vector *epsilon, class POSTMEAN &cPostM);
	void Analysis (const gsl_matrix *Read, const gsl_matrix *Depth, const gsl_matrix *K, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x);
};




#endif






