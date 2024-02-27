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
#include "io.h"
#include "bmm.h"

#ifdef WITH_LAPACK
#include "lapack.h"
#endif

using namespace std;





void BMM::CopyFromParam (PARAM &cPar)
{
  display_pace=cPar.display_pace;
  ng_test=cPar.ng_test;

  vec_h=cPar.vec_h;
  vb=cPar.vb;
  h_scale=cPar.h_scale;
  sigma_u2_sd=cPar.sigma_u2_sd;

  w_step=cPar.w_step;
  s_step=cPar.s_step;
  n_mh=cPar.n_mh;
  randseed=cPar.randseed;

  time_eigen=cPar.time_eigen;
  time_mv=cPar.time_mv;
  time_s_z=cPar.time_s_z;
  time_s_mw=cPar.time_s_mw;
  time_s_h=cPar.time_s_h;
  time_s_bau=cPar.time_s_bau;

  return;
}


void BMM::CopyToParam (PARAM &cPar)
{
  cPar.ng_test=ng_test;
  cPar.sumPost=sumPost;
  cPar.indicator_gene=indicator_gene;

  cPar.time_eigen=time_eigen;
  cPar.time_mv=time_mv;
  cPar.time_s_z=time_s_z;
  cPar.time_s_mw=time_s_mw;
  cPar.time_s_h=time_s_h;
  cPar.time_s_bau=time_s_bau;

  return;
}


//map a number 1-(n_cvt+2) to an index between 0 and [(n_c+2)^2+(n_c+2)]/2-1
size_t GetIndex (const size_t a, const size_t b, const size_t n_cvt) {
	if (a>n_cvt+2 || b>n_cvt+2 || a<=0 || b<=0) {cout<<"error in GetIndex."<<endl; return 0;}
	size_t index;
	size_t l, h;
	if (b>a) {l=a; h=b;} else {l=b; h=a;}

	size_t n=n_cvt+2;
	index=(2*n-l+2)*(l-1)/2+h-l;

	return index;
}



//Sampling Binomial distribution below:


//omit y instead of x
void CalcUabBMM (const size_t n_cvt, const gsl_matrix *UtW, const gsl_vector *Utx, gsl_matrix *Uab)
{
	size_t index_ab;
	gsl_vector *u_a=gsl_vector_alloc (UtW->size1);
	gsl_vector *u_b=gsl_vector_alloc (UtW->size1);

	for (size_t a=1; a<=n_cvt+2; a++) {
		if (a==n_cvt+2) {continue;}

		if (a==n_cvt+1) {
			gsl_vector_memcpy (u_a, Utx);
		}
		else {
			gsl_vector_const_view UtW_col=gsl_matrix_const_column (UtW, a-1);
			gsl_vector_memcpy (u_a, &UtW_col.vector);
		}

		for (size_t b=a; b<=n_cvt+2; b++) {
			if (b==n_cvt+2) {continue;}

			index_ab=GetIndex(a, b, n_cvt);

			if (b==n_cvt+1) {
				gsl_vector_memcpy (u_b, Utx);
			}
			else {
				gsl_vector_const_view UtW_col=gsl_matrix_const_column (UtW, b-1);
				gsl_vector_memcpy (u_b, &UtW_col.vector);
			}

			gsl_vector_view Uab_col=gsl_matrix_column (Uab, index_ab);
			gsl_vector_memcpy(&Uab_col.vector, u_a);
			gsl_vector_mul(&Uab_col.vector, u_b);
		}
	}

	gsl_vector_free (u_a);
	gsl_vector_free (u_b);

	return;
}


void CalcUabBMM (const size_t n_cvt, const gsl_matrix *UtW, const gsl_vector *Utx, const gsl_vector *Uty, gsl_matrix *Uab)
{
	size_t index_ab;
	gsl_vector *u_b=gsl_vector_alloc (UtW->size1);

	for (size_t b=1; b<=n_cvt+2; b++) {
		index_ab=GetIndex(n_cvt+2, b, n_cvt);

		if (b==n_cvt+1) {
			gsl_vector_memcpy (u_b, Utx);
		}
		else if (b==n_cvt+2) {
			gsl_vector_memcpy (u_b, Uty);
		}
		else {
			gsl_vector_const_view UtW_col=gsl_matrix_const_column (UtW, b-1);
			gsl_vector_memcpy (u_b, &UtW_col.vector);
		}

		gsl_vector_view Uab_col=gsl_matrix_column (Uab, index_ab);
		gsl_vector_memcpy(&Uab_col.vector, Uty);
		gsl_vector_mul(&Uab_col.vector, u_b);
	}

	gsl_vector_free (u_b);
	return;
}





void CalcDabBMM (const size_t n_cvt, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *Di, gsl_vector *ab)
{
	size_t index_ab;
	double f;
	gsl_vector *v_a=gsl_vector_alloc (W->size1);
	gsl_vector *v_b=gsl_vector_alloc (W->size1);
	gsl_vector *v=gsl_vector_alloc (W->size1);

	for (size_t a=1; a<=n_cvt+2; a++) {
		if (a==n_cvt+2) {continue;}

		if (a==n_cvt+1) {gsl_vector_memcpy (v_a, x);}
		else {
			gsl_vector_const_view W_col=gsl_matrix_const_column (W, a-1);
			gsl_vector_memcpy (v_a, &W_col.vector);
		}

		for (size_t b=a; b<=n_cvt+2; b++) {
			if (b==n_cvt+2) {continue;}

			index_ab=GetIndex (a, b, n_cvt);

			if (b==n_cvt+1) {gsl_vector_memcpy (v_b, x);}
			else {
				gsl_vector_const_view W_col=gsl_matrix_const_column (W, b-1);
				gsl_vector_memcpy (v_b, &W_col.vector);
			}

			gsl_vector_memcpy(v, v_a);
			gsl_vector_mul(v, Di);
			gsl_blas_ddot (v, v_b, &f);
			gsl_vector_set(ab, index_ab, f);
		}
	}

	gsl_vector_free (v_a);
	gsl_vector_free (v_b);
	gsl_vector_free (v);
	return;
}


void CalcDabBMM (const size_t n_cvt, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *y, const gsl_vector *Di, gsl_vector *ab)
{
	size_t index_ab;
	double f;
	gsl_vector *v_b=gsl_vector_alloc (W->size1);
	gsl_vector *v=gsl_vector_alloc (W->size1);

	for (size_t b=1; b<=n_cvt+2; b++) {
		index_ab=GetIndex (n_cvt+2, b, n_cvt);

		if (b==n_cvt+2) {
			gsl_vector_memcpy(v_b, y);
		} else if (b==n_cvt+1) {
		       	gsl_vector_memcpy (v_b, x);
		} else {
		  gsl_vector_const_view W_col=gsl_matrix_const_column (W, b-1);
		  gsl_vector_memcpy (v_b, &W_col.vector);
		}

		gsl_vector_memcpy(v, y);
		gsl_vector_mul(v, Di);
		gsl_blas_ddot (v, v_b, &f);
		gsl_vector_set(ab, index_ab, f);
	}

	gsl_vector_free (v_b);
	gsl_vector_free (v);
	return;
}




