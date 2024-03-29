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


#ifndef __LAPACK_H__                
#define __LAPACK_H__



using namespace std;


void lapack_double_eigen_symmv (gsl_matrix *A, gsl_vector *eval, gsl_matrix *evec);
void lapack_float_eigen_symmv (gsl_matrix_float *A, gsl_vector_float *eval, gsl_matrix_float *evec);
void lapack_eigen_fdf (gsl_matrix_float *A, gsl_vector_float *eval, gsl_matrix_float *evec);


#endif



