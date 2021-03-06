# NFPERTMASK -- Make persistence masks.

procedure nfpermask (input)

file	input			{prompt="List of input NEWFIRM files"}
file	output = "+_per"	{prompt="List of persistence mask files"}
string	maskkey = "permask"	{prompt="Keyword to record mask in input (optional)"}
int	maskvalue = 1		{prompt="Mask value for persistence"}

real	perwindow = 5		{prompt="Persistence window"}
real	perthresh = 0.8		{prompt="Persistence threshold fraction of saturation"}
string	coeffs = "parameter"	{prompt="Coefficients (parameter|exprdb|keyword|image)",
				    enum="parameter|exprdb|keyword|image"}
real	sat = 10000		{prompt="Saturation threshold"}
real	lin1 = -6.123E-6	{prompt="Linearity coefficient for im1"}
real	lin2 = -7.037E-6	{prompt="Linearity coefficient for im2"}
real	lin3 = -5.404E-6	{prompt="Linearity coefficient for im3"}
real	lin4 = -5.952E-6	{prompt="Linearity coefficient for im4"}
string	linimage = ""		{prompt="List of linearity coefficient images"}
string	satimage = ""		{prompt="List of saturation images"}

file	exprdb = "nfdat$exprdb.dat" {prompt="Expression database"}
bool	list = no		{prompt="List only?"}
string	logfiles = "STDOUT,logfile"	{prompt="Log files"}

begin
	string	linval, satval, maskval, outtype
	struct	expr

	# Set parameters.
	if (coeffs == "parameter") {
	    linval = "nfpermask.lin\I"
	    satval = "nfpermask.sat"
	    maskval = maskvalue
	} else if (coeffs == "exprdb") {
	    if (exprdb == "")
	        error (2, "Must specify expression database")
	    linval = "L\I"
	    satval = "S\I"
	    maskval = maskvalue
	} else if (coeffs == "keyword") {
	    linval = "lincoeff"
	    satval = "saturate"
	    maskval = maskvalue
	} else if (coeffs == "image") {
	    linval = "$L"
	    satval = "$R"
	    maskval = maskvalue
	} else
	    error (1, "Unknown coefficient type")

	# Set expression.
	if (exprdb == "")
	    printf ("%%($P>=%.2g*%s?%d: 0)\n",
	        perthresh, satval, maskval) | scan (expr)
	else
	    printf ("%%(per(%s,%.2g*%s,%d))\n",
	        linval, perthresh, satval, maskval) | scan (expr)

	# Set output type.
	if (list)
	    outtype = "vlist"
	else
	    outtype = "mask " // maskkey
	
	# Compute persistence mask or list the expressions.
	nfproc (input, output, outtype=outtype, logfiles=logfiles,
	    trim=no, fixpix=no, zerocor=no, biascor=no, lincor=no,
	    permask=yes, zerocor=no, darkcor=no, flatcor=no, skysub=no,
	    replace=no, normalize=no, zorder="TXB", dorder="TXBZ",
	    forder="TXBZDLR,N", order="TXBZDLFR,S", bpm="(bpm)",
	    obm="(objmask)", trimsec="(trimsec)", biassec="(biassec)",
	    linexpr="", linimage=linimage, persist=expr,
	    perwindow=perwindow, zeros="", darks="", flats="", flatexpr="",
	    skies="", skymatch="", skymode="median 10", repexpr="",
	    repimage=satimage, btype="fit", bfunction="legendre",
	    bsample="*", border="1", bnaverage="1", bniterate="1",
	    bhreject="3.", blreject="3.", bgrow="0.", intype="",
	    ztype="", dtype="(obstype='dark')", ftype="(obstype='flat')",
	    gtype="", stype="", imageid="(str(imageid))", filter="(filter)",
	    sortval="(@'mjd-obs')", exptime="(exptime)",
	    opdb="nfdat$opdb.dat", exprdb=exprdb, override=no, copy=no,
	    erraction="warn", gdevice="stdgraph", gcursor="", gplotfile="",
	    taskname="nfpermask")

end
