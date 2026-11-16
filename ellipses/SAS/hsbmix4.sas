%include data(hsbmix);
goptions vsize=6in hsize=6in;
goptions htext=2 htitle=2.5;
*goptions xpixels=600 ypixels=600;
*options mprint;
*gsize(hsize=6, vsize=6);
%gsize(dpi=100);

proc sort data=hsbmix;
	by sector school;

title 'OLS regression, ignoring sector';
proc reg data=hsbmix outest=parms1(drop=_model_ _type_ _rmse_ _depvar_ mathach) noprint;
	model mathach = cses;
	by sector;
run;
*proc print data=parms1;
*run;

title 'OLS regression, by sector';
proc reg data=hsbmix outest=parms2(drop=_model_ _type_ _rmse_ _depvar_ mathach ) noprint;
	by sector school;
	model mathach = cses;
	output out=predict p=pmath;
run;
*proc print data=parms2 (obs=30);
*run;

data olsparms;
	set parms1 (in=in1)
	    parms2 (in=in2);
	proc='reg';
	if in1 then type='pooled   ';
		else type='separate';
proc print data=olsparms (obs=30);
title2 'olsparms';
run;
	
title 'Mixed model: random intercepts & slopes';
proc mixed data=hsbmix noclprint covtest method=reml noitprint;
	class school sector;
	model mathach = cses / solution ddfm=bw outp=mix3 outpm=mix3m;
	random intercept cses / solution sub=school type=un;
	ods output solutionF = solutionF;
	ods output solutionR = solutionR;
run;

title2 'solutionF';
proc print data=solutionF;

*proc contents data=solutionR;
data solutionR;
	set solutionR;
	drop DF;
	run;
title2 'solutionR';
proc print data=solutionR (obs=20);

data parmsF;
	set solutionF end=eof;
	proc='mixed'; type='fixed   ';
	retain Intercept cses;
	keep Intercept cses proc type;
	if Effect='Intercept' then Intercept=Estimate;
	else cses=Estimate;
	if eof then output;
proc print;

proc transpose data=solutionR out=parmsR(drop=_name_);
	by school;
	var Estimate;
	id Effect;	
proc print data=parmsR (obs=20);

data mixparms;
	set parmsF (in=in1)
		parmsR (in=in2);
	proc='mixed ';
	retain IntF csesF;
	drop IntF csesF;
	if in1 then do;
		IntF = Intercept;
		csesF=cses;
		end;
	if in2 then do;
		type='random';
		Intercept = IntF + Intercept;
		cses = csesF + cses;
		end;
		
proc print data=mixparms(obs=20);

proc sort data=olsparms; by school;
proc sort data=mixparms; by school;

data allparms;
	merge olsparms(rename=(Intercept=InterceptReg cses=csesReg) where=(school ne .))
	      mixparms(rename=(Intercept=InterceptMix cses=csesMix) where=(school ne .));
	by school;
	label csesReg = 'CSES slope (BLUE)'
		  csesMix ='CSES slope (BLUP)'
		  InterceptReg = 'Intercept: Avg Math at CSES=0 (BLUE)'
		  InterceptMix = 'Intercept: Avg Math at CSES=0 (BLUP)'
		  ;
	drop proc type;
	format InterceptMix csesMix 7.3;
	run;
proc print data=allparms(obs=20);
title2 'allparms: ols+mix';

data line;
	retain xsys ysys '2';
	length function $8 text $25;
	x= 4; y= 4; function='move';  output;
	x=20; y=20; function='draw';  output;
	x= 4; y=12.6493; function='label'; position='3'; text='Mixed-model GLS'; output;
	angle=90;
/*
	x=12.76; y=20; function='label'; position='1'; text='Pooled OLS'; output;
*/
	x=12.6493; y=20; function='label'; position='1'; text='Mixed-model GLS'; output;

title 'BLUEs vs. BLUPS: Intercepts';	

proc gplot data=allparms;
	plot InterceptMix * InterceptReg = sector /
		vaxis=axis1 haxis=axis2 hm=1 vm=1 legend=legend1 anno=line
		href= 12.76 vref=12.6493;
	symbol1 v=square color=red;
	symbol2 v=dot color=blue;
	axis1 order=(4 to 20 by 4) label=(a=90);
	axis2 order=(4 to 20 by 4);
	legend1 position=(inside bottom right) mode=protect;
	format InterceptMix 3.0;
	run;
