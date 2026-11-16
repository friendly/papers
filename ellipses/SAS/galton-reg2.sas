%include goptions;
goptions hsize=7in vsize=6.5in htext=1.8;
*goptions hsize=3.5in vsize=3.25in htext=2.5 htitle=3;

%include data(galton);
proc corr;
	var child parent;
	weight frequency;
run;

	*-- Define axes;
   axis1 order = (61 to 75 by 2)  label=(a=90 r=0)
         minor = none;
   axis2 order = (61 to 75 by 2)
    	offset=(1,2)
         minor = none;

	*-- Data ellipses;
%contour(data=galton, 
	x=child, y=parent, weight=frequency,
	pvalue=.40 .68 .95, std=std, colors=blue,
	out=ellipse, plot=no);

	*-- lowess smooth;
	* NB: AICC gives f=.698;
*lowess(data=galton, 
	x=child, y=parent, freq=frequency, 
	colors=black,
	/* proctest=0, */
	outanno=lowess, gplot=no, f=.698);

	*-- regression of x on y: fit, then exchange X,Y;
%regline(data=galton,
	y=child, x=parent, weight=frequency,
	color=gray, width=2,
	xmin=62, xmax=74,
	out=regline2
	);
data regline2;
	set regline2;
	drop tmp;
	tmp = y;
	y = x;
	x = tmp;

data arrows;
	retain xsys ysys '2';
	color='blue'; line=5;
	x = 73;  y= 68.30;  function = 'move    ';  output;
	x = 75;  y= 68.30;  function = 'draw    ';  output;

	x = 74.5; yh = 45.969 + .328*x; 
	x = 73;    y=yh;	function = 'move    ';  output;	
	x = 74.5;  y=yh;	function = 'draw    ';  output;	
	
	x = 71;  y= 72.75;  function = 'move    ';  output;
	x = 75;  y= 72.75;  function = 'draw    ';  output;

	text='r'; size=2.7;
	x = 74.6;  y=70.2;  function = 'label   ';  output; 
	line=1; size=2.7;
	%arrow(74.3, 68.3, 74.3, yh,  vechead=0.2 0.1);
	%arrow(75,   68.3, 75, 72.75, vechead=0.2 0.1);
	run;
	
	*-- regression of y on x;
%regline(data=galton,
	x=child, y=parent, weight=frequency,
/*	color=red, width=3, */
	color=black, width=2,
	xmin=61, xmax=75,
	in= /* lowess */ ellipse regline2 arrows,
	out=regline	);


*title 'Galton data';
title;
%sunplot(data=galton, x=child, y=parent, count=frequency,
	hsym=3.5, color=gray,
	vaxis=axis1, haxis=axis2,
	anno=regline
	);


