
            ##--- Create second order trend surface ---## 
            ## Define the 2nd order polynomial equation
            f.2     <- as.formula(mm ~ x + y + I(x*x)+I(y*y) + I(x*y))
            
            ## Run the regression model
            lm.2    <- lm( f.2, data=tmp1)
            
            ## Use the regression model output to interpolate the surface
            tmp1.2nd <- SpatialGridDataFrame(grd, data.frame(var1.pred = predict(lm.2, newdata=grd)))
            
            ## Plot the surface and contours
            OP      <- par( mar=c(0,0,0,0))
            image(tmp1.2nd ,"var1.pred",col=terrain.colors(20))
            contour(tmp1.2nd ,"var1.pred", add=TRUE, nlevels=10)
            plot(tmp1, add=TRUE, pch=16, cex=0.5)
            text(coordinates(tmp1), as.character(round(tmp1$mm,1)), pos=4, cex=0.8, col="blue")
            par(OP)


            

            ## run Kriging
            ## get experimental variogram
            var.cld  <- variogram(mm ~ 1, tmp1, cloud = TRUE)

                                        # Plot the experimental variogram cloud
            OP       <- par( mar=c(4,6,1,1))
            plot(var.cld$dist , var.cld$gamma, col="grey", pch=20, 
                 xlab = "Distance between point pairs",
                 ylab = expression( gamma ) )
            par(OP)
            
            
            ## Let's define the (quadratic) trend formula
            f.2 <- as.formula(mm ~ x + y + I(x*x)+I(y*y) + I(x*y))

            ## Now include the formula in the variogram function
            var.cld  <- variogram(f.2, tmp1, cloud = TRUE)

            ## And plot the result
            OP       <- par( mar=c(4,6,1,1))
            plot(var.cld$dist , var.cld$gamma, col="grey", pch=20,
                 xlab = "Distance between point pairs",
                 ylab = expression( gamma ) )
            par(OP)

            ## identify outliers
            var.cld[ which.max(var.cld$gamma) , ]
            ## Plot them
            plot(tmp1, pch=16, col="grey")
            points(tmp1[c(31,19) , ], pch=16, col="red")
            text(tmp1[c(31,19) , ], as.character(tmp1$mm[c(31,19)]), pos=2 )

            ## get sample experimental variogram
            var.smpl <- variogram(f.2, tmp1, cloud = FALSE)
            plot(var.smpl, pch= 16, col= "red")

            ## Check if variance is same in all direction
            plot(variogram(f.2,tmp1, alpha = c(0,90), cloud=FALSE), pch= 16, col= "red")


            ## select suitable variogram model
            show.vgms()


            ## trying spherical fit
            dat.fit <- fit.variogram(var.smpl, vgm(psill=10, model="Sph", range=5000, nugget=5),fit.method = 2)
            plot(var.smpl, dat.fit)

            dat.krg <- krige( f.2, tmp1, grd, dat.fit)

            OP      <- par( mar=c(0,0,0,0))
            image(dat.krg ,"var1.pred",col=terrain.colors(20))
            contour(dat.krg ,"var1.pred", add=TRUE, nlevels=10)
            plot(tmp1, add=TRUE, pch=16, cex=0.5)
            text(coordinates(tmp1), as.character(round(tmp1$mm,1)), pos=4, cex=0.8, col="blue")
            par(OP)


            OP      <- par( mar=c(0,0,0,0))
            image(dat.krg ,"var1.var",col=terrain.colors(20))
            contour(dat.krg ,"var1.var", add=TRUE, nlevels=10)
            par(OP)