void CalcPabBMM (const size_t n_cvt, const double sigma_b2, const gsl_vector *Hi_eval, const gsl_vector *ab, const gsl_matrix *Uab, gsl_matrix *Pab)
{
	size_t index_ab, index_aw, index_bw, index_ww;
	double p_ab;
	double ps_ab, ps_aw=0.0, ps_bw=0.0, ps_ww;
	/*
	cout<<"Hi_eval: "<<endl;
	for (size_t i=0; i<Hi_eval->size; i++) {
	  cout<<gsl_vector_get(Hi_eval, i)<<endl;
	}
	*/
	for (size_t p=0; p<=n_cvt+1; p++) {
		//calculate Pab11
	  //cout<<p<<endl;
		for (size_t a=p+1; a<=n_cvt+2; a++) {
			for (size_t b=a; b<=n_cvt+2; b++) {
				index_ab=GetIndex(a, b, n_cvt);
				if (p==0) {
				  gsl_vector_const_view Uab_col=gsl_matrix_const_column (Uab, index_ab);
				  gsl_blas_ddot (Hi_eval, &Uab_col.vector, &p_ab);
				  //p_ab=gsl_vector_get (ab, index_ab)-p_ab;
				  gsl_matrix_set (Pab, 0, index_ab, p_ab);
				} else {
					index_aw=GetIndex (a, p, n_cvt);
					index_bw=GetIndex (b, p, n_cvt);
					index_ww=GetIndex (p, p, n_cvt);

					ps_ww=gsl_matrix_get (Pab, p-1, index_ww);
					if (p==n_cvt+1) {ps_ww+=1.0/sigma_b2;}

					ps_ab=gsl_matrix_get (Pab, p-1, index_ab);
					ps_aw=gsl_matrix_get (Pab, p-1, index_aw);
					ps_bw=gsl_matrix_get (Pab, p-1, index_bw);

					p_ab=ps_ab-ps_aw*ps_bw/ps_ww;
					gsl_matrix_set (Pab, p, index_ab, p_ab);
				}
				//cout<<p_ab<<" ";
			}
			//cout<<endl;
		}
	}


	return;
}



double BMM::ProposeHyper (const class HYPPAR &cHyp_old, class HYPPAR &cHyp_new)
{
  int h_id=cHyp_old.h_id, sb_id=cHyp_old.sb_id;
	double log_sigma_u2=log(cHyp_old.sigma_u2);
	size_t gamma=cHyp_old.gamma;

	/*
	if ((int)gsl_ran_bernoulli (gsl_r, h_prob*2.0)==1) {
		h_id+=(int)gsl_ran_bernoulli (gsl_r, 0.5)*2-1;
	}
	if (h_id<0) {h_id=vec_h.size()-1;}
	if (h_id>vec_h.size()-1) {h_id=0;}
	*/

	//sample h_id
	if (vec_h.size()!=1) {
		int d_h=(int)((double)vec_h.size()*h_scale);
		//cout<<"ProposeHyper::d_h before="<<d_h<<endl;

		if (d_h<2) {d_h=2;}
		h_id+=(int)gsl_rng_uniform_int (gsl_r, d_h)*((int)gsl_ran_bernoulli (gsl_r, 0.5)*2-1);
		//cout<<"ProposeHyper::d_h="<<d_h<<endl;
		//cout<<"PorposeHyper::h_id="<<h_id<<endl;

		if (h_id<0) {h_id=-1*h_id;}
		if (h_id>(int)vec_h.size()-1) {h_id=2*(int)vec_h.size()-2-h_id;}
	}

	/*
	//sample sigma_b2 id
	if (vec_sb.size()!=1) {
		sb_id+=(int)gsl_rng_uniform_int (gsl_r, 1)*((int)gsl_ran_bernoulli (gsl_r, 0.5)*2-1);
		if (sb_id<0) {sb_id=-1*sb_id;}
		if (sb_id>(int)vec_sb.size()-1) {sb_id=2*(int)vec_sb.size()-2-sb_id;}
	}
	*/

	//sample sigma_u2
	double d;
	do {
	  d=log_sigma_u2+gsl_ran_gaussian (gsl_r, sigma_u2_sd);
	} while (abs(d)>5);
	log_sigma_u2=d;

	//if (pi_beta==0) {gamma=0;} else if (pi_beta==1) {gamma=1;} else {gamma=gsl_ran_bernoulli (gsl_r, 0.5);}
	gamma=1;

	cHyp_new.h_id=h_id;
	cHyp_new.sb_id=sb_id;
	cHyp_new.sigma_u2=exp(log_sigma_u2);
	cHyp_new.gamma=gamma;

	/*
	if (vec_sb.size()!=1) {
		cHyp_new.sigma_b2=vec_sb[sb_id]*cHyp_new.sigma_u2;
	} else {
		cHyp_new.sigma_b2=vec_sb[sb_id];
	}
	*/
	cHyp_new.sigma_b2=vb;

	//cout<<h_scale<<" "<<sigma_u2_sd<<" "<<cHyp_new.sigma_b2<<" "<<cHyp_new.gamma<<" "<<cHyp_new.sigma_u2<<" "<<cHyp_new.h_id<<" "<<endl;

	return log(cHyp_new.sigma_u2)-log(cHyp_old.sigma_u2);
}



void BMM::MCMCInitial (const vector<size_t> &y, const gsl_vector *log_N, class HYPPAR &cHyp, gsl_vector *log_lambda)
{
	cHyp.h_id=vec_h.size()/2;
	//cHyp.sb_id=vec_sb.size()/2;
	cHyp.sigma_u2=1.0;
	//cHyp.sigma_b2=vec_sb[cHyp.sb_id];
	cHyp.sigma_b2=vb;

	//if (pi_beta==0) {cHyp.gamma=0;} else {cHyp.gamma=1;}
	cHyp.gamma=1;

	double f=0.0;

	  for (size_t i=0; i<y.size(); i++) {
	    if (y[i]==0) {
	      f=1.0/exp(gsl_vector_get(log_N, i));
	    } else {
	      f=y[i]/exp(gsl_vector_get(log_N, i));
	    }

	    if (f>0.99) {
	      f=log(99);
	    } else {
	      f=log(f)-log(1-f);
	    }
	    gsl_vector_set (log_lambda, i, f);
	    //cout<<y[i]<<"\t"<<exp(gsl_vector_get(log_N, i))<<"\t"<<f<<endl;
	  }


	return;
}






double BMM::CalcPosteriorBMM (const gsl_vector *H_eval, const gsl_matrix *Pab, const class HYPPAR &cHyp)
{
	double logdet_h, logdet_hiw, P_yy, logp;
	size_t index_ww;
	double f=0.0;

	//|I+sigma_u2*Dh|
	logdet_h=0.0;
	for (size_t i=0; i<H_eval->size; ++i) {
		f=gsl_vector_get (H_eval, i);
		logdet_h+=log(f);
	}

	//calculate |WHiW| (not -|WtW|)
	logdet_hiw=0.0;
	for (size_t i=0; i<n_cvt; ++i) {
		index_ww=GetIndex (i+1, i+1, n_cvt);
		f=gsl_matrix_get (Pab, i, index_ww);
		logdet_hiw+=log(f);
//		d=gsl_matrix_get (Iab, i, index_ww);
//		logdet_hiw-=log(d);
	}

	//calculate |Omega_b*sigma_b2| if gamma==1
	if (cHyp.gamma==1) {
		index_ww=GetIndex (n_cvt+1, n_cvt+1, n_cvt);
		f=gsl_matrix_get (Pab, n_cvt, index_ww);
		f*=cHyp.sigma_b2;
		f+=1.0;
		logdet_hiw+=log(f);
		//cout<<log(f)<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_ww)<<endl;
	}

	//calculate Pzz
	index_ww=GetIndex (n_cvt+2, n_cvt+2, n_cvt);
	if (cHyp.gamma==0) {
		P_yy=gsl_matrix_get (Pab, n_cvt, index_ww);
		//cout<<"gamma=0: "<<P_yy<<endl;
	}
	else {
		P_yy=gsl_matrix_get (Pab, n_cvt+1, index_ww);
		//cout<<"gamma=1: "<<P_yy<<endl;
	}
	//cout<<"logPosterior: "<<logdet_h<<" "<<logdet_hiw<<" "<<P_yy<<endl;
	logp=-0.5*logdet_h-0.5*logdet_hiw-0.5*P_yy;
	/*
	if (vec_sb.size()!=1) {
	  if (pi_beta==0 || pi_beta==1) {
	    logp+=-1.0*log(cHyp.sigma_u2);
	  } else {
	    logp+=cHyp.gamma*log(pi_beta)+(1-cHyp.gamma)*log(1-pi_beta)-log(cHyp.sigma_u2);
	  }
	}
	*/
	//logp+=-log(cHyp.sigma_u2);//for macau1, log(sigma_u2)~U(0,1)

	return logp;
}



