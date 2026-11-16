*include goptions;
goptions vsize=7.6 in htext=2;
%include data(iris);
title 'Data ellipses and HE plot for iris data';
title;
%gdispla(OFF);
%macro caption(label, x=2, y=96, htext=, out=caption);
	data &out;
	retain xsys ysys '1';
	length text $40;
	x=&x;
	y=&y;
	if &x < 20
		then position = '6';
	else if &x > 80
		then position = '4';
	else position = '5';
	%if %length(&htext) %then %do;
		size = &htext;
		%end;
	function ='label   ';
	text = "&label";
%mend;

%caption((a) Data ellipses, htext=2.4);
%ellipses(data=iris, 
   x=PetalLen, y=SepalLen, 
   group=species,
   colors=blue red green, 
   htext=1.8, 
   inanno=caption);


title; * 'HE-plot for Iris data';
proc glm data=iris outstat=stats noprint;
   class species;
   model SepalLen SepalWid PetalLen PetalWid = species / nouni ss3;


axis1 label=(a=90) order=(40 to 80 by 10);
legend1 position=(bottom center inside) offset=(0,1) mode=share frame;
%caption((b) H and E matrices, htext=2.4);
%heplot(data=iris,
   stat=stats,            /* Data set containing H & E matrices */
   var=Petallen SepalLen, /* Variables to plot */
   effect=species,        /* Effect to plot */
   vaxis=axis1,
   legend=legend1, 
   hsym=1.6, anno=caption);

%gdispla(ON);

%panels(rows=1, cols=2, name=heplot3a);
/*
%panels(rows=1, cols=2);
%gskip;
%panels(rows=1, cols=2, replay=1:3 2:4);
*/
