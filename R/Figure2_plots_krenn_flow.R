#' ---
#' title: "Plotting Figure 2: Krenn inflammatory score and flow cytometry gates 
#' for OA, non-inflamed RA, and non-inflamed RA"
#' author: "Fan Zhang"
#' 
#' date: "2018-03-23"
#' ---
#' 

setwd("/Users/fanzhang/Documents/GitHub/amp_phase1_ra/")

library(ggplot2)
library(reshape2)
library(dplyr)
require(gdata)
library(ggbeeswarm)

source("R/pure_functions.R")
source("R/meta_colors.R")

# Read the 51 post-QC data from postQC_all_samples.xlsx
dat <- read.xls("data-raw/postQC_all_samples.xlsx")
dim(dat)
dat <- dat[c(1:51),]
table(dat$Case.Control)

# Load flow cytometry data that collected by Kevin
flow <- read.xls("data-raw/171215_FACS_data_for_figure.xlsx")
flow_qc <- flow[which(flow$Sample.ID %in% dat$Patient),]
dim(flow_qc)
colnames(flow_qc)[2] <- "Patient"

dat_all <- merge(dat, flow_qc, by = "Patient")
dim(dat_all)
table(dat_all$Case.Control)


dat_all$Case.Control <- factor(dat_all$Case.Control,
                       levels = c('OA','non-inflamed RA', "inflamed RA"),ordered = TRUE)

# ---
# Plot B cells/total live cells by flow
# ---

# Boxplot
# ggplot(data=dat_all, 
#        aes(x=Case.Control, y=B.cells, fill=Case.Control)) +
#   geom_boxplot(outlier.colour = NA) +
#   scale_fill_manual(values = meta_colors$Case.Control) +
#   scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) + 
#   xlab('')+ylab('% of synovial cells')+
#   theme_bw(base_size = 20) +
#   labs(title = "Synovial B cells") +
#   theme(
#     # axis.text = element_blank(), 
#     axis.ticks = element_blank(), 
#     panel.grid = element_blank(),
#     axis.text = element_text(size = 20, color = "black"),
#     axis.text.x = element_text(angle=35, hjust=1, size=20),
#     axis.text.y = element_text(size = 20),
#     plot.title = element_text(color="black", size=20)) +
#   theme(legend.text=element_text(size=20)) +
#   geom_quasirandom(width = 0.25, size = 2) +
#   coord_cartesian(ylim = c(0, 60)) 
# ggsave(file = paste("flow_bcells_boxplot_active_inactive", ".pdf", sep = ""), width = 13.5, height = 12, dpi = 600)
# dev.off()



dat_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(B.cells))

ggplot(data=dat_all, 
       mapping = aes(x=Case.Control, y=B.cells, fill=Case.Control)) +
  geom_quasirandom(
    shape = 21, size = 4
  ) +
  stat_summary(
    fun.y = median, fun.ymin = median, fun.ymax = median,
    geom = "crossbar", width = 0.8
  ) +
  scale_fill_manual(values = meta_colors$Case.Control) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) + 
  xlab('')+ylab('% of synovial cells')+
  theme_bw(base_size = 20) +
  labs(title = "Synovial B cells") +
  theme(
    legend.position = "none",
    axis.ticks = element_blank(), 
    panel.grid = element_blank(),
    axis.text = element_text(size = 20, color = "black"),
    axis.text.x = element_text(angle=35, hjust=1, size=20),
    axis.text.y = element_text(size = 20),
    plot.title = element_text(color="black", size=22)) +
  theme(legend.text=element_text(size=20)) +
  coord_cartesian(ylim = c(0, 60)) 
ggsave(
  file = "flow_bcells_boxplot_inflamed_noninflamed.pdf",
  width = 4, height = 6
)

# ---
# Plot T cells/total live cells by flow
# ---
dat_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(T.cells))