void BMM::UpdateUabBMM (const size_t h_id, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *U_mat, const gsl_vector *z, gsl_matrix *Utz, gsl_matrix *Uab)
{
	clock_t time_start=clock();

	gsl_vector_view Utz_col=gsl_matrix_column (Utz, h_id);
	gsl_matrix_const_view U_sub=gsl_matrix_const_submatrix (U_mat, 0, h_id*UtW->size1, UtW->size1, UtW->size1);
	gsl_blas_dgemv (CblasTrans, 1.0, &U_sub.matrix, z, 0.0, &Utz_col.vector);
	time_mv+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);

	gsl_vector_const_view Utx_sub=gsl_matrix_const_column (Utx, h_id);
	gsl_vector_const_view Utz_sub=gsl_matrix_const_column (Utz, h_id);
	gsl_matrix_const_view UtW_sub=gsl_matrix_const_submatrix (UtW, 0, h_id*n_cvt, UtW->size1, n_cvt);

	gsl_matrix_view Uab_sub=gsl_matrix_submatrix (Uab, 0, h_id*(n_cvt+2+1)*(n_cvt+2)/2, UtW->size1, (n_cvt+2+1)*(n_cvt+2)/2 );
	CalcUabBMM (n_cvt, &UtW_sub.matrix, &Utx_sub.vector, &Utz_sub.vector, &Uab_sub.matrix);

	return;
}




void BMM::UpdatePabBMM (const class HYPPAR &cHyp, const gsl_matrix *Uab, const gsl_vector *eval, const gsl_vector *ab, gsl_vector *H_eval, gsl_vector *Hi_eval, gsl_matrix *Pab)
{
	gsl_vector_memcpy (H_eval, eval);
	gsl_vector_scale (H_eval, cHyp.sigma_u2);
    gsl_vector_add_constant (H_eval, 1.0);

//	gsl_vector_memcpy (Hi_eval, H_eval);
    gsl_vector_set_all (Hi_eval, 1.0);
	gsl_vector_div (Hi_eval, H_eval);

	gsl_matrix_const_view Uab_sub=gsl_matrix_const_submatrix (Uab, 0, cHyp.h_id*(n_cvt+2+1)*(n_cvt+2)/2, eval->size, (n_cvt+2+1)*(n_cvt+2)/2 );
	CalcPabBMM (n_cvt, cHyp.sigma_b2, Hi_eval, ab, &Uab_sub.matrix, Pab);

	return;
}




void BMM::EigenProcBMM (const gsl_matrix *K, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *Di, gsl_matrix *Uh_mat, gsl_matrix *Eval_h, gsl_matrix *UtW, gsl_matrix *Utx)
{
	clock_t time_start;

	gsl_vector *Dsqrt=gsl_vector_alloc (W->size1);		//Di sqrt
	gsl_vector *eval=gsl_vector_alloc (W->size1);
	gsl_matrix *B_temp=gsl_matrix_alloc (W->size1, W->size1);
	gsl_matrix *Vh=gsl_matrix_alloc (W->size1, W->size1);
	gsl_matrix *Uh=gsl_matrix_alloc (W->size1, W->size1);

	double f=0.0;

	//calculate Dsqrt

	for (size_t i=0; i<Dsqrt->size; i++) {
		f=gsl_vector_get (Di, i);
		f=sqrt(f);
		gsl_vector_set (Dsqrt, i, f);
	}
    /*
    cout<<"vec_h is: "<<endl;
	for (size_t i=0; i<vec_h.size(); i++) {
		cout<<vec_h[i]<<" ";
	}
    cout<<endl;

	cout<<"Dsqrt is: "<<endl;
	for (size_t i=0; i<Dsqrt->size; i++) {
		cout<<gsl_vector_get (Dsqrt, i)<<endl;
	}

    cout<<"K: "<<endl;
    for (size_t i=0; i<5; i++) {
        for (size_t j=0; j<5; j++) {
            cout<<gsl_matrix_get(K, i, j)<<" ";
        }
        cout<<endl;
    }
    */
	//calculate Vh, eigen-decomposition, and UtW, Utx
	for (size_t i=0; i<vec_h.size(); i++) {
//		cout<<vec_h[i]<<endl;
		gsl_matrix_memcpy (Vh, K);
		gsl_matrix_scale (Vh, vec_h[i]);
		gsl_matrix_memcpy (B_temp, B);
		gsl_matrix_scale (B_temp, 1-vec_h[i]);
		gsl_matrix_add (Vh, B_temp);

		for (size_t j=0; j<W->size1; j++) {
			f=gsl_vector_get (Dsqrt, j);
			gsl_vector_view Vh_row=gsl_matrix_row (Vh, j);
			gsl_vector_scale (&Vh_row.vector, f);
			gsl_vector_view Vh_col=gsl_matrix_column (Vh, j);
			gsl_vector_scale (&Vh_col.vector, f);
		}

		gsl_vector_view eval_col=gsl_matrix_column (Eval_h, i);



//		gsl_matrix_set_zero(U1);
		time_start=clock();
		lapack_double_eigen_symmv (Vh, eval, Uh);
		/*
		cout<<"eval is: "<<endl;
		for (size_t j=0; j<eval->size; j++) {
			cout<<gsl_vector_get (eval, j)<<endl;
		}
		*/
        for (size_t j=0; j<eval->size; j++) {
            f=gsl_vector_get(eval,j);
            if (f<0) {f=0; gsl_vector_set(eval, j, f);}
        }
	/*
	cout<<"eval is: "<<endl;
		for (size_t j=0; j<eval->size; j++) {
			cout<<gsl_vector_get (eval, j)<<endl;
		}

        if (i==0) {
            cout<<"B: "<<endl;
            for (size_t j=0; j<5; j++) {
                for (size_t k=0; k<5; k++) {
                    cout<<gsl_matrix_get(B, j, k)<<" ";
                }
                cout<<endl;
            }
            cout<<"Vh: "<<endl;
            for (size_t j=0; j<5; j++) {
                for (size_t k=0; k<5; k++) {
                    cout<<gsl_matrix_get(Vh, j, k)<<" ";
                }
                cout<<endl;
            }
            cout<<"eval: "<<endl;
            for (size_t j=0; j<eval->size; j++) {
                cout<<gsl_vector_get(eval, j)<<" ";
            }
            cout<<endl;
        }
		*/
//		lapack_eigen_fdf (Vh, eval, U1);

		time_eigen+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);

		gsl_vector_memcpy (&eval_col.vector, eval);



		//calculate U1, U2 and Uh
		for (size_t j=0; j<W->size1; j++) {
			f=gsl_vector_get (Dsqrt, j);
			gsl_vector_view Uh_row=gsl_matrix_row (Uh, j);
			gsl_vector_scale (&Uh_row.vector, f);
		}
		gsl_matrix_view Uh_sub=gsl_matrix_submatrix (Uh_mat, 0, i*W->size1, W->size1, W->size1);
		gsl_matrix_memcpy (&Uh_sub.matrix, Uh);

		//calculate UtW, Utx
		time_start=clock();

		gsl_vector_view Utx_col=gsl_matrix_column (Utx, i);
		gsl_blas_dgemv (CblasTrans, 1.0, Uh, x, 0.0, &Utx_col.vector);
		/*
		if (i==0) {
		  cout<<"x: "<<endl;
        for (size_t k=0; k<W->size1; k++) {
            cout<<gsl_vector_get(x, k)<<" ";
        }
        cout<<endl;
	cout<<"h: "<<vec_h[i]<<endl;
        cout<<"Utx: "<<endl;
        for (size_t k=0; k<W->size1; k++) {
            cout<<gsl_vector_get(&Utx_col.vector, k)<<" ";
        }
        cout<<endl;
		}
		*/
		for (size_t j=0; j<n_cvt; j++) {
			gsl_vector_const_view W_col=gsl_matrix_const_column (W, j);
			gsl_vector_view UtW_col=gsl_matrix_column (UtW, i*n_cvt+j);
			gsl_blas_dgemv (CblasTrans, 1.0, Uh, &W_col.vector, 0.0, &UtW_col.vector);
            /*
            cout<<"UtW: "<<endl;
            for (size_t k=0; k<W->size1; k++) {
                cout<<gsl_vector_get(&UtW_col.vector, k)<<" ";
            }
            cout<<endl;
            */
		}



		time_mv+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);
	}

	gsl_vector_free(Dsqrt);
	gsl_vector_free(eval);
	gsl_matrix_free(B_temp);
	gsl_matrix_free(Vh);
	gsl_matrix_free(Uh);

	return;
}


