
libname data 
	'D:\bagusco\Training ---- the essential of credit scoring model\data dan program';
run;

data data.datascoring;
set data.data;
run;



*** isi dari file datascoring;
proc contents data=data.datascoring;
run;


*** melihat sebaran nilai variabel AGE;
proc univariate data=data.datascoring;
var age;
histogram age;
run;


*** melakukan binning variabel AGE;
data data.datascoring;
set data.datascoring;
if age <= 25 then agegroup = 1;
else if age <= 30 then agegroup = 2;
else if age <= 35 then agegroup = 3;
else if age <= 40 then agegroup = 4;
else if age <= 45 then agegroup = 5;
else agegroup = 6;
run;

proc tabulate data=data.datascoring;
class agegroup;
table agegroup all, n colpctn;
run;


*** melihat sebaran variabel NUMBER_OF_DEPENDANTS;
proc tabulate data=data.datascoring;
class number_of_dependants;
table number_of_dependants all, n colpctn;
run;




**** menghitung WOE dari variabel GENDER ***;
* tahapan:
  1. Menghitung P(Gender | Good) dan P(Gender|Bad);

proc tabulate data=data.datascoring out=WOEgender;
class gender status;
tables gender, status*colpctn;
run;

proc transpose data=woegender out=woegender;
var pctn_01;
by gender;
id status;
run;


* tahapan:
  2. hitung WoE dengan formula 
		WoE = log(P(-|GOOD)/P(-|BAD));
data WOEgender;
set WOEgender;
WOEgender = log(GOOD / BAD);
run;

* tahapan:
  3. Berikan nilai WoE Gender pada data lengkap
     (datascoring);
data woegender (keep = gender woegender);
set woegender;
run;

proc print data=woegender;
run;

proc sort data=data.datascoring;
by gender;
run;

data data.datascoring;
merge data.datascoring woegender;
by gender;
run;


**** menghitung WOE dari variabel RESIDENCE ***;
proc tabulate data=data.datascoring out=WOEresidence;
class residence_ownership status;
tables residence_ownership, status*colpctn;
run;

proc transpose data=woeresidence out=woeresidence;
var pctn_01;
by residence_ownership;
id status;
run;

data WOEresidence;
set WOEresidence;
WOEresidence = log(GOOD / BAD);
run;

data woeresidence 
	(keep = residence_ownership woeresidence);
set woeresidence;
run;

proc sort data=data.datascoring;
by residence_ownership ;
run;

data data.datascoring;
merge data.datascoring woeresidence;
by residence_ownership ;
run;

proc print data=woeresidence;
run;



***** menghitung WOE untuk variabel AGE;
proc univariate data=data.datascoring;
var age;
histogram age;
run;

data data.datascoring;
set data.datascoring;
if age <= 25 then agegroup = 1;
else if age <= 30 then agegroup = 2;
else if age <= 35 then agegroup = 3;
else if age <= 40 then agegroup = 4;
else if age <= 45 then agegroup = 5;
else agegroup = 6;
run;

**** menghitung WOE dari variabel agegroup ***;
proc tabulate data=data.datascoring out=WOEagegroup;
class agegroup status;
tables agegroup, status*colpctn;
run;

proc transpose data=woeagegroup out=woeagegroup;
var pctn_01;
by agegroup;
id status;
run;

data WOEagegroup;
set WOEagegroup;
WOEagegroup = log(GOOD / BAD);
run;

data woeagegroup (keep = agegroup woeagegroup);
set woeagegroup;
run;

proc sort data=data.datascoring;
by agegroup;
run;

data data.datascoring;
merge data.datascoring woeagegroup;
by agegroup;
run;

proc print data=woeagegroup;
run;


* Menghitung WoE untuk variabel NUMBER OF DEPENDANTS;
proc tabulate data=data.datascoring;
class number_of_dependants;
tables number_of_dependants, n colpctn;
run;

proc tabulate data=data.datascoring out=WOEdependants;
class number_of_dependants status;
tables number_of_dependants, status*colpctn;
run;

proc transpose data=woedependants out=woedependants;
var pctn_01;
by number_of_dependants;
id status;
run;

data WOEdependants;
set WOEdependants;
WOEdependants = log(GOOD / BAD);
run;

data woedependants (keep = number_of_dependants woedependants);
set woedependants;
run;

proc sort data=data.datascoring;
by number_of_dependants;
run;

data data.datascoring;
merge data.datascoring woedependants;
by number_of_dependants;
run;

proc print data=woedependants;
run;


********* memeriksa kemampuan prediktif setiap
 variabel, menggunakan Nilai C (AUC) dari model
 secara univariate;
proc logistic data=data.datascoring;
model status (event = 'GOOD') = WOEgender;
run;
proc logistic data=data.datascoring;
model status (event = 'GOOD') = WOEagegroup;
run;
proc logistic data=data.datascoring;
model status (event = 'GOOD') = WOEresidence;
run;
proc logistic data=data.datascoring;
model status (event = 'GOOD') = WOEdependants;
run;



**** menghitung INFORMATION VALUE dari GENDER;
proc tabulate data=data.datascoring out=WOEgender;
class gender status;
tables gender, status*colpctn;
run;
proc transpose data=woegender out=woegender;
var pctn_01;
by gender;
id status;
run;
data WOEgender;
set WOEgender;
WOEgender = log(GOOD / BAD);
IVgender = (GOOD - BAD) * WOEgender /100;
run;
proc tabulate data=WOEgender;
var IVgender;
tables sum, IVgender;
run;

