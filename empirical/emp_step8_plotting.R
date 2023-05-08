# devtools::install_github("NightingaleHealth/ggforestplot")
library(ggforestplot)
library(tidyverse)
library("ggsci")
library(plotly)
library(hrbrthemes)
library(cowplot)
library(RColorBrewer)
getPalette = colorRampPalette(brewer.pal(name="RdYlBu", n = 11))
library(R.matlab)
library(viridis)
library(ggridges)
library(ggpubr)
library(gridExtra)


#### load derivatives ####
week_df <- read.csv('/data/derivatives/stats_df.csv')
week_df_std <- data.frame(scale(week_df[,1:(ncol(week_df)-1)]))
week_df_std <- cbind(week_df_std, week_df$week)
colnames(week_df)


hashtag_df <- read.csv('/data/derivatives/hashtag_df.csv')
hashtag_df <- hashtag_df[,2:ncol(hashtag_df)]

week_df_std$week <- as.Date(week_df_std$week)
hashtag_df$hashtag <- factor(hashtag_df$hashtag, levels=unique(hashtag_df$hashtag))

#### figure s4 ####

figures4 <- ggplot(week_df_std, aes(x=segregation_b, y=integration_b)) +
  geom_point() +
  geom_smooth(method=lm , color=getPalette(2)[1], fill=getPalette(2)[2], se=TRUE)+
  xlab('Segregation') +
  ylab('Integration') +
  ggtitle("Scatterplot of Segregation Against Integration") + 
  stat_cor(method = "pearson", label.x.npc = 'left', label.y.npc='top',
           colour=getPalette(2)[1], size=5) +
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              subtitle_size=20,
              plot_margin = margin(20, 1, 1, 1))+ 
  theme(plot.title = element_text(size = 20, face = "bold"))
figures4

#### figure s2 ####
vbi_df <- data.frame(
  type = c( rep("vbi2", 52), rep("vbi1", 52) ),
  value = c( week_df_std$viral_broadcast_1, week_df_std$viral_broadcast_2 ),
  integration = rep(week_df_std$integration_b, 2),
  segregation = rep(week_df_std$segregation_b, 2),
  gini = rep(week_df_std$gini, 2)
)

p1 <- ggplot(vbi_df, aes(x=value, y=integration)) +
  geom_point() +
  geom_smooth(method=lm , color=getPalette(2)[1], fill=getPalette(2)[2], se=TRUE)+
  xlab('Viral-Broadcast-Index') +
  ylab('Integration') +
  stat_cor(method = "pearson", label.x.npc = 'left', label.y.npc='top',
           colour=getPalette(2)[1], size=5) +
  facet_wrap(~type, scales = "free_x") + 
  theme_ipsum(strip_text_size = 25, 
              strip_text_face = "bold",
              axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(1, 1, 1, 1)) +
  theme(axis.title.x=element_blank(),
        strip.placement = "outside") 

p2 <- ggplot(vbi_df, aes(x=value, y=segregation)) +
  geom_point() +
  geom_smooth(method=lm , color=getPalette(2)[1], fill=getPalette(2)[2], se=TRUE)+
  xlab('Viral-Broadcast-Index') +
  ylab('Segregation') +
  stat_cor(method = "pearson", label.x.npc = 'left', label.y.npc='top',
           colour=getPalette(2)[1], size=5) +
  facet_wrap(~type, scales = "free_x") + 
  theme_ipsum(strip_text_size = 25, 
              strip_text_face = "bold",
              axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(20, 1, 1, 1)) +
  theme(axis.title.x=element_blank(),
        strip.text=element_blank()) 

