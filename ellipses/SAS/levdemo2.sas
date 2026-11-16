*include goptions;
goptions hsize=5in vsize=4in htext=3.5;
*goptions xpixels=500 ypixels=400 htext=3.5;

data levdemo;
   do i=1 to 20;
*      x = 40 + 20*(uniform(187543281)-.5);
      x = 40 + 10*normal(187543281);
      y = 10 + .75*x + 2.5*normal(187543281);
	  do case=0 to 3;
	      output;
		  end;
      end;

proc sort data=levdemo;
	by case x;

data extra;
   case=0; id='  ';  x = 65; y = .;  output;
   case=1; id='O ';  x = 40; y = 71; output;
   case=2; id='L ';  x = 88; y = 71; output;
   case=3; id='OL';  x = 88; y = 21; output;
/*
   case=2; id='-L';  x = 76; y = 60; output;
   case=3; id='OL';  x = 76; y = 21; output;
*/

data levdemo1;
	set levdemo extra;
	by case;

data points;
	set extra;
	length text $30 function color $8;;
	xsys='2'; ysys='2'; when='A';
	if case>0 then do;
		function = 'symbol'; 
			text='dot'; color='blue'; size=4;  output;
		function = 'text'; 
			text=id; color='blue'; size=4; position='4'; x=x-2;  output;
		end;
	x=12; y=75; position='C';  function='label'; size=4;
	select(case);
		when(0) text='(a) Original data'; 
		when(1) text='(b) Low leverage, Outlier  '; 
		when(2) text='(c) High leverage, good fit'; 
		when(3) text='(d) High leverage, Outlier '; 
		otherwise;
		end;
		output;
proc reg data=levdemo1 outest=parms noprint;
   model y = x ;
   output out=demo1 p=p;
   by case;

*proc print data=parms;

data regline;
	set parms;
	where case=0;
	slope = x;
	xsys='2'; ysys='2'; when='A'; size=1; line=5;
	x=12; y= intercept + slope * x;	function = 'move '; output;
	x=75; y= intercept + slope * x;	function = 'draw '; output;
data regline;
	set regline;
	do case=1 to 3;
	   output;
	   end;
proc sort data=regline;
	by case;
*proc print;

%ellipses(data=levdemo1, x=x, y=y, group=case, pvalue=0.68, out=ellipses,
plot=no);

*-- Fix up the annotate data set to be suitable for by-processing;
data ellipses;
	set ellipses; drop pvalue;
	retain case -1;
	if case = . then case=_gp_-1;
	if comment = 'ellipse' then color = 'black';
proc sort data=ellipses;
	by case;	
proc print;

data points;
	set points regline ellipses;
	by case;

%gdispla(OFF);	
axis1 order=(20 to 80 by 60) offset=(3);
axis2 order=(10 to 90 by 80) offset=(3);
goptions hby=0;
proc gplot data=demo1 uniform;
   plot y * x = 1
        p * x = 2 / 
		overlay  hm=0 vm=0 vaxis=axis1 haxis=axis2
		anno=points;
   by case;
   symbol1 v=dot     i=none   c=black h=2.5;
   symbol2 v=none    i=rl   l=1 c=blue width=3;
run;
%gdispla(ON);
%panels(rows=2,cols=2, order=down);   

%gskip;

data points;
	set extra;
	length text $25 function color $8;;
	xsys='2'; ysys='2'; when='A';
	select (case);
		when (1) color='red';
		when (2) color='blue';
		when (3) color='green';
		otherwise ;
		end;
	if case>0 then do;
		function = 'symbol'; 
		text='dot'; size=4;  output;
		function = 'text'; 
		text=id; size=4; position='4'; x=x-2;  output;
		end;

axis1 order=(20 to 80 by 60) offset=(3);
axis2 order=(10 to 90 by 80) offset=(3);
%ellipses(data=levdemo1, x=x, y=y, group=case, pvalue=0.68, annoadd=,
	symbols=dot none none none,
	hsym=2,
	colors=BLACK RED BLUE GREEN, 
	line = 1     5   5    5,
	width= 4     2   2    2,
	inanno=points,
	vaxis=axis1, haxis=axis2);
    
