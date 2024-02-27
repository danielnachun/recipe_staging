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
#include <limits.h>

#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"
#include "gsl/gsl_linalg.h"
#include "gsl/gsl_blas.h"
#include "gsl/gsl_cdf.h"
#include "Eigen/Dense"

#include "lapack.h"

#ifdef FORCE_FLOAT
#include "mathfunc_float.h"
#else
#include "mathfunc.h"
#endif


using namespace std;
using namespace Eigen;


//calculate variance of a vector
double VectorVar (const gsl_vector *v)
{
	double d, m=0.0, m2=0.0;
	for (size_t i=0; i<v->size; ++i) {
		d=gsl_vector_get (v, i);
		m+=d;
		m2+=d*d;
	}
	m/=(double)v->size;
	m2/=(double)v->size;
	return m2-m*m;
}



//center the matrix G
void CenterMatrix (gsl_matrix *G)
{
	double d;
	gsl_vector *w=gsl_vector_alloc (G->size1);
	gsl_vector *Gw=gsl_vector_alloc (G->size1);
	gsl_vector_set_all (w, 1.0);

	gsl_blas_dgemv (CblasNoTrans, 1.0, G, w, 0.0, Gw);
	gsl_blas_dsyr2 (CblasUpper, -1.0/(double)G->size1, Gw, w, G);
	gsl_blas_ddot (w, Gw, &d);
	gsl_blas_dsyr (CblasUpper, d/((double)G->size1*(double)G->size1), w, G);

	for (size_t i=0; i<G->size1; ++i) {
		for (size_t j=0; j<i; ++j) {
			d=gsl_matrix_get (G, j, i);
			gsl_matrix_set (G, i, j, d);
		}
	}

	gsl_vector_free(w);
	gsl_vector_free(Gw);

	return;
}


//center the matrix G
void CenterMatrix (gsl_matrix *G, const gsl_vector *w)
{
	double d, wtw;
	gsl_vector *Gw=gsl_vector_alloc (G->size1);

	gsl_blas_ddot (w, w, &wtw);
	gsl_blas_dgemv (CblasNoTrans, 1.0, G, w, 0.0, Gw);
	gsl_blas_dsyr2 (CblasUpper, -1.0/wtw, Gw, w, G);
	gsl_blas_ddot (w, Gw, &d);
	gsl_blas_dsyr (CblasUpper, d/(wtw*wtw), w, G);

	for (size_t i=0; i<G->size1; ++i) {
		for (size_t j=0; j<i; ++j) {
			d=gsl_matrix_get (G, j, i);
			gsl_matrix_set (G, i, j, d);
		}
	}

	gsl_vector_free(Gw);

	return;
}



//center the matrix G
void CenterMatrix (gsl_matrix *G, const gsl_matrix *W)
{
	gsl_matrix *WtW=gsl_matrix_alloc (W->size2, W->size2);
	gsl_matrix *WtWi=gsl_matrix_alloc (W->size2, W->size2);
	gsl_matrix *WtWiWt=gsl_matrix_alloc (W->size2, G->size1);
	gsl_matrix *GW=gsl_matrix_alloc (G->size1, W->size2);
	gsl_matrix *WtGW=gsl_matrix_alloc (W->size2, W->size2);
	gsl_matrix *Gtmp=gsl_matrix_alloc (G->size1, G->size1);

	gsl_blas_dgemm (CblasTrans, CblasNoTrans, 1.0, W, W, 0.0, WtW);

	int sig;
	gsl_permutation * pmt=gsl_permutation_alloc (W->size2);
	LUDecomp (WtW, pmt, &sig);
	LUInvert (WtW, pmt, WtWi);

	gsl_blas_dgemm (CblasNoTrans, CblasTrans, 1.0, WtWi, W, 0.0, WtWiWt);
	gsl_blas_dgemm (CblasNoTrans, CblasNoTrans, 1.0, G, W, 0.0, GW);
	gsl_blas_dgemm (CblasNoTrans, CblasNoTrans, 1.0, GW, WtWiWt, 0.0, Gtmp);

	gsl_matrix_sub (G, Gtmp);
	gsl_matrix_transpose (Gtmp);
	gsl_matrix_sub (G, Gtmp);

	gsl_blas_dgemm (CblasTrans, CblasNoTrans, 1.0, W, GW, 0.0, WtGW);
	//GW is destroyed
	gsl_blas_dgemm (CblasTrans, CblasNoTrans, 1.0, WtWiWt, WtGW, 0.0, GW);
	gsl_blas_dgemm (CblasNoTrans, CblasNoTrans, 1.0, GW, WtWiWt, 0.0, Gtmp);

	gsl_matrix_add (G, Gtmp);

	gsl_matrix_free(WtW);
	gsl_matrix_free(WtWi);
	gsl_matrix_free(WtWiWt);
	gsl_matrix_free(GW);
	gsl_matrix_free(WtGW);
	gsl_matrix_free(Gtmp);

	return;
}


