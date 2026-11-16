*include goptions;
goptions vsize=7.5in  hsize=7.5in;
*goptions xpixels=640 ypixels=640;
*options macrogen symbolgen;
%*gsize(hsize=7,vsize=7);

*options nomacrogen nosymbolgen;

 
%include data(iris);

%scatmat(data=iris,  
    var=SepalLen SepalWid PetalLen PetalWid, group=Species,
	symbols=triangle plus square, 
	colors= blue     red  green, 
	hsym=4, htitle=9,
	interp=rl, iwidth=4,
    anno=ellipse);
run;
%gskip;

*-- remove group means to view within-cell relations;
proc glm data=iris noprint;
	class species;
	model SepalLen SepalWid PetalLen PetalWid = Species /nouni;
	output out=resids
		r=seplen sepwid petlen petwid;
	run;
proc glm data=iris noprint;
	class species;
	model SepalLen SepalWid PetalLen PetalWid = Species /nouni;
	output out=fitted
		p=seplen sepwid petlen petwid;
	run;

proc corr data=resids nosimple noprob;
	var seplen sepwid petlen petwid;
	run;

%scatmat(data=resids,
    var=SepLen SepWid PetLen PetWid, group=Species,
    names=SepalLen SepalWid PetalLen PetalWid,
	symbols=triangle plus square, 
	colors= blue     red  green, 
	hsym=4, htitle=9,
	interp=rl, iwidth=4,
    anno=ellipse);
run;
%gskip;

%scatmat(data=iris,  
    var=SepalLen SepalWid PetalLen PetalWid, group=Species,
	symbols=none, 
	colors= blue     red  green, 
	hsym=4, htitle=9,
	interp=rl, iwidth=4,
    anno=ellipse);
run;
%gskip;

%scatmat(data=resids,
    var=SepLen SepWid PetLen PetWid, group=Species,
    names=SepalLen SepalWid PetalLen PetalWid,
	symbols=none, 
	colors= blue     red  green, 
	hsym=4, htitle=9,
	interp=rl,
    anno=ellipse);
run;
%gskip;

*-- view the E matrix (ignoring Species);

%scatmat(data=resids,
    var=SepLen SepWid PetLen PetWid, 
    names=SepalLen SepalWid PetalLen PetalWid,
	symbols=none, 
	colors= black, 
	hsym=4, htitle=9,
	interp=rl,
    anno=ellipse);
run;
%gskip;

%scatmat(data=fitted,
    var=SepLen SepWid PetLen PetWid, 
    names=SepalLen SepalWid PetalLen PetalWid,
	symbols=dot, 
	colors= black, 
	hsym=5, htitle=9,
	interp=rl,
    anno=ellipse, pvalue=0.5
	);
run;
