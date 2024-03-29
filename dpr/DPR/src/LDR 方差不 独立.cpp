/*
  OM*
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
  
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <cmath>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <ctime>
#include <cstring>
#include <algorithm>

#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"
#include "gsl/gsl_linalg.h"
#include "gsl/gsl_blas.h"
#include "gsl/gsl_eigen.h"
#include "gsl/gsl_randist.h"
#include "gsl/gsl_cdf.h"
#include "gsl/gsl_roots.h"
#include "Eigen/Dense"

#include "gsl/gsl_rng.h"


#include "lapack.h"

#ifdef FORCE_FLOAT
#include "param_float.h"
#include "ldr_float.h"
#include "lm_float.h"
#include "lmm_float.h"//for LMM class,and functions CalcLambda, CalcPve, CalcVgVe
#include "mathfunc_float.h"  //for function CenterVector
#else
#include "param.h"
#include "ldr.h"
#include "lm.h"
#include "bslmm.h"
#include "lmm.h"
#include "mathfunc.h"
#endif

using namespace std;
using namespace Eigen;

void LDR::CopyFromParam (PARAM &cPar)   {
	a_mode=cPar.a_mode;
	d_pace=cPar.d_pace;

	file_bfile=cPar.file_bfile;
	file_geno=cPar.file_geno;
	file_out=cPar.file_out;
	path_out=cPar.path_out;

	ni_total=cPar.ni_total;
	ns_total=cPar.ns_total;
	ni_test=cPar.ni_test;
	ns_test=cPar.ns_test;
	n_cvt=cPar.n_cvt;

// zeng ping LDR
	n_k=cPar.n_k;
	sp=cPar.sp;
	tp=cPar.tp;
	w_step=cPar.w_step;
	s_step=cPar.s_step;
  // zeng ping LDR

	indicator_idv=cPar.indicator_idv;
	indicator_snp=cPar.indicator_snp;
	snpInfo=cPar.snpInfo;
	mixture_no=cPar.mixture_no;
//LDR_PVE=cPar.LDR_PVE;

	return;
}

void LDR::CopyToParam (PARAM &cPar)   {
	/*cPar.time_UtZ=time_UtZ;
	cPar.time_Omega=time_Omega;
	cPar.time_Proposal=time_Proposal;
	cPar.cHyp_initial=cHyp_initial;
	cPar.n_accept=n_accept;
	cPar.pheno_mean=pheno_mean;
	cPar.randseed=randseed;*/
	cPar.LDR_PVE=LDR_PVE;
	cPar.pheno_mean=pheno_mean;
	cPar.mixture_no=mixture_no;
	return;
}

void LDR::WritevbBeta (const VectorXd Ebeta,size_t n_snp)  {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".param.txt";

	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}

	outfile<<"chr"<<"\t"<<"rs"<<"\t"
	<<"ps"<<"\t"<<"n_miss"<<"\t"<<"alpha"<<"\t"
	<<"beta"<<"\t"<<"gamma"<<endl;

	size_t t=0;
	for (size_t i=0; i<ns_total; ++i) {
		if (indicator_snp[i]==0) {continue;}

	outfile<<snpInfo[i].chr<<"\t"<<snpInfo[i].rs_number<<"\t"
	<<snpInfo[i].base_position<<"\t"<<snpInfo[i].n_miss<<"\t";

	outfile<<scientific<<setprecision(6)<<0.0<<"\t";
	outfile<<scientific<<setprecision(6)<<Ebeta(t)<<"\t";
	outfile<<1<<endl;
	t++;
}

	outfile.clear();
	outfile.close();
return;
}


void LDR::WritelmmBeta (const VectorXd Ebeta,size_t n_snp)  {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".lmm.param.txt";
	
	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}
	
	outfile<<"chr"<<"\t"<<"rs"<<"\t"
	<<"ps"<<"\t"<<"n_miss"<<"\t"<<"alpha"<<"\t"
	<<"beta"<<"\t"<<"gamma"<<endl;
	
	size_t t=0;
	for (size_t i=0; i<ns_total; ++i) {
		if (indicator_snp[i]==0) {continue;}
	
		outfile<<snpInfo[i].chr<<"\t"<<snpInfo[i].rs_number<<"\t"
		<<snpInfo[i].base_position<<"\t"<<snpInfo[i].n_miss<<"\t";
	
		outfile<<scientific<<setprecision(6)<<0.0<<"\t";
		outfile<<scientific<<setprecision(6)<<Ebeta(t)<<"\t";
		outfile<<1<<endl;
		t++;
	}
	
	outfile.clear();
	outfile.close();
	return;
}


void LDR::WritevbAlpha (const VectorXd Ealpha,size_t n_j) {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".alpha.txt";
	
	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}
	
	for (size_t i=0; i<n_j; i++) {
	outfile<<scientific<<setprecision(6)<<Ealpha(i)<<endl;
	}
	
	outfile.clear();
	outfile.close();
	return;
}

void LDR::WritevbVariance (const double variance) {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".variance.txt";
	
	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}
	
  outfile<<scientific<<setprecision(6)<<variance<<endl;
  
	outfile.clear();
	outfile.close();
	return;
}

void LDR::WritevbELBO (const VectorXd ELBO,size_t n_int) {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".ELBO.txt";
	
	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}
	
		for (size_t i=1; i<=n_int; i++) {
		outfile<<scientific<<setprecision(6)<<i<<"\t"<< ELBO(i)<<endl;
	}
	
	outfile.clear();
	outfile.close();
	return;
}

void LDR::WritegibbsBeta (const VectorXd Ebeta,size_t n_snp) {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".param.txt";
	
	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}
	
	outfile<<"chr"<<"\t"<<"rs"<<"\t"
	<<"ps"<<"\t"<<"n_miss"<<"\t"<<"alpha"<<"\t"
	<<"beta"<<"\t"<<"gamma"<<endl;
	
	size_t t=0;
	for (size_t i=0; i<ns_total; ++i) {
		if (indicator_snp[i]==0) {continue;}
		
		outfile<<snpInfo[i].chr<<"\t"<<snpInfo[i].rs_number<<"\t"
		<<snpInfo[i].base_position<<"\t"<<snpInfo[i].n_miss<<"\t";
		
		outfile<<scientific<<setprecision(6)<<0.0<<"\t";
		outfile<<scientific<<setprecision(6)<<Ebeta(t)<<"\t";
		outfile<<1<<endl;
		t++;
	}
	
	outfile.clear();
	outfile.close();
	return;
}


void LDR::WritegibbsAlpha (const VectorXd Ealpha,size_t n_j) {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".alpha.txt";
	
	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}
	
	for (size_t i=0; i<n_j; i++) {
		outfile<<scientific<<setprecision(6)<<Ealpha(i)<<endl;
	}
	
	outfile.clear();
	outfile.close();
	return;
}


void LDR::WritegibbsVariance (const double variance) {
	string file_str;
	file_str=path_out+"/"+file_out;
	file_str+=".variance.txt";
	
	ofstream outfile (file_str.c_str(), ofstream::out);
	if (!outfile) {cout<<"error writing file: "<<file_str.c_str()<<endl; return;}
	
	outfile<<scientific<<setprecision(6)<<variance<<endl;
	
	outfile.clear();
	outfile.close();
	return;
}