p3 <- ggplot(vbi_df, aes(x=value, y=gini)) +
  geom_point() +
  geom_smooth(method=lm , color=getPalette(2)[1], fill=getPalette(2)[2], se=TRUE)+
  xlab('Viral-Broadcast-Index') +
  ylab('Week Eventfulness') +
  stat_cor(method = "pearson", label.x.npc = 'left', label.y.npc='top',
           colour=getPalette(2)[1], size=5) +
  facet_wrap(~type, scales = "free_x") + 
  theme_ipsum(strip_text_size = 25, 
              strip_text_face = "bold",
              axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(20, 1, 1, 1)) +
  theme(strip.text=element_blank()) 

figure_s2 <- ggarrange(p1, p2, p3, nrow=3)
figure_s2

#### figure 4 ####
p2 <- ggplot(week_df_std, aes(x=viral_broadcast_2, y=integration_b)) +
  geom_point() +
  geom_smooth(method=lm , color=getPalette(2)[1], fill=getPalette(2)[2], se=TRUE)+ 
  xlab('Viral-Broadcast-Index') +
  ylab('Integration') +
  stat_cor(method = "pearson", label.x.npc = 'left', label.y.npc='top',
           colour=getPalette(2)[1], size=5) + 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 10, 10, 10))

p1 <- ggplot(week_df_std, aes(x=viral_broadcast_2, y=segregation_b)) +
  geom_point() +
  geom_smooth(method=lm , color=getPalette(2)[1], fill=getPalette(2)[2], se=TRUE)+ 
  xlab('Viral-Broadcast-Index') +
  ylab('Segregation') +
  theme(axis.text=element_text(size=10),
        axis.title=element_text(size=12)) + 
  stat_cor(method = "pearson", label.x.npc = 'left', label.y.npc='top',
           colour=getPalette(2)[1], size=5) + 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mcweek_df_std',
              plot_margin = margin(30, 10, 10, 10))


upper_plot <- plot_grid(p2, p1, labels = c('A', 'B'),
                        label_colour = "red",
                        nrow = 1,
                        label_size = 25)


inte_stat <- c()
for (i in 0:9) {
  formula <-  paste(c('integration_',i ,' ~ viral_broadcast_2'), collapse='')
  inte_stat_temp <- summary(lm(formula, week_df_std))$coef[2,]
  inte_stat <- rbind(inte_stat, inte_stat_temp)
}

inte_stat_temp <- summary(lm('integration_b ~ viral_broadcast_2',
                             week_df_std))$coef[2,]
inte_stat <- rbind(inte_stat, inte_stat_temp)
rownames(inte_stat) <- c('100%', '90%', '80%', '70%','60%',
                         '50%','40%','30%','20%','10%', 'Backbone')
colnames(inte_stat) <- c('estimate', 'se', 't', 'p')
inte_stat <- data.frame(inte_stat)
inte_stat$threthold <- c('100%', '90%', '80%', '70%','60%',
                         '50%','40%','30%','20%','10%', 'Backbone')

seg_stat <- c()
for (i in 0:9) {week_df_std
  formula <-  paste(c('segregation_',i ,' ~ viral_broadcast_2'), collapse='')
  seg_stat_temp <- summary(lm(formula, week_df_std))$coef[2,]
  seg_stat <- rbind(seg_stat, seg_stat_temp)
}
seg_stat_temp <- summary(lm('segregation_b ~ viral_broadcast_2',
                             week_df_std))$coef[2,]
seg_stat <- rbind(seg_stat, seg_stat_temp)
rownames(seg_stat) <- c('100%', '90%', '80%', '70%','60%',
                         '50%','40%','30%','20%','10%', 'Backbone')
colnames(seg_stat) <- c('estimate', 'se', 't', 'p')
seg_stat <- data.frame(seg_stat)
seg_stat$threthold <- c('100%', '90%', '80%', '70%','60%',
                        '50%','40%','30%','20%','10%', 'Backbone')


stat_df <- rbind(inte_stat, seg_stat)
stat_df$Variable <- rep(c('Integration', 'Segregation'), each=11)


