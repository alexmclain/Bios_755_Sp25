
data hiv;
infile "/home/mclaina0/Longitudinal Data/hivstudy.txt" dlm=tab;
input ID Month CD4 Group;
run;


ods rtf file="/home/mclaina0/Longitudinal Data/08 - LMM Example HIV.rtf";

proc print data = hiv (obs=10);
run;

*Now we will include the mean line on the graph by TRT;
proc sort data=hiv;
by Group Month;

*Calculate the mean by week;
proc means mean data=hiv noprint;
by Group Month;
var CD4;
output out = MN_GRP_dat mean = mn_GRP_CD4; 
run;


*First, let's look at the mean by TRT group;
Proc SGplot data = MN_GRP_dat;
series x=Month y=mn_GRP_CD4 / group =Group LineAttrs= (pattern=1 thickness=3);
run;


*We'll look at the means by TRT group with the rest of the data;
data stacked_hiv;
set hiv MN_GRP_dat;
run;


* Now we'll combine them onto one plot with two panels;
Proc SGpanel data = stacked_hiv;
PanelBy Group / columns=3;
series x=Month y=CD4 / group =ID LineAttrs= (pattern=1 color="black");
series x=Month y=mn_GRP_CD4 / LineAttrs= (pattern=1 color="blue" thickness=4);
run;


data hiv_spline;
set hiv;
sp_mn1 = min(month,4);
sp_mn2 = max(0,month-4);
run;


proc mixed data=hiv_spline covtest;
class ID group(ref='1');
model CD4 = group month sp_mn2 group*month group*sp_mn2/solution outpm=pred;
random intercept /type=UN subject=ID g gcorr v vcorr;
run;


proc mixed data=hiv_spline covtest;
class ID group(ref='1');
model CD4 = group month sp_mn2 group*month group*sp_mn2/solution outpm=pred;
random intercept month/type=UN subject=ID g gcorr v vcorr;
run;


proc mixed data=hiv_spline covtest;
class ID group(ref='1');
model CD4 = group month sp_mn2 group*month group*sp_mn2/solution outpm=pred;
random intercept month sp_mn2/type=UN subject=ID g gcorr v vcorr;
run;

proc mixed data=hiv_spline method=ml;
class ID group(ref='1');
model CD4 = group month sp_mn2 group*month group*sp_mn2/solution outpm=pred;
random intercept /type=UN subject=ID g gcorr v vcorr;
run;


proc mixed data=hiv_spline method=ml;
class ID month group(ref='1');
model CD4 = group month group*month/solution outpm=pred2;
random intercept/type=UN subject=ID g gcorr v vcorr;
run;

proc mixed data=hiv_spline;
class ID month group(ref='1');
model CD4 = group month group*month/solution outpm=pred2;
random intercept/type=UN subject=ID g gcorr v vcorr;
run;


proc mixed data=hiv_spline;
class ID month group(ref='1');
model CD4 = group month group*month/solution outpm=pred2;
repeated month/type=CSH subject=ID r rcorr;
run;


ods rtf close;
