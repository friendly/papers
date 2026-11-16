*include goptions;
goptions hsize=6in vsize=6in htext=2.2 htitle=2.4;
*size(1);
%include data(iris) ;

%let x=PetalWid;
%let y=PetalLen;

%let x=SepalWid;
%let y=SepalLen;

%gdispla(OFF);
*include macros(ellipses25);
title '(a) Total sample, marginal ellipse, ignoring species';
axis2 order=(20 to 45 by 5) offset=(3);
%ellipses(data=iris,
	x=&x, y=&y,
	colors=black, i=rl, iwidth=3,
	line=1,
	width=3,
	symbols=dot,
	haxis=axis2,
	pvalue=.68);
%gskip;

title '(b) Individual sample, conditional ellipses | species';
%ellipses(data=iris,
	x=&x, y=&y,
	group=species,
	colors=blue red green black, i=rl, iwidth=2,
	all=YES,
	symbols=triangle plus square,
	line = 5 5 5 1,
	width= 3 3 3 1,
	haxis=axis2,
	pvalue=.68);

/*
proc standard data=iris out=resids m=0;
	var SepalLen SepalWid PetalLen PetalWid;
	by species notsorted;


proc means mean std data=resids;
	var SepalLen SepalWid PetalLen PetalWid;
	class species;

title 'Pooled, within-sample ellipses';
axis2 order=(-20 to 10 by 10) offset=(3);
%ellipses(data=resids,
	x=&x, y=&y,
	group=species,
	colors=blue red green black, i=rl,
	all=YES,
	symbols=triangle plus square none,
	line = 5 5 5 1,
	width= 1 1 1 3,
	haxis=axis2,
	pvalue=.68);
*/

proc glm data=iris noprint;
	class species;
	model SepalLen SepalWid PetalLen PetalWid = species /nouni;
	output out=resids
		r=seplen sepwid petlen petwid;
/*
proc means mean std data=resids;
	var SepLen SepWid PetLen PetWid;
	class species;
*/

proc summary data=iris;
	var SepalLen SepalWid PetalLen PetalWid;
	output out=means mean=;
*proc print;

*-- translate to grand mean;
data resids;
	if _n_=1 then set means;
	retain SepalLen SepalWid PetalLen PetalWid;
	set resids (keep=seplen sepwid petlen petwid species);
	label 
		sepwid = 'Sepal width'
		seplen = 'Sepal Length'
		petwid = 'Petal width'
		petlen = 'Petal Length';

	sepwid = sepwid + SepalWid;
	seplen = seplen + SepalLen;
	petwid = petwid + PetalWid;
	petlen = petlen + PetalLen;

		
%let x=SepWid;
%let y=SepLen;
		
title '(c) Pooled, within-sample ellipse';
axis2 order=(20 to 45 by 5) offset=(3);
%ellipses(data=resids,
	x=&x, y=&y,
	group=species,
	colors=blue red green black, i=rl, iwidth=2,
	all=YES,
	symbols=triangle plus square none,
	line = 5 5 5 1,
	width= 1 1 1 3,
	haxis=axis2,
	pvalue=.68);
%gdispla(ON);

%panels(rows=1, cols=3);



