/*
    Genomic Enrichment Analysis using Hierachical Poisson Model (GEAP)
    Copyright (C) 2016 Shiquan Sun and Xiang Zhou

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
#include <map>

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
#include "gsl/gsl_multimin.h"

#include "param.h"
#include "io.h"
#include "nb.h"
// #include "logistic.h"

#ifdef WITH_LAPACK
#include "lapack.h"
#endif

using namespace std;

void NB::CopyFromParam(PARAM &cPar)
{
	display_pace = cPar.display_pace;
	ng_test = cPar.ng_test;

	// vec_h = cPar.vec_h;
	vec_h.push_back(0);
	vb = cPar.vb;

	// hirarchical model
	//   vec_sb=cPar.vec_sb;//**
	//   n_kd=cPar.n_kd;
	//   n_kc=cPar.n_kc;

	h_scale = cPar.h_scale;
	sigma_u2_sd = cPar.sigma_u2_sd;

	w_step = cPar.w_step;
	s_step = cPar.s_step;
	n_mh = cPar.n_mh;
	randseed = cPar.randseed;

	time_eigen = cPar.time_eigen;
	time_mv = cPar.time_mv;
	time_s_z = cPar.time_s_z;
	time_s_mw = cPar.time_s_mw;
	time_s_h = cPar.time_s_h;
	time_s_bau = cPar.time_s_bau;

	return;
}

void NB::CopyToParam(PARAM &cPar)
{
	cPar.ng_test = ng_test;
	cPar.sumPost = sumPost;
	cPar.indicator_gene = indicator_gene;
	// cPar.u_vec = u_vec;

	cPar.time_eigen = time_eigen;
	cPar.time_mv = time_mv;
	cPar.time_s_z = time_s_z;
	cPar.time_s_mw = time_s_mw;
	cPar.time_s_h = time_s_h;
	cPar.time_s_bau = time_s_bau;

	return;
}

size_t NB::FindIndex(const size_t a, const size_t b, const size_t n_cvt)
{
	return (a - 1) * (n_cvt + 2) + (b - 1);
}

//omit y instead of x
void NB::CalcUab12(const size_t n_cvt, const gsl_matrix *UtW, const gsl_matrix *Utx, gsl_matrix *Uab12)
{
	size_t index_ab, index_ba;
	gsl_vector *u_a1 = gsl_vector_alloc(UtW->size1);
	gsl_vector *u_a2 = gsl_vector_alloc(UtW->size1);
	gsl_vector *u_b1 = gsl_vector_alloc(UtW->size1);
	gsl_vector *u_b2 = gsl_vector_alloc(UtW->size1);

	for (size_t a = 1; a <= n_cvt + 2; a++)
	{
		if (a == n_cvt + 2)
		{
			continue;
		}

		if (a == n_cvt + 1)
		{
			gsl_vector_const_view Utx1_col = gsl_matrix_const_column(Utx, 0);
			gsl_vector_const_view Utx2_col = gsl_matrix_const_column(Utx, 1);
			gsl_vector_memcpy(u_a1, &Utx1_col.vector);
			gsl_vector_memcpy(u_a2, &Utx2_col.vector);
		}
		else
		{
			gsl_vector_const_view UtW1_col = gsl_matrix_const_column(UtW, a - 1);
			gsl_vector_const_view UtW2_col = gsl_matrix_const_column(UtW, n_cvt + a - 1);
			gsl_vector_memcpy(u_a1, &UtW1_col.vector);
			gsl_vector_memcpy(u_a2, &UtW2_col.vector);
		}

		for (size_t b = 1; b <= n_cvt + 2; b++)
		{
			if (b == n_cvt + 2)
			{
				continue;
			}

			index_ab = FindIndex(a, b, n_cvt);
			index_ba = FindIndex(b, a, n_cvt);

			if (b == n_cvt + 1)
			{
				gsl_vector_const_view Utx1_col = gsl_matrix_const_column(Utx, 0);
				gsl_vector_const_view Utx2_col = gsl_matrix_const_column(Utx, 1);
				gsl_vector_memcpy(u_b1, &Utx1_col.vector);
				gsl_vector_memcpy(u_b2, &Utx2_col.vector);
			}
			else
			{
				gsl_vector_const_view UtW1_col = gsl_matrix_const_column(UtW, b - 1);
				gsl_vector_const_view UtW2_col = gsl_matrix_const_column(UtW, n_cvt + b - 1);
				gsl_vector_memcpy(u_b1, &UtW1_col.vector);
				gsl_vector_memcpy(u_b2, &UtW2_col.vector);
			}

			if (b <= a)
			{
				gsl_vector_view Uab11_col = gsl_matrix_column(Uab12, index_ab);
				gsl_vector_memcpy(&Uab11_col.vector, u_a1);
				gsl_vector_mul(&Uab11_col.vector, u_b1);
				if (a != b)
				{
					gsl_vector_view Uab11_col2 = gsl_matrix_column(Uab12, index_ba);
					gsl_vector_memcpy(&Uab11_col2.vector, &Uab11_col.vector);
				}

				gsl_vector_view Uab22_col = gsl_matrix_column(Uab12, index_ab + (n_cvt + 2) * (n_cvt + 2));
				gsl_vector_memcpy(&Uab22_col.vector, u_a2);
				gsl_vector_mul(&Uab22_col.vector, u_b2);
				if (a != b)
				{
					gsl_vector_view Uab22_col2 = gsl_matrix_column(Uab12, index_ba + (n_cvt + 2) * (n_cvt + 2));
					gsl_vector_memcpy(&Uab22_col2.vector, &Uab22_col.vector);
				}
			}

			gsl_vector_view Uab12_col = gsl_matrix_column(Uab12, index_ab + (n_cvt + 2) * (n_cvt + 2) * 2);
			gsl_vector_memcpy(&Uab12_col.vector, u_a1);
			gsl_vector_mul(&Uab12_col.vector, u_b2);

			gsl_vector_view Uab21_col = gsl_matrix_column(Uab12, index_ba + (n_cvt + 2) * (n_cvt + 2) * 2);
			gsl_vector_memcpy(&Uab21_col.vector, u_a2);
			gsl_vector_mul(&Uab21_col.vector, u_b1);
		}
	}

	gsl_vector_free(u_a1);
	gsl_vector_free(u_a2);
	gsl_vector_free(u_b1);
	gsl_vector_free(u_b2);

	return;
}

void NB::CalcUab12(const size_t n_cvt, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *Uty, gsl_matrix *Uab12)
{
	size_t index_ab, index_ba;
	gsl_vector *u_b1 = gsl_vector_alloc(UtW->size1);
	gsl_vector *u_b2 = gsl_vector_alloc(UtW->size1);
	gsl_vector_const_view u_y1 = gsl_matrix_const_column(Uty, 0);
	gsl_vector_const_view u_y2 = gsl_matrix_const_column(Uty, 1);

	for (size_t b = 1; b <= n_cvt + 2; b++)
	{
		index_ab = FindIndex(n_cvt + 2, b, n_cvt);
		index_ba = FindIndex(b, n_cvt + 2, n_cvt);

		if (b == n_cvt + 1)
		{
			gsl_vector_const_view Utx1_col = gsl_matrix_const_column(Utx, 0);
			gsl_vector_memcpy(u_b1, &Utx1_col.vector);
			gsl_vector_const_view Utx2_col = gsl_matrix_const_column(Utx, 1);
			gsl_vector_memcpy(u_b2, &Utx2_col.vector);
		}
		else if (b == n_cvt + 2)
		{
			gsl_vector_memcpy(u_b1, &u_y1.vector);
			gsl_vector_memcpy(u_b2, &u_y2.vector);
		}
		else
		{
			gsl_vector_const_view UtW1_col = gsl_matrix_const_column(UtW, b - 1);
			gsl_vector_memcpy(u_b1, &UtW1_col.vector);
			gsl_vector_const_view UtW2_col = gsl_matrix_const_column(UtW, n_cvt + b - 1);
			gsl_vector_memcpy(u_b2, &UtW2_col.vector);
		}

		gsl_vector_view Uab11_col = gsl_matrix_column(Uab12, index_ab);
		gsl_vector_memcpy(&Uab11_col.vector, &u_y1.vector);
		gsl_vector_mul(&Uab11_col.vector, u_b1);
		if (b != n_cvt + 2)
		{
			gsl_vector_view Uab11_col2 = gsl_matrix_column(Uab12, index_ba);
			gsl_vector_memcpy(&Uab11_col2.vector, &Uab11_col.vector);
		}

		gsl_vector_view Uab22_col = gsl_matrix_column(Uab12, index_ab + (n_cvt + 2) * (n_cvt + 2));
		gsl_vector_memcpy(&Uab22_col.vector, &u_y2.vector);
		gsl_vector_mul(&Uab22_col.vector, u_b2);
		if (b != n_cvt + 2)
		{
			gsl_vector_view Uab22_col2 = gsl_matrix_column(Uab12, index_ba + (n_cvt + 2) * (n_cvt + 2));
			gsl_vector_memcpy(&Uab22_col2.vector, &Uab22_col.vector);
		}

		gsl_vector_view Uab12_col = gsl_matrix_column(Uab12, index_ab + (n_cvt + 2) * (n_cvt + 2) * 2);
		gsl_vector_memcpy(&Uab12_col.vector, &u_y1.vector);
		gsl_vector_mul(&Uab12_col.vector, u_b2);

		gsl_vector_view Uab21_col = gsl_matrix_column(Uab12, index_ba + (n_cvt + 2) * (n_cvt + 2) * 2);
		gsl_vector_memcpy(&Uab21_col.vector, &u_y2.vector);
		gsl_vector_mul(&Uab21_col.vector, u_b1);
	}

	gsl_vector_free(u_b1);
	gsl_vector_free(u_b2);
	return;
}

void NB::CalcDab(const size_t n_cvt, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *Di1, const gsl_vector *Di2, gsl_vector *ab)
{
	size_t index_ab, index_ba;
	double f;
	gsl_vector *v_a = gsl_vector_alloc(W->size1);
	gsl_vector *v_b = gsl_vector_alloc(W->size1);
	gsl_vector *v = gsl_vector_alloc(W->size1);

	for (size_t a = 1; a <= n_cvt + 2; a++)
	{
		if (a == n_cvt + 2)
		{
			continue;
		}

		if (a == n_cvt + 1)
		{
			gsl_vector_memcpy(v_a, x);
		}
		else
		{
			gsl_vector_const_view W_col = gsl_matrix_const_column(W, a - 1);
			gsl_vector_memcpy(v_a, &W_col.vector);
		}

		for (size_t b = 1; b <= n_cvt + 2; b++)
		{
			if (b > a)
			{
				continue;
			}

			if (b == n_cvt + 2)
			{
				continue;
			}

			index_ab = FindIndex(a, b, n_cvt);
			index_ba = FindIndex(b, a, n_cvt);

			if (b == n_cvt + 1)
			{
				gsl_vector_memcpy(v_b, x);
			}
			else
			{
				gsl_vector_const_view W_col = gsl_matrix_const_column(W, b - 1);
				gsl_vector_memcpy(v_b, &W_col.vector);
			}

			gsl_vector_memcpy(v, v_a);
			gsl_vector_mul(v, Di1);
			gsl_blas_ddot(v, v_b, &f);
			gsl_vector_set(ab, index_ab, f);
			if (a != b)
			{
				gsl_vector_set(ab, index_ba, f);
			}

			gsl_vector_memcpy(v, v_a);
			gsl_vector_mul(v, Di2);
			gsl_blas_ddot(v, v_b, &f);
			gsl_vector_set(ab, index_ab + (n_cvt + 2) * (n_cvt + 2), f);
			if (a != b)
			{
				gsl_vector_set(ab, index_ba + (n_cvt + 2) * (n_cvt + 2), f);
			}
		}
	}

	gsl_vector_free(v_a);
	gsl_vector_free(v_b);
	gsl_vector_free(v);
	return;
}

void NB::CalcDab(const size_t n_cvt, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *y, const gsl_vector *Di1, const gsl_vector *Di2, gsl_vector *ab)
{
	size_t index_ab, index_ba;
	double f;
	gsl_vector *v_b = gsl_vector_alloc(W->size1);
	gsl_vector *v = gsl_vector_alloc(W->size1);

	gsl_vector_const_view y1 = gsl_vector_const_subvector(y, 0, W->size1);
	gsl_vector_const_view y2 = gsl_vector_const_subvector(y, W->size1, W->size1);

	for (size_t b = 1; b <= n_cvt + 2; b++)
	{
		index_ab = FindIndex(n_cvt + 2, b, n_cvt);
		index_ba = FindIndex(b, n_cvt + 2, n_cvt);

		if (b == n_cvt + 2)
		{
			gsl_vector_memcpy(v, &y1.vector);
			gsl_vector_mul(v, Di1);
			gsl_blas_ddot(v, &y1.vector, &f);
			gsl_vector_set(ab, index_ab, f);

			gsl_vector_memcpy(v, &y2.vector);
			gsl_vector_mul(v, Di2);
			gsl_blas_ddot(v, &y2.vector, &f);
			gsl_vector_set(ab, index_ab + (n_cvt + 2) * (n_cvt + 2), f);
		}
		else
		{
			if (b == n_cvt + 1)
			{
				gsl_vector_memcpy(v_b, x);
			}
			else
			{
				gsl_vector_const_view W_col = gsl_matrix_const_column(W, b - 1);
				gsl_vector_memcpy(v_b, &W_col.vector);
			}

			gsl_vector_memcpy(v, &y1.vector);
			gsl_vector_mul(v, Di1);
			gsl_blas_ddot(v, v_b, &f);
			gsl_vector_set(ab, index_ab, f);
			gsl_vector_set(ab, index_ba, f);

			gsl_vector_memcpy(v, &y2.vector);
			gsl_vector_mul(v, Di2);
			gsl_blas_ddot(v, v_b, &f);
			gsl_vector_set(ab, index_ab + (n_cvt + 2) * (n_cvt + 2), f);
			gsl_vector_set(ab, index_ba + (n_cvt + 2) * (n_cvt + 2), f);
		}
	}

	gsl_vector_free(v_b);
	gsl_vector_free(v);
	return;
}

void NB::CalcPab12(const size_t n_cvt, const double sigma_b2, const gsl_vector *Hi_eval, const gsl_vector *ab, const gsl_matrix *Uab, gsl_matrix *Pab)
{
	size_t index_ab, index_ba, index_aw, index_bw, index_wa, index_wb, index_ww;
	double p_ab;
	double ps_ab, ps_aw = 0.0, ps_bw = 0.0, ps_ww;

	for (size_t p = 0; p <= n_cvt + 1; p++)
	{
		//calculate Pab11
		for (size_t a = p + 1; a <= n_cvt + 2; a++)
		{
			for (size_t b = p + 1; b <= n_cvt + 2; b++)
			{
				index_ab = FindIndex(a, b, n_cvt);
				index_ba = FindIndex(b, a, n_cvt);
				if (p == 0)
				{
					for (size_t i = 0; i <= 2; i++)
					{
						if (i != 2 && b > a)
						{
							continue;
						}

						gsl_vector_const_view Uab_col = gsl_matrix_const_column(Uab, index_ab + (n_cvt + 2) * (n_cvt + 2) * i);
						gsl_blas_ddot(Hi_eval, &Uab_col.vector, &p_ab);
						p_ab *= -1.0;
						if (i != 2)
						{
							p_ab += gsl_vector_get(ab, index_ab + (n_cvt + 2) * (n_cvt + 2) * i);
						}
						gsl_matrix_set(Pab, 0, index_ab + (n_cvt + 2) * (n_cvt + 2) * i, p_ab);
						if (i != 2 && a != b)
						{
							gsl_matrix_set(Pab, 0, index_ba + (n_cvt + 2) * (n_cvt + 2) * i, p_ab);
						}
					}
				}
				else
				{
					index_aw = FindIndex(a, p, n_cvt);
					index_wa = FindIndex(p, a, n_cvt);
					index_bw = FindIndex(b, p, n_cvt);
					index_wb = FindIndex(p, b, n_cvt);
					index_ww = FindIndex(p, p, n_cvt);

					ps_ww = gsl_matrix_get(Pab, p - 1, index_ww);
					ps_ww += gsl_matrix_get(Pab, p - 1, index_ww + (n_cvt + 2) * (n_cvt + 2));
					ps_ww += 2.0 * gsl_matrix_get(Pab, p - 1, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);
					if (p == n_cvt + 1)
					{
						ps_ww += 1.0 / sigma_b2;
					}

					for (size_t i = 0; i <= 2; i++)
					{
						if (i != 2 && b > a)
						{
							continue;
						}

						ps_ab = gsl_matrix_get(Pab, p - 1, index_ab + (n_cvt + 2) * (n_cvt + 2) * i);
						if (i == 0)
						{
							ps_aw = gsl_matrix_get(Pab, p - 1, index_aw);
							ps_aw += gsl_matrix_get(Pab, p - 1, index_aw + (n_cvt + 2) * (n_cvt + 2) * 2);
							ps_bw = gsl_matrix_get(Pab, p - 1, index_bw);
							ps_bw += gsl_matrix_get(Pab, p - 1, index_bw + (n_cvt + 2) * (n_cvt + 2) * 2);
						}
						else if (i == 1)
						{
							ps_aw = gsl_matrix_get(Pab, p - 1, index_wa + (n_cvt + 2) * (n_cvt + 2));
							ps_aw += gsl_matrix_get(Pab, p - 1, index_wa + (n_cvt + 2) * (n_cvt + 2) * 2);
							ps_bw = gsl_matrix_get(Pab, p - 1, index_wb + (n_cvt + 2) * (n_cvt + 2));
							ps_bw += gsl_matrix_get(Pab, p - 1, index_wb + (n_cvt + 2) * (n_cvt + 2) * 2);
						}
						else if (i == 2)
						{
							ps_aw = gsl_matrix_get(Pab, p - 1, index_aw);
							ps_aw += gsl_matrix_get(Pab, p - 1, index_aw + (n_cvt + 2) * (n_cvt + 2) * 2);
							ps_bw = gsl_matrix_get(Pab, p - 1, index_wb + (n_cvt + 2) * (n_cvt + 2));
							ps_bw += gsl_matrix_get(Pab, p - 1, index_wb + (n_cvt + 2) * (n_cvt + 2) * 2);
						}
						else
						{
						}

						p_ab = ps_ab - ps_aw * ps_bw / ps_ww;
						gsl_matrix_set(Pab, p, index_ab + (n_cvt + 2) * (n_cvt + 2) * i, p_ab);
						if (i != 2 && a != b)
						{
							gsl_matrix_set(Pab, p, index_ba + (n_cvt + 2) * (n_cvt + 2) * i, p_ab);
						}
					}
				}
			}
		}
	}

	return;
}

void NB::EigenProc(const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *D1i, const gsl_vector *D2i, gsl_matrix *U1_mat, gsl_matrix *U2_mat, gsl_matrix *Uh_mat, gsl_matrix *Eval_h, gsl_matrix *UtW, gsl_matrix *Utx)
{
	clock_t time_start;

	gsl_vector *Dsqrt = gsl_vector_alloc(W->size1); //D sqrt
	gsl_vector *eval = gsl_vector_alloc(W->size1);  //D sqrt
	//gsl_matrix *B_temp=gsl_matrix_alloc (W->size1, W->size1);
	gsl_matrix *Vh = gsl_matrix_alloc(W->size1, W->size1);
	gsl_matrix *U1 = gsl_matrix_alloc(W->size1, W->size1);
	gsl_matrix *U2 = gsl_matrix_alloc(W->size1, W->size1);
	gsl_matrix *Uh = gsl_matrix_alloc(W->size1, W->size1);

	double f = 0.0, f1;

	//calculate Dsqrt
	gsl_vector_memcpy(Dsqrt, D1i);
	gsl_vector_add(Dsqrt, D2i);
	for (size_t i = 0; i < Dsqrt->size; i++)
	{
		f = gsl_vector_get(Dsqrt, i);
		f = sqrt(f);
		gsl_vector_set(Dsqrt, i, f);
	}
	/*
	cout<<"D1i is: "<<endl;
	for (size_t i=0; i<D1i->size; i++) {
		cout<<gsl_vector_get (D1i, i)<<endl;
	}
	cout<<"D2i is: "<<endl;
	for (size_t i=0; i<D1i->size; i++) {
		cout<<gsl_vector_get (D2i, i)<<endl;
	}
	cout<<"Dsqrt is: "<<endl;
	for (size_t i=0; i<Dsqrt->size; i++) {
		cout<<gsl_vector_get (Dsqrt, i)<<endl;
	}
	*/
	//calculate Vh, eigen-decomposition, and UtW, Utx
	//	for (size_t i=0; i<vec_h.size(); i++) {
	//		cout<<vec_h[i]<<endl;

	//gsl_matrix_memcpy (Vh, K);
	//gsl_matrix_scale (Vh, vec_h[i]);
	//gsl_matrix_memcpy (B_temp, B);
	//gsl_matrix_scale (B_temp, 1-vec_h[i]);
	//gsl_matrix_add (Vh, B_temp);
	gsl_matrix_memcpy(Vh, B);

	for (size_t j = 0; j < W->size1; j++)
	{
		f = gsl_vector_get(Dsqrt, j);
		gsl_vector_view Vh_row = gsl_matrix_row(Vh, j);	//get value
		gsl_vector_scale(&Vh_row.vector, f);			   // multiply
		gsl_vector_view Vh_col = gsl_matrix_column(Vh, j); // get value
		gsl_vector_scale(&Vh_col.vector, f);			   // multiply
	}

	gsl_vector_view eval_col = gsl_matrix_column(Eval_h, 0);

	//		gsl_matrix_set_zero(U1);
	time_start = clock();
	lapack_double_eigen_symmv(Vh, eval, U1);

	//		lapack_eigen_fdf (Vh, eval, U1);

	time_eigen += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);

	gsl_vector_memcpy(&eval_col.vector, eval);

	for (size_t j = 0; j < eval->size; j++)
	{
		f = gsl_vector_get(eval, j);
		if (f < 0)
		{
			f = 0;
			gsl_vector_set(eval, j, f);
		}
	}
	/*
		cout<<"eval is: "<<endl;
		for (size_t j=0; j<eval->size; j++) {
			cout<<gsl_vector_get (eval, j)<<endl;
		}
		*/
	//calculate U1, U2 and Uh
	gsl_matrix_memcpy(U2, U1);
	gsl_matrix_memcpy(Uh, U1);
	for (size_t j = 0; j < W->size1; j++)
	{
		f1 = 1.0 / gsl_vector_get(Dsqrt, j);

		f = f1;
		gsl_vector_view Uh_row = gsl_matrix_row(Uh, j);
		gsl_vector_scale(&Uh_row.vector, f);

		f = gsl_vector_get(D1i, j) * f1;
		gsl_vector_view U1_row = gsl_matrix_row(U1, j);
		gsl_vector_scale(&U1_row.vector, f);

		f = gsl_vector_get(D2i, j) * f1;
		gsl_vector_view U2_row = gsl_matrix_row(U2, j);
		gsl_vector_scale(&U2_row.vector, f);
	}

	/* 	gsl_matrix_view U1_sub=gsl_matrix_submatrix (U1_mat, 0, i*W->size1, W->size1, W->size1);
		gsl_matrix_view U2_sub=gsl_matrix_submatrix (U2_mat, 0, i*W->size1, W->size1, W->size1);
		gsl_matrix_view Uh_sub=gsl_matrix_submatrix (Uh_mat, 0, i*W->size1, W->size1, W->size1);
		 */
	gsl_matrix_view U1_sub = gsl_matrix_submatrix(U1_mat, 0, 0, W->size1, W->size1);
	gsl_matrix_view U2_sub = gsl_matrix_submatrix(U2_mat, 0, 0, W->size1, W->size1);
	gsl_matrix_view Uh_sub = gsl_matrix_submatrix(Uh_mat, 0, 0, W->size1, W->size1);

	gsl_matrix_memcpy(&U1_sub.matrix, U1);
	gsl_matrix_memcpy(&U2_sub.matrix, U2);
	gsl_matrix_memcpy(&Uh_sub.matrix, Uh);

	//calculate UtW, Utx
	time_start = clock();

	/* 	gsl_vector_view Utx1_col=gsl_matrix_column (Utx, i*2);
		gsl_vector_view Utx2_col=gsl_matrix_column (Utx, i*2+1); */

	gsl_vector_view Utx1_col = gsl_matrix_column(Utx, 0);
	gsl_vector_view Utx2_col = gsl_matrix_column(Utx, 1);

	gsl_blas_dgemv(CblasTrans, 1.0, U1, x, 0.0, &Utx1_col.vector);
	gsl_blas_dgemv(CblasTrans, 1.0, U2, x, 0.0, &Utx2_col.vector);

	for (size_t j = 0; j < n_cvt; j++)
	{
		gsl_vector_const_view W_col = gsl_matrix_const_column(W, j);
		/* gsl_vector_view UtW1_col=gsl_matrix_column (UtW, i*2*n_cvt+j);
			gsl_vector_view UtW2_col=gsl_matrix_column (UtW, i*2*n_cvt+n_cvt+j); */

		gsl_vector_view UtW1_col = gsl_matrix_column(UtW, j);
		gsl_vector_view UtW2_col = gsl_matrix_column(UtW, n_cvt + j);
		gsl_blas_dgemv(CblasTrans, 1.0, U1, &W_col.vector, 0.0, &UtW1_col.vector);
		gsl_blas_dgemv(CblasTrans, 1.0, U2, &W_col.vector, 0.0, &UtW2_col.vector);
		/*
			cout<<"UtW2: "<<endl;
			for (size_t a=0; a<UtW->size1; a++) {
				cout<<scientific<<setprecision(10)<<gsl_vector_get(&UtW2_col.vector, a)<<endl;
			}
			*/
	}

	/*
		cout<<"Utx2: "<<endl;
		for (size_t a=0; a<UtW->size1; a++) {
			cout<<scientific<<setprecision(10)<<gsl_vector_get(&Utx2_col.vector, a)<<endl;
		}
		*/
	time_mv += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);
	//}

	gsl_vector_free(Dsqrt);
	gsl_vector_free(eval);
	//gsl_matrix_free(B_temp);
	gsl_matrix_free(Vh);
	gsl_matrix_free(U1);
	gsl_matrix_free(U2);
	gsl_matrix_free(Uh);

	return;
}

