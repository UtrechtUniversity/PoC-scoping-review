reshape_embase_data <- function(data_raw, key_variable, value_variable) {
#' @title Reshape Embase Data 
#' @description This function takes a long-format data frame from Embase and reshapes it into a wide format. It assumes that the data is grouped by a key variable (e.g., "TITLE") and that each group contains multiple rows with different variables (e.g., "ABSTRACT", "DOI", "AUTHOR", "YEAR").
#' @param data_raw A long-format data frame.
#' @param key_variable The name of the variable that marks the start of a new group.
#' @param value_variable The name of the variable that contains the values for each group.
#' @import tidyverse
#' @return A wide-format data frame with columns for each unique value in the `key_variable` column.
#' @example Assuming you have a long-format data frame named `data_raw` with columns "V1" and "V2" where "V1" contains the variable names ("TITLE", "ABSTRACT", "DOI", "AUTHOR", "YEAR") and "V2" contains the corresponding values.
#' # Reshape the data using the "TITLE" as the key variable:
#' embase_data <- reshape_embase_data(data_raw, "TITLE", "V2")
#' # Now, `embase_data` will have columns for "TITLE", "ABSTRACT", "DOI".

  # Create a grouping variable based on the key variable
  data_raw %>%
    mutate(group = cumsum(V1 == key_variable)) %>%
    pivot_wider(names_from = V1, values_from = value_variable) %>%
    select(-group)
}

if (!require("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}
