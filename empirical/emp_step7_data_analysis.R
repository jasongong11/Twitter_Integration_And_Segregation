#### reads data ####
# read the simulation data
sim_raw <- read.csv('~/data/derivatives/sim_derivatives.csv')
# read empirical data
week_df <- read.csv('~/data/derivatives/stats_df.csv')

# make the z-scores of the variables and make them into a dataframe
week_df_std <- data.frame(scale(week_df[,1:(ncol(week_df)-1)]))
week_df_std <- cbind(week_df_std, week_df$week)

# data wrangling of the simulation data
# restructure the data from multiple columns to one column and label it by variable and simulation
sim_df <- sim_raw[,2:ncol(sim_raw)]
sim_df <- data.frame(list("value"=unlist(sim_df),
                          "variable"=rep(colnames(sim_df), each=1000),
                          "sim"=rep(1:1000, 4)))

# separate the dataframe into integration and segregation dataframe
sim_int_df <- sim_df[1:2000,]
sim_int_df$sim <- as.numeric(sim_int_df$sim)
# effect code the variable, and 1 equals viral, and 2 equals broadcast
sim_int_df$variable <- as.factor(sim_int_df$variable)

sim_seg_df <- sim_df[2001:4000,]
sim_seg_df$sim <- as.numeric(sim_seg_df$sim)
# effect code the variable, and 1 equals viral, and 2 equals broadcast
sim_seg_df$variable <- as.factor(sim_seg_df$variable)

#### statistical analysis for H1a,b ####
lm.1 <- lm('value ~ sim', sim_int_df)
summary(lm.1)
# remember to flip the sign of the parameter estimate when reporting the result
lm.2 <- lm('value ~ sim + variable', sim_int_df)
summary(lm.2)
# model comparison between the full model (lm.2) and the reduced model (lm.1)
anova(lm.1, lm.2)


lm.1 <- lm('value ~ sim', sim_seg_df)
summary(lm.1)
# remember to flip the sign of the parameter estimate when reporting the result
lm.2 <- lm('value ~ sim + variable', sim_seg_df)
summary(lm.2)
# model comparison between the full model (lm.2) and the reduced model (lm.1)
anova(lm.1, lm.2)


#### statistical analysis for H2a,b and H3 ####
summary(lm(integration_b~viral_broadcast_2,week_df_std))
summary(lm(segregation_b~viral_broadcast_2,week_df_std))
summary(lm(eventfulness~viral_broadcast_2,week_df_std))