///////////////////////////////////////////
  //////// some functions for LDR ///////////
  ///////////////////////////////////////////
  // function 1: E(log(1-vk))
double sum_Elogvl(const VectorXd lambda_k, const VectorXd kappa_k, size_t k) {
	double sumElogvl = 0;
	if (k==0) sumElogvl = 0;
	else {
		for (size_t j = 0; j<k; j++)	{
		sumElogvl+=gsl_sf_psi(lambda_k(j))-gsl_sf_psi(kappa_k(j)+lambda_k(j));
		}
	}
	return sumElogvl;
}

// function 2: the first term of lambda_k
double sum_lambda_k(const MatrixXd pik_beta, size_t k, size_t n_k) {
	double slambda_k =0;
	if ((k+1)>(n_k-1)) {slambda_k =0;}
	else {
		for (size_t j=k+1; j<n_k-1; j++) {
		slambda_k+=pik_beta.col(j).sum();
		}
	}
	return slambda_k;
}

// function 3: the second term of b_lambda(i.e, sum(Elog(1-vk)))
double sum_b_lambda(const VectorXd lambda_k,const VectorXd kappa_k,size_t n_k) {
	double  sb_lambda=0;
	for (size_t k=0; k<n_k-1; k++) {
		sb_lambda+=gsl_sf_psi(lambda_k(k))-gsl_sf_psi(kappa_k(k)+lambda_k(k));
	}
	return sb_lambda;
}

// function 4
double ELBO1(const VectorXd a_k,const VectorXd b_k,size_t n_k) {
	double  sum_ELBO1=0;
	for (size_t k=0; k<n_k; k++) {
		sum_ELBO1+=lgamma(a_k(k))-a_k(k)*log(b_k(k));
	}
	return sum_ELBO1;
}

// function 5
double ELBO2(const VectorXd kappa_k,const VectorXd lambda_k,size_t n_k) {
	double  sum_ELBO2=0;
	for (size_t k=0; k<n_k-1; k++) {
		sum_ELBO2+=lgamma(kappa_k(k))+lgamma(lambda_k(k))-
		lgamma(kappa_k(k)+lambda_k(k));
	}
	return sum_ELBO2;
}

// function 6
double ELBO3(const MatrixXd pik_beta,const MatrixXd sik2_beta) {
	double  sum_ELBO3=0;
	MatrixXd pik_sik2;
	pik_sik2=((pik_beta.array()+1e-5).array().log()-0.5*sik2_beta.array().log());
	sum_ELBO3=(pik_sik2.array()*pik_beta.array()).sum();
	return sum_ELBO3;
}


//////////////////////////////////////
  //////// Function of VB /////////////
  /////////////////////////////////////
  //void LDR::VB (const vector<vector<unsigned char> > &Xt, const gsl_matrix *W_gsl, const gsl_vector *y_gsl, const gsl_vector *beta, const gsl_vector *Wbeta, const gsl_vector *se_B)
//void LDR::VB (const vector<vector<unsigned char> > &Xt, const gsl_matrix *W_gsl, const gsl_vector *y_gsl, const gsl_vector *beta, const gsl_vector *Wbeta, const gsl_vector *se_B, double lambda) {

//void LDR::VB (const vector<vector<unsigned char> > &Xt, const gsl_matrix *UtX, const gsl_matrix *U, const gsl_vector *eval, const gsl_matrix *W, const gsl_vector *y, const MatrixXd Xt_mixt, const VectorXd sig_subsnp_no, double lambda) {