ggplot(data=dat_all, 
       mapping = aes(x=Case.Control, y=T.cells, fill=Case.Control)) +
  geom_quasirandom(
    shape = 21, size = 4
  ) +
  stat_summary(
    fun.y = median, fun.ymin = median, fun.ymax = median,
    geom = "crossbar", width = 0.8
  ) +
  scale_fill_manual(values = meta_colors$Case.Control) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) + 
  xlab('')+ylab('% of synovial cells')+
  theme_bw(base_size = 20) +
  labs(title = "Synovial T cells") +
  theme(
    legend.position = "none",
    axis.ticks = element_blank(), 
    panel.grid = element_blank(),
    axis.text = element_text(size = 20, color = "black"),
    axis.text.x = element_text(angle=35, hjust=1, size=20),
    axis.text.y = element_text(size = 20),
    plot.title = element_text(color="black", size=22)) +
  theme(legend.text=element_text(size=20)) +
  coord_cartesian(ylim = c(0, 60)) 
ggsave(
  file = "flow_tcells_boxplot_inflamed_noninflamed.pdf",
  width = 4, height = 6
)


# ---------------
# Remove the n/a value patients for plotting Krenn score and Krenn lining
dat_kren <- dat_all[-which(dat_all$Krenn.Score.Inflammation == "n/a"),]
dat_kren <- dat_kren[-which(dat_kren$Krenn.Score.Lining == "n/a"),]
dim(dat_kren)

dat_kren$Krenn.Score.Inflammation <- as.numeric(as.character(dat_kren$Krenn.Score.Inflammation))
dat_kren$Krenn.Score.Lining <- as.numeric(as.character(dat_kren$Krenn.Score.Lining))

t.test(dat_kren$Krenn.Score.Inflammation[which(dat_kren$Case.Control == "inflamed RA")],
       dat_kren$Krenn.Score.Inflammation[which(dat_kren$Case.Control == "non-inflamed RA")],
       alternative ="greater")
# p-value = 0.004

t.test(dat_kren$Krenn.Score.Inflammation[which(dat_kren$Case.Control == "inflamed RA")],
       dat_kren$Krenn.Score.Inflammation[which(dat_kren$Case.Control == "OA")],
       alternative ="greater")
# p-value = 0.005


t.test(dat_kren$Krenn.Score.Inflammation[which(dat_kren$Case.Control == "inflamed RA")],
       dat_kren$Krenn.Score.Inflammation[which(dat_kren$Case.Control %in% c("OA", "on-inflamed RA"))],
       alternative ="greater")


# Symbol meaning
# ns P > 0.05
#
# *   P ≤ 0.05
# 
# **  P ≤ 0.01
# 
# *** P ≤ 0.001
# 
# ****  P ≤ 0.0001 (For the last two choices only)

# ---
# Plot Krenn inflammatory score
# ---

dat_median <- dat_kren %>% group_by(Case.Control) %>% summarise(median = median(Krenn.Score.Inflammation))

ggplot(data=dat_kren, 
       mapping = aes(x=Case.Control, y=Krenn.Score.Inflammation, fill=Case.Control)) +
  geom_quasirandom(
    shape = 21, size = 4
  ) +
  stat_summary(
    fun.y = median, fun.ymin = median, fun.ymax = median,
    geom = "crossbar", width = 0.8
  ) +
  scale_fill_manual(values = meta_colors$Case.Control) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) + 
  xlab('')+ylab('Krenn score')+
  theme_bw(base_size = 20) +
  labs(title = "Inflammatory infiltrate") +
  theme(
    legend.position = "none",
    axis.ticks = element_blank(), 
    panel.grid = element_blank(),
    axis.text = element_text(size = 20, color = "black"),
    axis.text.x = element_text(angle=35, hjust=1, size=20),
    axis.text.y = element_text(size = 20),
    plot.title = element_text(color="black", size=22)) +
  theme(legend.text=element_text(size=20)) +
  coord_cartesian(ylim = c(0, 3.5)) 
ggsave(
  file = "krenn_boxplot_inflamed_noninflamed.pdf",
  width = 4, height = 6
)

# ---
# Plot Krenn lining 
# ---
dat_median <- dat_kren %>% group_by(Case.Control) %>% summarise(median = median(Krenn.Score.Lining))

