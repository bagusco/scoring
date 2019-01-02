libname a 'D:\bagusco\bagusco\T ---- 2019 Credit Scoring Bank Sinarmas\data dan program';

proc contents data=a.rating;
run;

proc logistic data = a.rating;
model eksternal_rating (event = "OK") = Return_on_equity Return_on_Asset Cost_to_Income_Ratio;
run;

proc logistic data = a.rating outmodel=modelrating;
model eksternal_rating (event = "OK") = Return_on_equity Return_on_Asset Cost_to_Income_Ratio;
run;

data maudiprediksi;
input Return_on_equity Return_on_Asset Cost_to_Income_Ratio;
cards;
0.1		0.02	0.8
0.2		0.02	0.6
;

proc logistic inmodel=modelrating;
score data=maudiprediksi out=prediksi;
run;

proc univariate data=a.rating;
var Return_on_equity Return_on_Asset Cost_to_Income_Ratio;
histogram Return_on_equity Return_on_Asset Cost_to_Income_Ratio;
run;

data rating_disk;
set a.rating;
if Return_on_equity < 0.05 then ROE_class = 1;
else if Return_on_equity < 0.10 then ROE_class = 2;
else if Return_on_equity < 0.15 then ROE_class = 3;
else if Return_on_equity < 0.20 then ROE_class = 4;
else if Return_on_equity < 0.25 then ROE_class = 5;
else ROE_class = 6;
run;

proc tabulate data=rating_disk;
class ROE_class eksternal_rating;
table ROE_class, eksternal_rating*n;
run;
data rating_disk;
set a.rating;
if Return_on_equity < 0.10 then ROE_class = 1;
else if Return_on_equity < 0.15 then ROE_class = 2;
else if Return_on_equity < 0.20 then ROE_class = 3;
else if Return_on_equity < 0.25 then ROE_class = 4;
else ROE_class = 5;
run;

proc tabulate data=rating_disk;
class ROE_class eksternal_rating;
table ROE_class, eksternal_rating*n;
run;


data rating_disk;
set rating_disk;
if Return_on_asset < 0.005 then ROA_class = 1;
else if Return_on_asset < 0.010 then ROA_class = 2;
else if Return_on_asset < 0.015 then ROA_class = 3;
else if Return_on_asset < 0.020 then ROA_class = 4;
else ROA_class = 5;
run;

proc tabulate data=rating_disk;
class ROA_class eksternal_rating;
table ROA_class, eksternal_rating*n;
run;

data rating_disk;
set rating_disk;
if Return_on_asset < 0.015 then ROA_class = 1;
else if Return_on_asset < 0.020 then ROA_class = 2;
else ROA_class = 3;
run;

proc tabulate data=rating_disk;
class ROA_class eksternal_rating;
table ROA_class, eksternal_rating*n;
run;

data rating_disk;
set rating_disk;
if Cost_to_Income_Ratio < 0.35 then CIR_class = 1;
else if Cost_to_Income_Ratio < 0.50 then CIR_class = 2;
else if Cost_to_Income_Ratio < 0.65 then CIR_class = 3;
else CIR_class = 4;
run;
proc tabulate data=rating_disk;
class CIR_class eksternal_rating;
table CIR_class, eksternal_rating*n;
run;
proc logistic data = rating_disk;
class ROE_class ROA_class CIR_class;
model eksternal_rating (event = "OK") = ROE_class ROA_class CIR_class;
run;



