library(ggplot2)
library(plotly)
library(dplyr)
library(htmlwidgets)
options(browser="chromium")

# Paths
csv_path <- "gps/2025/2025_traps_gps.csv"
html_path <- sub("\\.csv$", ".html", csv_path)

# Data
df <- read.csv(csv_path)

# Force character then factor
df$trap <- factor(as.character(df$trap))

# Tooltip content: trap + pheromone + comment + Moth_count (if already merged)
df$tooltip <- paste0(
  "Trap: ", df$trap, "<br>",
  "Pheromone: ", ifelse(df$pheromone == "", "NA", df$pheromone), "<br>",
  "Comment: ", ifelse(df$comment == "", "NA", df$comment),
  if ("Moth_count" %in% names(df)) paste0("<br>Moth_count: ", df$Moth_count) else ""
)

# Generate pastel color for each trap
n <- length(levels(df$trap))
pastel_colors <- rep("#de6e7c", n)

# Map background
fr_map <- map_data("france")

# Plot
p <- ggplot() +
    geom_polygon(data = fr_map, aes(x = long, y = lat, group = group),
                 fill = "#e0e8f0", color = "#aabccc") +
    geom_point(data = df,
               aes(x = longitude, y = latitude, color = trap, group = trap, text = tooltip),
               size = 3, show.legend = TRUE) +
    scale_color_manual(values = pastel_colors) +
    coord_fixed(1.3) +
    theme_minimal() +
    theme(legend.title = element_blank(),
          panel.background = element_rect(fill = "#fefefe", color = NA,)
          plot.background = element_rect(fill = "#fefefe", color = NA))

# Interactive conversion with scrollZoom
# ggplotly(p, tooltip = "label")

# Export map
htmlwidgets::saveWidget(as_widget(ggplotly(p, tooltip = "text") %>%
  layout(dragmode = "zoom", scrollZoom = TRUE)),
  file = html_path,
  selfcontained = TRUE
  )


(require 'tree-sitter-r)

(global-tree-sitter-mode)
