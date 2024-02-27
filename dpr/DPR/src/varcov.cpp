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

#include "gsl/gsl_vector.h"
#include "gsl/gsl_matrix.h"
#include "gsl/gsl_linalg.h"
#include "gsl/gsl_blas.h"
#include "gsl/gsl_cdf.h"

#include "lapack.h"
#include "gzstream.h"

#ifdef FORCE_FLOAT
#include "param_float.h"
#include "varcov_float.h"
#include "io_float.h"
#include "mathfunc_float.h"
#else
#include "param.h"
#include "varcov.h"
#include "io.h"
#include "mathfunc.h"
#endif


using namespace std;




void VARCOV::CopyFromParam (PARAM &cPar)
{
	d_pace=cPar.d_pace;
	
	file_bfile=cPar.file_bfile;
	file_geno=cPar.file_geno;
	file_out=cPar.file_out;
	path_out=cPar.path_out;
	
	time_opt=0.0;

	window_cm=cPar.window_cm;
	window_bp=cPar.window_bp;
	window_ns=cPar.window_ns;
	
	indicator_idv=cPar.indicator_idv;
	indicator_snp=cPar.indicator_snp;
	snpInfo=cPar.snpInfo;
	
	return;
}


void VARCOV::CopyToParam (PARAM &cPar)
{
	cPar.time_opt=time_opt;
	return;
}



//chr rs ps n_idv allele1 allele0 af var window_size r2 (r2_11,n_11,r2_12,n_12...r2_1m,n_1m)
void VARCOV::WriteCov (const int flag, const vector<SNPINFO> &snpInfo_sub, const vector<vector<double> > &Cov_mat) 
{
  string file_cov;
  file_cov=path_out+"/"+file_out;
  file_cov+=".cor.txt";

  ofstream outfile;

  if (flag==0) {
    outfile.open (file_cov.c_str(), ofstream::out);
    if (!outfile) {cout<<"error writing file: "<<file_cov<<endl; return;}
		
    outfile<<"chr"<<"\t"<<"rs"<<"\t"<<"ps"<<"\t"<<"n_mis"
	   <<"\t"<<"n_obs"<<"\t"<<"allele1"<<"\t"<<"allele0"
	   <<"\t"<<"af"<<"\t"<<"window_size"
	   <<"\t"<<"var"<<"\t"<<"cor"<<endl;
  } else {
    outfile.open (file_cov.c_str(), ofstream::app);
    if (!outfile) {cout<<"error writing file: "<<file_cov<<endl; return;}

    for (size_t i=0; i<Cov_mat.size(); i++) {
      outfile<<snpInfo_sub[i].chr<<"\t"<<snpInfo_sub[i].rs_number<<"\t"<<snpInfo_sub[i].base_position<<"\t"<<snpInfo_sub[i].n_miss<<"\t"<<snpInfo_sub[i].n_idv<<"\t"<<snpInfo_sub[i].a_minor<<"\t"<<snpInfo_sub[i].a_major<<"\t"<<fixed<<setprecision(3)<<snpInfo_sub[i].maf<<"\t"<<Cov_mat[i].size()-1<<"\t";
      outfile<<scientific<<setprecision(6)<<Cov_mat[i][0]<<"\t";

      if (Cov_mat[i].size()==1) {
	outfile<<"NA";
      } else {
	for (size_t j=1; j<Cov_mat[i].size(); j++) {
	  if (j==(Cov_mat[i].size()-1)) {
	    outfile<<Cov_mat[i][j];
	  } else {
	    outfile<<Cov_mat[i][j]<<",";
	  }
	}
      }
      
      outfile<<endl;
    }
  }
	
  outfile.close();
  outfile.clear();
  return;
}