ggplot(data=dat_kren, 
       mapping = aes(x=Case.Control, y=Krenn.Score.Lining, fill=Case.Control)) +
  geom_quasirandom(
    shape = 21, size = 4
  ) +
  stat_summary(
    fun.y = median, fun.ymin = median, fun.ymax = median,
    geom = "crossbar", width = 0.8
  ) +
  scale_fill_manual(values = meta_colors$Case.Control) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) + 
  xlab('')+ylab('Krenn lining score')+
  theme_bw(base_size = 20) +
  labs(title = "Lining cell layer") +
  theme(
    legend.position = "none",
    axis.ticks = element_blank(), 
    panel.grid = element_blank(),
    axis.text = element_text(size = 20, color = "black"),
    axis.text.x = element_text(angle=35, hjust=1, size=20),
    axis.text.y = element_text(size = 20),
    plot.title = element_text(color="black", size=22)) +
  theme(legend.text=element_text(size=20)) 
ggsave(
  file = "lining_krenn_boxplot_inflamed_noninflamed.pdf",
  width = 4, height = 6
)

# ggplot(data=dat_all,
#        aes(x=Case.Control, y=Krenn.Score.Lining, fill=Case.Control)) +
#   geom_boxplot(outlier.colour = NA) +
#   scale_fill_manual(values = meta_colors$Case.Control) +
#   xlab('')+ylab('Krenn lining score')+
#   theme_bw(base_size = 20) +
#   labs(title = "Lining cell layer") +
#   theme(
#     legend.position = "none",
#     axis.ticks = element_blank(),
#     panel.grid = element_blank(),
#     axis.text = element_text(size = 20,  color = "black"),
#     axis.text.x = element_text(angle=35, hjust=1, size=20),
#     axis.text.y = element_text(size = 20),
#     plot.title = element_text(color="black", size=22)) +
#   theme(legend.text=element_text(size=20)) +
#   geom_jitter(width = 0.23, size = 4)
# ggsave(file = paste("lining_krenn_boxplot_inflamed_noninflamed_v2", ".pdf", sep = ""), 
#        width = 4, height = 6)
# dev.off()

# ---
# Krenn score vs lymphocyte plot
# ---

# Spearman correlation
cor(dat_kren$Krenn.Score.Inflammation, dat_kren$Lymphocytes, method = "spearman")

fit <- lm(Krenn.Score.Inflammation ~ Lymphocytes, data = dat_kren)
summary(fit)
summary(fit)$adj.r.squared
summary(fit)$r.squared
summary(fit)$coefficients[2,"Pr(>|t|)"]

fit$model$Case.Control <- dat_kren$Case.Control

# Put the P-value and R-square in the right lower corner
d1 <- paste("P", "==", "7E-05", sep="") 
d2 <- paste("R","^","2", "==", round(summary(fit)$r.squared, 3), sep="") 
ggplot(
  fit$model,
  aes(
    x=Krenn.Score.Inflammation,
    y=Lymphocytes* 100,
    fill = Case.Control
    )
  ) +
  geom_point(
    shape=21, size = 5, stroke = 0.7
  ) +
  scale_fill_manual(values = meta_colors$Case.Control) +
  ## if we wanted the points coloured, but not separate lines there are two
  ## options---force stat_smooth() to have one group
  geom_smooth(aes(group = 1), method = "lm", formula = y ~ x, # se = FALSE,
               size = 3, linetype="dashed",
              col= "darkgrey", fill="lightgrey") +
  # geom_text(
  #   # aes(4.25,1), label = as.character(d1), parse = TRUE, size=14
  #   aes(2.5,13.9), label = as.character(d1), parse = TRUE, size=17
  # ) +
  # geom_text(
  #   # aes(4.33,0.5), label = as.character(d2), parse = TRUE, size=14
  #   aes(2.45,8), label = as.character(d2), parse = TRUE, size=17
  # ) +
  xlab('Krenn inflammatory score')+ylab('Lymphocyte abundance\n(% of synovial cells)')+
  theme_bw(base_size = 20) +
  theme(
    legend.position = "none",
    axis.ticks = element_blank(), 
    panel.grid = element_blank(),
    axis.text = element_text(size = 20, color = "black"),
    axis.text.x = element_text(size=20),
    axis.text.y = element_text(size = 20)) +
  theme(legend.text=element_text(size=20))
ggsave(file = paste("krenn_lym_inflamed_noninflamed", ".pdf", sep = ""), 
       width = 6, height = 6)
dev.off()


# Plot proportion of B cells, CD4 T cells, CD8 T cells, endothelial cells,
# fibroblasts, monocytes, and other cells for three disease cohorts.