double NB::ProposeHyper(const class HYPPAR &cHyp_old, class HYPPAR &cHyp_new)
{
	int h_id = cHyp_old.h_id, sb_id = cHyp_old.sb_id;
	double log_sigma_u2 = log(cHyp_old.sigma_u2);
	size_t gamma = cHyp_old.gamma;
	/*
	if ((int)gsl_ran_bernoulli (gsl_r, h_prob*2.0)==1) {
		h_id+=(int)gsl_ran_bernoulli (gsl_r, 0.5)*2-1;
	}
	if (h_id<0) {h_id=vec_h.size()-1;}
	if (h_id>vec_h.size()-1) {h_id=0;}
	*/

	/* 	//sample h_id
	if (vec_h.size()!=2) {
		int d_h=(int)((double)vec_h.size()*h_scale);
		if (d_h==0) {d_h=2;}
		h_id+=(int)gsl_rng_uniform_int (gsl_r, d_h)*((int)gsl_ran_bernoulli (gsl_r, 0.5)*2-1);
		if (h_id<0) {h_id=-1*h_id;}
		if (h_id>(int)vec_h.size()-1) {h_id=2*(int)vec_h.size()-2-h_id;}
	}
 */
	h_id = 0; // only have one element and its value equals to 0

	/*
	//sample sigma_b2 id
	if (vec_sb.size()!=1) {
		sb_id+=(int)gsl_rng_uniform_int (gsl_r, 2)*((int)gsl_ran_bernoulli (gsl_r, 0.5)*2-1);
		if (sb_id<0) {sb_id=-1*sb_id;}
		if (sb_id>(int)vec_sb.size()-1) {sb_id=2*(int)vec_sb.size()-2-sb_id;}
	}
	*/

	//sample sigma_u2
	double d;
	do
	{
		d = log_sigma_u2 + gsl_ran_gaussian(gsl_r, sigma_u2_sd);
	} while (abs(d) > 5);
	log_sigma_u2 = d;

	//if (pi_beta==0) {gamma=0;} else if (pi_beta==1) {gamma=1;} else {gamma=gsl_ran_bernoulli (gsl_r, 0.5);}
	//if (cHyp_old.prior_pi==0) {gamma=0;} else if (cHyp_old.prior_pi==1) {gamma=1;} else {gamma=gsl_ran_bernoulli (gsl_r, 0.5);}
	gamma = 1;

	// important step to replace cHyp_old with cHyp_new
	cHyp_new.h_id = h_id;
	cHyp_new.sb_id = sb_id;
	cHyp_new.sigma_u2 = exp(log_sigma_u2);
	cHyp_new.gamma = gamma;
	// cHyp_new.prob_pi = cHyp_old.prob_pi;
	// cHyp_new.prior_pi = cHyp_old.prior_pi;
	//cHyp_new.prior_pi_u = cHyp_old.prior_pi_u;
	// 2017-01-02
	// cHyp_new.ig_alpha = cHyp_old.ig_alpha;
	// cHyp_new.ig_beta =  cHyp_old.ig_beta;
/*
	if (vec_sb.size() != 1)
	{
		cHyp_new.sigma_b2 = vec_sb[sb_id] * cHyp_new.sigma_u2;
		//cHyp_new.sigma_b2=vec_sb[sb_id];
	}
	else
	{
		cHyp_new.sigma_b2 = vec_sb[sb_id];
	}
*/
	// cout<<"ProposeHyper::sigma_b2_id="<<sb_id<<"; ProposeHyper::sigma_b2="<<cHyp_new.sigma_b2<<endl;
	cHyp_new.sigma_b2=vb;

	//cout<<"ProposeHyper::sigma_b2="<<cHyp_new.sigma_b2<<"ProposeHyper::gamma="<<cHyp_new.gamma<<"ProposeHyper::sigma_u2"<<cHyp_new.sigma_u2<<endl;

	return log(cHyp_new.sigma_u2) - log(cHyp_old.sigma_u2);
}// end func