***********;
proc tabulate data=data.datascoring out=WOEagegroup;
class agegroup status;
tables agegroup, status*colpctn;
run;
proc transpose data=woeagegroup out=woeagegroup;
var pctn_01;
by agegroup;
id status;
run;
data WOEagegroup;
set WOEagegroup;
WOEagegroup = log(GOOD / BAD);
IVagegroup = (GOOD - BAD) * WOEagegroup / 100;
run;
proc tabulate data=WOEagegroup;
var IVagegroup;
tables sum, IVagegroup;
run;


*********;
proc tabulate data=data.datascoring out=WOEresidence;
class residence_ownership status;
tables residence_ownership, status*colpctn;
run;
proc transpose data=woeresidence out=woeresidence;
var pctn_01;
by residence_ownership;
id status;
run;
data WOEresidence;
set WOEresidence;
WOEresidence = log(GOOD / BAD);
IVresidence = (GOOD - BAD) * WOEresidence / 100;
run;
proc tabulate data=WOEresidence;
var IVresidence;
tables sum, IVresidence;
run;


*********;
proc tabulate data=data.datascoring out=WOEdependants;
class number_of_dependants status;
tables number_of_dependants, status*colpctn;
run;
proc transpose data=woedependants out=woedependants;
var pctn_01;
by number_of_dependants;
id status;
run;
data WOEdependants;
set WOEdependants;
WOEdependants = log(GOOD / BAD);
IVdependants = (GOOD - BAD) * WOEdependants / 100;
run;
proc tabulate data=WOEdependants;
var IVdependants;
tables sum, IVdependants;
run;



********* menentukan bobot masing-masing variabel;
proc logistic data=data.datascoring outest=bobot;
model status (event = 'GOOD') = WOEgender WOEagegroup WOEresidence WOEdependants;
run;


*** penskalaan

(BiWoEi + B0/p) * factor + Offset / p 

Misal, scorecard yang diinginkan memiliki odds of 50:1 
pada nilai 600 dan odds-nya akan dua kali lipat kalau skornya 
bertambah 20 points (pdo = 20)

Maka akan diperoleh
Factor = 20 / ln (2) = 28.8539
Offset = 600 – {28.8539 ln (50)} = 487.123
;

data WOEgender (keep = category WOE input);
set WOEgender;
length input $ 20;
input = 'WOEgender';
category = gender;
WOE = WOEgender;
run;

data WOEagegroup (keep = category WOE input);
set WOEagegroup;
length input $ 20;
input = 'WOEagegroup';
category = compress(agegroup);
WOE = WOEagegroup;
run;

data WOEresidence (keep = category WOE input);
set WOEresidence;
length input $ 20;
input = 'WOEresidence';
category = residence_ownership;
WOE = WOEresidence;
run;

data WOEdependants (keep = category WOE input);
set WOEdependants;
length input $ 20;
input = 'WOEdependants';
category = compress(number_of_dependants);
WOE = WOEdependants;
run;

data WOEall;
set WOEgender WOEagegroup WOEresidence WOEdependants;
run;


data _null_;
set bobot;
if _n_=1 then call symput("b0", intercept);
if _n_=1 then call symput("bgender", WOEgender);
if _n_=1 then call symput("bagegroup", WOEagegroup);
if _n_=1 then call symput("bresidence", WOEresidence);
if _n_=1 then call symput("bdependants", WOEdependants);
run;
data WOEall (drop = factor offset);
set WOEall;
Factor = 20 / log (2);
Offset = 600 - factor * log (50);
if input = 'WOEgender' then score = (&bgender * WOE + &b0 / 4) * factor + offset / 4;
if input = 'WOEagegroup' then score = (&bagegroup * WOE + &b0 / 4) * factor + offset / 4;
if input = 'WOEresidence' then score = (&bresidence * WOE + &b0 / 4) * factor + offset / 4;
if input = 'WOEdependants' then score = (&bdependants * WOE + &b0 / 4) * factor + offset / 4;
score = round(score);
run;
proc print data=WOEall;
run;

data data.datascoring;
set data.datascoring;
Factor = 20 / log (2);
Offset = 600 - factor * log (50);
SCOREgender = round((&bgender * WOEgender + &b0 / 4) * factor + offset / 4);
SCOREagegroup = round((&bagegroup * WOEagegroup + &b0 / 4) * factor + offset / 4);
SCOREresidence = round((&bresidence * WOEresidence + &b0 / 4) * factor + offset / 4);
SCOREdependants = round((&bdependants * WOEdependants + &b0 / 4) * factor + offset / 4);
SCOREtotal = sum(SCOREgender, SCOREagegroup, SCOREresidence, SCOREdependants);
run;

data data.datascoring;
set data.datascoring;
if SCOREtotal > 500 then predict = "GOOD";
else predict = "BAD ";
run;

proc tabulate data=data.datascoring;
class status predict;
table status, predict*(n pctn rowpctn);
run;

 
proc sort data=data.datascoring;
by status;
run;
proc kde data=data.datascoring;
univar SCOREtotal / out=density bwm=3;
by status;
run;

symbol1 i=join w=2;
symbol2 i=join w=2;
proc gplot data=density;
plot density*value=status;
run;
quit;