void BMM::SampleZBMM (const vector<size_t> &N, const vector<size_t> &y, const gsl_vector *log_lambda, gsl_vector *z)
{
  double tau=0.0, d;
    //cout<<"z: ";
  for (size_t i=0; i<log_lambda->size; i++) {
    d=exp(gsl_vector_get(log_lambda, i));

    if (N[i]==0) {
      tau=0.0;
    } else if (y[i]==N[i]) {
      tau=gsl_ran_gamma (gsl_r, N[i], 1)/(1+d);
    } else {
      tau=gsl_ran_gamma (gsl_r, N[i], 1)/(1+d);
      tau+=gsl_ran_gamma (gsl_r, N[i]-y[i], 1)/d;
    }

    //cout<<tau<<" "<<-1*log(tau)<<" "<<d<<" ";
    if (tau!=0.0) {tau=-1*log(tau);}

    gsl_vector_set (z, i, tau);
  }
  //cout<<endl;

  return;
}




//sample mean, weight, and update z
void BMM::SampleMWBMM (const vector<size_t> &N, const gsl_vector *log_lambda, const gsl_matrix *weight, const gsl_matrix *mean, const gsl_vector *sigmasq, gsl_vector *z)
{
	double p[10];
	unsigned int n[10];
	double w, m=0, f, l, s, p_max=0.0;
	size_t sample_flag=0;

	for (size_t i=0; i<log_lambda->size; i++) {
		//sample m1, w1, and update z1
		l=gsl_vector_get (log_lambda, i);
		f=gsl_vector_get (z, i);

		if (N[i]==0) {m=0;}
		else {
			sample_flag=0;
			p_max=0.0;
			s=gsl_vector_get (sigmasq, i);
			for (size_t j=0; j<10; j++) {
				w=gsl_matrix_get (weight, i, j);
				if (w==0) {continue;}

				m=gsl_matrix_get (mean, i, j);

				p[j]=-0.5*(f-l-m)*(f-l-m)/s;
				if (j==0) {p_max=p[j];}
				else if (p_max<p[j]) {p_max=p[j];}

				sample_flag++;
			}

			if (sample_flag>1) {
				for (size_t j=0; j<10; j++) {
					w=gsl_matrix_get (weight, i, j);
					if (w==0) {p[j]=0; continue;}			//use continue here
					p[j]=exp(p[j]-p_max);
					p[j]*=w;
				}
				gsl_ran_multinomial (gsl_r, 10, 1, p, n);
				for (size_t j=0; j<10; j++) {
					if (n[j]==1) {m=gsl_matrix_get (mean, i, j); break;}
				}
			}
		}

		gsl_vector_set (z, i, f-m);
	}

	return;
}



void BMM::SampleHyperBMM (const gsl_matrix *Eval_h, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *U_mat, const gsl_vector *z, const gsl_vector *ab, gsl_matrix *Utz, gsl_matrix *Uab, gsl_matrix *Pab, class HYPPAR &cHyp)
{
	double logMHratio=0.0, logPost_old=0.0, logPost_new=0.0;

	class HYPPAR cHyp_new;

	gsl_matrix *Pab_new=gsl_matrix_alloc (n_cvt+2, (n_cvt+2+1)*(n_cvt+2)/2);
	gsl_vector *Hi_eval=gsl_vector_alloc(UtW->size1);
	gsl_vector *H_eval=gsl_vector_alloc(UtW->size1);

	gsl_matrix_set_zero (Pab_new);

	vector<size_t> indicator_h;
	for (size_t i=0; i<vec_h.size(); i++) {
		indicator_h.push_back(0);
	}

	//initial
	indicator_h[cHyp.h_id]=1;
	UpdateUabBMM (cHyp.h_id, UtW, Utx, U_mat, z, Utz, Uab);

	gsl_vector_const_view eval=gsl_matrix_const_column (Eval_h, cHyp.h_id);
	UpdatePabBMM (cHyp, Uab, &eval.vector, ab, H_eval, Hi_eval, Pab);

	logPost_old=CalcPosteriorBMM (H_eval, Pab, cHyp);

	//cout<<"old h:"<<cHyp.h_id<<"\t"<<vec_h[cHyp.h_id]<<"\t"<<logPost_old<<endl;

	for (size_t i=0; i<n_mh; i++) {
		logMHratio=0.0;
		logMHratio+=ProposeHyper (cHyp, cHyp_new);

		//if necessary, calculate Utz, and update Uab
		if (indicator_h[cHyp_new.h_id]==0) {
			indicator_h[cHyp_new.h_id]=1;
			UpdateUabBMM (cHyp_new.h_id, UtW, Utx, U_mat, z, Utz, Uab);
		}

		gsl_vector_const_view eval=gsl_matrix_const_column (Eval_h, cHyp_new.h_id);
		UpdatePabBMM (cHyp_new, Uab, &eval.vector, ab, H_eval, Hi_eval, Pab_new);

		logPost_new=CalcPosteriorBMM (H_eval, Pab_new, cHyp_new);
		//cout<<"old:"<<logPost_old<<"\t"<<cHyp.h_id<<"\t"<<vec_h[cHyp.h_id]<<"\t"<<cHyp.gamma<<"\t"<<cHyp.sigma_b2<<"\t"<<cHyp.sigma_u2<<endl;
		//cout<<"new:"<<logPost_new<<"\t"<<cHyp_new.h_id<<"\t"<<vec_h[cHyp_new.h_id]<<"\t"<<cHyp_new.gamma<<"\t"<<cHyp_new.sigma_b2<<"\t"<<cHyp_new.sigma_u2<<endl;

		logMHratio+=logPost_new-logPost_old;
		if (logMHratio>0 || log(gsl_rng_uniform(gsl_r))<logMHratio) {
		  //cout<<"old = "<<logPost_old<<"\t"<<cHyp.gamma<<"\t"<<cHyp.sigma_b2<<"\t"<<cHyp.sigma_u2<<endl;
		  //cout<<"new = "<<logPost_new<<"\t"<<cHyp_new.gamma<<"\t"<<cHyp_new.sigma_b2<<"\t"<<cHyp_new.sigma_u2<<endl;

			logPost_old=logPost_new;
			cHyp=cHyp_new;
			gsl_matrix_memcpy (Pab, Pab_new);
			n_accept++;

			/*
			double p_ab=0;
			size_t index_ab=FindIndex(1, 2, n_cvt);
			gsl_vector_const_view Uab_col=gsl_matrix_const_column (Uab, index_ab+(n_cvt+2)*(n_cvt+2)*1);
			gsl_blas_ddot (Hi_eval, &Uab_col.vector, &p_ab);
			cout<<"sigma_u2 = "<<cHyp_new.sigma_u2<<", sigma_b2 = "<<cHyp_new.sigma_b2<<", p_ab = "<<p_ab<<endl;
			cout<<"accept :"<<cHyp.h_id<<"\t"<<logPost_old<<endl;
			*/

		}

	}

	gsl_matrix_free(Pab_new);
	gsl_vector_free(Hi_eval);
	gsl_vector_free(H_eval);

	return;
}