double NB::CalcPosterior(const gsl_vector *H_eval, const gsl_matrix *Pab, const class HYPPAR &cHyp)
{
	double logdet_h, logdet_hiw, P_yy, logp;
	size_t index_ww;
	double f = 0.0;

	//|I+sigma_u2*Dh|
	logdet_h = 0.0;
	for (size_t i = 0; i < H_eval->size; ++i)
	{
		f = gsl_vector_get(H_eval, i);
		logdet_h += log(f);
	}

	//calculate |WHiW|
	logdet_hiw = 0.0;
	for (size_t i = 0; i < n_cvt; ++i)
	{
		index_ww = FindIndex(i + 1, i + 1, n_cvt);
		f = gsl_matrix_get(Pab, i, index_ww);
		f += gsl_matrix_get(Pab, i, index_ww + (n_cvt + 2) * (n_cvt + 2));
		f += 2.0 * gsl_matrix_get(Pab, i, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);
		logdet_hiw += log(f);
		//		d=gsl_matrix_get (Iab, i, index_ww);
		//		logdet_hiw-=log(d);
	}

	//calculate |Omega_b*sigma_b2| if gamma==1
	if (cHyp.gamma == 1)
	{
		index_ww = FindIndex(n_cvt + 1, n_cvt + 1, n_cvt);
		f = gsl_matrix_get(Pab, n_cvt, index_ww);
		f += gsl_matrix_get(Pab, n_cvt, index_ww + (n_cvt + 2) * (n_cvt + 2));
		f += 2.0 * gsl_matrix_get(Pab, n_cvt, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);
		f *= cHyp.sigma_b2;
		f += 1.0;
		logdet_hiw += log(f);
		//		cout<<log(f)<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_ww)<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_ww+(n_cvt+2)*(n_cvt+2))<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_ww+(n_cvt+2)*(n_cvt+2)*2)<<endl;
	}

	//calculate Pzz
	index_ww = FindIndex(n_cvt + 2, n_cvt + 2, n_cvt);
	if (cHyp.gamma == 0)
	{
		P_yy = gsl_matrix_get(Pab, n_cvt, index_ww);
		P_yy += gsl_matrix_get(Pab, n_cvt, index_ww + (n_cvt + 2) * (n_cvt + 2));
		P_yy += 2.0 * gsl_matrix_get(Pab, n_cvt, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);
		//		cout<<"gamma=0: "<<P_yy<<endl;
	}
	else
	{
		P_yy = gsl_matrix_get(Pab, n_cvt + 1, index_ww);
		P_yy += gsl_matrix_get(Pab, n_cvt + 1, index_ww + (n_cvt + 2) * (n_cvt + 2));
		P_yy += 2.0 * gsl_matrix_get(Pab, n_cvt + 1, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);
		//		cout<<"gamma=1: "<<P_yy<<endl;
	}// end fi

	logp = -0.5 * logdet_h - 0.5 * logdet_hiw - 0.5 * P_yy;

/*
	if (vec_sb.size() != 1)
	{
		if (cHyp.prior_pi == 0 || cHyp.prior_pi == 1)
		{
			logp += -1.0 * log(cHyp.sigma_u2);
		}
		else
		{
			// logp+=cHyp.gamma*(log(cHyp.prior_pi)+log(1-cHyp.prior_pi_u)) +(1-cHyp.gamma)*( log(1-cHyp.prior_pi)+log(cHyp.prior_pi_u))-log(cHyp.sigma_u2); 
			logp += cHyp.gamma * (log(cHyp.prior_pi)) + (1 - cHyp.gamma) * (log(1 - cHyp.prior_pi)) - log(cHyp.sigma_u2);
		}
	}// end fi
*/
	// double ig_alpha = 0.01, ig_beta = 0.01;
	//cout<<"CalPosterior: cHyp.ig_alpha and cHyp.ig_beta::"<<cHyp.ig_alpha<<cHyp.ig_beta<< endl;
	// double pp = 0;
	// 2017-1-2
	// pp = cHyp.ig_alpha*log( cHyp.ig_beta ) - lgamma( cHyp.ig_alpha ) - ( cHyp.ig_alpha+1 )*log( cHyp.sigma_b2 ) - cHyp.ig_beta*(1/cHyp.sigma_b2);
	//cout<<"CalPosterior: pp="<<pp<< endl;
	// logp += pp;
	//logp += - ( ig_alpha+1 )*log( cHyp.sigma_b2 ) - ig_beta*(1/cHyp.sigma_b2);

	return logp;
}