//scale the matrix G such that the mean diagonal = 1
double ScaleMatrix (gsl_matrix *G)
{
	double d=0.0;

	for (size_t i=0; i<G->size1; ++i) {
		d+=gsl_matrix_get(G, i, i);
	}
	d/=(double)G->size1;

	if (d!=0) {
	  gsl_matrix_scale (G, 1.0/d);
	}

	return d;
}


//center the vector y
double CenterVector (gsl_vector *y)
{
	double d=0.0;

	for (size_t i=0; i<y->size; ++i) {
		d+=gsl_vector_get (y, i);
	}
	d/=(double)y->size;

	gsl_vector_add_constant (y, -1.0*d);

	return d;
}


//center the vector y
void CenterVector (gsl_vector *y, const gsl_matrix *W)
{
	gsl_matrix *WtW=gsl_matrix_alloc (W->size2, W->size2);
	gsl_vector *Wty=gsl_vector_alloc (W->size2);
	gsl_vector *WtWiWty=gsl_vector_alloc (W->size2);

	gsl_blas_dgemm (CblasTrans, CblasNoTrans, 1.0, W, W, 0.0, WtW);
	gsl_blas_dgemv (CblasTrans, 1.0, W, y, 0.0, Wty);

	int sig;
	gsl_permutation * pmt=gsl_permutation_alloc (W->size2);
	LUDecomp (WtW, pmt, &sig);
	LUSolve (WtW, pmt, Wty, WtWiWty);

	gsl_blas_dgemv (CblasNoTrans, -1.0, W, WtWiWty, 1.0, y);

	gsl_matrix_free(WtW);
	gsl_vector_free(Wty);
	gsl_vector_free(WtWiWty);

	return;
}


//standardize vector y to have mean 0 and y^ty/n=1
void StandardizeVector (gsl_vector *y)
{
  double d=0.0, m=0.0, v=0.0;

  for (size_t i=0; i<y->size; ++i) {
    d=gsl_vector_get (y, i);
    m+=d;
    v+=d*d;
  }
  m/=(double)y->size;
  v/=(double)y->size;
  v-=m*m;

  gsl_vector_add_constant (y, -1.0*m);
  gsl_vector_scale (y, 1.0/sqrt(v));

  return;
}


//calculate UtX
void CalcUtX (const gsl_matrix *U, gsl_matrix *UtX)
{
	gsl_vector *Utx_vec=gsl_vector_alloc (UtX->size1);
	for (size_t i=0; i<UtX->size2; ++i) {
		gsl_vector_view UtX_col=gsl_matrix_column (UtX, i);
		gsl_blas_dgemv (CblasTrans, 1.0, U, &UtX_col.vector, 0.0, Utx_vec);
		gsl_vector_memcpy (&UtX_col.vector, Utx_vec);
	}
	gsl_vector_free (Utx_vec);
	return;
}


void CalcUtX (const gsl_matrix *U, const gsl_matrix *X, gsl_matrix *UtX)
{
	for (size_t i=0; i<X->size2; ++i) {
		gsl_vector_const_view X_col=gsl_matrix_const_column (X, i);
		gsl_vector_view UtX_col=gsl_matrix_column (UtX, i);
		gsl_blas_dgemv (CblasTrans, 1.0, U, &X_col.vector, 0.0, &UtX_col.vector);
	}
	return;
}

void CalcUtX (const gsl_matrix *U, const gsl_vector *x, gsl_vector *Utx)
{
	gsl_blas_dgemv (CblasTrans, 1.0, U, x, 0.0, Utx);
	return;
}


//Kronecker product
void Kronecker(const gsl_matrix *K, const gsl_matrix *V, gsl_matrix *H)
{
	for (size_t i=0; i<K->size1; i++) {
		for (size_t j=0; j<K->size2; j++) {
			gsl_matrix_view H_sub=gsl_matrix_submatrix (H, i*V->size1, j*V->size2, V->size1, V->size2);
			gsl_matrix_memcpy (&H_sub.matrix, V);
			gsl_matrix_scale (&H_sub.matrix, gsl_matrix_get (K, i, j));
		}
	}
	return;
}

//symmetric K matrix
void KroneckerSym(const gsl_matrix *K, const gsl_matrix *V, gsl_matrix *H)
{
	for (size_t i=0; i<K->size1; i++) {
		for (size_t j=i; j<K->size2; j++) {
			gsl_matrix_view H_sub=gsl_matrix_submatrix (H, i*V->size1, j*V->size2, V->size1, V->size2);
			gsl_matrix_memcpy (&H_sub.matrix, V);
			gsl_matrix_scale (&H_sub.matrix, gsl_matrix_get (K, i, j));

			if (i!=j) {
				gsl_matrix_view H_sub_sym=gsl_matrix_submatrix (H, j*V->size1, i*V->size2, V->size1, V->size2);
				gsl_matrix_memcpy (&H_sub_sym.matrix, &H_sub.matrix);
			}
		}
	}
	return;
}


