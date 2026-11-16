%newsas(hecaniris);
*include goptions;
*goptions vsize=3.2 in horigin=.5in htext=2;
*eps(hecaniris);

%include macros(canplot);
%include data(iris);
		
title h=2.5 'Iris Data - HE plot of Canonical Dimensions';
title;
/*
axis1 order=(-10 to 10 by 2);
axis2 label=(a=90);
*/
legend1 value=(h=1.5) position=(inside bottom center) mode=protect;
*-- use canplot for side effect of getting Can scores and annotate dataset;
%canplot(
   data=iris,
   class=species,
   var=SepalLen SepalWid PetalLen PetalWid,
   legend=legend1, 
   hsym=1,
   colors=blue red green ,
   symbols=triangle plus square,
   yextra=1 0, inc=2 2, 
   plot=NO,
   scale=4.5, varcolor=blue,
   out=canscores,      /* output data set containing discrim scores */
   anno=cananno);      /* output data set containing annotations    */

*-- Remove stuff we dont want;
data cananno;
	set cananno;
	where comment not in ('MEAN', 'CIRCLE');
	run;

*-- Get H and E matrices for canonical scores;
proc glm data=canscores outstat=stats;
	class species;
	model can1 can2  = species / nouni ss3;
	manova h=species;
	run;

*-- Axis statements to equate axis units;
axis1 length=2.6 IN order=(-4 to 4 by 2) label=(a=90);
axis2 length=6.5 IN order=(-10 to 10 by 2);

%heplot(data=canscores, stat=stats, 
	x=Can1, y=Can2,
	effect=species,
	haxis=axis2, vaxis=axis1, 
	legend=none, hsym=1.6,
	anno=cananno
);

	