%gskip;

data line;
	retain xsys ysys '2';
	length function $8 text $25;
	x=-3; y=-3; function='move   ';  output;
	x= 7; y= 7; function='draw   ';  output;

	x=-3; y=2.1932; function='label'; position='3'; text='Mixed-model GLS'; output;
	angle=90;
/*
	x=2.19; y=7; function='label'; position='1'; text='Pooled OLS'; output;
*/
	x=2.1932; y=7; function='label'; position='1'; text='Mixed-model GLS'; output;

	run;
/*
%ellipses(data=allparms, var=csesReg csesMix, group=sector, 
	symbols=none, line=34, width=1, out=ellslope, plot=no, annoadd=NONE, pvalue=0.68);
data line;
	set line ellslope;
	run;
*/

*title 'OLS vs. Mixed estimates: Slopes';	
title 'BLUEs vs. BLUPS: Slopes';	
proc gplot data=allparms;
	plot csesMix * csesReg = sector /
		vaxis=axis1 haxis=axis2 hm=1 vm=1 legend=legend1 anno=line
		href=2.19   vref=2.1932;
	symbol1 v=square color=red;
	symbol2 v=dot color=blue;
	axis1 order=(-3 to 7) label=(a=90) ;
	axis2 order=(-3 to 7) ;
	format csesMix 3.0;
run;
%gskip;

title;
data allparms;
	set allparms;
	format csesMix 7.0;
	format InterceptMix 7.0;
run;

proc summary data=allparms nway;
	class sector;
	var InterceptMix csesMix;
	output out=mixmeans mean=Intercept cses;
	run;
proc print;

proc summary data=allparms nway;
	class sector;
	var InterceptReg csesReg;
	output out=regmeans mean=Intercept cses;
	run;
proc print;

data lines;
	set regmeans mixmeans;
	drop _type_ _freq_;
	by sector;
	retain xsys ysys '2';
	length function color $8;
	x = Intercept; y = cses;
	if sector=0 then color='red'; else color='blue'; size=1; line=2;
	if first.sector then function='move'; else function='draw';	
	output;
	function = 'symbol'; text='dot'; size=2;
	output;
	
	if last.sector then do; 
		function = 'draw'; size=1;
	/*	x = 12.76; y = 2.19; */
		x = 12.6493; y = 2.1932;
		output;
		function = 'symbol'; color='black'; text='dot'; size=2;
		output;
		end;	
	

proc print;


data labels;
	retain xsys ysys '2';
	length function color $8 text $25;
	function='label';
	y=2.1932;  x=6;  position='3'; text='Mixed-model GLS'; output;
	angle=90;
	x=12.6493; y=-1; position='3'; text='Mixed-model GLS'; output;
	angle=0;
	x=10;   y=4.5;  position='5'; text='Public'; color='red';   output;
	x=16.5; y=0;    position='5'; text='Catholic'; color='blue'; output;
	size=1.5; color='black';
	x=14.4; y=4.5;  position='5'; text='BLUEs';  output;
	x=16.6; y=2.9;  position='5'; text='BLUEs';  output;
	x= 9.0; y=1.9;  position='5'; text='BLUPs';  output;
	x=16.0; y=1.6;  position='5'; text='BLUPs';  output;
	run;
	
axis1 order=(-1 to 5) label=(a=90 'CSES slope');
axis2 order=(6 to 18 by 4) label=('Intercept: Avg Math at CSES=0');
%ellipses(data=allparms, var=InterceptMix csesMix, group=sector, vaxis=axis1, haxis=axis2, 
	symbols=none, line=1, width=3, name=e1, out=ell1, plot=no, annoadd=NONE, pvalue=0.5);

data ell1;
	set ell1 labels lines;

%ellipses(data=allparms, var=InterceptReg csesReg, group=sector, vaxis=axis1, haxis=axis2, 
	symbols=none, line=5,  inanno=ell1, plotopt=vref=2.1932 href=12.6493, annoadd=NONE, pvalue=0.5);





