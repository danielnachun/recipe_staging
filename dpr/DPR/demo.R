## Detailed description of the data set is available in the online DPR user manual
## Each of the following steps may take over one minute to run



## To calculate a centered relatedness matrix:
cd /net/mulan/pingzeng/software/DPR1
./bin/DPR -g ./example/mouse_hs1940.geno.txt.gz -p ./example/mouse_hs1940.pheno.txt -a ./example/mouse_hs1940.anno.txt -gk -o mouse_hs1940

# The estimated relatedness matrix should look like this:
0.3350590  -0.0227226  0.0103535 ...
-0.0227226  0.3035960 -0.0253762 ...
0.0103535  -0.0253762  0.3536100 ...
....................................


## To fit DPR in the training set:

## To fit a quantitative trait (i.e. CD8) with VB algorithm
./bin/DPR -g ./example/mouse_hs1940.geno.txt.gz -p ./example/mouse_hs1940.pheno.txt -n 2 -a ./example/mouse_hs1940.anno.txt -k ./example/mouse_hs1940.cXX.txt -dpr 1 -nk 4 -o mouse_hs1940_CD8_vb

## To fit a quantitative trait (i.e. CD8) with VB algorithm
./bin/DPR -bfile ./example/mouse_hs1940 -n 2 -k ./example/mouse_hs1940.cXX.txt -dpr 1 -nk 4 -o mouse_hs1940_CD8_vb




## To fit a quantitative trait (i.e. CD8) with MCMC algorithm
./bin/DPR -g ./example/mouse_hs1940.geno.txt.gz -p ./example/mouse_hs1940.pheno.txt -n 2 -a ./example/mouse_hs1940.anno.txt -k ./example/mouse_hs1940.cXX.txt -dpr 2 -o mouse_hs1940_CD8_mcmc -m 100000 -t 1 -w 1000 -s 1000

# in both the algorithms, the following two files are generated:
# the *.log.txt contains the fitting log.
# the *.param.txt contains estimates for betas, gammas and alphas


## To obtain predicted values for the test set using estimates from DPR
## To do prediction in the test set for CD8 with VB algorithm
./bin/DPR -g ./example/mouse_hs1940.geno.txt.gz -p ./example/mouse_hs1940.pheno.txt -n 2 -epm ./output/mouse_hs1940_CD8_vb.param.txt -emu ./output/mouse_hs1940_CD8_vb.log.txt -predict -o mouse_hs1940_CD8_prdt_vb

## To do prediction in the test set for CD8 with MCMC algorithm
./bin/DPR -g ./example/mouse_hs1940.geno.txt.gz -p ./example/mouse_hs1940.pheno.txt -n 2 -epm ./output/mouse_hs1940_CD8_mcmc.param.txt -emu ./output/mouse_hs1940_CD8_mcmc.log.txt -predict -o mouse_hs1940_CD8_prdt_mcmc



