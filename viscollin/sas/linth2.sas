%include data(linthall);

proc format;
	value $loclr 'OI' = 'red ' 'SI'='blue' 'SM'='green';
data linthall;
	set linthall;
	case = _n_;
	length col $8;
	col = put(loc, $loclr.);
	run;

*-- standard biplot;
%biplot(data=linthall, var=H2S sal Eh7 pH buf P K Ca Mg Na Mn Zn Cu NH4, id=case,
	std=std, htext=0.9 1.5, m0=0.0,
	colors = (col) black, copy=col loc type);
%gskip;

*-- Collinearity biplot;
%biplot(data=linthall, var=H2S sal Eh7 pH buf P K Ca Mg Na Mn Zn Cu NH4, id=case,
	std=std, htext=0.9 1.5, m0=0.0, inc=0.1,
	colors = (col) black, copy=col loc type,
	dim=14, plotreq=dim14*dim13,
	out=biplot, anno=bianno
);
%gskip;

goptions vsize=5in htext=2.;
axis1 order=(0 to 200 by 40) label=(a=90);
*outlier(data=linthall, var=H2S sal Eh7 pH buf P K Ca Mg Na Mn Zn Cu NH4, id=case);
