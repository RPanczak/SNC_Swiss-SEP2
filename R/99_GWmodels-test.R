################################################################################
# code from examples from paper
# http://dx.doi.org/10.18637/jss.v063.i17

library("GWmodel")

# Robust GW summary statistics

data("DubVoter")
plot(Dub.voter)
View(Dub.voter@data)

gw.ss.bx <- gwss(Dub.voter, vars = c("GenEl2004", "LARent", "Unempl"),
                 kernel = "boxcar", adaptive = TRUE, bw = 48, quantile = TRUE)
gw.ss.bs <- gwss(Dub.voter,vars = c("GenEl2004", "LARent", "Unempl"), 
                 kernel = "bisquare", adaptive = TRUE, bw = 48)

library("RColorBrewer")

map.na = list("SpatialPolygonsRescale", layout.north.arrow(),
              offset = c(329000, 261500), scale = 4000, col = 1)
map.scale.1 = list("SpatialPolygonsRescale", layout.scale.bar(),
                   offset = c(326500, 217000), scale = 5000, col = 1,
                   fill = c("transparent", "blue"))
map.scale.2 = list("sp.text", c(326500, 217900), "0", cex = 0.9, col = 1)
map.scale.3 = list("sp.text", c(331500, 217900), "5km", cex = 0.9, col = 1)
map.layout <- list(map.na, map.scale.1, map.scale.2, map.scale.3)
mypalette.1 <- brewer.pal(8, "Reds")
mypalette.2 <- brewer.pal(5, "Blues")
mypalette.3 <- brewer.pal(6, "Greens")

spplot(gw.ss.bx$SDF, "GenEl2004_LSD", key.space = "right",
       col.regions = mypalette.1, cuts = 7, sp.layout = map.layout,
       main = "GW standard deviations for GenEl2004 (basic)")

spplot(gw.ss.bx$SDF, "GenEl2004_IQR", key.space = "right",
       col.regions = mypalette.1, cuts = 7, sp.layout = map.layout,
       main = "GW inter-quartile ranges for GenEl2004 (robust)")

spplot(gw.ss.bx$SDF, "Corr_GenEl2004.LARent", key.space = "right",
       col.regions = mypalette.2, at = c(-1, -0.8, -0.6, -0.4, -0.2, 0),
       main = "GW correlations: GenEl2004 and LARent (box-car kernel)",
       sp.layout = map.layout)

spplot(gw.ss.bs$SDF, "Corr_GenEl2004.LARent", key.space = "right",
       col.regions = mypalette.2, at = c(-1, -0.8, -0.6, -0.4, -0.2, 0),
       main = "GW correlations: GenEl2004 and LARent (bi-square kernel)", sp.layout = map.layout)

spplot(gw.ss.bs$SDF, "Corr_LARent.Unempl", key.space = "right",
       col.regions = mypalette.3, at = c(-0.2, 0, 0.2, 0.4, 0.6, 0.8, 1),
       main = "GW correlations: LARent and Unempl (basic)",
       sp.layout = map.layout)

spplot(gw.ss.bs$SDF, "Spearman_rho_LARent.Unempl", key.space = "right",
       col.regions = mypalette.3, at = c(-0.2, 0, 0.2, 0.4, 0.6, 0.8, 1),
       main = "GW correlations: LARent and Unempl (robust)",
       sp.layout = map.layout)

# GW principal components analysis

Data.scaled <- scale(as.matrix(Dub.voter@data[, 4:11]))
pca.basic <- princomp(Data.scaled, cor = FALSE)
(pca.basic$sdev^2 / sum(pca.basic$sdev^2)) * 100

pca.basic$loadings

R.COV <- covMcd(Data.scaled, cor = FALSE, alpha = 0.75)
pca.robust <- princomp(Data.scaled, covmat = R.COV, cor = FALSE)
pca.robust$sdev^2 / sum(pca.robust$sdev^2)

pca.robust$loadings

Coords <- as.matrix(cbind(Dub.voter$X, Dub.voter$Y))
Data.scaled.spdf <- SpatialPointsDataFrame(Coords, as.data.frame(Data.scaled))

bw.gwpca.basic <- bw.gwpca(Data.scaled.spdf, 
                           vars = colnames(Data.scaled.spdf@data), 
                           k = 3, robust = FALSE, adaptive = TRUE)
bw.gwpca.basic

bw.gwpca.robust <- bw.gwpca(Data.scaled.spdf, 
                            vars = colnames(Data.scaled.spdf@data), 
                            k = 3, robust = TRUE, adaptive = TRUE)
bw.gwpca.robust