p_f <- ggforestplot::forestplot(
  df = stat_df,
  name = threthold,
  estimate = estimate,
  se = se,
  pvalue = p,
  psignif = 0.05,
  colour = Variable,
  xlab = "Standardized Regression Coefficient",
  ylab = "Thresholds",
  title = "Standardized Regression Coefficient of \nIntegration & Segregation on Viral-Broadcast-Index"
)  +
  scale_color_manual(values = getPalette(2))

figure_4 <- plot_grid(upper_plot, p_f, labels = c('', 'C'),
                      label_colour = "red",
                      nrow = 2, rel_heights = c(1,1.2),
                      label_size = 25)
figure_4

#### figure 5 ####
p_w <- week_df_std %>% 
  ggplot( ) +
  geom_line(aes(x=week, y=integration_b, color="Integration")) +
  geom_line(aes(x=week, y=segregation_b, color="Segregation")) +
  annotate(geom="text", x=as.Date("2020-03-16"), y=3.5, 
           label="COVID-19 announced as \nglobal pandemic") +
  annotate(geom="text", x=as.Date("2020-06-05"), y=4, 
           label="BLM protest") +
  annotate(geom="text", x=as.Date("2020-11-07"), y=4, 
           label="2020 election") +
  annotate(geom="text", x=as.Date("2020-02-09"), y=-2, 
           label="Superbowl") +
  annotate(geom="text", x=as.Date("2020-09-29"), y=2.2, 
           label="Debate") +
  geom_segment(aes(x = as.Date("2020-03-16"), y = 2.7, xend = as.Date("2020-03-16"), yend = 2.2),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-06-01"), y = 3.8, xend = as.Date("2020-06-01"), yend = 3.3),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-11-07"), y = 3.8, xend = as.Date("2020-11-07"), yend = 3.3),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-10-03"), y = 2, xend = as.Date("2020-10-03"), yend = 1.5),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-01-28"), y = -1.5, xend = as.Date("2020-01-28"), yend = -1),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_hline(yintercept=mean(week_df_std$integration_0), color="orange", size=.5) +
  xlab('Weeks in year of 2020') +
  ylab('Integration & Segregation') +
  ggtitle('Time Series of Integration and Segregation') + 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 220, 10, 25)) + 
  theme(legend.text=element_text(size=12),
        legend.title=element_text(size=12, face='bold')) + 
  labs(color='Variables') +
  scale_color_manual(values = getPalette(2))

p_h <- hashtag_df[1:(50*52),] %>% 
  ggplot() +
  geom_line(aes(x=week, y=count, colour=hashtag)) +
  annotate(geom="text", x=as.Date("2020-03-16"), y=4500, 
           label="COVID-19 announced as \nglobal pandemic") +
  annotate(geom="text", x=as.Date("2020-06-05"), y=4800, 
           label="BLM protest") +
  annotate(geom="text", x=as.Date("2020-11-07"), y=4800, 
           label="2020 election") +
  annotate(geom="text", x=as.Date("2020-02-02"), y=3000, 
           label="Superbowl") +
  annotate(geom="text", x=as.Date("2020-09-29"), y=3900, 
           label="Debate") +
  geom_segment(aes(x = as.Date("2020-03-16"), y = 4000, xend = as.Date("2020-03-16"), yend = 3700),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-06-01"), y = 4600, xend = as.Date("2020-06-01"), yend = 4300),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-11-07"), y = 4600, xend = as.Date("2020-11-07"), yend = 4300),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-10-03"), y = 3800, xend = as.Date("2020-10-03"), yend = 3300),
               arrow = arrow(length = unit(0.3, "cm"))) +
  geom_segment(aes(x = as.Date("2020-02-01"), y = 2800, xend = as.Date("2020-02-01"), yend = 2500),
               arrow = arrow(length = unit(0.3, "cm"))) +
  xlab('Weeks in year of 2020') +
  ylab('Hashtag Counts') +
  labs(color='Hashtag') +
  ggtitle('Time Series of Hashtag Counts in 2020') + 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 0, 10, 10)) + 
  theme(legend.text=element_text(size=11),
        legend.title=element_text(size=12, face='bold'),
        legend.key.width=unit(0.3,"cm"),
        legend.key.size = unit(0.2, "cm")) + 
  scale_color_manual(values = getPalette(50)) +
  guides(colour=guide_legend(ncol=3))

