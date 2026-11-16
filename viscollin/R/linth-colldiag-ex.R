# Linthall Biomass data - collinearity diagnostics examples

library(car)         # for vif
library(perturb)     # for colldiag

# table plot programs
source("c:/R/tableplot/tableplot.R")
source("c:/R/tableplot/cellgram.R")
source("c:/R/tableplot/make.patterns.R")
source("c:/R/tableplot/tableplot.colldiag.R")
setwd("c:/sasuser/datavis/collin/")

# read the data, slightly awkward in R because there are 2 lines/case
mat <-
matrix(scan("http://www.math.yorku.ca/SCS/viscollin/data/linthall.dat",what=""),
            ncol=17, byrow=TRUE)
linth <- data.frame(mat[-1,], stringsAsFactors=FALSE)
linth[] <- lapply(linth, type.convert)
names(linth) <- mat[1,]

linth.mod <- lm (bio ~ H2S+sal+Eh7+pH+buf+P+K+Ca+Mg+Na+Mn+Zn+Cu+NH4, data=linth)
vif(linth.mod)

cd <- colldiag(linth.mod, add.intercept=FALSE, center=TRUE)
# simplified display
print(colldiag(linth.mod, add.intercept=FALSE, center=TRUE), fuzz=.3)

tableplot.colldiag(cd, show.rows=14:5)

# collinearity biplot of last 2 dimensions
# [the scaling of variable vectors differs from the SAS version]
biplot( prcomp(linth[,4:17]), scale=0.5, choices=13:14, cex=c(0.6,1))