# Have to remove 300-0512 since we don't have flow of fibroblast and endothelial cells
dat_all <- dat_all[-which(dat_all$Patient == "300-0512"),]
dat_all$Endothelial <- as.numeric(as.character(dat_all$Endothelial))
dat_all$Fibroblasts <- as.numeric(as.character(dat_all$Fibroblasts))
dat_all$Other <- as.numeric(as.character(dat_all$Other))

bcell_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(B.cells))
cd4_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(CD4.T.cells))
cd8_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(CD8.T.cells.))
endo_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(Endothelial))
fibro_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(Fibroblasts))
mono_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(Monocytes))
other_median <- dat_all %>% group_by(Case.Control) %>% summarise(median = median(Other))

dat_percent = data.frame(
  bcell = bcell_median$median,
  cd4 = cd4_median,
  cd8 = cd8_median,
  endo = endo_median,
  fibro = fibro_median,
  mono = mono_median,
  other = other_median
)
dat_percent <- t(dat_percent)





# # ------------------
# active <- dat_all[which(dat_all$Case.Control == "active RA"), c(22:30)]
# active <- colMeans(active[sapply(active, is.numeric)])
# active <- active[-c(7,9)]
# 
# inactive <- dat_all[which(dat_all$Case.Control == "inactive RA"), c(22:30)]
# inactive <- colMeans(inactive[sapply(inactive, is.numeric)])
# inactive <- inactive[-c(7,9)]
# 
# oa <- dat_all[which(dat_all$Case.Control == "OA"), c(22:30)]
# oa <- colMeans(oa[sapply(oa, is.numeric)])
# oa <- oa[-c(7,9)]
# 
# ave_all = data.frame(
#   disease = c(rep("active RA", length(active)), 
#               rep("inactive RA", length(inactive)), 
#               rep("OA", length(oa))
#               ),
#   flow_cell = c(names(active), names(inactive), names(oa)),
#   flow_pro = c(active, inactive, oa)
# )
# dim(ave_all)
# 
# 
# 
# # ---------------------------------------------------------------------------
# # ave_all is the all 59 samples based on RA biopsy, RA arthro, and OA arthro
# # saveRDS(ave_all, "barplot_ave_all_flow.rds")
# # ave_all <- readRDS("barplot_ave_all_flow.rds")
# 
# ave_all$flow_cell <- as.character(ave_all$flow_cell)
# ave_all$flow_cell[which(ave_all$flow_cell == "CD8.T.cells.")] <- "CD8 T cell"
# ave_all$flow_cell[which(ave_all$flow_cell == "CD4.T.cells")] <- "CD4 T cell"
# ave_all$flow_cell[which(ave_all$flow_cell == "Monocytes")] <- "Monocyte"
# ave_all$flow_cell[which(ave_all$flow_cell == "B.cells")] <- "B cell"
# ave_all$flow_cell[which(ave_all$flow_cell == "Endo")] <- "Endothelial cell"
# ave_all$flow_cell[which(ave_all$flow_cell == "Fibroblasts")] <- "Fibroblast"
# 
# ave_all$disease <- as.character(ave_all$disease)
# ave_all$disease[which(ave_all$disease == "OA")] <- "OA arthro"
# ave_all$disease[which(ave_all$disease == "RA arthroplasty")] <- "RA arthro"
# 
# source("../2017_02_28_Phase1_cellseq_RA_single_cell_data/meta_colors.R")
# ggplot(
#   data=ave_all,
#   # aes(x=reorder(disease, flow_pro), y= flow_pro, fill = flow_cell)
#   aes(x=disease, y= flow_pro, fill = flow_cell)
#   ) +
#   geom_bar(stat="identity", position = "fill") +
#   scale_fill_manual("", values = meta_colors$flow) + 
#   labs(
#     x = NULL,
#     y = "Abundance of flow\n (% of live cells)"
#     # title = ""
#   ) +
#   theme_bw(base_size = 30) +
#   theme(axis.text = element_text(size = 30, color = "black"),
#         axis.text.x = element_text(angle = 30, hjust = 1),
#         axis.text.y = element_text(size = 30),
#         legend.key.size = unit(2.5, 'lines'))
# ggsave(file = paste("barplot_flow_v1", ".pdf", sep = ""), width = 8, height = 9, dpi = 600)
# dev.off()
# 
# 
# 