void NB::UpdateUab(const size_t h_id, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *U1_mat, const gsl_matrix *U2_mat, const gsl_vector *z, gsl_matrix *Utz, gsl_matrix *Uab)
{
	clock_t time_start = clock();

	gsl_vector_view Utz1_col = gsl_matrix_column(Utz, h_id * 2);
	gsl_vector_view Utz2_col = gsl_matrix_column(Utz, h_id * 2 + 1);
	gsl_vector_const_view z_1 = gsl_vector_const_subvector(z, 0, UtW->size1);
	gsl_vector_const_view z_2 = gsl_vector_const_subvector(z, UtW->size1, UtW->size1);
	gsl_matrix_const_view U1_sub = gsl_matrix_const_submatrix(U1_mat, 0, h_id * UtW->size1, UtW->size1, UtW->size1);
	gsl_matrix_const_view U2_sub = gsl_matrix_const_submatrix(U2_mat, 0, h_id * UtW->size1, UtW->size1, UtW->size1);
	gsl_blas_dgemv(CblasTrans, 1.0, &U1_sub.matrix, &z_1.vector, 0.0, &Utz1_col.vector);
	gsl_blas_dgemv(CblasTrans, 1.0, &U2_sub.matrix, &z_2.vector, 0.0, &Utz2_col.vector);

	time_mv += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);

	gsl_matrix_const_view Utx_sub = gsl_matrix_const_submatrix(Utx, 0, h_id * 2, UtW->size1, 2);
	gsl_matrix_const_view Utz_sub = gsl_matrix_const_submatrix(Utz, 0, h_id * 2, UtW->size1, 2);
	gsl_matrix_const_view UtW_sub = gsl_matrix_const_submatrix(UtW, 0, h_id * 2 * n_cvt, UtW->size1, 2 * n_cvt);

	gsl_matrix_view Uab_sub = gsl_matrix_submatrix(Uab, 0, h_id * 3 * (n_cvt + 2) * (n_cvt + 2), UtW->size1, 3 * (n_cvt + 2) * (n_cvt + 2));
	CalcUab12(n_cvt, &UtW_sub.matrix, &Utx_sub.matrix, &Utz_sub.matrix, &Uab_sub.matrix);

	return;
}

void NB::UpdatePab(const class HYPPAR &cHyp, const gsl_matrix *Uab, const gsl_vector *eval, const gsl_vector *ab, gsl_vector *H_eval, gsl_vector *Hi_eval, gsl_matrix *Pab)
{
	gsl_vector_memcpy(H_eval, eval);
	gsl_vector_scale(H_eval, cHyp.sigma_u2);
	gsl_vector_memcpy(Hi_eval, H_eval);
	gsl_vector_add_constant(H_eval, 1.0);
	gsl_vector_div(Hi_eval, H_eval);

	gsl_matrix_const_view Uab_sub = gsl_matrix_const_submatrix(Uab, 0, cHyp.h_id * 3 * (n_cvt + 2) * (n_cvt + 2), eval->size, 3 * (n_cvt + 2) * (n_cvt + 2));
	CalcPab12(n_cvt, cHyp.sigma_b2, Hi_eval, ab, &Uab_sub.matrix, Pab);

	return;
}