// sort SNPs first based on chromosomes then based on bp (or cm, if bp is not available)
//if chr1=chr2 and bp1=bp2, then return with the same order
bool CompareSNPinfo (const SNPINFO &snpInfo1, const SNPINFO &snpInfo2)
{
  int c_chr=snpInfo1.chr.compare(snpInfo2.chr);
  long int c_bp=snpInfo1.base_position-snpInfo2.base_position;

  if(c_chr<0) {
    return true;
  } else if (c_chr>0) {
    return false;
  } else {
    if (c_bp<0) {
      return true;
    } else if (c_bp>0) {
      return false;
    } else {
      return true;
    }
  }
}


// do not sort SNPs (because gzip files do not support random access)
// then calculate n_nb, the number of neighbours, for each snp
void VARCOV::CalcNB (vector<SNPINFO> &snpInfo_sort)
{
  //  stable_sort(snpInfo_sort.begin(), snpInfo_sort.end(), CompareSNPinfo);

  size_t t2=0, n_nb=0;
  for (size_t t=0; t<indicator_snp.size(); ++t) {
    if (indicator_snp[t]==0) {continue;}
    
    if (snpInfo_sort[t].chr=="-9" || (snpInfo_sort[t].cM==-9 && window_cm!=0) || (snpInfo_sort[t].base_position==-9 && window_bp!=0) ) {
      snpInfo_sort[t].n_nb=0; continue;
    }

    if (t==indicator_snp.size()-1) {snpInfo_sort[t].n_nb=0; continue;}

    t2=t+1; n_nb=0;

    while (t2<indicator_snp.size() && snpInfo_sort[t2].chr==snpInfo_sort[t].chr  && indicator_snp[t2]==0) {t2++;}

    while (t2<indicator_snp.size() && snpInfo_sort[t2].chr==snpInfo_sort[t].chr && (snpInfo_sort[t2].cM-snpInfo_sort[t].cM<window_cm || window_cm==0) && (snpInfo_sort[t2].base_position-snpInfo_sort[t].base_position<window_bp || window_bp==0) && (n_nb<window_ns|| window_ns==0)  ) {
      t2++; n_nb++;
      while (t2<indicator_snp.size() && snpInfo_sort[t2].chr==snpInfo_sort[t].chr && indicator_snp[t2]==0) {t2++;}
    }

    snpInfo_sort[t].n_nb=n_nb;
  }

  return;
}



//vector double is centered to have mean 0
void Calc_Cor(vector<vector<double> > &X_mat, vector<double> &cov_vec)
{
  cov_vec.clear();

  double v1, v2, r;
  vector<double> x_vec=X_mat[0];

  lapack_ddot(x_vec, x_vec, v1);
  cov_vec.push_back(v1/(double)x_vec.size() );

  for (size_t i=1; i<X_mat.size(); i++) {
    lapack_ddot(X_mat[i], x_vec, r);
    lapack_ddot(X_mat[i], X_mat[i], v2);
    r/=sqrt(v1*v2);

    cov_vec.push_back(r);
  }

  return;
} 