//setprecision(8); PARAM cPar; clock_t time_start;
////save gsl_vector and gsl_matrix into eigen library formats
////Xt is a p by n matrix and code as 0,1 and 2.
////beta, Wbeta and se_B will be used as initial values.
//cout<<"Now perform the Variational Bayesian analysis..." <<endl;
//size_t n_idv = y->size;
//size_t n_j   = W->size2;
//size_t n_snp = UtX->size2;
//size_t n_snp_mixt = sig_subsnp_no.size(); // number of significant SNPs
//gsl_matrix *UtW = gsl_matrix_alloc (n_idv, n_j);
//gsl_vector *Uty = gsl_vector_alloc (n_idv);
//
//VectorXd y0(n_idv);
//for (size_t i=0; i<n_idv; i++) {y0(i)=gsl_vector_get(y, i);}
//
//CalcUtX (U, W, UtW);
//gsl_matrix *B       = gsl_matrix_alloc (n_idv, n_j); // intercept beta
//gsl_vector *Wbeta   = gsl_vector_alloc (n_j); // intercept beta
//gsl_vector *se_Wbeta= gsl_vector_alloc (n_j);//intercept se
//gsl_matrix *se_B    = gsl_matrix_alloc (n_idv, n_j);//intercept se
//gsl_vector *beta    = gsl_vector_alloc (n_snp);// snp beta
//gsl_vector *H_eval  = gsl_vector_alloc (n_idv);
//gsl_vector *bv      = gsl_vector_alloc (n_idv);
//gsl_vector *muw     = gsl_vector_alloc (n_idv);
//gsl_vector *y_res = gsl_vector_alloc (n_idv); //y0-alpha residual from intercept
//gsl_vector *y_Gb = gsl_vector_alloc (n_idv); //y0-Gb residual from sig SNPs
//gsl_vector_memcpy(y_Gb, y); //y_Gb = y
////
//VectorXd x_col(n_idv);
//VectorXd u_est(n_idv); // estimate for polygenic effects:u
//VectorXd y_u(n_idv);//y0-u
////
//VectorXd xtx(n_snp_mixt); 
//VectorXd xty(n_snp_mixt); 
//VectorXd  ywx_res(n_idv);
//VectorXd   yx_res(n_idv);
//VectorXd   XEbeta(n_idv);
//VectorXd Ebeta(n_snp_mixt);
//VectorXd VarBeta;
//MatrixXd mik_beta  = MatrixXd::Random(n_snp_mixt, n_k);
//MatrixXd sik2_beta = MatrixXd::Random(n_snp_mixt, n_k);
//
//MatrixXd pik_beta = MatrixXd::Zero(n_snp_mixt, n_k);
//pik_beta=pik_beta.array()+(double)1/n_k;
//
//MatrixXd Ebeta2k;
//MatrixXd B1;
//VectorXd Ebeta2;
//VectorXd pikexp1(n_k);
//VectorXd pikexp2(n_k);
//VectorXd index;
//VectorXd a_k = VectorXd::Random(n_k);
//VectorXd b_k = VectorXd::Random(n_k);
//VectorXd  kappa_k;
//kappa_k = pik_beta.colwise().sum();
//VectorXd lambda_k;
//lambda_k = pik_beta.colwise().sum();
//
//cout << endl;
//cout<<"Lambda estimate = " << lambda <<endl;
//cout << endl;
//
////initial values for SNP and
//////each normal component has the same initial values
//for (size_t i=0;i<n_snp_mixt; i++)  {
//	for (size_t k=0;k<n_k; k++)  {
//			mik_beta(i,k) =gsl_vector_get(beta,sig_subsnp_no(i));
//	}
//}
//
//for (size_t i=0;i<n_snp_mixt; i++)  {
//		uchar_matrix_get_row(Xt, sig_subsnp_no(i), x_col);
//		xtx(i) = x_col.dot(x_col);
//	}
//
//XEbeta.setZero();
//for (size_t i=0; i<n_snp_mixt; i++) {
//		uchar_matrix_get_row(Xt, sig_subsnp_no(i), x_col);
//		XEbeta+=x_col*mik_beta(i,0);
//}
//
//double sigma2e0=((y0-XEbeta).cwiseProduct(y0-XEbeta)).sum()/(n_idv-1);
//cout <<"sigma2e0= "<<sigma2e0<<endl;
//double a_e  = (n_idv+n_snp_mixt)/2;
//double b_e  = (a_e-1)*sigma2e0;
//
//double ak   = 11;
//if (lambda < 0.001)        {lambda =  0.001;}
//	else if (lambda > 100) {lambda =  100;}
//		else               {lambda = lambda;}
//double bk0   = lambda*(ak-1)/n_snp_mixt;
//
//VectorXd bk(n_k); bk(0)= bk0;
//for (size_t i=1;i<n_k; i++)  {
//		bk(i) = bk(i-1)*1.7*pow(i,i);
//}
////
//for (size_t i=0;i<n_k; i++)  {
//		cout << bk(i) <<" "<<bk(i)/(ak-1)*sigma2e0<<endl;
//	}
////
//for (size_t i=0;i<n_snp_mixt; i++)  {
//	for (size_t k=0;k<n_k; k++)  {
//		sik2_beta(i,k) = bk(k)/(ak-1)*sigma2e0;
//		}
//}
//
//double ae   = 11;
//double be   = 8;
//double a0   = 400;
//double b0   = 40;
//double a_lambda = a0 + n_k;
//double b_lambda = b0;
//double Elogsigmae, tx_ywx_res, xtxabk, Elogsigmak, Elogvk, sumElogvl, A;
//double delta = 10;
//
//////initial values for a_k and b_k
//Ebeta2k = (mik_beta.cwiseProduct(mik_beta))+sik2_beta;
//Ebeta2k = Ebeta2k.cwiseProduct(pik_beta);
//for (size_t k=0; k<n_k; k++)  {
//		a_k(k)=(pik_beta.col(k).sum())/2 + ak;
//		b_k(k)=Ebeta2k.col(k).sum()*(a_e/b_e)/2+bk(k);
//}
//
//Ebeta=(mik_beta.cwiseProduct(pik_beta)).rowwise().sum();
//clock_t time_begin;time_begin = clock();
//size_t int_step = 0;
//size_t max_step = n_idv*sqrt(10);
////size_t max_step = 5;
//VectorXd ELBO = VectorXd::Zero(max_step);
//
//while ((int_step<max_step) ) {
////while ((int_step<max_step) && (delta > 1e-5)) {
//
//	/// ML estimate the mixed model
//	CalcUtX (U, y_Gb, Uty); //initial value for y_Gb (y_Gb = y0 - Gb) is y
//	CalcLambda ('R', eval, UtW, Uty, cPar.l_min, cPar.l_max, cPar.n_region, cPar.l_remle_null, cPar.logl_remle_H0);
//	//CalcPve (eval, UtW, Uty, cPar.l_remle_null, cPar.trace_G, cPar.pve_null, cPar.pve_se_null);
//	gsl_vector_view xbeta=gsl_matrix_row (B, 0);
//	gsl_vector_view se_xbeta=gsl_matrix_row (se_B, 0);
//	CalcLmmVgVeBeta (eval, UtW, Uty, cPar.l_remle_null, cPar.vg_remle_null, cPar.ve_remle_null, &xbeta.vector, &se_xbeta.vector);
//	for (size_t i=0; i<B->size2; i++) {
//		cPar.beta_remle_null.push_back(gsl_matrix_get(B, 0, i) );
//		cPar.se_beta_remle_null.push_back(gsl_matrix_get(se_B, 0, i) );
//		gsl_vector_set(Wbeta, i, gsl_matrix_get(B, 0, i));
//		gsl_vector_set(se_Wbeta, i, gsl_matrix_get(se_B, 0, i));
//		}
//	gsl_vector_memcpy (y_res, y_Gb);//y_res = y0-Gb
//	gsl_blas_dgemv (CblasNoTrans, -1, W, Wbeta, 0, muw);
//	gsl_vector_add (y_res, muw);//y_res = y0-Gb-intercept
//	CalcUtX (U, y_res, Uty);
//	gsl_vector_memcpy (H_eval, eval);
//	gsl_vector_scale (H_eval, cPar.l_remle_null);
//	gsl_vector_add_constant (H_eval, 1.0);
//	gsl_vector_memcpy (bv, Uty);
//	gsl_vector_div (bv, H_eval);	
//	gsl_blas_dgemv (CblasTrans, cPar.l_remle_null/(double)UtX->size2, UtX, bv, 0.0, beta);
//
//	lambda=cPar.l_remle_null;
//	double ve = cPar.ve_remle_null;
//	double vg = cPar.vg_remle_null;
//	cout<<"intercept= "<<gsl_vector_get(Wbeta,0)<<endl;
//	cout<<"ve = " << ve <<endl;
//	cout<< endl;
//	/// ML estimate the mixed model
//
//	/// obtain the estimate of u
//	u_est.setZero();
//	for (size_t i=0; i<n_snp; i++)   {
//		uchar_matrix_get_row(Xt, i, x_col);
//		u_est+=x_col*gsl_vector_get(beta, i);
//	}
//	u_est = u_est.array() + gsl_vector_get(Wbeta, 0);
//
//	y_u = y0.array()-u_est.array(); // residual from blup; used  for vb as y
//
/////////////////////// variational bayesian   /////////////
//	//Elogsigmae=0.5*(log(b_e)-gsl_sf_psi(a_e));
//	Elogsigmae=-log(sqrt(ve));
//	XEbeta.setZero(); //set to zero
//	// obtain xtx and xty before VB and compute x*beta
//	for (size_t i=0; i<n_snp_mixt; i++)   {
//		uchar_matrix_get_row(Xt, sig_subsnp_no(i), x_col);
//		xty(i) = x_col.dot(y_u);
//		XEbeta+= x_col*Ebeta(i);
//		}
//
//	lambda_k(n_k-1) = 0;
//	double ab_e = a_e/b_e;
//	double ba_e = b_e/a_e;
//	// compute mik, sik and pik
//	for (size_t i=0; i<n_snp_mixt; i++)   {
//		uchar_matrix_get_row(Xt, sig_subsnp_no(i), x_col);
//		XEbeta=XEbeta-x_col*Ebeta(i);
//		tx_ywx_res=x_col.dot(y_u-XEbeta);
//	
//	// n_k components of normal mixture
//		for (size_t k=0; k<n_k; k++)  {
//			xtxabk = xtx(i) + a_k(k)/b_k(k);
//			mik_beta(i,k)  = tx_ywx_res/xtxabk;
//			//sik2_beta(i,k) = ba_e/xtxabk;
//			sik2_beta(i,k) = ve/xtxabk;
//			Elogsigmak     = 0.5*(log(b_k(k))-gsl_sf_psi(a_k(k)));
//
//			//if (k==(n_k-1)) {lambda_k(k) = 0;}
//			Elogvk = gsl_sf_psi(kappa_k(k))-gsl_sf_psi(kappa_k(k)+lambda_k(k));
//			sumElogvl = sum_Elogvl(lambda_k, kappa_k, k);
//			pikexp1(k)= -mik_beta(i,k)*mik_beta(i,k)*(a_k(k)/b_k(k))/(ve*2);
//			pikexp2(k)= -Elogsigmae-Elogsigmak+Elogvk+sumElogvl;
//		}
//		index = pikexp1 + pikexp2;
//		index = (index.array()-index.maxCoeff()).exp();
//		pik_beta.row(i) = index/index.sum();
//		Ebeta(i)=((mik_beta.row(i)).cwiseProduct(pik_beta.row(i))).sum();
//		XEbeta = XEbeta + x_col*Ebeta(i);
//	}
//
//	// for kappa and lambda
//	for (size_t k=0; k<n_k-1; k++)  {
//		 kappa_k(k) = pik_beta.col(k).sum() + 1;
//		lambda_k(k) = sum_lambda_k(pik_beta,k,n_k) + a_lambda/b_lambda;
//	}
//
//	//Ebetak  =  mik_beta.cwiseProduct(pik_beta);
//	Ebeta2k = (mik_beta.cwiseProduct(mik_beta)) + sik2_beta;
//	Ebeta2k =  Ebeta2k.cwiseProduct(pik_beta);
//	
//	// for a_k and b_k
//	for (size_t k=0; k<n_k; k++)  {
//		a_k(k) = (pik_beta.col(k).sum())/2 + ak;
//		b_k(k) = (Ebeta2k.col(k).sum())/(ve*2) + bk(k);
//	}
//
//	// for a_lambda and b_lambda;
//	a_lambda = a0 + n_k;
//	b_lambda = b0 - sum_b_lambda(lambda_k,kappa_k,n_k);
//	
//	ywx_res = y_u - XEbeta;
//
//	for (size_t i=0; i<n_idv; i++)  {
//		gsl_vector_set(y_Gb, i, y0(i) - XEbeta(i));
//	}
//
//	// for a_e and b_e
//	Ebeta2  = Ebeta2k.rowwise().sum();
//	VarBeta = Ebeta2 - Ebeta.cwiseProduct(Ebeta);	
//	A = ywx_res.dot(ywx_res) + (xtx.cwiseProduct(VarBeta)).sum();
//	B1 = (a_k.array()/b_k.array()).rowwise().replicate(n_snp_mixt);
//	Ebeta2k = Ebeta2k.cwiseProduct(B1.transpose());
//	double Be = Ebeta2k.sum();
//	//a_e = (n_idv + n_snp_mixt)/2 + ae;
//	//b_e = 0.5*(A + Be + 2*be);
//	// compute EBLO
//	int_step++;
//	//ELBO(int_step)=(-a_e*log(b_e) +
//	ELBO(int_step)= ELBO1(a_k, b_k, n_k) +
//					ELBO2(kappa_k, lambda_k, n_k) -
//					ELBO3(pik_beta, sik2_beta) +
//					lgamma(a_lambda)-a_lambda*log(b_lambda);
//	delta = abs((ELBO(int_step)-ELBO(int_step-1))/ELBO(int_step));
//	if ((int_step+1)%1==0) {
//		cout<<"ELBO["<<int_step+1<<"] "<<ELBO(int_step)<<" ";
//		cout<<"Lambda estimate = " << lambda <<endl;
//	}
//}
//}


