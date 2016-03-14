## Created March 2016
## function to plot a confidence band around the NLS fit
## meant to be called by all stations
## awaiting code from Jagdish
## NOTE THIS ROUTINE IS NOT WORKING
##-- plot the nls fit
library(ggplot2)
require(nlme)
pred.nls <- predict(nls.res)
pred.frame <- data.frame(sd.fl$Stage, pred.nls)
names(pred.frame) <- c("Stage", "Pred")
## pred.frame[order(pred.frame$sd.fl.Stage),]
pred.frame <- pred.frame[order(pred.frame$Stage),]

## from here
V <- vcov(nls.res)
X <- model.matrix(~(Stage)^5,data=sd.fl) ## JK check this
se.fit <- sqrt(diag(X %*% V %*% t(X)))  ## JK check this

pred.frame$lwr <- pred.nls-1.96*se.fit
pred.frame$upr <- pred.nls+1.96*se.fit

## plot(sd.fl$Stage, sd.fl$Discharge, add=TRUE)
## par(new=t)
## plot(pred.frame$Pred, type="l", add = TRUE)

ggplot(data = sd.fl, aes(Stage, Discharge)) + 
    geom_point(aes(position="jitter")) +
    ggtitle("SD curve for station 103") + labs(x = "Stage (m)", y = "Discharge (m3/s)") +
    theme(axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12)) +
    geom_line(data=pred.frame, aes(Stage, Pred)) +
    geom_ribbon(data=pred.frame,aes(ymin=lwr,ymax=upr),alpha=0.3)
    ## geom_smooth(formula=pred.frame$sd.fl.Stage~pred.frame$pred.nls, se=TRUE)


## grid <- with(mtcars, expand.grid(
##        wt = seq(min(wt), max(wt), length = 20),
##        cyl = levels(factor(cyl))
##      ))

## err <- stats::predict(model, newdata=grid, se = TRUE)
 ##     grid$ucl <- err$fit + 1.96 * err$se.fit
 ##     grid$lcl <- err$fit - 1.96 * err$se.fit
     
 ##     qplot(wt, mpg, data=mtcars, colour=factor(cyl)) +
 ##       geom_smooth(aes(ymin = lcl, ymax = ucl), data=grid, stat="identity")

grid <- with(sd.fl, expand.grid(Stage = seq(min(Stage), max(Stage), length=20), Dicharge = Discharge))                               
grid$model <-predict(nls.res, newdata=grid)

qplot(Stage, Discharge, data=sd.fl) +
                            geom_line(data=grid$model)

## qplot(wt, mpg, data=mtcars, colour=factor(cyl)) + geom_line(data=grid)
## work on getting the predict.nls working and set both interval and se.fit. Use the code above to fill into the ggplot figure.
predict(nls.res, newdata=grid,  se.fit=TRUE)


## from <http://stackoverflow.com/questions/14033551/r-plotting-confidence-bands-with-ggplot>
fit
