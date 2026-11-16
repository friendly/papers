library(car)         # for vif
library(perturb)     # for colldiag

#baseball <- read.csv("c:/sasuser/data/baseball.csv")
baseball <- read.csv("http://www.math.yorku.ca/SCS/viscollin/data/baseball.csv")

baseball$logsal <- log(baseball$salary)
baseball$years7 <- pmin(baseball$years,7)

base.mod <- lm(logsal ~ years7+atbatc+hitsc+homerc+runsc+rbic+walksc, data=baseball)
vif(base.mod)

# SAS: / collin option
colldiag(base.mod)

# SAS: / collinoint option
cd <- colldiag(base.mod, add.intercept=FALSE, center=TRUE)
# simplified display
print(colldiag(base.mod, add.intercept=FALSE, center=TRUE), fuzz=.3)


source("c:/R/tableplot/tableplot.R")
source("c:/R/tableplot/cellgram.R")
source("c:/R/tableplot/make.patterns.R")
source("c:/R/tableplot/tableplot.colldiag.R")
setwd("c:/sasuser/datavis/collin/")

tableplot.colldiag(cd)

# same result, using the lm() object:
# tableplot.colldiag(base.mod)

# do collinearity biplot
pca <- princomp( ~years+atbatc+hitsc+homerc+runsc+rbic+walksc, data=baseball, cor=TRUE)
biplot(pca, choices=c(6,7), expand=1.5, cex=c(0.5,1.6), xlim=c(-0.3,0.4))

