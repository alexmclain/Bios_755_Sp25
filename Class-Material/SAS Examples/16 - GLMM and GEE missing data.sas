libname BIOS755 "C:\Users\mclaina\OneDrive - University of South Carolina\Teaching\755_Spring_2022\Examples";



ods rtf file="C:\Users\mclaina\OneDrive - University of South Carolina\Teaching\755_Spring_2022\Examples\21 - GLMM and GEE missing data example.rtf";

proc print  data = BIOS755.Amenorrhea (obs=10);
run;


proc mi data=BIOS755.Amenorrhea NIMPUTE=10 seed=8675309 out=MI_Amen noprint;
* We could use the "by" statement to impute separately for each ID.
* We don't want to do that here, but it's an option when there is lots of data;
* by id;
class trt time y;
monotone logistic (y = trt time);
var trt time y;
run;


proc means data=MI_Amen mean stderr ;
by _imputation_ trt time;
var y;
output out=MI_mn mean=mn_Y stderr=SE_Y;
run ;


proc sort data=MI_mn ;
by trt time _imputation_ ;
run ;

proc mianalyze data=MI_mn ;
by trt time;
modeleffects mn_Y;
stderr SE_Y;
ods output parameterestimates=outcombine_1 ;
run ;

proc print data=outcombine_1;
run;

proc means data = BIOS755.Amenorrhea;
var Y;
by TRT time;
run;


proc transpose data=BIOS755.Amenorrhea out=Amenorrhea_wide prefix=Y;
by id;
id time;
var y;
run; 

data BIOS755.Amenorrhea_wide;
merge BIOS755.Amenorrhea Amenorrhea_wide;
by id;
if first.id;
drop y _NAME_ _LABEL_ prevy;
run;

proc print  data = BIOS755.Amenorrhea_wide (obs=10);
run;

proc sort data = BIOS755.Amenorrhea_wide;
by TRT;
run;


proc means data = BIOS755.Amenorrhea_wide;
var Y1 Y2 Y3 Y4;
by TRT;
run;


proc mi data=BIOS755.Amenorrhea_wide NIMPUTE=10 seed=8675309 out=MI_wide;
class y1 - y4;
fcs nbiter=20 logistic(y1-y4 = trt);
var trt y1 - y4;
run;

proc print  data = MI_wide (obs=10);
run;

proc means data=MI_wide mean stderr ;
by _imputation_ trt;
var y1 - y4;
output out=MI_mn mean=mn_Y1 mn_Y2 mn_Y3 mn_Y4 stderr=SE_Y1 SE_Y2 SE_Y3 SE_Y4;
run ;

proc print data=MI_mn ;
run ;

proc sort data=MI_mn ;
by trt _imputation_ ;
run ;

proc mianalyze data=MI_mn ;
by trt ;
modeleffects mn_Y1 mn_Y2 mn_Y3 mn_Y4 ;
stderr SE_Y1 SE_Y2 SE_Y3 SE_Y4 ;
ods output parameterestimates=outcombine_1 ;
run ;

proc print data=outcombine_1;
run;

proc means data = BIOS755.Amenorrhea_wide mean stderr clm alpha=0.05;
var Y1 Y2 Y3 Y4;
by TRT;
run;


proc mi data=BIOS755.Amenorrhea_wide NIMPUTE=10 seed=8675309 out=MI_wide;
class y1 - y4;
monotone logistic (y2 = y1 trt);
monotone logistic (y3 = y2 y1 y1*y2 trt);
monotone logistic (y4 = y3 y2 y1 y1*y2 y3*y2 trt);
var trt y1 - y4;
run;

proc print  data = MI_wide (obs=10);
run;

proc means data=MI_wide mean stderr ;
by _imputation_ trt;
var y1 - y4;
output out=MI_mn mean=mn_Y1 mn_Y2 mn_Y3 mn_Y4 stderr=SE_Y1 SE_Y2 SE_Y3 SE_Y4;
run ;

proc print data=MI_mn ;
run ;

proc sort data=MI_mn ;
by trt _imputation_ ;
run ;

proc mianalyze data=MI_mn ;
by trt ;
modeleffects mn_Y1 mn_Y2 mn_Y3 mn_Y4 ;
stderr SE_Y1 SE_Y2 SE_Y3 SE_Y4 ;
ods output parameterestimates=outcombine_1 ;
run ;

proc print data=outcombine_1;
run;

proc means data = BIOS755.Amenorrhea_wide mean std clm alpha=0.05;
var Y1 Y2 Y3 Y4;
by TRT;
run;



data MI_wide_long;
set MI_wide;
  time=1;
  Y=Y1;
  output;
  time=2;
  Y=Y2;
  output;
  time=3;
  Y=Y3;
  output;
  time=4;
  Y=Y4;
  output;
  drop Y1-Y4;
run;
run;

proc glimmix data=MI_wide_long method=QUAD(qpoints=50);
   by _Imputation_;
   class ID;
   model Y = Time trt Time*Time trt*Time trt*Time*Time / dist=bin solution covb;
   random intercept  / subject=id;
   ods output ParameterEstimates=mixparms CovB=mixcovb;
run;

   proc mianalyze parms=mixparms covb(effectvar=rowcol)=mixcovb ; 
   *The covb is only needed for multi-variate results (i.e., type III tests or contrast statements;
      modeleffects Intercept Time trt Time*Time trt*Time trt*Time*Time;
     title 'MIANALYZE Results';
   run;


proc glimmix data=BIOS755.Amenorrhea method=QUAD(qpoints=50);
   class ID;
   model Y = Time trt Time*Time trt*Time trt*Time*Time / dist=bin solution;
   random intercept  / subject=id;
run;



data BIOS755.Amenorrhea;
set BIOS755.Amenorrhea;
Ctime = time;
prevy = lag(y);
run;

ods graphics on;
proc gee data=BIOS755.Amenorrhea desc plots=histogram;
   class ID Ctime;
   missmodel Ctime Prevy trt trt*Prevy / type=obslevel;
   model Y = Time trt Time*Time trt*Time trt*Time*Time / dist=bin;
   repeated subject=ID / within=Ctime corr=cs;
run;


proc gee data=BIOS755.Amenorrhea desc plots=histogram;
   class ID Ctime;
   model Y = Time trt Time*Time trt*Time trt*Time*Time / dist=bin;
   repeated subject=ID / within=Ctime corr=cs;
run;

ods graphics off;

ods rtf close;