// this function calculates HWE p value with methods described in Wigginton et al., 2005 AJHG;
// it is based on the code in plink 1.07
double CalcHWE (const size_t n_hom1, const size_t n_hom2, const size_t n_ab)
{
	if ( (n_hom1+n_hom2+n_ab)==0 ) {return 1;}

	//aa is the rare allele
	int n_aa=n_hom1 < n_hom2 ? n_hom1 : n_hom2;
	int n_bb=n_hom1 < n_hom2 ? n_hom2 : n_hom1;

	int rare_copies = 2 * n_aa + n_ab;
	int genotypes   = n_ab + n_bb + n_aa;

	double * het_probs = (double *) malloc( (rare_copies + 1) * sizeof(double));
	if (het_probs == NULL)
		cout<<"Internal error: SNP-HWE: Unable to allocate array"<<endl;

		int i;
	for (i = 0; i <= rare_copies; i++)
		het_probs[i] = 0.0;

	/* start at midpoint */
		int mid = rare_copies * (2 * genotypes - rare_copies) / (2 * genotypes);

	/* check to ensure that midpoint and rare alleles have same parity */
		if ((rare_copies & 1) ^ (mid & 1))
			mid++;

	int curr_hets = mid;
	int curr_homr = (rare_copies - mid) / 2;
	int curr_homc = genotypes - curr_hets - curr_homr;

	het_probs[mid] = 1.0;
	double sum = het_probs[mid];
	for (curr_hets = mid; curr_hets > 1; curr_hets -= 2)
    {
		het_probs[curr_hets - 2] = het_probs[curr_hets] * curr_hets * (curr_hets - 1.0)
		/ (4.0 * (curr_homr + 1.0) * (curr_homc + 1.0));
		sum += het_probs[curr_hets - 2];

		/* 2 fewer heterozygotes for next iteration -> add one rare, one common homozygote */
		curr_homr++;
		curr_homc++;
    }

	curr_hets = mid;
	curr_homr = (rare_copies - mid) / 2;
	curr_homc = genotypes - curr_hets - curr_homr;
	for (curr_hets = mid; curr_hets <= rare_copies - 2; curr_hets += 2)
    {
		het_probs[curr_hets + 2] = het_probs[curr_hets] * 4.0 * curr_homr * curr_homc
		/((curr_hets + 2.0) * (curr_hets + 1.0));
		sum += het_probs[curr_hets + 2];

		/* add 2 heterozygotes for next iteration -> subtract one rare, one common homozygote */
		curr_homr--;
		curr_homc--;
    }

	for (i = 0; i <= rare_copies; i++)
		het_probs[i] /= sum;

	/* alternate p-value calculation for p_hi/p_lo
	 double p_hi = het_probs[n_ab];
	 for (i = n_ab + 1; i <= rare_copies; i++)
     p_hi += het_probs[i];

	 double p_lo = het_probs[n_ab];
	 for (i = n_ab - 1; i >= 0; i--)
	 p_lo += het_probs[i];

	 double p_hi_lo = p_hi < p_lo ? 2.0 * p_hi : 2.0 * p_lo;
	 */

		double p_hwe = 0.0;
	/*  p-value calculation for p_hwe  */
		for (i = 0; i <= rare_copies; i++)
		{
			if (het_probs[i] > het_probs[n_ab])
				continue;
			p_hwe += het_probs[i];
		}

	p_hwe = p_hwe > 1.0 ? 1.0 : p_hwe;

	free(het_probs);

	return p_hwe;
}




double UcharToDouble02(const unsigned char c) {
  return (double)c*0.01;
  //  return (double)c*2/(double)UCHAR_MAX;
}

unsigned char Double02ToUchar(const double dosage) {
  return (int) (dosage*100);
  //  return (int) (dosage/2*UCHAR_MAX);
}





void uchar_matrix_get_row (const vector<vector<unsigned char> > &X, const size_t i_row, VectorXd &x_row)
{
  if (i_row<X.size()) {
    for (size_t j=0; j<x_row.size(); j++) {
      x_row(j)=UcharToDouble02(X[i_row][j]);
    }
  } else {
    std::cerr << "Error return genotype vector...\n";
    exit(1);
  }
}


/*
void getGTgslVec(uchar ** X, gsl_vector *xvec, size_t marker_i, const size_t ni_test, const size_t ns_test){

    double geno, geno_mean = 0.0;
    if (marker_i < ns_test ) {
        for (size_t j=0; j<ni_test; j++) {
            geno = UcharToDouble(X[marker_i][j]);
            //cout << geno << ", ";
            if (geno < 0.0 || geno > 2.0) {
                cerr << "wrong genotype value = " << geno << endl;
                exit(1);
            }
            gsl_vector_set(xvec, j, geno);
            geno_mean += geno;
        }
        geno_mean /= (double)ni_test;
        geno_mean = -geno_mean;
        gsl_vector_add_constant(xvec, geno_mean); // center genotypes here
    }
    else {
        std::cerr << "Error return genotype vector...\n";
        exit(1);
    }
    //cout << endl;
}
*/