void BMM::SampleBAUBMM (const class HYPPAR &cHyp, const gsl_matrix *Eval_h, const gsl_matrix *Pab, const gsl_matrix *Uh_mat, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *Utz, double &beta, vector<double> &alpha, gsl_vector *u)
{
	gsl_vector *u_prime=gsl_vector_alloc (Eval_h->size1);

	size_t index_xz, index_xx;
	size_t index_xw, index_zw, index_ww;

	double f;
	double P_xx, P_xz, P_zr;
	double P_xw, P_zw, P_ww;

	beta=0.0;
	gsl_vector_set_zero(u);
	alpha.clear();
	for (size_t i=0; i<n_cvt; i++) {
		alpha.push_back(0.0);
	}

	/*
	cout<<"Pab11 is: "<<endl;
	for (size_t i=0; i<3; i++) {
		for (size_t j=0; j<9; j++) {
			cout<<gsl_matrix_get (Pab, i, j)<<"\t";
		}
		cout<<endl;
	}
	cout<<"Pab22 is: "<<endl;
	for (size_t i=0; i<3; i++) {
		for (size_t j=9; j<9*2; j++) {
			cout<<gsl_matrix_get (Pab, i, j)<<"\t";
		}
		cout<<endl;
	}
	cout<<"Pab12 is: "<<endl;
	for (size_t i=0; i<3; i++) {
		for (size_t j=9*2; j<9*3; j++) {
			cout<<gsl_matrix_get (Pab, i, j)<<"\t";
		}
		cout<<endl;
	}
	*/
	//sample beta
	if (cHyp.gamma==0) {beta=0.0;}
	else {
		index_xz=GetIndex (n_cvt+1, n_cvt+2, n_cvt);
		P_xz=gsl_matrix_get (Pab, n_cvt, index_xz);

		index_xx=GetIndex (n_cvt+1, n_cvt+1, n_cvt);
		P_xx=gsl_matrix_get (Pab, n_cvt, index_xx);
		P_xx+=1.0/cHyp.sigma_b2;

		beta=P_xz/P_xx+gsl_ran_gaussian (gsl_r, sqrt(1.0/P_xx) );
		//cout<<"beta: "<<beta<<"\t"<<P_xz<<"\t"<<P_xx<<endl;
		//cout<<"sigma_b2: "<<cHyp.sigma_b2<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_xx)<<endl;
	}



	//sample alpha
	for (size_t i=n_cvt; i>=1; i--) {
		index_xw=GetIndex (i, n_cvt+1, n_cvt);
		P_xw=gsl_matrix_get (Pab, i-1, index_xw);

		index_zw=GetIndex (i, n_cvt+2, n_cvt);
		P_zw=gsl_matrix_get (Pab, i-1, index_zw);

		P_zr=P_zw-P_xw*beta;
		for (size_t j=i+1; j<=n_cvt; j++) {
			index_ww=GetIndex (j, i, n_cvt);
			P_ww=gsl_matrix_get (Pab, i-1, index_ww);

			P_zr-=P_ww*alpha[j-1];
		}

		index_ww=GetIndex (i, i, n_cvt);
		P_ww=gsl_matrix_get (Pab, i-1, index_ww);


		alpha[i-1]=P_zr/P_ww+gsl_ran_gaussian (gsl_r, sqrt(1.0/P_ww) );
		//cout<<"alpha: "<<alpha[i-1]<<"\t"<<P_zr<<"\t"<<P_ww<<"\t"<<P_zw<<"\t"<<P_xw<<"\t"<<beta<<endl;
	}
	/*
	cout<<"P_xz = "<<P_xz<<endl;
	cout<<"P_xx = "<<P_xx<<endl;
	cout<<"P_zw = "<<P_zw<<endl;
	cout<<"P_xw = "<<P_xw<<endl;
	cout<<"P_ww = "<<P_ww<<endl;
	cout<<"P_zr = "<<P_zr<<endl;
	*/
	//sample u
	gsl_vector_const_view Utx_col=gsl_matrix_const_column (Utx, cHyp.h_id);
	gsl_vector_const_view Utz_col=gsl_matrix_const_column (Utz, cHyp.h_id);
	gsl_matrix_const_view Uh_sub=gsl_matrix_const_submatrix (Uh_mat, 0, cHyp.h_id*UtW->size1, UtW->size1, UtW->size1);

	gsl_vector_memcpy (u_prime, &Utx_col.vector);
	gsl_vector_scale (u_prime, -1.0*beta);

	gsl_vector_add (u_prime, &Utz_col.vector);

	for (size_t i=0; i<n_cvt; i++) {
		gsl_vector_const_view UtW_col=gsl_matrix_const_column (UtW, cHyp.h_id*n_cvt+i);
		gsl_blas_daxpy (-1.0*alpha[i], &UtW_col.vector, u_prime);
		//cout<<"u_prime: "<<alpha[i]<<" "<<gsl_vector_get(&Utz_col.vector, 13)<<" "<<gsl_vector_get(&UtW_col.vector, 13)<<" "<<gsl_vector_get(&Utx_col.vector, 13)<<" "<<gsl_vector_get(u_prime, 13)<<endl;
		//cout<<beta<<" "<<alpha[i]<<endl;
	}
	//cout<<"u_prime: ";
	for (size_t i=0; i<UtW->size1; i++) {
		f=gsl_matrix_get (Eval_h, i, cHyp.h_id);
		f*=cHyp.sigma_u2;
		f=f/(1+f);
		//if (i==13) {
		//cout<<cHyp.sigma_u2<<" "<<gsl_matrix_get (Eval_h, i, cHyp.h_id)<<" "<<gsl_vector_get (u_prime, i)<<" "<<f<<" ";
		//}
		f=gsl_vector_get (u_prime, i)*f+gsl_ran_gaussian (gsl_r, sqrt(f) );
		gsl_vector_set (u_prime, i, f);

	}
	//cout<<endl;

	clock_t time_start=clock();

	gsl_blas_dgemv (CblasNoTrans, 1.0, &Uh_sub.matrix, u_prime, 0.0, u);

	time_mv+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);

	gsl_vector_free(u_prime);

	return;
}






