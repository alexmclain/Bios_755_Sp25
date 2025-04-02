

proc import file= 'C:/Users/mclaina/OneDrive - University of South Carolina/Teaching/755_Spring_2022/Homework/ahead.csv' out=ahead dbms=csv replace;
getnames=Yes;
run;

data ahead_lag;
set ahead;
iadlany_lag = lag(iadlany);
run;

proc gee data=ahead_lag desc plots=histogram;
   class id;
   missmodel age sex age*sex iadlany_lag sex*iadlany_lag / type=obslevel;
   model iadlany = age sex age*sex  / dist=bin;
   repeated subject=id / corr=cs;
run;


data ahead_mono;
set ahead_lag;
iadlany_mono = .;
if iadlany_lag ne . then iadlany_mono=iadlany;
if year = 0 then iadlany_mono=iadlany;
run;


proc gee data=ahead_mono desc plots=histogram;
   class id;
   missmodel age sex age*sex iadlany_lag sex*iadlany_lag / type=obslevel;
   model iadlany_mono = age sex age*sex  / dist=bin;
   repeated subject=id / corr=cs;
run;

data ahead_mono2;
set ahead_lag;
by id;
  miss = 0;
  do i=1 to 4;
  if first.id then miss = 0;
  if iadlany eq . then miss = 1;
  if lag(miss) eq 1 then miss = 1;
iadlany_mono = iadlany;
if miss = 1 then iadlany_mono = .;
end;
output;
drop i miss; 
run;


proc gee data=ahead_mono2 desc plots=histogram;
   class id;
   missmodel age sex age*sex iadlany_lag sex*iadlany_lag / type=obslevel;
   model iadlany_mono = age sex age*sex  / dist=bin;
   repeated subject=id / corr=cs;
run;

