data bloodpressure;
Input person $ @@;
do i=1 to 10;
input sysbp @@;
output;
end;
datalines;
1 130 136 124 121 128 138 130 126 136 133
2 123 116 117 120 117 113 111 124 110 116
3 144 139 136 142 142 133 140 138 140 139
4 128 133 127 124 132 130 134 124 131 128
5 128 128 122 120 121 123 132 130 126 132
;

proc mixed data=bloodpressure covtest;
class person;
model sysbp = / solution;
random person;
run;
