# First, handle entries with multiple countries
studies_expanded <- studies %>%
  mutate(
    country_split = strsplit(as.character(country), ", ")
  ) %>%
  tidyr::unnest(country_split)

# Count studies per country
country_counts <- studies_expanded %>%
  group_by(country_split) %>%
  summarize(n = n()) %>%
  rename(country = country_split)

# Get world map data
mapdata <- map_data("world")
mapdata$country <- mapdata$region
mapdata <- mapdata %>% select(-region)

# Join the dataset with the world map data
mapfig <- left_join(mapdata, country_counts, by="country")
mapfig$n[is.na(mapfig$n)] <- 0

# Create discrete breaks for the color scale
# Adjust these breaks based on your data distribution
mapfig <- mapfig %>%
  mutate(count_category = cut(n, 
                              breaks = c(-1, 0, Inf),
                              labels = c("0", "1"),
                              include.lowest = TRUE))

# Define regions by longitude and latitude
# North America
north_america <- mapfig %>%
  filter(long >= -170 & long <= -50 & lat >= 15 & lat <= 85)

# Europe
europe <- mapfig %>%
  filter(long >= -15 & long <= 45 & lat >= 35 & lat <= 75)

# Asia
asia <- mapfig %>%
  filter(long >= 45 & long <= 150 & lat >= 0 & lat <= 75)

# Create a function to generate consistent maps for each region
create_region_map <- function(data, title) {
  ggplot(data, aes(x = long, y = lat, group = group)) +
    geom_polygon(aes(fill = count_category), color = "black", size = (0.1)) +
    scale_fill_manual(
      name = "Published studies",
      values = c("0" = "white", "1" = "firebrick"),
      drop = FALSE
    ) +
    ggtitle(title) +
    theme_minimal() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.background = element_blank(),
      axis.line = element_blank(),
      axis.text = element_blank(),
      axis.title = element_blank(),
      axis.ticks = element_blank(),
      plot.title = element_text(size = 12, face = "bold")
    )
}

# Create individual maps
na_map <- create_region_map(north_america, "North America")
eu_map <- create_region_map(europe, "Europe")
asia_map <- create_region_map(asia, "Asia")

# Combine maps into a grid
combined_map <- na_map + eu_map + asia_map + plot_layout(ncol = 2, guides = "collect")

# Save the map as a PNG file
ggsave(paste0(figfolder,"/map_countries.png"), plot = combined_map, width = 8, height = 5, units = "in", dpi = 600)