p_time_series <- plot_grid(p_w, p_h, labels = c('C', 'D'),
          label_colour = "red",
          nrow = 2,
          label_size = 25)


p3 <- ggplot(week_df_std, aes(x=viral_broadcast_1, y=gini)) +
  geom_point() +
  geom_smooth(method=lm , color=getPalette(2)[1], fill=getPalette(2)[2], se=TRUE)+
  xlab('Viral-Broadcast-Index') +
  ylab('Week Eventfulness') +
  theme(axis.text=element_text(size=10),
        axis.title=element_text(size=12)) +
  stat_cor(method = "pearson", label.x.npc = 'left', label.y.npc='top',
           colour=getPalette(2)[1], size=5) +
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 10, 10, 10))
p4 <- week_df_std %>%
  ggplot( ) +
  geom_line(aes(x=week, y=gini, color="Week Eventfulness")) +
  geom_line(aes(x=week, y=viral_broadcast_1, color="Viral-Broadcast-Index")) +
  geom_hline(yintercept=mean(week_df_std$integration_0), color="orange", size=.5) +
  xlab('Weeks in year of 2020') +
  ylab('VBI & Week Eventfulness') +
  ggtitle('Time Series of Vbi and Week Eventfulness') +
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 10, 10, 25)) +
  theme(legend.text=element_text(size=12),
        legend.position = 'bottom',
        legend.title=element_text(size=12, face='bold')) +
  labs(color='Variables') +
  scale_color_manual(values = getPalette(2))
fig_5_upper <- plot_grid(p4, p3,  labels = c('A', 'B'),
          label_colour = "red",
          rel_widths = c(1.6,1),
          nrow = 1,
          label_size = 25)

figure_5 <- plot_grid(fig_5_upper, p_time_series, labels = c('', ''),
          label_colour = "red", rel_heights = c(1,2),
          nrow = 2)
figure_5


#### figure 1 C D ####

hts <- unique(hashtag_df$hashtag)

cal_vbi <- function(ts) {
  max_index <- which.max(ts)
  pre <- sum(ts[1:(max_index-1)])
  after <- sum(ts[(max_index+1):52])
  pre_after <- after/(after+pre)
  return(round(pre_after, 3))
}

ht <- hts[21]
ht
temp_df <- hashtag_df %>% filter(hashtag == ht)
p1 <- temp_df  %>% 
  ggplot() +
  geom_line(aes(x=week, y=count), color=getPalette(2)[1]) + 
  annotate(geom="text", x=max(temp_df$week), y=max(temp_df$count), hjust=1,
           label=paste("#", ht, " vbi: ", as.character(cal_vbi(temp_df$count)), sep=""),
           size=6, color=getPalette(2)[1], fontface = 'italic', family = "sans")+ 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 10, 10, 10)) +
  ylim(c(0, 1100))+
  xlab('Weeks') +
  ylab('Hashtag Counts') +
  ggtitle('Viral Spreading')

hts <- unique(hashtag_df$hashtag)
ht <- hts[58]
ht
temp_df <- hashtag_df %>% filter(hashtag == ht)
p2 <- temp_df %>% 
  ggplot() +
  geom_line(aes(x=week, y=count), color=getPalette(2)[2]) + 
  annotate(geom="text", x=max(temp_df$week), y=900, hjust=1,
           label=paste("#", ht, " vbi: ", as.character(cal_vbi(temp_df$count)), sep=""),
           size=6, color=getPalette(2)[2], fontface = 'italic', family = "sans")+ 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 10, 10, 10))  +
  ylim(c(0,1100))+
  xlab('Weeks') +
  ylab('Hashtag Counts') +
  ggtitle('Broadcast Spreading')
