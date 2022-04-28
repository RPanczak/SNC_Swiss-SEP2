* PCA >> USING DIFFERENT OCCUP DENOMINATOR >> FOR SENSITIVITY ANALYSIS

pca  ocu1p2 edu1p ppr1 rent [aw = tot_hh]

predict i_hw

/* DIAGNOSTICS
estat kmo 
estat residual, fit f(%7.3f)
estat smc
estat anti, nocov f(%7.3f)
* screeplot, mean ci
*/

* 0-100 score
* based on p.6 http://www.geosoft.com/media/uploads/resources/technical-notes/Principal%20Component%20Analysis.pdf
egen A = min(i_hw)
egen B = max(i_hw)
gen ind = (i_hw-A)*100/(B-A)
gen ssepALT = (ind - 100)*(-1)

*xtile ssepALT_t = ssepALT, nq(3)
*xtile ssepALT_q = ssepALT, nq(5)
xtile ssepALT_d = ssepALT, nq(10)

drop  i_hw ind A B

la de ssepALT_d 1 "1 (lowest SEP)" 2 "2" 3 "3" 4 "4" 5 "5th decile" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10 (highest SEP)", modify 
la val ssepALT_d ssep2_10

gen occup_diff = ssep2 - ssepALT
* univar occup_diff
* hist occup_diff, w(0.25) start(-10) percent

ta ssep2_d ssepALT_d , m

* https://www.stata.com/meeting/uk19/slides/uk19_newson.pdf
somersd ssep ssepALT, taua transf(z) tdist
scsomersd difference 0, transf(z) tdist

* baplot ssep ssepALT, info

* batplot ssep ssepALT, info
batplot ssep ssepALT, notrend info dp(0)
gr export $td\gr\BA_occu.png, replace width(800) height(600)