//    
//    /*
//      //output mik and pik
//    ofstream outfile1;
//    ofstream outfile2;
//    ofstream outfile3;
//    ofstream outfile4;
//    outfile1.open ("mik.txt", ios::out | ios::binary);
//    outfile2.open ("pik.txt", ios::out | ios::binary);
//    outfile3.open ("sik.txt", ios::out | ios::binary);
//    outfile4.open ("sigmak.txt", ios::out | ios::binary);
//    
//    for (size_t i = 0; i<n_snp; i++)  {
//      for (size_t k = 0; k<n_k; k++)  {
//        outfile1 << setprecision(4) <<  mik_beta(i,k)<<"\t";
//        outfile2 << setprecision(4) <<  pik_beta(i,k)<<"\t";
//        outfile3 << setprecision(4) << sik2_beta(i,k)<<"\t";
//        outfile4 << setprecision(4) << b_k(k)/a_k(k) <<"\t";
//      }
//      outfile1 << endl;
//      outfile2 << endl;
//      outfile3 << endl;
//      outfile4 << endl;
//    }
//    outfile1.close();
//    outfile2.close();
//    outfile3.close();
//    outfile4.close();
//    //output mik and pik
//    */   
//      
//    cout << "LDR estimated via variational method" << endl;
//    cout << endl;
//    
//    cout << "delta = "<<scientific<<setprecision(6)<<delta << endl;
//    cout << "iteraion count = "<<scientific<<int_step<<endl;
//    cout << "ELBO = "<<scientific<<setprecision(6)<<ELBO(int_step) << endl;
//    
//    cout << endl;
//    cout << "Computaion Time for LDR.VB = "<<(clock()-time_begin)/(double(CLOCKS_PER_SEC)*60.0)<<" min"<<endl;
//    cout << endl;
//    
//    /*
//      for (size_t j=0; j<n_j; j++)   {
//        cout << "alpha[" << j <<"] " << Ealpha(j) << endl;
//      }
//    cout << endl;
//    cout << "residual variance = "<< b_e/(a_e-1) << endl;
//    cout << endl;
//    */
//      
//      /*
//      // estimate LDR_PVE
//    XEbeta.setZero(); //set to zero at begin
//    for (size_t i=0; i<n_snp; i++)   {
//      uchar_matrix_get_row(Xt, i, x_col);
//      XEbeta+=x_col*Ebeta(i);
//    }
//    
//    double LDR_PVE;
//    double mean_xb = XEbeta.sum()/n_idv;
//    double var_xb = 0;
//    
//    for (size_t i=0; i<n_idv; i++)   {
//      var_xb += (XEbeta(i)-mean_xb)*(XEbeta(i)-mean_xb)/n_idv;
//    }
//    */
//      
//      /*
//      LDR_PVE = var_xb/(var_xb+b_e/(a_e-1));
//    cout << "LDR_PVE estimate in the null model =" << LDR_PVE << endl;
//    cout << endl<< endl<< endl;
//    // estimate LDR_PVE
//    */
//      
//      WritevbBeta (Ebeta,n_snp);
//    //WritevbAlpha (Ealpha,n_j);
//    //double variance = b_e/(a_e-1);
//    //WritevbVariance (variance);
//    //WritevbELBO (ELBO,int_step);
//    pheno_mean=Ealpha(0);
//    
//    //gsl_matrix_free(W_gsl);
//    //gsl_vector_free(y_gsl);
//    //gsl_vector_free(beta);
//    //gsl_vector_free(Wbeta);
//    //gsl_vector_free(se_B);
//    
//  }
//}


//////////////////////////////////////////////
  //////////////////////////////////////////////
  //////////////////////////////////////////////
  double sum_Elogvl2(const VectorXd vk, size_t k) {
    double sumElogvl = 0;
    if (k==0) sumElogvl = 0;
    else {
      for (size_t j = 0; j<k; j++)	{
        sumElogvl+=log(1-vk(j));
      }
    }
    return sumElogvl;
  }