void NB::SampleHyper(const gsl_matrix *Eval_h, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *U1_mat, const gsl_matrix *U2_mat, const gsl_vector *z, const gsl_vector *ab, gsl_matrix *Utz, gsl_matrix *Uab, gsl_matrix *Pab, class HYPPAR &cHyp)
{
	double logMHratio = 0.0, logPost_old = 0.0, logPost_new = 0.0;

	class HYPPAR cHyp_new;

	gsl_matrix *Pab_new = gsl_matrix_alloc(n_cvt + 2, (n_cvt + 2) * (n_cvt + 2) * 3);
	gsl_vector *Hi_eval = gsl_vector_alloc(UtW->size1);
	gsl_vector *H_eval = gsl_vector_alloc(UtW->size1);

	gsl_matrix_set_zero(Pab_new);

	vector<size_t> indicator_h;
	for (size_t i = 0; i < vec_h.size(); i++)
	{
		indicator_h.push_back(0);
	}

	//initial
	indicator_h[cHyp.h_id] = 1;
	UpdateUab(cHyp.h_id, UtW, Utx, U1_mat, U2_mat, z, Utz, Uab);

	gsl_vector_const_view eval = gsl_matrix_const_column(Eval_h, cHyp.h_id);
	UpdatePab(cHyp, Uab, &eval.vector, ab, H_eval, Hi_eval, Pab);
	logPost_old = CalcPosterior(H_eval, Pab, cHyp);

	// cout<<"old :"<<cHyp.h_id<<"\t"<<logPost_old<<endl;

	for (size_t i = 0; i < n_mh; i++)
	{
		logMHratio = 0.0;
		logMHratio += ProposeHyper(cHyp, cHyp_new);
		
		//if necessary, calculate Utz, and update Uab
		if (indicator_h[cHyp_new.h_id] == 0)
		{
			indicator_h[cHyp_new.h_id] = 1;
			UpdateUab(cHyp_new.h_id, UtW, Utx, U1_mat, U2_mat, z, Utz, Uab);
		}

		gsl_vector_const_view eval = gsl_matrix_const_column(Eval_h, cHyp_new.h_id);
		UpdatePab(cHyp_new, Uab, &eval.vector, ab, H_eval, Hi_eval, Pab_new);

		logPost_new = CalcPosterior(H_eval, Pab_new, cHyp_new);
		// cout<<cHyp_new.h_id<<"\t"<<logPost_new<<endl;

		logMHratio += logPost_new - logPost_old;
		if (logMHratio > 0 || log(gsl_rng_uniform(gsl_r)) < logMHratio)
		{
			// cout<<"old = "<<logPost_old<<"\t"<<cHyp.gamma<<"\t"<<cHyp.sigma_b2<<"\t"<<cHyp.sigma_u2<<endl;
			// cout<<"new = "<<logPost_new<<"\t"<<cHyp_new.gamma<<"\t"<<cHyp_new.sigma_b2<<"\t"<<cHyp_new.sigma_u2<<endl;

			logPost_old = logPost_new;
			cHyp = cHyp_new;
			gsl_matrix_memcpy(Pab, Pab_new);
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

void NB::SampleBAU(class HYPPAR &cHyp, const gsl_matrix *Eval_h, const gsl_matrix *Pab, const gsl_matrix *Uh_mat, const gsl_matrix *UtW, const gsl_matrix *Utx, const gsl_matrix *Utz, double &beta, vector<double> &alpha, gsl_vector *u)
{
	gsl_matrix *UtW12 = gsl_matrix_alloc(Eval_h->size1, n_cvt);
	gsl_vector *u_prime = gsl_vector_alloc(Eval_h->size1);

	size_t index_zx, index_xz, index_xx;
	size_t index_xw, index_wx, index_zw, index_wz, index_ww;

	double f;
	double P_xx, P_xz, P_zr;
	double P_xw, P_zw, P_ww;

	beta = 0.0;
	gsl_vector_set_zero(u);
	alpha.clear();
	for (size_t i = 0; i < n_cvt; i++)
	{
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
	if (cHyp.gamma == 0)
	{
		beta = 0.0;
	}
	else
	{
		index_zx = FindIndex(n_cvt + 2, n_cvt + 1, n_cvt);
		index_xz = FindIndex(n_cvt + 1, n_cvt + 2, n_cvt);
		P_xz = gsl_matrix_get(Pab, n_cvt, index_xz);
		P_xz += gsl_matrix_get(Pab, n_cvt, index_xz + (n_cvt + 2) * (n_cvt + 2));
		P_xz += gsl_matrix_get(Pab, n_cvt, index_xz + (n_cvt + 2) * (n_cvt + 2) * 2);
		P_xz += gsl_matrix_get(Pab, n_cvt, index_zx + (n_cvt + 2) * (n_cvt + 2) * 2);

		index_xx = FindIndex(n_cvt + 1, n_cvt + 1, n_cvt);
		P_xx = gsl_matrix_get(Pab, n_cvt, index_xx);
		P_xx += gsl_matrix_get(Pab, n_cvt, index_xx + (n_cvt + 2) * (n_cvt + 2));
		P_xx += 2.0 * gsl_matrix_get(Pab, n_cvt, index_xx + (n_cvt + 2) * (n_cvt + 2) * 2);
		P_xx += 1.0 / cHyp.sigma_b2;

		beta = P_xz / P_xx + gsl_ran_gaussian(gsl_r, sqrt(1.0 / P_xx));
		//		cout<<"beta: "<<beta<<"\t"<<P_xz<<"\t"<<P_xx<<endl;
		//		cout<<cHyp.sigma_b2<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_xx)<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_xx+(n_cvt+2)*(n_cvt+2))<<"\t"<<gsl_matrix_get (Pab, n_cvt, index_xx+(n_cvt+2)*(n_cvt+2)*2)<<endl;
	}

	// calculate |Omega_b*sigma_b2| if gamma==1
	index_ww = FindIndex(n_cvt + 1, n_cvt + 1, n_cvt);
	f = gsl_matrix_get(Pab, n_cvt, index_ww);
	f += gsl_matrix_get(Pab, n_cvt, index_ww + (n_cvt + 2) * (n_cvt + 2));
	f += 2.0 * gsl_matrix_get(Pab, n_cvt, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);
	f *= cHyp.sigma_b2;
	f += 1.0;

	/*
	//calculate Pzz
	double P_yy_0, P_yy_1;
	// gamma = 0
	index_ww=FindIndex (n_cvt+2, n_cvt+2, n_cvt);
	P_yy_0=gsl_matrix_get (Pab, n_cvt, index_ww);
	P_yy_0+=gsl_matrix_get (Pab, n_cvt, index_ww+(n_cvt+2)*(n_cvt+2));
	P_yy_0+=2.0*gsl_matrix_get (Pab, n_cvt, index_ww+(n_cvt+2)*(n_cvt+2)*2);
		
	//calculate Pzz when gamma=1
	P_yy_1=gsl_matrix_get (Pab, n_cvt+1, index_ww);
	P_yy_1+=gsl_matrix_get (Pab, n_cvt+1, index_ww+(n_cvt+2)*(n_cvt+2));
	P_yy_1+=2.0*gsl_matrix_get (Pab, n_cvt+1, index_ww+(n_cvt+2)*(n_cvt+2)*2);
		
	double max_value = P_yy_0>P_yy_1?P_yy_0:P_yy_1;
	//cout<<"SampleBAU::P_yy_0 = "<<exp(-0.5*(P_yy_0-max_value))<<endl;
	//cout<<"SampleBAU::P_yy_1 = "<<exp(-0.5*(P_yy_1-max_value))<<endl;
	// cout<<"SampleBAU::pi_beta = "<<pi_beta<<endl;
		
	cHyp.prob_pi = (cHyp.prior_pi)*exp(-0.5*(P_yy_1-max_value))*(1/sqrt(f))/( (cHyp.prior_pi)*exp(-0.5*(P_yy_1-max_value))*(1/sqrt(f))+(1-cHyp.prior_pi)*exp(-0.5*(P_yy_0-max_value)));
	
	//cout<<"SampleBAU::cHyp.prior_pi = "<<cHyp.prior_pi<<endl;
	//cout<<"SampleBAU::cHyp.sigma_b2 = "<<cHyp.sigma_b2<<endl;
	
	//cout<<"SampleBAU::cHyp.prob_pi = "<<cHyp.prob_pi<<endl;
*/
	//sample alpha
	for (size_t i = n_cvt; i >= 1; i--)
	{
		index_xw = FindIndex(n_cvt + 1, i, n_cvt);
		index_wx = FindIndex(i, n_cvt + 1, n_cvt);
		P_xw = gsl_matrix_get(Pab, i - 1, index_xw);
		P_xw += gsl_matrix_get(Pab, i - 1, index_xw + (n_cvt + 2) * (n_cvt + 2));
		P_xw += gsl_matrix_get(Pab, i - 1, index_xw + (n_cvt + 2) * (n_cvt + 2) * 2);
		P_xw += gsl_matrix_get(Pab, i - 1, index_wx + (n_cvt + 2) * (n_cvt + 2) * 2);

		index_zw = FindIndex(n_cvt + 2, i, n_cvt);
		index_wz = FindIndex(i, n_cvt + 2, n_cvt);
		P_zw = gsl_matrix_get(Pab, i - 1, index_zw);
		P_zw += gsl_matrix_get(Pab, i - 1, index_zw + (n_cvt + 2) * (n_cvt + 2));
		P_zw += gsl_matrix_get(Pab, i - 1, index_zw + (n_cvt + 2) * (n_cvt + 2) * 2);
		P_zw += gsl_matrix_get(Pab, i - 1, index_wz + (n_cvt + 2) * (n_cvt + 2) * 2);

		P_zr = P_zw - P_xw * beta;
		for (size_t j = i + 1; j <= n_cvt; j++)
		{
			index_ww = FindIndex(j, i, n_cvt);
			P_ww = gsl_matrix_get(Pab, i - 1, index_ww);
			P_ww += gsl_matrix_get(Pab, i - 1, index_ww + (n_cvt + 2) * (n_cvt + 2));
			P_ww += gsl_matrix_get(Pab, i - 1, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);
			index_ww = FindIndex(i, j, n_cvt);
			P_ww += gsl_matrix_get(Pab, i - 1, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);

			P_zr -= P_ww * alpha[j - 1];
		}

		index_ww = FindIndex(i, i, n_cvt);
		P_ww = gsl_matrix_get(Pab, i - 1, index_ww);
		P_ww += gsl_matrix_get(Pab, i - 1, index_ww + (n_cvt + 2) * (n_cvt + 2));
		P_ww += 2.0 * gsl_matrix_get(Pab, i - 1, index_ww + (n_cvt + 2) * (n_cvt + 2) * 2);

		alpha[i - 1] = P_zr / P_ww + gsl_ran_gaussian(gsl_r, sqrt(1.0 / P_ww));
		//		cout<<"alpha: "<<alpha[i-1]<<"\t"<<P_zr<<"\t"<<P_ww<<"\t"<<P_zw<<"\t"<<P_xw<<"\t"<<beta<<endl;
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
	gsl_vector_const_view Utx1 = gsl_matrix_const_column(Utx, 2 * cHyp.h_id);
	gsl_vector_const_view Utx2 = gsl_matrix_const_column(Utx, 2 * cHyp.h_id + 1);
	gsl_vector_const_view Utz1 = gsl_matrix_const_column(Utz, 2 * cHyp.h_id);
	gsl_vector_const_view Utz2 = gsl_matrix_const_column(Utz, 2 * cHyp.h_id + 1);
	gsl_matrix_const_view UtW1 = gsl_matrix_const_submatrix(UtW, 0, 2 * cHyp.h_id * n_cvt, UtW->size1, n_cvt);
	gsl_matrix_const_view UtW2 = gsl_matrix_const_submatrix(UtW, 0, 2 * cHyp.h_id * n_cvt + n_cvt, UtW->size1, n_cvt);
	gsl_matrix_const_view Uh_sub = gsl_matrix_const_submatrix(Uh_mat, 0, cHyp.h_id * UtW->size1, UtW->size1, UtW->size1);

	gsl_vector_memcpy(u_prime, &Utx1.vector);
	gsl_vector_add(u_prime, &Utx2.vector);
	gsl_vector_scale(u_prime, -1.0 * beta);

	gsl_vector_add(u_prime, &Utz1.vector);
	gsl_vector_add(u_prime, &Utz2.vector);

	gsl_matrix_memcpy(UtW12, &UtW1.matrix);
	gsl_matrix_add(UtW12, &UtW2.matrix);
	for (size_t i = 0; i < n_cvt; i++)
	{
		gsl_vector_view UtW12_col = gsl_matrix_column(UtW12, i);
		gsl_vector_scale(&UtW12_col.vector, alpha[i]);
		gsl_vector_sub(u_prime, &UtW12_col.vector);
	}

	for (size_t i = 0; i < UtW->size1; i++)
	{
		f = gsl_matrix_get(Eval_h, i, cHyp.h_id);
		f *= cHyp.sigma_u2;
		f = f / (1 + f);
		f = gsl_vector_get(u_prime, i) * f + gsl_ran_gaussian(gsl_r, sqrt(f));
		gsl_vector_set(u_prime, i, f);
	}

	clock_t time_start = clock();

	gsl_blas_dgemv(CblasNoTrans, 1.0, &Uh_sub.matrix, u_prime, 0.0, u);

	time_mv += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);

	gsl_matrix_free(UtW12);
	gsl_vector_free(u_prime);

	return;
}

void NB::MCMCInitial(const vector<size_t> &y, const gsl_vector *log_N, class HYPPAR &cHyp, gsl_vector *log_lambda)
{
	//cHyp.h_id=vec_h.size()/2;
	cHyp.h_id = 0;
	cHyp.sb_id = vec_sb.size() / 2;
	cHyp.sigma_u2 = 1.0;
	//cout<<"vec_sb size = "<<vec_sb.size()<<endl;
	//cHyp.sigma_b2=vec_sb[cHyp.sb_id];
	cHyp.sigma_b2 = vb;
	//cout<<"here!"<<endl;
	//if (cHyp.prior_pi==0) {cHyp.gamma=0;} else {cHyp.gamma=1;}
	cHyp.gamma = 1;

	/*
	double f=0.0;
	  for (size_t i=0; i<y.size(); i++) {
	    f+=y[i];
	  }
	  f/=(double)y.size();

	  if (f!=0) {gsl_vector_set_all (log_lambda, log(f) );} else {gsl_vector_set_zero(log_lambda);}
	  gsl_vector_add (log_lambda, log_N);
	  */
	for (size_t i = 0; i < y.size(); i++)
	{
		if (y[i] != 0)
		{
			gsl_vector_set(log_lambda, i, log(y[i]));
		}
		else
		{
			gsl_vector_set(log_lambda, i, 0);
		}
	}

	return;
}

void NB::SampleZ(const vector<size_t> &y, const gsl_vector *log_lambda, gsl_vector *z)
{
	double tau1 = 0.0, tau2 = 0.0;
	for (size_t i = 0; i < log_lambda->size; i++)
	{
		if (y[i] == 0)
		{
			tau2 = 0.0;
		}
		else
		{
			tau2 = gsl_ran_beta(gsl_r, y[i], 1);
		}
		tau1 = gsl_ran_exponential(gsl_r, exp(-1.0 * gsl_vector_get(log_lambda, i)));
		tau1 += 1 - tau2;

		if (tau2 != 0.0)
		{
			tau2 = -1 * log(tau2);
		}
		tau1 = -1 * log(tau1);

		//		cout<<scientific<<tau1<<"\t"<<tau2<<endl;

		gsl_vector_set(z, i, tau1);
		gsl_vector_set(z, i + log_lambda->size, tau2);
	}

	return;
}

//sample mean, weight, and update z
void NB::SampleMW(const vector<size_t> &y, const gsl_vector *log_lambda, const gsl_matrix *weight, const gsl_matrix *mean, const gsl_vector *sigmasq, const gsl_vector *weight1, const gsl_vector *mean1, const double sigmasq1, gsl_vector *z)
{
	double p[10];
	unsigned int n[10];
	double w, m, f, l, s, p_max = 0.0;
	size_t sample_flag = 0;

	for (size_t i = 0; i < log_lambda->size; i++)
	{
		//sample m1, w1, and update z1
		l = gsl_vector_get(log_lambda, i);
		f = gsl_vector_get(z, i);

		for (size_t j = 0; j < 10; j++)
		{
			m = gsl_vector_get(mean1, j);
			p[j] = -0.5 * (f - l - m) * (f - l - m) / sigmasq1;
			if (j == 0)
			{
				p_max = p[j];
			}
			else if (p_max < p[j])
			{
				p_max = p[j];
			}
		}
		for (size_t j = 0; j < 10; j++)
		{
			w = gsl_vector_get(weight1, j);
			p[j] = exp(p[j] - p_max);
			p[j] *= w;
		}
		gsl_ran_multinomial(gsl_r, 10, 1, p, n);
		for (size_t j = 0; j < 10; j++)
		{
			if (n[j] == 1)
			{
				m = gsl_vector_get(mean1, j);
				break;
			}
		}

		gsl_vector_set(z, i, f - m);

		//sample m2, w2, and update z2
		f = gsl_vector_get(z, i + log_lambda->size);

		if (y[i] == 0)
		{
			m = 0;
		}
		else
		{
			sample_flag = 0;
			p_max = 0.0;
			s = gsl_vector_get(sigmasq, i);
			for (size_t j = 0; j < 10; j++)
			{
				w = gsl_matrix_get(weight, i, j);
				if (w == 0)
				{
					continue;
				}

				m = gsl_matrix_get(mean, i, j);

				p[j] = -0.5 * (f - l - m) * (f - l - m) / s;
				if (j == 0)
				{
					p_max = p[j];
				}
				else if (p_max < p[j])
				{
					p_max = p[j];
				}

				sample_flag++;
			}

			if (sample_flag > 1)
			{
				for (size_t j = 0; j < 10; j++)
				{
					w = gsl_matrix_get(weight, i, j);
					if (w == 0)
					{
						p[j] = 0;
						continue;
					} //use continue here
					p[j] = exp(p[j] - p_max);
					p[j] *= w;
				}
				gsl_ran_multinomial(gsl_r, 10, 1, p, n);
				for (size_t j = 0; j < 10; j++)
				{
					if (n[j] == 1)
					{
						m = gsl_matrix_get(mean, i, j);
						break;
					}
				}
			}
		}

		gsl_vector_set(z, i + log_lambda->size, f - m);
	}

	return;
}

void NB::MCMCRun(const vector<size_t> &y, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x, const gsl_vector *log_N, const gsl_vector *D1i, const gsl_vector *D2i, const gsl_matrix *weight, const gsl_matrix *mean, const gsl_vector *sigmasq, const gsl_vector *weight1, const gsl_vector *mean1, const double sigmasq1, gsl_vector *epsilon, class POSTMEAN &cPostM)
{
	clock_t time_start;
	// cout<<" vec_h.size() = " << vec_h.size() << endl;
	//set up matrices, and calculate basic quantities
	gsl_matrix *U1_mat = gsl_matrix_alloc(W->size1, W->size1 * vec_h.size());
	gsl_matrix *U2_mat = gsl_matrix_alloc(W->size1, W->size1 * vec_h.size());
	gsl_matrix *Uh_mat = gsl_matrix_alloc(W->size1, W->size1 * vec_h.size());
	gsl_matrix *Eval_h = gsl_matrix_alloc(W->size1, vec_h.size());

	gsl_matrix *UtW = gsl_matrix_alloc(W->size1, vec_h.size() * n_cvt * 2);
	gsl_matrix *Utx = gsl_matrix_alloc(W->size1, vec_h.size() * 2);
	gsl_matrix *Utz = gsl_matrix_alloc(W->size1, vec_h.size() * 2);


	gsl_vector *log_lambda = gsl_vector_alloc(W->size1);
	gsl_vector *z = gsl_vector_alloc(W->size1 * 2);
	gsl_vector *u = gsl_vector_alloc(W->size1);

	gsl_vector *ab = gsl_vector_alloc((n_cvt + 2) * (n_cvt + 2) * 2);
	gsl_matrix *Uab = gsl_matrix_alloc(W->size1, (n_cvt + 2) * (n_cvt + 2) * 3 * vec_h.size());
	gsl_matrix *Pab = gsl_matrix_alloc(n_cvt + 2, (n_cvt + 2) * (n_cvt + 2) * 3);

	gsl_matrix *W_temp = gsl_matrix_alloc(W->size1, W->size2);

	vector<double> beta_samples, h_samples, sigma_u2_samples, vec_tmp;
	vector< vector<double> > alpha_samples;

	vec_tmp.push_back(0);
	for (size_t i = 0; i < W->size2; i++)
	{
		alpha_samples.push_back(vec_tmp);
	}
	vec_tmp.clear();
	//calculate basic quantities
	//EigenProc (K, B, W, x, D1i, D2i, U1_mat, U2_mat, Uh_mat, Eval_h, UtW, Utx);
	EigenProc(B, W, x, D1i, D2i, U1_mat, U2_mat, Uh_mat, Eval_h, UtW, Utx);

	//calculate ab and Uab
	CalcDab(n_cvt, W, x, D1i, D2i, ab);
	for (size_t i = 0; i < vec_h.size(); i++)
	{
		gsl_matrix_const_view Utx_sub = gsl_matrix_const_submatrix(Utx, 0, i * 2, W->size1, 2);
		gsl_matrix_const_view UtW_sub = gsl_matrix_const_submatrix(UtW, 0, i * 2 * n_cvt, W->size1, 2 * n_cvt);
		gsl_matrix_view Uab_sub = gsl_matrix_submatrix(Uab, 0, i * 3 * (n_cvt + 2) * (n_cvt + 2), W->size1, 3 * (n_cvt + 2) * (n_cvt + 2));
		CalcUab12(n_cvt, &UtW_sub.matrix, &Utx_sub.matrix, &Uab_sub.matrix);
	}// end for


	//initial parameters to zero
	double beta = 0.0;
	vector<double> alpha;

	for (size_t i = 0; i < W->size2; i++)
	{
		alpha.push_back(0.0);
	}
	gsl_vector_set_zero(epsilon);

	//initial MCMC parameters
	class HYPPAR cHyp;
	// initial prior probability of pi
	//cHyp.prior_pi = cPostM.prior_pi;
	//cHyp.prior_pi_u = cPostM.prior_pi_u;
	MCMCInitial(y, log_N, cHyp, log_lambda);

	//cHyp.ig_alpha = cPostM.ig_alpha;
	//cHyp.ig_beta =  cPostM.ig_beta;

	//start MCMC
	for (size_t t = 0; t < (w_step + s_step); t++)
	{
		//	for (size_t t=0; t<1; t++) {
		//sample tau, and update z
		time_start = clock();
		SampleZ(y, log_lambda, z);
		time_s_z += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);

		//sample mean and weights, and update z
		time_start = clock();
		SampleMW(y, log_lambda, weight, mean, sigmasq, weight1, mean1, sigmasq1, z);
		time_s_mw += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);

		//subtract log_N, and update z
		gsl_vector_view z_1 = gsl_vector_subvector(z, 0, W->size1);
		gsl_vector_view z_2 = gsl_vector_subvector(z, W->size1, W->size1);
		gsl_vector_sub(&z_1.vector, log_N);
		gsl_vector_sub(&z_2.vector, log_N);
		/*
		cout<<"z_1 = ";
		for (size_t j=0; j<W->size1; j++) {
			cout<<gsl_vector_get(z, j)<<", ";
		}
		cout<<endl;
		cout<<"z_2 = ";
		for (size_t j=0; j<W->size1; j++) {
			cout<<gsl_vector_get(z, j+W->size1)<<", ";
		}
		cout<<endl;
		*/
		//update ab, but not Uab
		CalcDab(n_cvt, W, x, z, D1i, D2i, ab);

		//sample hyp-parameters, within which update Uab and Pab if necessary
		time_start = clock();
		SampleHyper(Eval_h, UtW, Utx, U1_mat, U2_mat, z, ab, Utz, Uab, Pab, cHyp);
		time_s_h += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);
	
		//sample beta, alpha and u
		time_start = clock();
		SampleBAU(cHyp, Eval_h, Pab, Uh_mat, UtW, Utx, Utz, beta, alpha, u);
		time_s_bau += (clock() - time_start) / (double(CLOCKS_PER_SEC) * 60.0);
		/*
		cout<<"beta = "<<beta<<endl;
		*/
		if (fabs(beta) < 1e-10)
		{
			beta = 0;
			cHyp.gamma = 0;
		}

		//save results
		if (t >= w_step)
		{
			if (cHyp.gamma == 1)
			{
				cPostM.beta += beta;
				cPostM.gamma += 1.0;
				// cPostM.inv_sigma_b2 += 1.0 / cHyp.sigma_b2;
				// cPostM.log_sigma_b2 += log(cHyp.sigma_b2);

				beta_samples.push_back(beta);
			}

			cPostM.h += vec_h[cHyp.h_id];
			cPostM.sigma_u2 += cHyp.sigma_u2;

			h_samples.push_back(vec_h[cHyp.h_id]);
			sigma_u2_samples.push_back(cHyp.sigma_u2);

			for (size_t i = 0; i < alpha.size(); i++)
			{
				cPostM.alpha[i] += alpha[i];

				if (t == w_step)
				{
					alpha_samples[i][0] = alpha[i];
				}
				else
				{
					alpha_samples[i].push_back(alpha[i]);
				}
			}
			//			cout<<beta<<"\t"<<alpha[0]<<"\t"<<cHyp.rho<<"\t"<<cHyp.sigma_b2<<"\t"<<cHyp.sigma_u2<<"\t"<<vec_h[cHyp.h_id]<<endl;

			gsl_vector_add(epsilon, u);
		}

		
		//update log_lambda
		gsl_vector_memcpy(log_lambda, x);
		gsl_vector_scale(log_lambda, beta);

		gsl_matrix_memcpy(W_temp, W);
		for (size_t i = 0; i < n_cvt; i++)
		{
			gsl_vector_view W_col = gsl_matrix_column(W_temp, i);
			gsl_vector_scale(&W_col.vector, alpha[i]);
			gsl_vector_add(log_lambda, &W_col.vector);
		}

		gsl_vector_add(log_lambda, u);
		gsl_vector_add(log_lambda, log_N);
	}

	cPostM.h /= (double)s_step;
	gsl_vector_scale(epsilon, 1.0 / (double)s_step);

	if (cPostM.gamma == 0)
	{
		cPostM.beta = 0.0;
		// cPostM.inv_sigma_b2 = 0.0; //!!!!!
		// cPostM.log_sigma_b2 = 0.0; //!!!!!
	}
	else
	{
		cPostM.beta /= (double)cPostM.gamma;
		// cPostM.inv_sigma_b2 /= (double)cPostM.gamma; //!!!!!
		// cPostM.log_sigma_b2 /= (double)cPostM.gamma; //!!!!!
	}

	cPostM.gamma /= (double)s_step;

	for (size_t i = 0; i < W->size2; i++)
	{
		cPostM.alpha[i] /= (double)s_step;
		cPostM.alpha_se[i] = calcSD(alpha_samples[i]);
	}

	//obtain quantiles
	size_t l = beta_samples.size();
	if (l == 0)
	{
		cPostM.beta_025 = 0.0;
		cPostM.beta_500 = 0.0;
		cPostM.beta_975 = 0.0;
	}
	else
	{
		cPostM.beta_se = calcSD(beta_samples);

		sort(beta_samples.begin(), beta_samples.end());
		cPostM.beta_025 = beta_samples[(size_t)((double)l * 0.025)];
		cPostM.beta_500 = beta_samples[(size_t)((double)l * 0.500)];
		cPostM.beta_975 = beta_samples[(size_t)((double)l * 0.975)];
	}

	l = h_samples.size();
	if (l == 0)
	{
		cPostM.h_025 = 0.0;
		cPostM.h_500 = 0.0;
		cPostM.h_975 = 0.0;
	}
	else
	{
		cPostM.h_se = calcSD(h_samples);

		sort(h_samples.begin(), h_samples.end());
		cPostM.h_025 = h_samples[(size_t)((double)l * 0.025)];
		cPostM.h_500 = h_samples[(size_t)((double)l * 0.500)];
		cPostM.h_975 = h_samples[(size_t)((double)l * 0.975)];
	}

	l = sigma_u2_samples.size();
	if (l == 0)
	{
		cPostM.sigma_u2_025 = 0.0;
		cPostM.sigma_u2_500 = 0.0;
		cPostM.sigma_u2_975 = 0.0;
	}
	else
	{
		cPostM.sigma_u2_se = calcSD(sigma_u2_samples);

		sort(sigma_u2_samples.begin(), sigma_u2_samples.end());
		cPostM.sigma_u2_025 = sigma_u2_samples[(size_t)((double)l * 0.025)];
		cPostM.sigma_u2_500 = sigma_u2_samples[(size_t)((double)l * 0.500)];
		cPostM.sigma_u2_975 = sigma_u2_samples[(size_t)((double)l * 0.975)];
	}

	cPostM.acc_rate = n_accept / ((double)(w_step + s_step) * (double)n_mh);

	gsl_matrix_free(U1_mat);
	gsl_matrix_free(U2_mat);
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

	gsl_matrix_free(W_temp);

	beta_samples.clear();
	h_samples.clear();
	sigma_u2_samples.clear();
	vec_tmp.clear();
	alpha_samples.clear();
	return;
}

//void NB::Analysis(const gsl_matrix *Read, const gsl_matrix *Depth, gsl_matrix *Ac, gsl_matrix_int *Ad, gsl_vector_int *dlevel, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x)
void NB::Analysis(const gsl_matrix *Read, const gsl_matrix *Depth, const gsl_matrix *B, const gsl_matrix *W, const gsl_vector *x)
{
	sumPost.clear();
	indicator_gene.clear();
	size_t ng_total = Read->size1, ni_test = W->size1;
	n_cvt = W->size2;

	// scale B_sub by the mean of diagonal elements
	//gsl_matrix *K_scaled=gsl_matrix_alloc (K->size1, K->size2);
	gsl_matrix *B_scaled = gsl_matrix_alloc(B->size1, B->size2);
	//gsl_matrix_memcpy (K_scaled, K);
	gsl_matrix_memcpy(B_scaled, B);

	gsl_matrix *mean = gsl_matrix_alloc(W->size1, 10);
	gsl_vector *sigmasq = gsl_vector_alloc(W->size1);
	gsl_vector *D2i = gsl_vector_alloc(W->size1);
	gsl_vector *log_N = gsl_vector_alloc(W->size1);
	gsl_vector *epsilon = gsl_vector_alloc(W->size1);

	double f = 0.0;


	for (size_t i = 0; i < B_scaled->size1; i++)
	{
		f += gsl_matrix_get(B_scaled, i, i);
	}
	f /= (double)B_scaled->size1;
	gsl_matrix_scale(B_scaled, 1.0 / f);

	//prepare analysis
	vector<size_t> y;
	size_t ci_test, nu;
	double var_y, mean_y;

	//set up random seed
	gsl_rng_env_setup();
	const gsl_rng_type *gslType;
	gslType = gsl_rng_default;
	if (randseed < 0)
	{
		time_t rawtime;
		time(&rawtime);
		tm *ptm = gmtime(&rawtime);

		randseed = (unsigned)(ptm->tm_hour % 24 * 3600 + ptm->tm_min * 60 + ptm->tm_sec);
	}
	gsl_r = gsl_rng_alloc(gslType);
	gsl_rng_set(gsl_r, randseed);

	gsl_matrix *weight = gsl_matrix_alloc(W->size1, 10);

	gsl_vector *weight1 = gsl_vector_alloc(10);
	gsl_vector *mean1 = gsl_vector_alloc(10);

	double sigmasq1;

	gsl_vector *D1i = gsl_vector_alloc(W->size1);

	NormalMixture(1, weight1, mean1, sigmasq1);
	gsl_vector_set_all(D1i, 1.0 / sigmasq1);

	class POSTMEAN cPostM;
	ng_test = 0;
	for (size_t i = 0; i < ng_total; i++)
	{
		if (i % display_pace == 0 || i == ng_total - 1)
		{
			ProgressBar("Performing Analysis ", i, ng_total - 1);
		}

		//if(it<1){cPostM.prior_pi = 0.5;}
		//else{cPostM.prior_pi = gsl_vector_get(prior_vec,i);}

		gsl_matrix_set_zero(mean);
		gsl_matrix_set_zero(weight);
		gsl_vector_set_zero(D2i);

		ci_test = 0;
		var_y = 0.0;
		mean_y = 0.0;
		y.clear();
		n_accept = 0;
		cPostM.n = 0;
		for (size_t j = 0; j < ni_test; ++j)
		{
			nu = gsl_matrix_get(Read, i, j);
			y.push_back(nu);
			var_y += nu * nu;
			mean_y += nu;

			if (Depth->size1 == 1)
			{
				f = gsl_matrix_get(Depth, 0, j);
			}
			else
			{
				f = gsl_matrix_get(Depth, i, j);
			}
			if (f != 0)
			{
				f = log(f);
			}
			gsl_vector_set(log_N, j, f);

			if (nu != 0)
			{
				gsl_vector_view w_row = gsl_matrix_row(weight, ci_test);
				gsl_vector_view m_row = gsl_matrix_row(mean, ci_test);
				NormalMixture(nu, &w_row.vector, &m_row.vector, f);
				gsl_vector_set(sigmasq, ci_test, f);
				gsl_vector_set(D2i, ci_test, 1.0 / f);
				cPostM.n++;
			}
			ci_test++;
		}
		var_y /= (double)ni_test;
		mean_y /= (double)ni_test;
		var_y -= mean_y * mean_y;
		cPostM.initial(n_cvt);
		if (var_y != 0 || mean_y > 0)
		{
			MCMCRun(y, B_scaled, W, x, log_N, D1i, D2i, weight, mean, sigmasq, weight1, mean1, sigmasq1, epsilon, cPostM);
			indicator_gene.push_back(1);
			ng_test++;
		}
		else
		{
			indicator_gene.push_back(0);
		}

		sumPost.push_back(cPostM);
	} // end for genes
	  //cPostM.prior_pi = sum_gamma/ng_test;
	  //cout<<endl;
	  //*******************************************
	  //deal with sigma_b2 parameters, s and r   //
	  //*******************************************
	  //cout<<"sum_log_sigma_b2="<<sum_log_sigma_b2<<"; sum_inv_sigma_b2="<<sum_inv_sigma_b2<<endl;
	  //cal_igamma_param( (int)sum_gamma, sum_log_sigma_b2, sum_inv_sigma_b2, cPostM );
	  //cal_igamma_param( ng_test, sum_log_sigma_b2, sum_inv_sigma_b2, cPostM );
	  //cout << it+1 <<": cPostM.ig_alpha="<<cPostM.ig_alpha<<";   cPostM.ig_beta="<<cPostM.ig_beta<<";   sum_gamma="<<sum_gamma<<endl;

	//ig_alpha = cPostM.ig_alpha;
	//ig_beta = cPostM.ig_beta;
	//***************************************
	//deal with enrichment parameters, u   //
	//***************************************
	/* for(size_t i=0;i<ng_total;i++){
			cout<<"geap::pip_vec="<<gsl_vector_get(pip_vec,i)<<endl;
		}*/

	//cout<<"geap::num_coeff = "<<ncoef<<endl;
	//gsl_vector *coef_u = gsl_vector_calloc(ncoef);
	//u_vec = gsl_vector_calloc(ncoef);// global variable
	//if(it==1){gsl_vector_set_zero(coef_u_old);}
	//cout<<"calculate the coefficient of annotations"<<endl;
	//if(n_kc==0 && n_kd!=0){//only discrete annotations
	//	if(n_kd == 1){
	//		single_ct_regression(Ad, dlevel, pip_vec, coef_u, prior_vec, ng_test);
	//	}else{
	//cout<<"geap::here"<<endl;
	//		logistic_cat_fit(coef_u, Ad, dlevel, pip_vec, 0, 0);
	//cout<<"geap::here2"<<endl;
	//		logistic_cat_pred(coef_u, Ad, dlevel, prior_vec);
	//	}
	//} else if (n_kc!=0 && n_kd==0) {//only continuous annotations
	//	logistic_cont_fit(coef_u, Ac, pip_vec, 0, 0);
	//	logistic_cont_pred(coef_u, Ac, prior_vec);
	//} else if (n_kc!=0 && n_kd!=0) {//both continuous and categorical annotations
	//	logistic_mixed_fit(coef_u, Ad, dlevel, Ac, pip_vec, 0, 0);
	//	logistic_mixed_pred(coef_u, Ad, dlevel, Ac, prior_vec);
	//}
	//cout<< it+1 <<": coefficient of annotations:"<<endl;
	//for(int i=0;i<ncoef;i++){cout<<gsl_vector_get(coef_u,i)<<" ";}
	//cout<<endl;
	//double conv_cond = 0.0;
	//for(int i=0;i<ncoef;i++){conv_cond += pow(gsl_vector_get(coef_u,i)-gsl_vector_get(coef_u_old,i),2);}
	//for(int i=0;i<ncoef;i++){conv_cond += //abs(gsl_vector_get(coef_u,i)-gsl_vector_get(coef_u_old,i))/(abs(gsl_vector_get(coef_u,i))+abs(gsl_vector_get(coef_u_old,i)) );}
	//*********************************************************************
	/*for(size_t i=0;i<ng_total;i++){
			cout<<"geap::prior_vec="<<gsl_vector_get(prior_vec,i)<<endl;
		}*/
	// check the convergence
	/* if(abs(ig_alpha-cPostM.ig_alpha)/(abs(ig_alpha)+abs(cPostM.ig_alpha))<5e-3||abs(ig_beta-cPostM.ig_beta)/(abs(ig_beta)+abs(cPostM.ig_beta))<5e-3||it>=n_iter-1||conv_cond<1e-3){
			gsl_vector_memcpy(u_vec,coef_u);
			break;
		} */
	//if(it>=n_iter-1||conv_cond<1e-4){
	//	gsl_vector_memcpy(u_vec,coef_u);
	//	break;
	//}else{sumPost.clear(); indicator_gene.clear(); ig_alpha = cPostM.ig_alpha; ig_beta = cPostM.ig_beta;}

	//if(it>1){
	//	for(int i=0;i<ncoef;i++){
	//		gsl_vector_set(coef_u_old,i,gsl_vector_get(coef_u,i));
	//	}
	//}
	//cout<<endl;
	//***************************
	// release
	//gsl_vector_free(coef_u);

	//}// end for iteration
	gsl_matrix_free(mean);
	gsl_matrix_free(weight);
	gsl_vector_free(D2i);
	gsl_vector_free(log_N);
	gsl_vector_free(epsilon);
	gsl_vector_free(sigmasq);
	//gsl_matrix_free(K_scaled);
	gsl_matrix_free(B_scaled);
	gsl_vector_free(weight1);
	gsl_vector_free(mean1);
	gsl_vector_free(D1i);

	return;
}

/*
// likelihood function of inverse gamma distribution
double eval_loglik_func(const gsl_vector *v, void *params) {
  double a, b;
  double *dp = (double *)params;
  double N = dp[0];
  double sum_log_sigma2 = dp[1];
  double sum_inv_sigma2 = dp[2];

  a = exp(gsl_vector_get(v, 0));
  b = exp(gsl_vector_get(v, 1));

  return (-N*(a*log(b)-lgamma(a)) + (a+1)*sum_log_sigma2 + b*sum_inv_sigma2 );

 }


 
// calculate the parameters for inverse gamma distribution
void NB::cal_igamma_param( int ng_test, double sum_log_sigma_b2, double sum_inv_sigma_b2, class POSTMEAN &cPostM )
 {
	 
   // number of variable to solve
   size_t np = 2;
   gsl_multimin_fminimizer *s;
   gsl_vector *ss, *x;

   gsl_multimin_function ex4_fn;

   int status;
   double size;

   cPostM.ig_alpha = 0;
   cPostM.ig_beta = 0;
   // initial vertex size vector
   ss = gsl_vector_alloc( np );
   gsl_vector_set_all( ss, 1.0 ); // Set all step sizes to 1

   // initialze the variable and value
   x = gsl_vector_alloc ( np );
   gsl_vector_set(x, 0, 2.0);
   gsl_vector_set(x, 1, 1.0);

   // initialize method and iterate
   ex4_fn.f = &eval_loglik_func;  //address of the function
   ex4_fn.n = np;               // dimension of the problem
   // The parameter vector for the function defn: UNUSED
   double d_ng_total = static_cast<double>(ng_test);
   double pars[3] = {d_ng_total, sum_log_sigma_b2, sum_inv_sigma_b2};
   ex4_fn.params  = (void *)pars;

   s = gsl_multimin_fminimizer_alloc( gsl_multimin_fminimizer_nmsimplex, np );
   // the function gsl_multimin_fminimizer_set initializes the minimizer s to minimize the function
   // f, starting from the initial point x. the size of the initial trial steps is given in vector ss(step_size)
   // the precise meaning of this parameter depends on the method used.
   gsl_multimin_fminimizer_set( s, &ex4_fn, x, ss );

   size_t iter = 0;
   do{
       iter++;
       status = gsl_multimin_fminimizer_iterate( s );

       if(status) {break;}

       size = gsl_multimin_fminimizer_size( s );
       status = gsl_multimin_test_size( size, 1e-3 );


       if (status == GSL_SUCCESS) {
		  printf("\n");
		  printf("IG:converged to minimum!\n");
		  cPostM.ig_alpha = exp(gsl_vector_get( s->x, 0 ));
		  cPostM.ig_beta = exp(gsl_vector_get( s->x, 1 ));
	   }else{
		  cPostM.ig_alpha = 2;
		  cPostM.ig_beta = 1;
	   }

   } while( status == GSL_CONTINUE && iter < 100 );

   gsl_vector_free( x );
   gsl_vector_free( ss );
   gsl_multimin_fminimizer_free( s );

   return;

 }// end function

 */