/*
//somehow this can produce nan for some snps; perhaps due to missing values?
//vector int is not centered, and have 0/1/2 values only
//missing value is -9; to calculate covariance, these values are replaced by 
void Calc_Cor(const vector<vector<int> > &X_mat, vector<double> &cov_vec)
{
  cov_vec.clear();

  int d1, d2, m1, m2, n1, n2, n12;
  double m1d, m2d, m12d, v1d, v2d, v;

  vector<int> x_vec=X_mat[0];
  
  //calculate m2
  m2=0; n2=0;
  for (size_t j=0; j<x_vec.size(); j++) {
    d2=x_vec[j];
    if (d2==-9) {continue;}
    m2+=d2; n2++;
  }
  m2d=(double)m2/(double)n2;

  for (size_t i=0; i<X_mat.size(); i++) {
    //calculate m1
    m1=0; n1=0;
    for (size_t j=0; j<x_vec.size(); j++) {
      d1=X_mat[i][j];
      if (d1==-9) {continue;}
      m1+=d1; n1++;
    }
    m1d=(double)m1/(double)n1;

    //calculate v1
    m1=0; m2=0; m12d=0; n12=0;
    for (size_t j=0; j<x_vec.size(); j++) {
      d1=X_mat[i][j];
      if (d1==-9) {
	n12++;
      } else if (d1!=0) {
	if (d1==1) {m12d+=1;} else if (d1==2) {m12d+=4;} else {m12d+=(double)(d1*d1);}
      }
    }
    
    v1d=((double)m12d+m1d*(double)m2+m2d*(double)m1+(double)n12*m1d*m2d)/(double)x_vec.size()-m1d*m2d;

    //calculate covariance
    if (i!=0) {
      m1=0; m2=0; m12d=0; n12=0;
      for (size_t j=0; j<x_vec.size(); j++) {
	d1=X_mat[i][j]; d2=x_vec[j];
	if (d1==-9 && d2==-9) {
	  n12++;
	} else if (d1==-9) {
	  m2+=d2;
	} else if (d2==-9) {
	  m1+=d1;
	} else if (d1!=0 && d2!=0) {
	  if (d1==1) {m12d+=d2;} else if (d1==2) {m12d+=d2+d2;} else {m12d+=(double)(d1*d2);}
	}
      }
    
      v=((double)m12d+m1d*(double)m2+m2d*(double)m1+(double)n12*m1d*m2d)/(double)x_vec.size()-m1d*m2d;
      v/=sqrt(v1d*v2d);
    } else {
      v2d=v1d;
      v=v1d/(double)x_vec.size();
    }
    
    cov_vec.push_back(v);
  }
  return;
} 
*/


//read the genotype file again, calculate r2 between pairs of SNPs within a window, output the file every 10K SNPs
//the output results are sorted based on chr and bp
//output format similar to assoc.txt files (remember n_miss is replaced by n_idv)

//r2 between the current SNP and every following SNPs within the window_size (which can vary if cM was used)
//read bimbam mean genotype file and calculate the covariance matrix for neighboring SNPs
//output values at 10000-SNP-interval
void VARCOV::AnalyzeBimbam ()
{
  igzstream infile (file_geno.c_str(), igzstream::in);
  if (!infile) {cout<<"error reading genotype file:"<<file_geno<<endl; return;}

  //calculate the number of right-hand-side neighbours for each SNP
  vector<SNPINFO> snpInfo_sub;
  CalcNB(snpInfo);

  size_t ni_test=0;
  for (size_t i=0; i<indicator_idv.size(); i++) {
    ni_test+=indicator_idv[i];
  }
  
  gsl_vector *geno=gsl_vector_alloc (ni_test);
  double geno_mean;

  vector<double> x_vec, cov_vec;
  vector<vector<double> > X_mat, Cov_mat;

  for (size_t i=0; i<ni_test; i++) {
    x_vec.push_back(0);
  }

  WriteCov (0, snpInfo_sub, Cov_mat);

  size_t t2=0, inc;
  int n_nb=0;

  for (size_t t=0; t<indicator_snp.size(); ++t) {
    if (t%d_pace==0 || t==(indicator_snp.size()-1)) {ProgressBar ("Reading SNPs  ", t, indicator_snp.size()-1);}
    if (indicator_snp[t]==0) {continue;}
    //    if (t>=2) {break;}    

    if (X_mat.size()==0) {
      n_nb=snpInfo[t].n_nb+1;
    } else {
      n_nb=snpInfo[t].n_nb-n_nb+1;       
    }

    for (int i=0; i<n_nb; i++) {
      if (X_mat.size()==0) {t2=t;} 

      //read a line of the snp is filtered out
      inc=0;
      while (t2<indicator_snp.size() && indicator_snp[t2]==0) {
	t2++; inc++; 
      }

      Bimbam_ReadOneSNP (inc, indicator_idv, infile, geno, geno_mean);
      gsl_vector_add_constant (geno, -1.0*geno_mean);
            
      for (size_t j=0; j<geno->size; j++) {
	x_vec[j]=gsl_vector_get(geno, j);
      }
      X_mat.push_back(x_vec);

      t2++;
    }     
    
    n_nb=snpInfo[t].n_nb;

    Calc_Cor(X_mat, cov_vec);
    Cov_mat.push_back(cov_vec);
    snpInfo_sub.push_back(snpInfo[t]);

    X_mat.erase(X_mat.begin());

    //write out var/cov values
    if (Cov_mat.size()==10000) {
      WriteCov (1, snpInfo_sub, Cov_mat);
      Cov_mat.clear();
      snpInfo_sub.clear();
    }
  }

  if (Cov_mat.size()!=0) {
    WriteCov (1, snpInfo_sub, Cov_mat);
    Cov_mat.clear();
    snpInfo_sub.clear();
  }

  gsl_vector_free(geno);

  infile.close();
  infile.clear();	
	
  return;
}