void LDR::call_sig_allsnp_no(gsl_matrix *W, vector<double> *sig_subsnp_no, PARAM &cPar)
{
	//PARAM cPar;
	////////////////////////////Fit LM 
	vector<double> lm_pvalue;
	vector<double> lm_beta;
	vector<double> lm_se;
	vector<string> lm_rs;

	gsl_matrix *Y=gsl_matrix_alloc (cPar.ni_test, cPar.n_ph);
	cPar.CopyCvtPhen (W, Y, 0);
	if (cPar.n_ph==1) {
	LM cLm;
	cLm.CopyFromParam(cPar);
	gsl_vector_view Y_col=gsl_matrix_column (Y, 0);
	if (!cPar.file_gene.empty()) {
	cLm.AnalyzeGene (W, &Y_col.vector); 
			}
		else if (!cPar.file_bfile.empty()) {
				cLm.AnalyzePlink (W, &Y_col.vector);
				} 
			else if (!cPar.file_oxford.empty()) {
				cLm.Analyzebgen (W, &Y_col.vector);
					} 
				else {
					cLm.AnalyzeBimbam (W, &Y_col.vector);
					}
	cLm.Call_lm_Pvalue(&lm_pvalue);
	cLm.Call_lm_Beta(&lm_beta);
	cLm.Call_lm_Se(&lm_se);
	cLm.Call_lm_Rs(&lm_rs);
	}
		///Significant SNPs screening
	cout<<endl;
	cout<<"Significant SNPs screening..."<<endl;
	double cutoff=cPar.pcutoff;//lm_pvalue.size()
	VectorXd  sig_index(lm_pvalue.size());
	for (size_t i=0; i<lm_pvalue.size(); ++i) {
		sig_index(i)=(lm_pvalue[i]<cutoff)*1;
		}

	VectorXd sig_allsnp_no(lm_pvalue.size());
	VectorXd sig_subsnp_no_index(sig_index.sum());
	VectorXd nonsig_subsnp_no(lm_pvalue.size()-sig_index.sum());
	VectorXd sig_subsnp_se(sig_index.sum());
	VectorXd nonsig_subsnp_se(lm_pvalue.size()-sig_index.sum());
	int icount1=0;
	int icount2=0;
	for (size_t i=0; i<lm_pvalue.size(); ++i) {
		sig_index(i)=(lm_pvalue[i]<cutoff)*1;
		sig_allsnp_no(i)=sig_index(i)*i;
		//cout<<lm_rs[i]<<"\t";
		//cout<<setprecision(6)<<lm_beta[i]<<"\t"<<lm_se[i];
		//cout<<"\t"<<lm_pvalue[i];
		//cout<<setprecision(0)<<"\t"<<sig_index(i);
		//cout<<"\t"<<sig_allsnp_no(i)<<endl;
		if(((lm_pvalue[i]<cutoff)*1)>0) {
			sig_subsnp_no_index(icount1)=sig_allsnp_no(i);
			sig_subsnp_se(icount1)=lm_se[i];
			icount1++;}
		if(((lm_pvalue[i]<cutoff)*1)==0) {
			nonsig_subsnp_no(icount2)=i;
			nonsig_subsnp_se(icount2)=lm_se[i];
			icount2++;}
		}
		cout<<"number of analyzed polygenic SNPs = "<<setprecision(0)<<lm_pvalue.size()-sig_index.sum()<<endl;
		cout<<"number of analyzed mixture SNPs   = "<<setprecision(0)<<sig_index.sum()<<endl;
		cout<<setprecision(6)<<endl;
		///Significant SNPs screening
		for (size_t i=0; i<(size_t)sig_subsnp_no_index.size(); ++i) {
			//cout <<sig_subsnp_no_index(i)<<endl;
			//(*sig_subsnp_no)(i) = sig_subsnp_no_index(i);
			(*sig_subsnp_no).push_back(sig_subsnp_no_index(i));
			}
	sig_index.resize(0);
	sig_allsnp_no.resize(0);
	sig_subsnp_no_index.resize(0);
	nonsig_subsnp_no.resize(0);
	sig_subsnp_se.resize(0);
	nonsig_subsnp_se.resize(0);
	gsl_matrix_free(Y);
}




void LDR::call_sig_index(gsl_matrix *W, vector<double> *sig_index, PARAM &cPar)
{
	//PARAM cPar;
	////////////////////////////Fit LM 
	vector<double> lm_pvalue;
	vector<double> lm_beta;
	vector<double> lm_se;
	vector<string> lm_rs;
	gsl_matrix *Y=gsl_matrix_alloc (cPar.ni_test, cPar.n_ph);
	cPar.CopyCvtPhen (W, Y, 0);
	if (cPar.n_ph==1) {
	LM cLm;
	cLm.CopyFromParam(cPar);
	gsl_vector_view Y_col=gsl_matrix_column (Y, 0);
	if (!cPar.file_gene.empty()) {
	cLm.AnalyzeGene (W, &Y_col.vector); 
			}
		else if (!cPar.file_bfile.empty()) {
				cLm.AnalyzePlink (W, &Y_col.vector);
				} 
			else if (!cPar.file_oxford.empty()) {
				cLm.Analyzebgen (W, &Y_col.vector);
					} 
				else {
					cLm.AnalyzeBimbam (W, &Y_col.vector);
					}
	cLm.Call_lm_Pvalue(&lm_pvalue);
	cLm.Call_lm_Beta(&lm_beta);
	cLm.Call_lm_Se(&lm_se);
	cLm.Call_lm_Rs(&lm_rs);
	}
		///Significant SNPs screening
	double cutoff=cPar.pcutoff;//lm_pvalue.size()
	VectorXd  sig_index0(lm_pvalue.size());
	for (size_t i=0; i<lm_pvalue.size(); ++i) {
		sig_index0(i)=(lm_pvalue[i]<cutoff)*1;
		}

	VectorXd sig_allsnp_no(lm_pvalue.size());
	VectorXd sig_subsnp_no_index(sig_index0.sum());
	VectorXd nonsig_subsnp_no(lm_pvalue.size()-sig_index0.sum());
	VectorXd sig_subsnp_se(sig_index0.sum());
	VectorXd nonsig_subsnp_se(lm_pvalue.size()-sig_index0.sum());
	int icount1=0;
	int icount2=0;
	for (size_t i=0; i<lm_pvalue.size(); ++i) {
		sig_index0(i)=(lm_pvalue[i]<cutoff)*1;
		sig_allsnp_no(i)=sig_index0(i)*i;
		//cout<<lm_rs[i]<<"\t";
		//cout<<setprecision(6)<<lm_beta[i]<<"\t"<<lm_se[i];
		//cout<<"\t"<<lm_pvalue[i];
		//cout<<setprecision(0)<<"\t"<<sig_index0(i);
		//cout<<"\t"<<sig_allsnp_no(i)<<endl;
		if(((lm_pvalue[i]<cutoff)*1)>0) {
			sig_subsnp_no_index(icount1)=sig_allsnp_no(i);
			sig_subsnp_se(icount1)=lm_se[i];
			icount1++;}
		if(((lm_pvalue[i]<cutoff)*1)==0) {
			nonsig_subsnp_no(icount2)=i;
			nonsig_subsnp_se(icount2)=lm_se[i];
			icount2++;}
		}
	///Significant SNPs screening
	for (size_t i=0; i<(size_t)sig_index0.size(); ++i) {
		//(*sig_index)(i) = sig_index0(i);
		(*sig_index).push_back(sig_index0(i));
		}

	sig_index0.resize(0);
	sig_allsnp_no.resize(0);
	sig_subsnp_no_index.resize(0);
	nonsig_subsnp_no.resize(0);
	sig_subsnp_se.resize(0);
	nonsig_subsnp_se.resize(0);
	gsl_matrix_free(Y);
}

