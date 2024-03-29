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
#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"

using namespace std;

extern "C" void dsyev_(char* JOBZ, char* UPLO, int *N, double *A, int *LDA, double *W, double *WORK, int *LWORK, int *INFO);
extern "C" void ssyev_(char* JOBZ, char* UPLO, int *N, float *A, int *LDA, float *W, float *WORK, int *LWORK, int *INFO);


//eigen value decomposition, matrix A is destroyed
void lapack_double_eigen_symmv (gsl_matrix *A, gsl_vector *eval, gsl_matrix *evec)
{
	int N=A->size1, LDA=A->size1, INFO, LWORK=-1;
	char JOBZ='V', UPLO='L';
	double temp[1];

	if (N!=(int)A->size2 || N!=(int)eval->size) {cout<<"Matrix needs to be symmetric and same dimension in lapack_eigen_symmv."<<endl; return;}

	dsyev_(&JOBZ, &UPLO, &N, A->data, &LDA, eval->data, temp, &LWORK, &INFO);
	if (INFO!=0) {cout<<"Work space estimate unsuccessful in lapack_eigen_symmv."<<endl; return;}
	
	LWORK=(int)temp[0];
	double *WORK=new double [LWORK];	
	dsyev_(&JOBZ, &UPLO, &N, A->data, &LDA, eval->data, WORK, &LWORK, &INFO);
	if (INFO!=0) {cout<<"Eigen decomposition unsuccessful in lapack_eigen_symmv."<<endl; return;}
	
	gsl_matrix_view A_sub=gsl_matrix_submatrix(A, 0, 0, N, N);
	gsl_matrix_memcpy (evec, &A_sub.matrix);
	gsl_matrix_transpose (evec);

  	delete [] WORK;
	return;
}



//eigen value decomposition, matrix A is destroyed, float seems to have problem with large matrices
void lapack_float_eigen_symmv (gsl_matrix_float *A, gsl_vector_float *eval, gsl_matrix_float *evec)
{
	int N=A->size1, LDA=A->size1, INFO, LWORK=-1;
	char JOBZ='V', UPLO='L';
	float temp[1];

	if (N!=(int)A->size2 || N!=(int)eval->size) {cout<<"Matrix needs to be symmetric and same dimension in lapack_eigen_symmv."<<endl; return;}

	ssyev_(&JOBZ, &UPLO, &N, A->data, &LDA, eval->data, temp, &LWORK, &INFO);
	if (INFO!=0) {cout<<"Work space estimate unsuccessful in lapack_eigen_symmv."<<endl; return;}
	
	LWORK=(int)temp[0];
	float *WORK=new float [LWORK];	
	ssyev_(&JOBZ, &UPLO, &N, A->data, &LDA, eval->data, WORK, &LWORK, &INFO);
	if (INFO!=0) {cout<<"Eigen decomposition unsuccessful in lapack_eigen_symmv."<<endl; return;}
	
	gsl_matrix_float_view A_sub=gsl_matrix_float_submatrix(A, 0, 0, N, N);
	gsl_matrix_float_memcpy (evec, &A_sub.matrix);
	gsl_matrix_float_transpose (evec);

  	delete [] WORK;
	return;
}



void lapack_eigen_fdf (gsl_matrix_float *A, gsl_vector_float *eval, gsl_matrix_float *evec)
{
	gsl_matrix *A_double=gsl_matrix_alloc (A->size1, A->size2);
	gsl_vector *eval_double=gsl_vector_alloc (eval->size);
	gsl_matrix *evec_double=gsl_matrix_alloc (evec->size1, evec->size2);
	
	double d;
	
	for (size_t i=0; i<A->size1; i++) {
		for (size_t j=0; j<A->size2; j++) {
			d=gsl_matrix_float_get (A, i, j);
			gsl_matrix_set (A_double, i, j, d);
		}
	}
	
	for (size_t i=0; i<A->size1; i++) {
		d=gsl_vector_float_get (eval, i);
		gsl_vector_set (eval_double, i, d);
	}
	
	for (size_t i=0; i<evec->size1; i++) {
		for (size_t j=0; j<evec->size2; j++) {
			d=gsl_matrix_float_get (evec, i, j);
			gsl_matrix_set (evec_double, i, j, d);
		}
	}
	
	lapack_double_eigen_symmv (A_double, eval_double, evec_double);
	
	float f;
	
	for (size_t i=0; i<A->size1; i++) {
		for (size_t j=0; j<A->size2; j++) {
			f=gsl_matrix_get (A_double, i, j);
			gsl_matrix_float_set (A, i, j, f);
		}
	}
	
	for (size_t i=0; i<A->size1; i++) {
		f=gsl_vector_get (eval_double, i);
		gsl_vector_float_set (eval, i, f);
	}
	
	for (size_t i=0; i<evec->size1; i++) {
		for (size_t j=0; j<evec->size2; j++) {
			f=gsl_matrix_get (evec_double, i, j);
			gsl_matrix_float_set (evec, i, j, f);
		}
	}
	
	gsl_matrix_free(A_double);
	gsl_vector_free(eval_double);
	gsl_matrix_free(evec_double);
	
	return;
}


