%include data(baseball);

options ls=120 ps=100;

%outlier(data=baseball,
	var= years 
         atbatc hitsc homerc runsc rbic walksc,
	id=name, print=no, pvalue=0.001, gplot=NO,
	out=baseout);
*proc print data=baseout;
*	where (_weight_=0);
title;

data baseout;
   set baseout;
   length lname $12; drop lname;
   lname=scan(name,2);
   if _weight_=0
    	then case=lname;
		else case=' ';
   logsal = log(salary);
   label logsal = 'log(Salary)';
   years7 = min(years,7);
   col = scan('blue red', index('NA', league));
   
*-- Only career statistics;
proc reg data=baseout;
	model logsal = 
         years7 
         atbatc hitsc homerc runsc rbic walksc
		 / vif collinoint;
run;
%biplot(data=baseout,
	var= years7 
         atbatc hitsc homerc runsc rbic walksc,
	id=case,
	std=std,
	dim=7, plotreq=dim7*dim6,
	m0 = 0.0, htext=0.8 1.8, 
	inc = 0.1, xextra=0 1,
	colors=(col) black, copy=col, dimlab=Dimension)