void Eigen_matrix_get_row (const gsl_matrix *X, const size_t i_col, VectorXd &x_col)
{
  if (i_col < X->size2) {
    for (size_t j=0; j < (size_t)x_col.size(); j++) {
      x_col(j)=gsl_matrix_get(X,j,i_col);
    }
  } else {
    std::cerr << "Error return genotype vector...\n";
    exit(1);
  }
}

//permutation the snp label
VectorXd permute(size_t n_snp)  {
	VectorXd snp_label (n_snp);
	long int randseed;
	gsl_rng *gsl_r;
	time_t rawtime;
	time (&rawtime);
	tm * ptm = gmtime (&rawtime);
	randseed = (unsigned) (ptm->tm_hour%24*3600+ptm->tm_min*60+ptm->tm_sec);
	const gsl_rng_type * gslType;
	gslType = gsl_rng_default; 
	gsl_r = gsl_rng_alloc(gslType); 
	gsl_rng_set(gsl_r, randseed);
	gsl_permutation * perm = gsl_permutation_alloc (n_snp);
	gsl_permutation_init (perm);
	gsl_ran_shuffle (gsl_r, perm->data, n_snp, sizeof(size_t));
	for (size_t i = 0; i<n_snp; i++)	{
		snp_label(i) = perm->data[i];
	}
	return snp_label;
}


//UtX should be in gsl_matrix form, 
//since it is needed to compute the polygentic effects

