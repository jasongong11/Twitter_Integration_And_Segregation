library(TSA)
library(tseries)
library(urca)
library(astsa)
library(forecast)

stats_df = read.csv("~/data/stats_df.csv")

x <- ts(stats_df$viral_broadcast_2)
h3 <- ts(stats_df$gini)
h2a <- ts(stats_df$integration_b)
h2b <- ts(stats_df$segregation_b)

pairs(stats_df[,c('viral_broadcast_2', 'gini', 'segregation_b', 'integration_b')])

trend <- time(x)

lm_int <- lm(h2a ~ trend + x)
summary(lm_int)
acf2(residuals(lm_int), main="Trend model testing integration")
Box.test (residuals(lm_int), type = "Ljung")

lm_seg <- lm(h2b ~ trend + x)
summary(lm_seg)
acf2(residuals(lm_seg), main="Trend model testing segregation")
Box.test (residuals(lm_seg), type = "Ljung")

lm_gini <- lm(h3 ~ trend + x)
summary(lm_gini)
acf2(residuals(lm_gini), main="Trend model testing week eventful")
Box.test (residuals(lm_int), type = "Ljung")



adjreg2 = sarima (h2a, 0,0,1, xreg=cbind(trend,x))
adjreg2$fit
residuals(adjreg2$fit)
Box.test (residuals(adjreg2$fit), type = "Ljung")
acf2(residuals(adjreg2$fit))

adjreg1 = sarima (h2b, 0,0,1, xreg=cbind(trend,x))
adjreg1$fit
residuals(adjreg1$fit)
Box.test (residuals(adjreg1$fit), type = "Ljung")
acf2(residuals(adjreg1$fit), main="MA(1) model testing segregation")
2*pt(q=2.648, df=49, lower.tail=FALSE)

adjreg3 = sarima (x, 1,0,0, xreg=cbind(trend,x1))
adjreg3$fit
residuals(adjreg2$fit)
Box.test (residuals(adjreg3$fit), type = "Ljung")
acf2(residuals(adjreg2$fit), main="AR(1) model testing week eventful")
2*pt(q=2.778761, df=49, lower.tail=FALSE)

