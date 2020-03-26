library(tidyverse)
library(ggforce)
library(futurevisions)

tbi_age <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-24/tbi_age.csv')

tbi_deaths <- tbi_age %>% 
  filter(type == "Deaths" & age_group != "0-17" & age_group != "Total") %>% 
  na.omit() %>% 
  group_by(age_group) %>% 
  mutate(freq = number_est/sum(number_est)) %>% 
  top_n(1, wt = freq) %>% 
  ungroup() %>% 
  mutate(
    age_group = fct_relevel(age_group, c("0-4", "5-14", "15-24", "25-34", "35-44", "45-54", "55-64", "65-74", "75+")),
    # injury_mechanism = sub(" ([^ ]*)$", "\n\\1", injury_mechanism),
    age_n = as.numeric(as.factor(age_group)),
    inj_n = as.numeric(as.factor(injury_mechanism))
  )

ggplot(tbi_deaths, aes(x = c(0.5, 2, 5, 6, 6, 10, 11, 10, 11),
                       y = c(4, 6, 4, 4, 6, 5, 4, 3, 0),
                       group = -1L, fill = injury_mechanism)) +
  geom_voronoi_tile(
    max.radius = 5, size = 0.75, colour = "black") +
  geom_text(aes(label = age_group),
            family = "IBM Plex Sans",
            stat = 'delvor_summary', switch.centroid = TRUE
            ) +
  annotate("text", x = -4, y = -3, label = "Assault for children\n0-4 years old", hjust = 1, family = "IBM Plex Sans") +
  annotate("text", x = 5, y = -3, label = "Vehicle crashes for ages\n5-25 years", hjust = 1, family = "IBM Plex Sans") +
  coord_fixed(xlim = c(-10, 20), ylim = c(-10, 15)) +
  scale_fill_manual(values = futurevisions("mars")) +
  theme_minimal(base_family = "JetBrains Mono") +
  theme() +
  ggsave(here::here("2020-week13", "plots", "tbi.png"), dpi = 300)
  