plot_grid(p1, p2, labels = c('C', 'D'),
          label_colour = "red",
          nrow = 1,
          label_size = 25)





#### figure s5 ####
degrees <- readMat("/data/derivatives/degree_distributions.mat")

degree_dist <- unlist(degrees["degree.dist.list"][[1]])
degree_dist_df <- as.data.frame(degree_dist)
degree_dist_df$par <- rep(1:10155, 52)
degree_dist_df$week <- as.factor(rep(1:52, each=10155))
degree_dist_df$event <- "Ordinary Week"
degree_dist_df$event[degree_dist_df$week == 45] <- "2020 Election"
degree_dist_df$event[degree_dist_df$week %in% c(22, 23)] <- "BLM Protests"
degree_dist_df$event[degree_dist_df$week %in% c(11, 12)] <- "Covid Pandemic"

degree_dist_b <- unlist(degrees["degree.dist.list.b"][[1]])
degree_dist_b_df <- as.data.frame(degree_dist_b)
degree_dist_b_df$par <- rep(1:10155, 52)
degree_dist_b_df$week <- as.factor(rep(1:52, each=10155))
degree_dist_b_df$event <- "Ordinary Week"
degree_dist_b_df$event[degree_dist_b_df$week == 45] <- "2020 Election"
degree_dist_b_df$event[degree_dist_b_df$week %in% c(22, 23)] <- "BLM Protests"
degree_dist_b_df$event[degree_dist_b_df$week %in% c(11, 12)] <- "Covid Pandemic"

pr <- ggplot(degree_dist_df,
       aes(x = degree_dist, y = week, fill = event)) +
  geom_density_ridges(scale = 3, rel_min_height = 0.01) +
  labs(title = 'Raw Network') +
  theme_ipsum(axis_title_just='mc') +
  theme(
    legend.position="none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8)
  ) +
  scale_fill_manual(values = c(getPalette(4)[1:3], 'grey'))+
  scale_y_discrete(limits=rev)

pb <- ggplot(degree_dist_b_df,
       aes(x = degree_dist_b, y = week, fill = event)) +
  geom_density_ridges(scale = 3, rel_min_height = 0.01) +
  labs(title = 'Backbone Network') +
  theme_ipsum(axis_title_just='mc') +
  theme(
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8),
  ) + 
  scale_x_continuous(limits = c(0, 2000)) +
  scale_fill_manual(values = c(getPalette(4)[1:3], 'grey'))+
  scale_y_discrete(limits=rev)

legend <- get_legend(
  pb + theme(legend.box.margin = margin(0, 0, 0, 0))
)

prow <- plot_grid(pr, pb+theme(legend.position="none"), labels = c('A', 'B'),
          label_colour = "red", 
          nrow = 1,
          label_size = 25)
figure_s5 <- plot_grid(prow, legend, rel_widths = c(3, .5))
figure_s5

#### figure s1 ####


alpha_df <- read.csv("/data/derivatives/alpha_df.csv")
beta_df <- read.csv("/data/derivatives/beta_df.csv")

p_beta_i <- beta_df %>% filter(variable=="integration") %>% 
  ggplot(aes(x=sim, y=value, color=type, linetype=as.factor(beta))) + geom_line() + 
  labs(x = "Simulated Spreading Events",
       y = "Integration",
       color = "Spreading Type",
       linetype = "Alpha = 0.1\n\nBeta") +
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(10, 10, 10, 10)) + 
  theme(legend.text=element_text(size=11),
        legend.title=element_text(size=12, face='bold'))+
  scale_color_manual(labels = c("Broadcast Spreading", "Viral Spreading"),
                     values = getPalette(2))+
  theme(legend.position = c(0.3, 0.6))