gwpca.basic <- gwpca(Data.scaled.spdf, 
                     vars = colnames(Data.scaled.spdf@data), 
                     bw = bw.gwpca.basic, 
                     k = 8, robust = FALSE, adaptive = TRUE)

gwpca.robust <- gwpca(Data.scaled.spdf,
                      vars = colnames(Data.scaled.spdf@data), 
                      bw = bw.gwpca.robust, 
                      k = 8, robust = TRUE, adaptive = TRUE)

prop.var <- function(gwpca.obj, n.components) {
  return((rowSums(gwpca.obj$var[, 1:n.components]) /
            rowSums(gwpca.obj$var)) * 100)
}

var.gwpca.basic <- prop.var(gwpca.basic, 3)
var.gwpca.robust <- prop.var(gwpca.robust, 3)

Dub.voter$var.gwpca.basic <- var.gwpca.basic
Dub.voter$var.gwpca.robust <- var.gwpca.robust

mypalette.4 <- brewer.pal(8, "YlGnBu")

spplot(Dub.voter, "var.gwpca.basic", key.space = "right",
       col.regions = mypalette.4, cuts = 7, sp.layout = map.layout,
       main = "PTV for local components 1 to 3 (basic GW PCA)")

spplot(Dub.voter, "var.gwpca.robust", key.space = "right",
       col.regions = mypalette.4, cuts = 7, sp.layout = map.layout,
       main = "PTV for local components 1 to 3 (robust GW PCA)")         

loadings.pc1.basic <- gwpca.basic$loadings[, , 1]
win.item.basic = max.col(abs(loadings.pc1.basic))

loadings.pc1.robust <- gwpca.robust$loadings[, , 1]
win.item.robust = max.col(abs(loadings.pc1.robust))

Dub.voter$win.item.basic <- win.item.basic
Dub.voter$win.item.robust <- win.item.robust

mypalette.5 <- c("lightpink", "blue", "grey", "purple", "orange", "green", "brown", "yellow")

spplot(Dub.voter, "win.item.basic", key.space = "right",
       col.regions = mypalette.5, at = c(1, 2, 3, 4, 5, 6, 7, 8, 9),
       main = "Winning variable: highest abs. loading on local Comp.1 (basic)",
       colorkey = FALSE, sp.layout = map.layout)

spplot(Dub.voter, "win.item.robust", key.space = "right",
       col.regions = mypalette.5, at = c(1, 2, 3, 4, 5, 6, 7, 8, 9),
       main = "Winning variable: highest abs. loading on local Comp.1 (robust)",
       colorkey = FALSE, sp.layout = map.layout)

################################################################################
# The code for the paper titled "The GWmodel R package: further topics
# for exploring spatial heterogeneity using geographically weighted models" by
# Binbin Lu, Paul Harris, Martin Charlton, and Chris Brunsdon
# Published in Geo-spatial Information Science

#  Code for section 3.4

# Dublin voter turnout data
data(DubVoter)

# GWSS for nearest 15% of data using a bi-square kernel
gwss.1 <- gwss(Dub.voter,
               vars = c("GenEl2004","LARent","Unempl"),
               kernel="bisquare",adaptive=TRUE,bw=48)

# GWSS Monte Carlo test
gwss.mc <- montecarlo.gwss(Dub.voter,
                           vars = c("GenEl2004","LARent","Unempl"),
                           kernel="bisquare",adaptive=TRUE,bw=48)

# Finding the unsual local correlations
gwss.mc.data <- data.frame(gwss.mc)
gwss.mc.out.1 <-ifelse(gwss.mc.data$Corr_GenEl2004.LARent < 0.975 & gwss.mc.data$Corr_GenEl2004.LARent > 0.025 , 0, 1)
gwss.mc.out.2 <-ifelse(gwss.mc.data$Corr_LARent.Unempl < 0.975 & gwss.mc.data$Corr_LARent.Unempl > 0.025 , 0, 1)
gwss.mc.out <- data.frame(Dub.voter$X, Dub.voter$Y, gwss.mc.out.1, gwss.mc.out.2)

# So can map them
gwss.mc.out.1.sig <- subset(gwss.mc.out, gwss.mc.out.1==1, select=c(Dub.voter.X, Dub.voter.Y, gwss.mc.out.1))
gwss.mc.out.2.sig <- subset(gwss.mc.out, gwss.mc.out.2==1, select=c(Dub.voter.X, Dub.voter.Y, gwss.mc.out.2))
pts.1 <- list("sp.points", cbind(gwss.mc.out.1.sig[,1],gwss.mc.out.1.sig[,2]),  cex=2, pch="+", col="black")
pts.2 <- list("sp.points", cbind(gwss.mc.out.2.sig[,1],gwss.mc.out.2.sig[,2]),  cex=2, pch="+", col="black")

