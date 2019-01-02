libname training
	'E:\training';
run;

proc import 
datafile= 'E:\training\scoringtest.csv'
out=training.scoringtest dbms=csv replace;
getnames=yes; run;

data datascoring;
set training.scoringtest;
*age;
if age <= 25 then SCOREage = 108;
else if age <= 30 then SCOREage = 123;
else if age <= 35 then SCOREage = 121;
else if age <= 40 then SCOREage = 133;
else if age <= 45 then SCOREage = 128;
else SCOREage = 186;
*gender;
if gender = "FEMALE" then SCOREgender = 165;
else SCOREgender = 107;
*residence;
if residence_ownership = "OTHERS" then SCOREresidence = 98;
else if residence_ownership = "OWNED" then SCOREresidence = 172;
else if residence_ownership = "PARENT" then SCOREresidence = 115;
else SCOREresidence = 83;
*dependants;
if number_of_dependants = 0 then SCOREdependants = 169;
else if number_of_dependants = 1 then SCOREdependants = 140;
else if number_of_dependants = 2 then SCOREdependants = 136;
else if number_of_dependants = 3 then SCOREdependants = 122;
else if number_of_dependants = 4 then SCOREdependants = 89;
else SCOREdependants = 92;
*total score;
SCOREtotal=sum(SCOREage,SCOREgender,SCOREresidence,SCOREdependants);
if SCOREtotal > 540 then predict = "GOOD";
else predict = "BAD"; run;

ods listing close;
proc tabulate data=datascoring;
class status predict;
table status, predict*(n pctn rowpctn); run;
ods listing;
proc sort data=datascoring;
by status; run;


***model distribution***;
ods listing close;
proc kde data=datascoring out=density method=snr bwm=1.5;
var SCOREtotal; by status; run;
ods listing;
symbol1 i=join w=2;
symbol2 i=join w=2;
proc gplot data=density;
plot density*SCOREtotal=status; run;


***menghitung population stability index***;
data datascoring;
set datascoring;
if SCOREtotal <= 440 then scoreband = 1;
else if SCOREtotal > 620 then scoreband = 11;
else scoreband = ceil((SCOREtotal-440)/20)+1; run;

ods listing close;
proc tabulate data=datascoring out=score_band;
class scoreband status;
table scoreband, status*rowpctn; run;
ods listing;
proc transpose data=score_band out=score_band;
var pctn_10; by scoreband; id status; run;
data expected;
input exp_odds;
exp_bad = 1/(1+exp_odds)*100;
cards;
.2
.4
.8
1.6
3.1
6.3
12.5
25
50
100
200
; run;
data score_band;
set score_band;
if bad = . then bad = .5;
odds = good/bad; run;
data score_band;
merge score_band expected;
stability = (exp_bad - bad)*log(exp_bad / bad); run;
proc print data=score_band; run;
proc means data=score_band sum;
var stability; run;


***menghitung KS statistics***;
ods listing close;
proc tabulate data=datascoring out=stat_KS;
class scoreband status;
table scoreband, status*n; run;
ods listing;

proc transpose data=stat_KS out=stat_KS;
var n; by scoreband; id status; run;
data stat_KS;
set stat_KS;
if bad = . then bad = 0; run;
proc iml;
use stat_KS;
read all var {scoreband} into scoreband;
read all var {bad} into bad;
read all var {good} into good;
n=11;
pctbad=J(n,1,.);
pctgood=J(n,1,.);
cumbad=J(n,1,.);
cumgood=J(n,1,.);
diff=J(n,1,.);
cumbad0 = 0;
cumgood0 = 0;
do i=1 to n;
	pctbad[i] = bad[i]/sum(bad)*100;
	pctgood[i] = good[i]/sum(good)*100;
	cumbad[i] = cumbad0 + pctbad[i];
	cumbad0 = cumbad[i];
	cumgood[i] = cumgood0 + pctgood[i];
	cumgood0 = cumgood[i];
	diff[i] = abs(cumbad[i]-cumgood[i]);
end;
KS=max(diff);
print KS;
create stat_KS1 var{scoreband bad good pctbad pctgood cumbad cumgood diff};
append;
quit;
proc print data=stat_KS1;
run;


