/*
 Genome-wide Efficient Mixed Model Association (GEMMA)
 Copyright (C) 2011  Xiang Zhou
 
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


#ifndef __LDR_H__                
#define __LDR_H__

#include <vector>
#include <map>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_sf_psi.h>

#include <gsl/gsl_sort.h>
#include <gsl/gsl_sort_vector.h>
#include <gsl/gsl_sort_float.h>
#include <gsl/gsl_sort_vector_float.h>

#ifdef FORCE_FLOAT
#include "param_float.h"
#else
#include "param.h"
#endif
#include "Eigen/Dense"
using namespace Eigen;

using namespace std;


class LDR {

public:	
	// IO related parameters
	int    a_mode;	
	size_t d_pace;
	
	string file_bfile;
	string file_geno;
	string file_out;
	string path_out;

	// LDR zeng ping
	double pheno_mean,DIC1,BIC1,pD1,DIC2,BIC2,pD2,LBO;
	double sp;
	double tp;
	size_t n_cvt, n_k, w_step, s_step, mixture_no,mnk; 
	//LDR zeng ping
			
	// Summary statistics
	size_t ni_total, ns_total;	//number of total individuals and snps
	size_t ni_test, ns_test;	//number of individuals and snps used for analysis
	vector<int> indicator_idv;	//indicator for individuals (phenotypes), 0 missing, 1 available for analysis
	vector<int> indicator_snp;	//sequence indicator for SNPs: 0 ignored because of (a) maf, (b) miss, (c) non-poly; 1 available for analysis
	
	vector<SNPINFO> snpInfo;	//record SNP information
	
	// Not included in PARAM
	gsl_rng *gsl_r; 	
	
	// Main Functions
	void CopyFromParam (PARAM &cPar);
	void CopyToParam   (PARAM &cPar);
	void WritevbBeta (const VectorXd Ebeta);
	void WritelmmBeta (const VectorXd Ebeta);
	void WritevbAlpha (const VectorXd Ealpha,size_t n_j);
	void WritevbVariance (const double variance);
	void WritevbELBO (const VectorXd ELBO,size_t n_int);
	void WriteCoeff (const VectorXd Alpha, const VectorXd Beta);
	void WriteParam (const VectorXd Alpha); 
	void WriteLike (const VectorXd Like,size_t t);

	//double sum_Elogvl (const VectorXd lambda_k, const VectorXd kappa_k, size_t k);
	//double  sum_lambda_k(const MatrixXd pik_beta, size_t k, size_t n_k);
	//double sum_b_lambda(const VectorXd lambda_k,const VectorXd kappa_k,size_t n_k);
	//double ELBO1(const VectorXd a_k,const VectorXd b_k,size_t n_k);
	//double ELBO2(const VectorXd kappa_k,const VectorXd lambda_k,size_t n_k);
	//double ELBO3(const MatrixXd pik_beta,const MatrixXd sik2_beta);
	//double sum_Elogvl2(const VectorXd vk, size_t k);

	void WritegibbsBeta (const VectorXd Ebeta);
	void WritegibbsAlpha (const VectorXd Ealpha,size_t n_j);
	void WritegibbsVariance (const double variance);
	void call_sig_allsnp_no (gsl_matrix *W, vector<int> *sig_subsnp_no, PARAM &cPar);
	void call_sig_index (gsl_matrix *W, vector<int> *sig_index, PARAM &cPar);
	void call_Position  (gsl_matrix *W, vector<int> *ps, PARAM &cPar);
	void call_Pvalue    (gsl_matrix *W, vector<double> *pvalue, PARAM &cPar);
	void call_Chr       (gsl_matrix *W, vector<int> *Chr, PARAM &cPar);
	void call_Chr_Position(gsl_matrix *W, vector<int> *Chr, vector<int> *ps, PARAM &cPar);
	
	//void LDscreen (gsl_matrix *LDblock0, MatrixXd LDblock, gsl_matrix *W, gsl_vector *y, gsl_matrix *UtX, vector<int> *selectX_block, vector<int> *selectX_snp, vector<double> *selectX_pvalue, PARAM &cPar);
	void LDscreen (gsl_matrix *LDblock0, MatrixXd LDblock, gsl_matrix *W, gsl_vector *y, gsl_matrix *UtX, vector<int> *selectX_snp, PARAM &cPar);
	
	void LDscreen (gsl_matrix *LDblock0, MatrixXd LDblock, gsl_matrix *W, gsl_vector *y, MatrixXd UtX, vector<int> *selectX_snp, PARAM &cPar);

	void VB(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, double lambda);


	void VBslmm(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, double lambda);

	void Gibbs(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, double lambda);
	void Gibbs_without_u(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, double lambda);

	void GibbScreen(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, const VectorXi snp_no, double lambda);

	void GibbScreen500(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, const VectorXi snp_no, double lambda);

	void Gibbs_without_u_screen(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, const VectorXi snp_no, double lambda);

	void Gibbs_without_u_screen_dic0(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, const VectorXi snp_no, double lambda, size_t n_k);

	void Gibbs_without_u_screen_dic1(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, const VectorXi snp_no, double lambda, size_t n_k);

	void GibbScreenX(const MatrixXd UtX, const VectorXd Uty, const MatrixXd UtW, const VectorXd D, const VectorXd Wbeta, const VectorXd se_Wbeta, const VectorXd beta, const VectorXi snp_no, double lambda);
};

#endif