void LDR::Gibbs1 (const gsl_matrix *UtX, const VectorXd Uty, const MatrixXd UtW,const VectorXd D, const VectorXd Wbeta0, const VectorXd se_Wbeta0, const VectorXd beta0, double lambda) 
{
	
	setprecision(5); 
	clock_t time_begin  = clock();
	clock_t time_begin1 = clock();
	size_t n_snp = UtX->size2;
	size_t n_idv = Uty.size();
	size_t n_j   = UtW.cols();
	VectorXd x_col(n_idv);

	VectorXd xtx(n_snp); 
	VectorXd xty(n_snp); 
	VectorXd wtw(n_j);		 
	VectorXd wty(n_j);
	VectorXd Utu = VectorXd::Zero(n_idv);
	VectorXd Ue(n_idv);
	VectorXd Ub(n_idv);
	VectorXd bv0 = VectorXd::Zero(n_idv); //for computation of alpha
	VectorXd bv  = VectorXd::Zero(n_idv); //for computation of alpha
	VectorXd V = VectorXd::Zero (n_idv);//compute Utu 
	VectorXd M = VectorXd::Zero (n_idv);//compute Utu
	VectorXd snp_label(n_snp);

	VectorXd Ealpha      = Wbeta0;//intercept
	VectorXd post_Ealpha = VectorXd::Zero(n_j);//save intercept
	VectorXd m_alpha     = Wbeta0;
	VectorXd s2_alpha    = se_Wbeta0.array()*se_Wbeta0.array();

	VectorXd WEalpha(n_idv); 
	double   sigma2e=0, lambdax;
	VectorXd XEbeta(n_idv); //G*beta
	VectorXd Ebeta(n_snp);
	VectorXd post_Ebeta(n_snp);//save beta
	MatrixXd Ebeta2k;
	MatrixXd B1;
	MatrixXd mik_beta = MatrixXd::Zero(n_snp, n_k);

	for (size_t i=0;i<n_snp; i++)  {
		Eigen_matrix_get_row (UtX, i, x_col);
		xtx(i) = x_col.dot(x_col);
		xty(i) = x_col.dot(Uty);
	}

	for (size_t j=0;j<n_j; j++)  {
		wtw(j) = UtW.col(j).dot(UtW.col(j));
		wty(j) = UtW.col(j).dot(Uty);
	}

	//// initial values for SNP and each normal
	//// component has the same initial values
	for (size_t i=0;i<n_snp; i++)  {
		for (size_t k=1;k<n_k; k++)  {
			mik_beta(i,k) = beta0(i);
	}
	}

	mik_beta.col(0).fill(0);
	MatrixXd sik2_beta  =(MatrixXd::Random(n_snp, n_k)).array().abs();
	MatrixXd pik_beta   = MatrixXd::Zero  (n_snp, n_k);
	pik_beta = pik_beta.array() + (double)1/n_k;

	//MatrixXd beta_beta  = mik_beta;
	MatrixXd beta_beta  = MatrixXd::Zero(n_snp, n_k);
	MatrixXd gamma_beta = MatrixXd::Zero(n_snp, n_k);
	MatrixXd post_gamma_beta = gamma_beta;
	MatrixXd post_pik_beta   = gamma_beta;
	gamma_beta = gamma_beta.array() + (double)1/n_k;

	VectorXd sigma2k (n_k);
	VectorXd vk (n_k);
	VectorXd Elogsigmak (n_k);
	VectorXd Elogvk (n_k);
	VectorXd sumElogvl (n_k);

	VectorXd pikexp1(n_k);
	VectorXd pikexp2(n_k);
	VectorXd index;
	VectorXd a_k = (VectorXd::Random(n_k)).array().abs();
	VectorXd b_k = (VectorXd::Random(n_k)).array().abs();
	VectorXd  kappa_k = pik_beta.colwise().sum();
	VectorXd lambda_k = (VectorXd::Random(n_k)).array().abs();

	XEbeta.setZero();//set to zero
	for (size_t i=0; i<n_snp; i++)   {
		Eigen_matrix_get_row (UtX, i, x_col);
		XEbeta += x_col*beta0(i);
		}

	WEalpha.setZero(); //set to zero
	for (size_t j=0;j<n_j; j++)   {
		WEalpha += UtW.col(j)*m_alpha(j);
		}

	VectorXd y_res  = Uty - WEalpha - XEbeta;
	double sigma2e0 = ((y_res).dot(y_res))/(n_idv-1);
	//cout << endl << "sigma2e0 = " << sigma2e0 << endl;
	cout << endl << endl;
	double a_e  = (2*n_idv + n_snp)/2;
	double b_e  = (a_e-1)*sigma2e0;

	double ak   = 21;
	if (lambda < 0.01)     {lambda =    0.01;}
	else if (lambda > 100) {lambda =     100;}
	else                   {lambda =  lambda;}
	double bk0  = lambda*(ak-1)/n_snp;

	VectorXd bk(n_k);
	bk(0) = bk0;
	for (size_t i=1;i<n_k; i++)  {
		bk(i) = bk(i-1)*1.7*sqrt(pow(i,i));
		}

	for (size_t i=0;i<n_snp; i++)  {
		for (size_t k=0;k<n_k; k++)  {
			sik2_beta(i,k) = bk(k)/(ak-1)*sigma2e0;
		}
		}

	double ae   = 0.1;
	double be   = 0.1;
	double a0   = 400;
	double b0   = 40;
	double a_lambda = a0 + n_k;
	double b_lambda = b0;
	double tx_ywx_res, xtxabk, A;
	double sigma2b = 0.001;
	double Gne = 0, Gn;

	////initial values for a_k, b_k and sigma2k
	Ebeta2k = (mik_beta.cwiseProduct(mik_beta)) + sik2_beta;
	for (size_t k=0; k<n_k; k++)  {
		a_k(k) = (pik_beta.col(k).sum())/2 + ak;
		b_k(k) = (Ebeta2k.col(k).sum())*(a_e/b_e)/2 + bk(k);
		sigma2k(k) = b_k(k)/(a_k(k)-1);
		}

	A = (y_res).dot(y_res);
	B1=(1/sigma2k.array()).rowwise().replicate(n_snp);
	B1.col(0).fill(0);

	Ebeta2k = Ebeta2k.cwiseProduct(B1.transpose());
	double B = Ebeta2k.sum();
	a_e = n_idv + n_snp*0.1 + ae;
	b_e = (A + B + 2*be)/2;
	////random seed
	gsl_rng * rs = gsl_rng_alloc (gsl_rng_mt19937);

	//WritelmmBeta(beta0,n_snp);
	if (n_k == 1)   {
		WritegibbsBeta (beta0,n_snp);
		pheno_mean = m_alpha(0);
		}

	// //  begin Gibbs sampling
	else {
	for (size_t S=0; S<(w_step+s_step); S++)   { 

		sigma2e    = 1/gsl_ran_gamma(rs,a_e,1/b_e);

		// save Ebeta for the mixture normal component
		Ebeta = (beta_beta.cwiseProduct(gamma_beta)).rowwise().sum();		
		if (S > (w_step-1))   {
			post_Ebeta += Ebeta;
			}

		//sample sigma2k and compute related quantities
		for (size_t k=0; k<n_k; k++)   {
			if (k==0) {
				sigma2k(k)    = 0; 
				Elogsigmak(k) = 0;
				}

			else {
				sigma2k(k)    = 1/gsl_ran_gamma(rs,a_k(k),1/b_k(k));
				Elogsigmak(k) = log(sqrt(sigma2k(k)));
				}

				if (k == (n_k-1)) {vk(k) = 0; Elogvk(k) = 0;}
				else {
					vk(k)     = gsl_ran_beta(rs,kappa_k(k),lambda_k(k));
					Elogvk(k) = log(vk(k));
				}
				sumElogvl(k)  = sum_Elogvl2(vk,k);
			}

		//////////////  sampling the mixture snp effects 
		XEbeta.setZero(); //set Gbeta to zero first
			for (size_t i=0; i<n_snp; i++)   {
				Eigen_matrix_get_row (UtX, i, x_col);
				XEbeta += x_col*Ebeta(i);
		}

		if (S < (w_step+s_step)*tp)  {
		y_res.setZero();
		y_res = Uty - WEalpha - Utu;
		for (size_t i=0; i<n_snp; i++)   {
			Eigen_matrix_get_row (UtX, i, x_col);
			XEbeta    -= x_col*Ebeta(i);
			tx_ywx_res = x_col.dot(y_res - XEbeta);
			for (size_t k=0; k<n_k; k++)   {				
				if (k == 0) {
					mik_beta(i,k)  = 0; 
					sik2_beta(i,k) = 0; 
					pikexp1(k)     = 0;
					}
				else {
					xtxabk         = xtx(i) + 1/sigma2k(k);
					//xtxabk         = xtx(i) + sigma2e/sigma2k(k);
					mik_beta(i,k)  = tx_ywx_res/xtxabk;
					sik2_beta(i,k) = sigma2e/xtxabk;
					pikexp1(k)     = pow(mik_beta(i,k),2)/(2*sik2_beta(i,k)) + log(sqrt(sik2_beta(i,k))) - log(sqrt(sigma2e)) - Elogsigmak(k);
					//pikexp1(k)     = pow(mik_beta(i,k),2)/(2*sik2_beta(i,k)) + log(sqrt(sik2_beta(i,k))) - Elogsigmak(k);
				}
				beta_beta(i,k) = gsl_ran_gaussian(rs,sqrt(sik2_beta(i,k))) + mik_beta(i,k);
				pikexp2(k)     = Elogvk(k) + sumElogvl(k);
				}
			index = pikexp1 + pikexp2;
			index = (index.array() - index.maxCoeff()).exp();
			pik_beta.row(i) = index/index.sum();

		// multinomial sampling
		double mult_prob[n_k];
		unsigned int mult_no[n_k];
		for (size_t k=0; k<n_k; k++)   {
			mult_prob[k] = pik_beta(i,k);
			}
		gsl_ran_multinomial(rs, n_k, 1, mult_prob, mult_no);
		for (size_t k=0; k<n_k; k++)   {
			gamma_beta(i,k) = mult_no[k];
		}
		// multinomial sampling

		Ebeta(i) = ((beta_beta.row(i)).dot(gamma_beta.row(i)));
		XEbeta  += x_col*Ebeta(i);
		}
		}

		else  {
		y_res.setZero();
		snp_label = permute(n_snp);
		y_res = Uty - WEalpha - Utu;
		size_t tx = 0, count = 0, i;
		gamma_beta.setZero();
		while (count < n_snp*sp)  {
			i = snp_label(tx);
			Eigen_matrix_get_row (UtX, i, x_col);
			XEbeta    -= x_col*Ebeta(i);
			tx_ywx_res = x_col.dot(y_res - XEbeta);
			for (size_t k=0; k<n_k; k++)   {				
				if (k == 0) {
					mik_beta(i,k)  = 0; 
					sik2_beta(i,k) = 0; 
					pikexp1(k)     = 0;
					}
				else {
					xtxabk         = xtx(i) + 1/sigma2k(k);
					//xtxabk         = xtx(i) + sigma2e/sigma2k(k);
					mik_beta(i,k)  = tx_ywx_res/xtxabk;
					sik2_beta(i,k) = sigma2e/xtxabk;
					pikexp1(k)     = pow(mik_beta(i,k),2)/(2*sik2_beta(i,k)) + log(sqrt(sik2_beta(i,k))) - log(sqrt(sigma2e)) - Elogsigmak(k);
					//pikexp1(k)     = pow(mik_beta(i,k),2)/(2*sik2_beta(i,k)) + log(sqrt(sik2_beta(i,k))) - Elogsigmak(k);
				}
				beta_beta(i,k) = gsl_ran_gaussian(rs,sqrt(sik2_beta(i,k))) + mik_beta(i,k);
				pikexp2(k)     = Elogvk(k) + sumElogvl(k);
				}
			index = pikexp1 + pikexp2;
			index = (index.array() - index.maxCoeff()).exp();
			pik_beta.row(i) = index/index.sum();

		// multinomial sampling
		double mult_prob[n_k];
		unsigned int mult_no[n_k];
		for (size_t k=0; k<n_k; k++)   {
			mult_prob[k] = pik_beta(i,k);
			}
		gsl_ran_multinomial(rs, n_k, 1, mult_prob, mult_no);
		for (size_t k=0; k<n_k; k++)   {
			gamma_beta(i,k) = mult_no[k];
		}
		// multinomial sampling

		Ebeta(i) = ((beta_beta.row(i)).dot(gamma_beta.row(i)));
		XEbeta  += x_col*Ebeta(i);
		tx++;
		count = gamma_beta.rightCols(n_k-1).sum();
		}
		}

		if (S > (w_step-1))   {
			post_gamma_beta += gamma_beta;
			post_pik_beta   += pik_beta;
			}
		//////////////  sampling the mixture snp effects 

		WEalpha.setZero();
		for (size_t j=0;j<n_j; j++)   {
			WEalpha += UtW.col(j)*Ealpha(j);
		}

		y_res.setZero();
		y_res = Uty - XEbeta - Utu;
		for (size_t j=0;j<n_j; j++)   {
			WEalpha    -= UtW.col(j)*Ealpha(j);
			m_alpha(j)  = 1/wtw(j)*(UtW.col(j).dot(y_res - WEalpha));
			s2_alpha(j) = sigma2e/wtw(j);
			Ealpha(j)   = m_alpha(j) + gsl_ran_gaussian(rs,sqrt(s2_alpha(j)));
			WEalpha    += UtW.col(j)*Ealpha(j);
			}

		if (S>(w_step-1))   {
			post_Ealpha += Ealpha;
			}

		a_lambda = a0 + n_k;
		b_lambda = b0 - sum_Elogvl2(vk,n_k-1);
		lambdax  = gsl_ran_gamma(rs,a_lambda,1/b_lambda);

		for (size_t k=0; k<n_k-1; k++)   {
			kappa_k(k)  = gamma_beta.col(k).sum() + 1;
			lambda_k(k) = sum_lambda_k(gamma_beta,k,n_k) + lambdax;
			}

		Ebeta2k = beta_beta.cwiseProduct(beta_beta).cwiseProduct(gamma_beta);
		for (size_t k=0; k<n_k; k++)   {
			a_k(k) = (gamma_beta.col(k).sum())/2 + ak;
			b_k(k) = (Ebeta2k.col(k).sum())/(2*sigma2e) + bk(k);
			//b_k(k) = (Ebeta2k.col(k).sum())/(2) + bk(k);
			}

		y_res.setZero();
		y_res = Uty - XEbeta - WEalpha;
		for (size_t i=0; i<n_idv; i++) {
			V(i)  = sigma2b*D(i)/(sigma2b*D(i) + 1);
			M(i)  = y_res(i)*V(i);
			Utu(i)= M(i) + gsl_ran_gaussian(rs,sqrt(V(i)*sigma2e));
			//Utu(i)= M(i) + gsl_ran_gaussian(rs,sqrt(V(i)));
			if (D(i)  == 0) {
				Ue(i) = 0; 
				Ub(i) = 0;
				}
			else {
				Ue(i) = Utu(i)/(sigma2b*D(i)); //for sigma2e
				Ub(i) = Utu(i)/(sigma2e*D(i)); //for sigma2b
				//Ub(i) = Utu(i)/(D(i)); //for sigma2b
			}
			bv0(i) = y_res(i)*sigma2b/(sigma2b*D(i) + 1); 
			}

		if (S>(w_step-1))   {
			bv += bv0;
			}

		A  = (y_res-Utu).dot(y_res-Utu);
		B1 = (1/sigma2k.tail(n_k-1).array()).rowwise().replicate(n_snp);
		Ebeta2k   = Ebeta2k.rightCols(n_k-1).cwiseProduct(B1.transpose());
		double B  = Ebeta2k.sum();

		if (S<(w_step+s_step)*tp)  {
			Gn   = gamma_beta.rightCols(n_k-1).sum();
			Gne += Gn;
			a_e  = n_idv + 0.5*Gn + ae;
			//a_e  = n_idv + ae;
		}

		else {
			a_e  = n_idv + 0.5*Gne/((w_step+s_step)*tp) + ae;
		}

		b_e = (A + B + Ue.dot(Utu) + 2*be)/2;
		sigma2b = 1/gsl_ran_gamma(rs,n_idv/2+ae,1/(2*Ub.dot(Utu))+be);
		////////////////////////////////////

		cout<<S+1<<setprecision(4)<<"  "<<Gn<<"  "<<Gne/((w_step+s_step)*0.1)<<" "<<sigma2e<<endl;
		size_t xstep = (s_step + w_step)*0.1;
		if (S%xstep==0||S==(s_step + w_step-1)) {ProgressBar ("Gibbs sampling ", S, s_step+w_step-1);}
		}
	}

	/*cout<<endl;cout<<endl;
	for (size_t i=0; i<n_snp; i++) {
			for (size_t j=0; j<n_k; j++) {
				cout<<setprecision(4)<<post_gamma_beta(i,j)/s_step<<"    ";
				//cout<<setprecision(4)<<post_pik_beta(i,j)/s_step<<"    ";
			}
			cout<<endl;
	}*/
	
	cout<<endl<<endl<<"Gibbs sampling is finished";
	cout<<" and now compute the polygenic effects ..."<<endl;
	time_begin1 = clock();
	gsl_vector *gsl_bv    = gsl_vector_alloc (n_idv);
	gsl_vector *gsl_alpha = gsl_vector_alloc (n_snp);
	gsl_vector_set_zero (gsl_bv);
	VectorXd eigen_alpha = VectorXd::Zero (n_snp);
	for (size_t i=0; i<n_idv; i++) {
		gsl_vector_set (gsl_bv, i, bv(i)/s_step);
	}

	gsl_blas_dgemv (CblasTrans,1.0/(double)n_snp,UtX,gsl_bv,0.0,gsl_alpha);
	for (size_t i = 0; i < n_snp; i++) {
		eigen_alpha(i) = gsl_vector_get(gsl_alpha, i);
		}

	cout<<"Time for computing polygenic effects is "<<(clock()-time_begin1)/(double(CLOCKS_PER_SEC)*60.0)<<" mins"<<endl;

	WritegibbsBeta (eigen_alpha+post_Ebeta/s_step, n_snp);
	pheno_mean = post_Ealpha(0)/s_step;

	cout << endl;
	cout << "Computaion Time for LDR.Gibbs = ";
	cout << (clock()-time_begin)/(double(CLOCKS_PER_SEC)*60.0)<<" min"<<endl;
	cout << endl;

	////////////
	xtx.resize(0);
	xty.resize(0);
	wtw.resize(0);
	wty.resize(0);
	Utu.resize(0);
	Ue.resize(0);
	Ub.resize(0);
	bv0.resize(0);
	bv.resize(0);
	V.resize(0);
	M.resize(0);
	Ealpha.resize(0);
	post_Ealpha.resize(0);
	m_alpha.resize(0);
	s2_alpha.resize(0);
	WEalpha.resize(0);
	XEbeta.resize(0);
	Ebeta.resize(0);
	post_Ebeta.resize(0);
	Ebeta2k.resize(0,0);
	B1.resize(0,0);
	mik_beta.resize(0,0);
	sik2_beta.resize(0,0);
	pik_beta.resize(0,0);
	beta_beta.resize(0,0);
	gamma_beta.resize(0,0);
	sigma2k.resize(0);
	vk.resize(0);
	Elogsigmak.resize(0);
	Elogvk.resize(0);
	sumElogvl.resize(0);
	pikexp1.resize(0);
	pikexp2.resize(0);
	index.resize(0);
	a_k.resize(0);
	b_k.resize(0);
	kappa_k.resize(0);
	lambda_k.resize(0);
	y_res.resize(0);
	bk.resize(0);
	gsl_vector_free (gsl_bv);
	gsl_vector_free (gsl_alpha);
	eigen_alpha.resize(0);

}