p_beta_s <- beta_df %>% filter(variable=="segregation") %>% 
  ggplot(aes(x=sim, y=value, color=type, linetype=as.factor(beta))) + geom_line()  + 
  labs(x = "Simulated Spreading Events",
       y = "Segregation",
       color = "Spreading Type",
       linetype = "Beta") +
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(10, 10, 10, 10)) + 
  theme(legend.text=element_text(size=11),
        legend.title=element_text(size=12, face='bold'))+
  scale_color_manual(labels = c("Broadcast Spreading", "Viral Spreading"),
                     values = getPalette(2))+
  theme(legend.position = "none")


p_beta <- ggarrange(p_beta_i, p_beta_s,
          nrow = 2)
p_beta

p_alpha_i <- alpha_df %>% filter(variable=="integration") %>% 
  ggplot(aes(x=sim, y=value, color=type, linetype=as.factor(alpha))) + geom_line() + 
  labs(x = "Simulated Spreading Events",
       y = "Integration",
       color = "Spreading Type",
       linetype = "Beta = 0.2\n\nAlpha") +
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(10, 10, 10, 20)) + 
  theme(legend.text=element_text(size=11),
        legend.title=element_text(size=12, face='bold'))+
  scale_color_manual(labels = c("Broadcast Spreading", "Viral Spreading"),
                     values = getPalette(2))+
  theme(legend.position = c(0.3, 0.6))

p_alpha_s <- alpha_df %>% filter(variable=="segregation") %>% 
  ggplot(aes(x=sim, y=value, color=type, linetype=as.factor(alpha))) + geom_line()  + 
  labs(x = "Simulated Spreading Events",
       y = "Segregation",
       color = "Spreading Type",
       linetype = "Alpha") +
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(10, 10, 10, 20)) + 
  theme(legend.text=element_text(size=11),
        legend.title=element_text(size=12, face='bold'))+
  scale_color_manual(labels = c("Broadcast Spreading", "Viral Spreading"),
                     values = getPalette(2))+
  theme(legend.position = "none")

p_alpha <- ggarrange(p_alpha_i, p_alpha_s,
          nrow = 2)

figure_s1 <- plot_grid(p_beta, p_alpha, labels = c('A', 'B'),
          label_colour = "red",
          nrow = 1,
          label_size = 25)
figure_s1

#### figure 3 ####
p_i <- beta_df %>% filter(variable=="integration", beta==0.2) %>% ggplot() +
  geom_line(aes(x=sim, y=value, color=as.factor(type))) + 
  xlab("Number of Simulated Spreading Events") +
  ylab("Public Discourse Integration") +
  labs(color='Simulated Events') + 
  ggtitle('Public Discourse Integration Changes Against \nViral vs. Broadcast Simulated Events') + 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 10, 10, 10)) + 
  theme(legend.text=element_text(size=11),
        legend.title=element_text(size=12, face='bold'))+
  scale_color_manual(labels = c("Broadcast Spreading", "Viral Spreading"),
                     values = getPalette(2))
p_s <- beta_df %>% filter(variable=="segregation", beta==0.2) %>% ggplot() +
  geom_line(aes(x=sim, y=value, color=as.factor(type))) + 
  xlab("Number of Simulated Spreading Events") +
  ylab("Public Discourse Segregation") +
  labs(color='Simulated Events') + 
  ggtitle('Public Discourse Segregation Changes Against \nViral vs. Broadcast Simulated Events') + 
  theme_ipsum(axis_text_size = 12,
              axis_title_size = 14,
              axis_title_just='mc',
              plot_margin = margin(30, 10, 10, 10)) + 
  theme(legend.text=element_text(size=11),
        legend.title=element_text(size=12, face='bold'))+
  scale_color_manual(labels = c("Broadcast Spreading", "Viral Spreading"),
                     values = getPalette(2))

figure_3 <- plot_grid(p_i, p_s, labels = c('A', 'B'),
                      label_colour = "red",
                      nrow = 2,
                      label_size = 25)
figure_3