//MCMC to run Binomial Mixed Model
void BMM::MCMCRunBMM (const vector<size_t> &N, const vector<size_t> &y, const gsl_matrix *K, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *Di, const gsl_matrix *weight, const gsl_matrix *mean, const gsl_vector *sigmasq, gsl_vector *epsilon, class POSTMEAN &cPostM)
{
	clock_t time_start;

	//set up matrices, and calculate basic quantities
	gsl_matrix *Uh_mat=gsl_matrix_alloc (W->size1, W->size1*vec_h.size());
	gsl_matrix *Eval_h=gsl_matrix_alloc (W->size1, vec_h.size());

	gsl_matrix *UtW=gsl_matrix_alloc (W->size1, vec_h.size()*n_cvt );
	gsl_matrix *Utx=gsl_matrix_alloc (W->size1, vec_h.size());
	gsl_matrix *Utz=gsl_matrix_alloc (W->size1, vec_h.size());

	gsl_vector *log_lambda=gsl_vector_alloc (W->size1);
	gsl_vector *z=gsl_vector_alloc (W->size1);
	gsl_vector *u=gsl_vector_alloc (W->size1);
	gsl_vector_set_zero(u);
	gsl_vector *ab=gsl_vector_alloc ((n_cvt+2+1)*(n_cvt+2)/2);
	gsl_matrix *Uab=gsl_matrix_alloc (W->size1, (n_cvt+2+1)*(n_cvt+2)*vec_h.size()/2 );
	gsl_matrix *Pab=gsl_matrix_alloc (n_cvt+2, (n_cvt+2+1)*(n_cvt+2)/2);

	gsl_matrix *W_temp=gsl_matrix_alloc (W->size1, W->size2);

	gsl_vector *log_N=gsl_vector_alloc (W->size1);

	gsl_vector_set_zero (log_N);
	for (size_t i=0; i<log_N->size; i++) {
	  if (N[i]!=0) {gsl_vector_set(log_N, i, log(N[i]) );}
	}
	vector<double> beta_samples, h_samples, sigma_u2_samples, vec_tmp;
	vector<vector<double > > alpha_samples;

	vec_tmp.push_back(0);
	for (size_t i=0; i<W->size2; i++) {
	  alpha_samples.push_back(vec_tmp);
	}
	vec_tmp.clear();

	//calculate basic quantities
	EigenProcBMM (K, B, W, x, Di, Uh_mat, Eval_h, UtW, Utx);

	//calculate ab and Uab
	CalcDabBMM (n_cvt, W, x, Di, ab);
	for (size_t i=0; i<vec_h.size(); i++) {
		gsl_vector_const_view Utx_sub=gsl_matrix_const_column (Utx, i);
		gsl_matrix_const_view UtW_sub=gsl_matrix_const_submatrix (UtW, 0, i*n_cvt, W->size1, n_cvt);
		gsl_matrix_view Uab_sub=gsl_matrix_submatrix (Uab, 0, i*(n_cvt+2+1)*(n_cvt+2)/2, W->size1, (n_cvt+2+1)*(n_cvt+2)/2 );
		CalcUabBMM (n_cvt, &UtW_sub.matrix, &Utx_sub.vector, &Uab_sub.matrix);
	}

	//initial parameters to zero
	double beta=0.0;
	vector<double> alpha;

	for (size_t i=0; i<W->size2; i++) {
		alpha.push_back(0.0);
	}
	gsl_vector_set_zero(epsilon);

	//initial MCMC parameters
	class HYPPAR cHyp;
	MCMCInitial(y, log_N, cHyp, log_lambda);

	//start MCMC
	for (size_t t=0; t<(w_step+s_step); t++) {
	  //for (size_t t=0; t<1; t++) {
		//sample tau, and update z
		time_start=clock();
		SampleZBMM (N, y, log_lambda, z);
		/*
		cout<<"u: "<<endl;
		for (size_t i=0; i<z->size; i++) {
		  cout<<gsl_vector_get(u, i)<<endl;
		}

		cout<<"log_lambda: "<<endl;
		for (size_t i=0; i<z->size; i++) {
		  cout<<gsl_vector_get(log_lambda, i)<<endl;
		}

		cout<<"samplez, z: "<<endl;
		for (size_t i=0; i<z->size; i++) {
		  cout<<gsl_vector_get(z, i)<<endl;
		}
		*/
		time_s_z+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);

		//sample mean and weights, and update z
		time_start=clock();
		SampleMWBMM (N, log_lambda, weight, mean, sigmasq, z);
		time_s_mw+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);
		/*
		cout<<"sampleMW, z: "<<endl;
		for (size_t i=0; i<z->size; i++) {
		  cout<<gsl_vector_get(z, i)<<endl;
		}
		*/
		//update ab, but not Uab
		CalcDabBMM (n_cvt, W, x, z, Di, ab);

		//sample hyp-parameters, within which update Uab and Pab if necessary
		time_start=clock();
		SampleHyperBMM (Eval_h, UtW, Utx, Uh_mat, z, ab, Utz, Uab, Pab, cHyp);
		time_s_h+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);

		/*
		cout<<"ab11 = "<<endl;
		for (size_t a=0; a<(n_cvt+2)*(n_cvt+2); a++) {
			cout<<gsl_vector_get(ab, a)<<endl;
		}
		cout<<"ab22 = "<<endl;
		for (size_t a=(n_cvt+2)*(n_cvt+2); a<(n_cvt+2)*(n_cvt+2)*2; a++) {
			cout<<gsl_vector_get(ab, a)<<endl;
		}

		cout<<"sigma_u2: "<<cHyp.sigma_u2<<endl;
		cout<<"h_id: "<<cHyp.h_id<<endl;

		cout<<"Pab11 = "<<endl;
		for (size_t a=0; a<Pab->size1; a++) {
			for (size_t b=0; b<(n_cvt+2)*(n_cvt+2); b++) {
				cout<<gsl_matrix_get(Pab, a, b)<<"\t";
			}
			cout<<endl;
		}
		cout<<"Pab22 = "<<endl;
		for (size_t a=0; a<Pab->size1; a++) {
			for (size_t b=(n_cvt+2)*(n_cvt+2); b<(n_cvt+2)*(n_cvt+2)*2; b++) {
				cout<<gsl_matrix_get(Pab, a, b)<<"\t";
			}
			cout<<endl;
		}
		cout<<"Pab12 = "<<endl;
		for (size_t a=0; a<Pab->size1; a++) {
			for (size_t b=(n_cvt+2)*(n_cvt+2)*2; b<(n_cvt+2)*(n_cvt+2)*3; b++) {
				cout<<gsl_matrix_get(Pab, a, b)<<"\t";
			}
			cout<<endl;
		}
		*/
		//sample beta, alpha and u
		time_start=clock();
		SampleBAUBMM (cHyp, Eval_h, Pab, Uh_mat, UtW, Utx, Utz, beta, alpha, u);
		gsl_vector_div(u, Di);
		time_s_bau+=(clock()-time_start)/(double(CLOCKS_PER_SEC)*60.0);

		//cout<<"beta = "<<beta<<endl;

		if (fabs(beta)<1e-10) {beta=0; cHyp.gamma=0;}

		//save results
		if (t>=w_step) {
			if (cHyp.gamma==1) {
				cPostM.beta+=beta;
				cPostM.gamma+=1.0;

				beta_samples.push_back(beta);
			}
			cPostM.h+=vec_h[cHyp.h_id];
			cPostM.sigma_u2+=cHyp.sigma_u2;

			h_samples.push_back(vec_h[cHyp.h_id]);
			sigma_u2_samples.push_back(cHyp.sigma_u2);

			for (size_t i=0; i<alpha.size(); i++) {
			  cPostM.alpha[i]+=alpha[i];

			  if (t==w_step) {
			    alpha_samples[i][0]=alpha[i];
			  } else {
			    alpha_samples[i].push_back(alpha[i]);
			  }
			}
			//cout<<beta<<"\t"<<alpha[0]<<"\t"<<cHyp.sigma_b2<<"\t"<<cHyp.sigma_u2<<"\t"<<vec_h[cHyp.h_id]<<endl;

			gsl_vector_add(epsilon, u);

		}

		/*
		cout<<t<<endl;
		cout<<"beta = "<<beta<<endl;
		cout<<"gamma = "<<cHyp.gamma<<endl;
		cout<<"sigma_u2 = "<<cHyp.sigma_u2<<endl;
		cout<<"alpha = "<<alpha[0]<<endl;
		cout<<"n_accept = "<<(double)n_accept/(10.0*(t+1))<<endl;

		cout<<"z: "<<endl;
		for (size_t i=0; i<z->size; i++) {
			cout<<gsl_vector_get (z, i)<<endl;
		}
		*/
		//update log_lambda
		gsl_vector_memcpy (log_lambda, x);
		gsl_vector_scale (log_lambda, beta);
        //cout<<"log_lambda: "<<gsl_vector_get(log_lambda, 0)<<endl;
		/*
		cout<<"log_lambda: "<<endl;
		for (size_t i=0; i<log_lambda->size; i++) {
			cout<<gsl_vector_get (log_lambda, i)<<endl;
		}
		*/
		gsl_matrix_memcpy (W_temp, W);
		for (size_t i=0; i<n_cvt; i++) {
			gsl_vector_view W_col=gsl_matrix_column (W_temp, i);
			gsl_vector_scale (&W_col.vector, alpha[i]);
			gsl_vector_add (log_lambda, &W_col.vector);
		}
		/*
		cout<<"log_lambda after alpha: "<<endl;
		for (size_t i=0; i<log_lambda->size; i++) {
			cout<<gsl_vector_get (log_lambda, i)<<endl;
		}
		*/
		gsl_vector_add (log_lambda, u);
		/*
		cout<<"log_lambda after u: "<<endl;
		for (size_t i=0; i<log_lambda->size; i++) {
			cout<<gsl_vector_get (log_lambda, i)<<endl;
		}
		*/
		//		gsl_vector_add (log_lambda, log_N);

	}

	cPostM.h/=(double)s_step;
	cPostM.sigma_u2/=(double)s_step;
	gsl_vector_scale(epsilon, 1.0/(double)s_step);

	if (cPostM.gamma==0) {
		cPostM.beta=0.0;
	}
	else {
		cPostM.beta/=(double)cPostM.gamma;
	}

	cPostM.gamma/=(double)s_step;

	for (size_t i=0; i<W->size2; i++) {
	  cPostM.alpha[i]/=(double)s_step;
	  cPostM.alpha_se[i]=calcSD(alpha_samples[i]);
	}

	//obtain quantiles
	size_t l=beta_samples.size();
	if (l==0) {
		cPostM.beta_025=0.0;
		cPostM.beta_500=0.0;
		cPostM.beta_975=0.0;
	}
	else {
	        cPostM.beta_se=calcSD(beta_samples);

		sort (beta_samples.begin(), beta_samples.end());
		cPostM.beta_025=beta_samples[(size_t)((double)l*0.025)];
		cPostM.beta_500=beta_samples[(size_t)((double)l*0.500)];
		cPostM.beta_975=beta_samples[(size_t)((double)l*0.975)];
	}

	l=h_samples.size();
	if (l==0) {
		cPostM.h_025=0.0;
		cPostM.h_500=0.0;
		cPostM.h_975=0.0;
	}
	else {
	        cPostM.h_se=calcSD(h_samples);

		sort (h_samples.begin(), h_samples.end());
		cPostM.h_025=h_samples[(size_t)((double)l*0.025)];
		cPostM.h_500=h_samples[(size_t)((double)l*0.500)];
		cPostM.h_975=h_samples[(size_t)((double)l*0.975)];
	}

	l=sigma_u2_samples.size();
	if (l==0) {
		cPostM.sigma_u2_025=0.0;
		cPostM.sigma_u2_500=0.0;
		cPostM.sigma_u2_975=0.0;
	}
	else {
	        cPostM.sigma_u2_se=calcSD(sigma_u2_samples);

		sort (sigma_u2_samples.begin(), sigma_u2_samples.end());
		cPostM.sigma_u2_025=sigma_u2_samples[(size_t)((double)l*0.025)];
		cPostM.sigma_u2_500=sigma_u2_samples[(size_t)((double)l*0.500)];
		cPostM.sigma_u2_975=sigma_u2_samples[(size_t)((double)l*0.975)];
	}

	cPostM.acc_rate=n_accept/((double)(w_step+s_step)*(double)n_mh);

	gsl_matrix_free(Uh_mat);
	gsl_matrix_free(Eval_h);

	gsl_matrix_free(UtW);
	gsl_matrix_free(Utx);
	gsl_matrix_free(Utz);

	gsl_vector_free(log_lambda);
	gsl_vector_free(z);
	gsl_vector_free(u);

	gsl_vector_free(ab);
	gsl_matrix_free(Uab);
	gsl_matrix_free(Pab);

	gsl_vector_free(log_N);

	gsl_matrix_free(W_temp);

	beta_samples.clear(); h_samples.clear(); sigma_u2_samples.clear(); vec_tmp.clear();
	alpha_samples.clear();
	return;
}