# Colour palette for maps
mypalette.gwss.1 <-brewer.pal(5,"Blues")
mypalette.gwss.2 <-brewer.pal(6,"Greens")

# North arrow and map scale bar
map.na = list("SpatialPolygonsRescale", layout.north.arrow(), offset = c(329000,261500), scale = 4000, col=1)
map.scale.1 = list("SpatialPolygonsRescale", layout.scale.bar(), offset = c(326500,217000), scale = 5000, col=1,
                   fill=c("transparent","green"))
map.scale.2  = list("sp.text", c(326500,217900), "0", cex=0.9, col=1)
map.scale.3  = list("sp.text", c(331500,217900), "5km", cex=0.9, col=1)
map.layout.1 <- list(map.na,map.scale.1,map.scale.2,map.scale.3,pts.1)
map.layout.2 <- list(map.na,map.scale.1,map.scale.2,map.scale.3,pts.2)

# GW correlation maps
X11(width=10,height=12)
spplot(gwss.1$SDF,"Corr_GenEl2004.LARent",key.space = "right",
       col.regions=mypalette.gwss.1,at=c(-1,-0.8,-0.6,-0.4,-0.2,0),
       par.settings=list(fontsize=list(text=15)),
       main=list(label="GW correlations: GenEl2004 and LARent", cex=1.25),
       sub=list(label="+ Results of Monte Carlo test", cex=1.15),
       sp.layout=map.layout.1)

X11(width=10,height=12)
spplot(gwss.1$SDF,"Corr_LARent.Unempl",key.space = "right",
       col.regions=mypalette.gwss.2,at=c(-0.2,0,0.2,0.4,0.6,0.8,1),
       par.settings=list(fontsize=list(text=15)),
       main=list(label="GW correlations: LARent and Unempl", cex=1.25),
       sub=list(label="+ Results of Monte Carlo test", cex=1.15),
       sp.layout=map.layout.2)


# Code for section 3.5

# PCA/GWPCA on standardised data (unit variance)
Data.scaled <- scale(as.matrix(Dub.voter@data[,4:11]))

# PCA
pca <- princomp(Data.scaled,cor=F)
(pca$sdev^2 / sum(pca$sdev^2))*100
pca$loadings

# GWPCA
Coords <- as.matrix(cbind(Dub.voter$X,Dub.voter$Y))
Data.scaled.spdf <- SpatialPointsDataFrame(Coords,as.data.frame(Data.scaled))
bw.gwpca.1 <- bw.gwpca(Data.scaled.spdf,vars=colnames(Data.scaled.spdf@data),k=3,adaptive=TRUE)
bw.gwpca.1
gwpca.1 <- gwpca(Data.scaled.spdf,vars=colnames(Data.scaled.spdf@data),bw=bw.gwpca.1,k=8,adaptive=TRUE)

# For PTV map
prop.var <- function(gwpca.obj, n.components) {
  return((rowSums(gwpca.obj$var[, 1:n.components])/rowSums(gwpca.obj$var))*100)}

var.gwpca <- prop.var(gwpca.1,2)
Dub.voter$var.gwpca <- var.gwpca
mypalette.gwpca.1 <-brewer.pal(8,"YlGnBu")
map.layout.3 <- list(map.na,map.scale.1,map.scale.2,map.scale.3)

# PTV map
X11(width=10,height=12)
spplot(Dub.voter,"var.gwpca",key.space = "right",
       col.regions=mypalette.gwpca.1,cuts=7,
       par.settings=list(fontsize=list(text=15)),
       main=list(label="GW PCA: PTV for local components 1 to 2", cex=1.25),
       sp.layout=map.layout.3)

# Multivariate glyph map
loadings.1 <- gwpca.1$loadings[,,1]
X11(width=10,height=12)
plot(Dub.voter)
glyph.plot(loadings.1,Coords,r1=20,add=T,alpha=0.85)
title(main=list("GW PCA: Multivariate glyphs of loadings",cex=1.75,col="black",font=1),
      sub=list("For component 1",cex=1.5,col="black",font=3))

# GWPCA Monte Carlo test
gwpca.mc <-montecarlo.gwpca.2(Data.scaled.spdf,vars=colnames(Data.scaled.spdf@data),k=3,adaptive=TRUE)
X11(width=8,height=5)
plot.mcsims(gwpca.mc)