void VARCOV::AnalyzePlink ()
{
  string file_bed=file_bfile+".bed";
  ifstream infile (file_bed.c_str(), ios::binary);
  if (!infile) {cout<<"error reading bed file:"<<file_bed<<endl; return;}

  //calculate the number of right-hand-side neighbours for each SNP
  vector<SNPINFO> snpInfo_sub;
  CalcNB(snpInfo);
  
  size_t ni_test=0;
  for (size_t i=0; i<indicator_idv.size(); i++) {
    ni_test+=indicator_idv[i];
  }

  gsl_vector *geno=gsl_vector_alloc (ni_test);
  double geno_mean;

  vector<double> x_vec, cov_vec;
  vector<vector<double> > X_mat, Cov_mat;

  for (size_t i=0; i<ni_test; i++) {
    x_vec.push_back(0);
  }

  WriteCov (0, snpInfo_sub, Cov_mat);

  size_t t2=0, inc;
  int n_nb=0;

  for (size_t t=0; t<indicator_snp.size(); ++t) {
    if (t%d_pace==0 || t==(indicator_snp.size()-1)) {ProgressBar ("Reading SNPs  ", t, indicator_snp.size()-1);}
    if (indicator_snp[t]==0) {continue;}
    //    if (t>=2) {break;}    

    if (X_mat.size()==0) {
      n_nb=snpInfo[t].n_nb+1;
    } else {
      n_nb=snpInfo[t].n_nb-n_nb+1;       
    }

    for (int i=0; i<n_nb; i++) {
      if (X_mat.size()==0) {t2=t;} 

      //read a line of the snp is filtered out
      inc=0;
      while (t2<indicator_snp.size() && indicator_snp[t2]==0) {
	t2++; inc++; 
      }

      Plink_ReadOneSNP (t2, indicator_idv, infile, geno, geno_mean);
      gsl_vector_add_constant (geno, -1.0*geno_mean);
            
      for (size_t j=0; j<geno->size; j++) {
	x_vec[j]=gsl_vector_get(geno, j);
      }
      X_mat.push_back(x_vec);

      t2++;
    }     
    
    n_nb=snpInfo[t].n_nb;

    Calc_Cor(X_mat, cov_vec);
    Cov_mat.push_back(cov_vec);
    snpInfo_sub.push_back(snpInfo[t]);

    X_mat.erase(X_mat.begin());

    //write out var/cov values
    if (Cov_mat.size()==10000) {
      WriteCov (1, snpInfo_sub, Cov_mat);
      Cov_mat.clear();
      snpInfo_sub.clear();
    }
  }

  if (Cov_mat.size()!=0) {
    WriteCov (1, snpInfo_sub, Cov_mat);
    Cov_mat.clear();
    snpInfo_sub.clear();
  }

  gsl_vector_free(geno);

  infile.close();
  infile.clear();	
	
  return;
}