void BMM::Analysis (const gsl_matrix *Read, const gsl_matrix *Depth, const gsl_matrix *K, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x)
{
  sumPost.clear(); indicator_gene.clear();
  size_t ng_total=Read->size1, ni_test=W->size1;
  n_cvt=W->size2;
  //cout<<ng_total<<" "<<ni_test<<" "<<n_cvt<<endl;

  vector<size_t> y_vec, N_vec, idv_sub, y_sub, N_sub;

  size_t ci_test, flag_value, y, t;
  double f;
  class POSTMEAN cPostM;

  //set up random seed
  gsl_rng_env_setup();
  const gsl_rng_type * gslType;
  gslType = gsl_rng_default;
  if (randseed<0) {
    time_t rawtime;
    time (&rawtime);
    tm * ptm = gmtime (&rawtime);

    randseed = (unsigned) (ptm->tm_hour%24*3600+ptm->tm_min*60+ptm->tm_sec);
  }
  gsl_r = gsl_rng_alloc(gslType);
  gsl_rng_set(gsl_r, randseed);

  //set up matrices and vectors
  gsl_matrix *weight=gsl_matrix_alloc (W->size1, 10);
  gsl_matrix *mean=gsl_matrix_alloc (W->size1, 10);
  gsl_vector *sigmasq=gsl_vector_alloc (W->size1);
  gsl_vector *epsilon=gsl_vector_alloc (W->size1);
  gsl_vector *Di=gsl_vector_alloc (W->size1);

  // Read gene expression file

  //output prior values
  /*
    cout<<"h: ";
    for (size_t i=0; i<vec_h.size(); i++) {
    cout<<vec_h[i]<<" ";
    }
    cout<<endl;

    cout<<"sb: ";
    for (size_t i=0; i<vec_sb.size(); i++) {
    cout<<vec_sb[i]<<" ";
    }
    cout<<endl;

    cout<<"pi_beta: "<<pi_beta<<endl;
    cout<<"h scale: "<<h_scale<<endl;
    cout<<"sigma_u2 sd: "<<sigma_u2_sd<<endl;
  */

  for (size_t i=0; i<ng_total; i++) {
    //if (i!=0) {continue;}
    if (i%display_pace==0 || i==ng_total-1) {ProgressBar ("Performing Analysis ", i, ng_total-1);}
    n_accept=0;

    gsl_matrix_set_zero(mean);
    gsl_matrix_set_zero(weight);
    gsl_vector_set_zero(sigmasq);
    gsl_vector_set_zero(Di);

    //set up idv_sub, to contain the subset of individuals that undergo analysis
    //and set up normal mixtures
    flag_value=0; idv_sub.clear(); y_vec.clear(); N_vec.clear(); ci_test=0;
    for (size_t j=0; j<ni_test; ++j) {
      y=gsl_matrix_get(Read, i, j);
      if (Depth->size1==1) {
	t=gsl_matrix_get(Depth, 0, j);
      } else {
	t=gsl_matrix_get(Depth, i, j);
      }

      if (y>t) {flag_value=1; break;}

      y_vec.push_back(y); N_vec.push_back(t);

      if (t!=0) {
	idv_sub.push_back(j);

	gsl_vector_view w_row=gsl_matrix_row (weight, ci_test);
	gsl_vector_view m_row=gsl_matrix_row (mean, ci_test);
	NormalMixture (t, &w_row.vector, &m_row.vector, f);
	gsl_vector_set (sigmasq, ci_test, f);
	gsl_vector_set (Di, ci_test, 1.0/f);
      }
      ci_test++;
    }

    //cout<<"y: "<<y_vec[0]<<" "<<y_vec[23]<<endl;
    //cout<<"N: "<<N_vec[0]<<" "<<N_vec[23]<<endl;
    //cout<<"x: "<<gsl_vector_get(x,0)<<" "<<gsl_vector_get(x, 23)<<endl;
    //cout<<idv_sub.size()<<endl;
    //cout<<randseed<<"\t"<<gsl_ran_gaussian (gsl_r, 1)<<endl;

    cPostM.initial(n_cvt);
    if (idv_sub.size()>1 && flag_value==0) {
      //record values
      if (idv_sub.size()<ni_test) {
	y_sub.clear(); N_sub.clear();
	gsl_matrix *K_sub=gsl_matrix_alloc (idv_sub.size(), idv_sub.size() );
	gsl_matrix *B_sub=gsl_matrix_alloc (idv_sub.size(), idv_sub.size() );
	gsl_matrix *W_sub=gsl_matrix_alloc (idv_sub.size(), W->size2 );
	gsl_vector *x_sub=gsl_vector_alloc (idv_sub.size() );
	gsl_vector *epsilon_sub=gsl_vector_alloc (idv_sub.size() );
	gsl_matrix *weight_sub=gsl_matrix_alloc (idv_sub.size(), weight->size2 );
	gsl_matrix *mean_sub=gsl_matrix_alloc (idv_sub.size(), mean->size2 );
	gsl_vector *sigmasq_sub=gsl_vector_alloc (idv_sub.size() );
	gsl_vector *Di_sub=gsl_vector_alloc (idv_sub.size() );

	for (size_t k=0; k<idv_sub.size(); k++) {
	  y_sub.push_back(y_vec[idv_sub[k]]);
	  N_sub.push_back(N_vec[idv_sub[k]]);
	  f=gsl_vector_get (x, idv_sub[k]);
	  gsl_vector_set (x_sub, k, f);
	  f=gsl_vector_get (sigmasq, idv_sub[k]);
	  gsl_vector_set (sigmasq_sub, k, f);
	  f=gsl_vector_get (Di, idv_sub[k]);
	  gsl_vector_set (Di_sub, k, f);

	  for (size_t l=0; l<W->size2; l++) {
	    f=gsl_matrix_get (W, idv_sub[k], l);
	    gsl_matrix_set (W_sub, k, l, f);
	  }

	  for (size_t l=0; l<mean->size2; l++) {
	    f=gsl_matrix_get (mean, idv_sub[k], l);
	    gsl_matrix_set (mean_sub, k, l, f);

	    f=gsl_matrix_get (weight, idv_sub[k], l);
	    gsl_matrix_set (weight_sub, k, l, f);
	  }

	  for (size_t l=0; l<idv_sub.size(); l++) {
	    f=gsl_matrix_get (K, idv_sub[k], idv_sub[l]);
	    gsl_matrix_set (K_sub, k, l, f);

	    f=gsl_matrix_get (B, idv_sub[k], idv_sub[l]);
	    gsl_matrix_set (B_sub, k, l, f);
	  }
	}

	//scale K_sub and B_sub by the mean of diagonal elements
	f=0.0;
	for (size_t i=0; i<K_sub->size1; i++) {
	  f+=gsl_matrix_get (K_sub, i, i);
	}
	f/=(double)K_sub->size1;
	gsl_matrix_scale (K_sub, 1.0/f);

	f=0.0;
	for (size_t i=0; i<B_sub->size1; i++) {
	  f+=gsl_matrix_get (B_sub, i, i);
	}
	f/=(double)B_sub->size1;
	gsl_matrix_scale (B_sub, 1.0/f);

	//center matrix
	//cout<<"a"<<endl;

	cPostM.n=idv_sub.size();
	MCMCRunBMM (N_sub, y_sub, K_sub, B_sub, W_sub, x_sub, Di_sub, weight_sub, mean_sub, sigmasq_sub, epsilon_sub, cPostM);

	//free matrices
	gsl_matrix_free(K_sub);
	gsl_matrix_free(B_sub);
	gsl_matrix_free(W_sub);
	gsl_vector_free(x_sub);
	gsl_vector_free(epsilon_sub);
	gsl_matrix_free(weight_sub);
	gsl_matrix_free(mean_sub);
	gsl_vector_free(sigmasq_sub);
	gsl_vector_free(Di_sub);
      } else {
	cPostM.n=ni_test;
	MCMCRunBMM (N_vec, y_vec, K, B, W, x, Di, weight, mean, sigmasq, epsilon, cPostM);
      }
      indicator_gene.push_back(1);
      ng_test++;
    } else {
      indicator_gene.push_back(0);
    }



		/*
		cout<<"result: "<<endl;
		cout<<cPostM.beta<<endl;
		cout<<cPostM.gamma<<endl;
		cout<<cPostM.h<<endl;
		cout<<cPostM.rho<<endl;
		cout<<cPostM.sigma_b2<<endl;
		cout<<cPostM.sigma_u2<<endl;
		cout<<cPostM.alpha[0]<<endl;
		cout<<endl;
		*/

    sumPost.push_back(cPostM);
  }
  cout<<endl;

  gsl_matrix_free(weight);
  gsl_matrix_free(mean);
  gsl_vector_free(sigmasq);
  gsl_vector_free(Di);
  gsl_vector_free(epsilon);

  return;
}
