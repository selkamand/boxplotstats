#' Calculate Boxplot Summary Statistics for a Numeric Vector
#'
#' This function calculates the summary statistics typically used in a boxplot,
#' including the minimum, maximum, median, first quartile (Q1), third quartile (Q3),
#' interquartile range (IQR), and outliers.
#'
#' @param numeric_vector A numeric vector for which to calculate boxplot summary statistics.
#' @param id An optional string to add as an ID column to the dataframe
#' @param return_dataframe Logical, if TRUE, returns a dataframe; otherwise returns a list.
#' @return A list or dataframe containing the following elements:
#' \describe{
#'   \item{min}{The minimum value of the vector.}
#'   \item{max}{The maximum value of the vector.}
#'   \item{median}{The median value of the vector.}
#'   \item{q1}{The first quartile (25th percentile) of the vector.}
#'   \item{q3}{The third quartile (75th percentile) of the vector.}
#'   \item{iqr}{The interquartile range, calculated as \code{q3 - q1}.}
#'   \item{outlier_low_threshold}{The lower threshold for outliers, calculated as \code{q1 - 1.5 * iqr}.}
#'   \item{outlier_high_threshold}{The upper threshold for outliers, calculated as \code{q3 + 1.5 * iqr}.}
#'   \item{outliers}{A numeric vector of outlier values that are either below the lower threshold or above the upper threshold.}
#'   \item{id}{An optional ID if provided.}
#' }
#' @export
#'
#' @examples
#' vec <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100)
#' calculate_boxplot_stats(vec)
#'
#' # More complex version with actual outliers
#' calculate_boxplot_stats(c(rep(1, times =3), 1:10, 22, 23))
#'
calculate_boxplot_stats <- function(numeric_vector, id = NULL, return_dataframe = TRUE){
  # Initialize an empty list to store summary statistics
  boxplot_stats <- list()
  boxplot_stats$min <- min(numeric_vector, na.rm = TRUE)
  boxplot_stats$max <- max(numeric_vector, na.rm = TRUE)
  boxplot_stats$median <- median(numeric_vector, na.rm = TRUE)
  boxplot_stats$q1 <- stats::quantile(numeric_vector, probs = 0.25, na.rm = TRUE)
  boxplot_stats$q3 <- stats::quantile(numeric_vector, probs = 0.75, na.rm = TRUE)
  boxplot_stats$iqr <- boxplot_stats$q3 - boxplot_stats$q1
  boxplot_stats$outlier_low_threshold <- boxplot_stats$q1 - 1.5 * boxplot_stats$iqr
  boxplot_stats$outlier_high_threshold <- boxplot_stats$q3 + 1.5 * boxplot_stats$iqr
  boxplot_stats$outliers <- numeric_vector[numeric_vector < boxplot_stats$outlier_low_threshold | numeric_vector > boxplot_stats$outlier_high_threshold]
  boxplot_stats$id <- id

  # If return_dataframe is TRUE, convert the list to a dataframe
  if(return_dataframe){
    boxplot_stats_df <- data.frame(
      min = boxplot_stats$min,
      max = boxplot_stats$max,
      q1 = boxplot_stats$q1,
      q3 = boxplot_stats$q3,
      iqr = boxplot_stats$iqr,
      median = boxplot_stats$median,
      outlier_low_threshold = boxplot_stats$outlier_low_threshold,
      outlier_high_threshold = boxplot_stats$outlier_high_threshold,
      outliers = I(list(boxplot_stats$outliers))
    )

    if(!is.null(id))
      boxplot_stats_df$id <- id

    return(boxplot_stats_df)
  }
  return(boxplot_stats)
}

#' Calculate Boxplot Summary Statistics for Multiple Groups
#'
#' This function calculates boxplot summary statistics for a numeric vector,
#' grouped by a corresponding vector of IDs.
#'
#' @param values A numeric vector for which to calculate boxplot summary statistics.
#' @param ids A vector of IDs corresponding to the groups in 'values'.
#' @return A dataframe containing boxplot summary statistics for each group.
#' @export
#'
#' @examples
#' values <- c(1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 22, 23, 8, 8, 8, 12,
#'     13, 14, 15, 30, 31)
#' ids <- c("b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1",
#'  "b1", "b1", "b1", "b1", "b1", "b2", "b2", "b2", "b2", "b2", "b2",
#'  "b2", "b2", "b2")
#'
#' calculate_boxplot_stats_for_multiple_groups(values, ids)
calculate_boxplot_stats_for_multiple_groups <- function(values, ids){

  # Split the values by the ids
  grouped_values <- split(values, ids)

  # Apply the calculate_boxplot_stats function to each group
  boxplot_stats_list <- mapply(
    function(group, group_id) {
      calculate_boxplot_stats(numeric_vector = group, id = group_id, return_dataframe = TRUE)
    },
    grouped_values,
    names(grouped_values),
    SIMPLIFY = FALSE
  )

  # Combine the resulting dataframes into one
  result_df <- do.call(rbind, boxplot_stats_list)
  rownames(result_df) <- NULL

  return(result_df)
}

#' Convert List Column to Delimited String
#'
#' This function converts list columns in a dataframe to delimited strings.
#'
#' @param list_column A list column to convert.
#' @return A character vector with delimited strings.
list_column_to_delim <- function(list_column){
  unlist(lapply(list_column, function(x) {paste0(x, collapse = ",")}))
}

#' Write Boxplot Statistics to TSV File
#'
#' This function writes the boxplot statistics dataframe to a TSV file.
#'
#' @param df A dataframe containing boxplot statistics.
#' @param file The file path where the TSV file will be written.
write_boxplot_stats_tsv <- function(df, file){
  df$outliers <- list_column_to_delim(df$outliers)
  utils::write.table(df, file = file, sep = "\t", col.names = TRUE, row.names = FALSE)
}


`%isNOTin%` <- function(LHS, RHS) {
  !LHS %in% RHS
}

#' Simple Unnest Function
#'
#' This function unnests a list column in a data frame, creating a long format data frame.
#'
#' @param ids A vector of IDs corresponding to each nested list.
#' @param nested_list A list of vectors, where each element of the list corresponds to the values for each ID.
#' @return A data frame with two columns: 'id' and 'values', where 'values' are the unnested elements of the original list.
#' @export
#'
#' @examples
#' ids <- c(1, 2, 3)
#' nested_list <- list(
#'   c(1, 2, 3),
#'   c(4, 5),
#'   c(6, 7, 8, 9)
#' )
#' unnest(ids, nested_list)
#'
unnest <- function(ids, nested_list) {

  # Use mapply to iterate over ids and nested_list in parallel
  # and create a list of data frames where each data frame
  # contains the id repeated for the length of the list of values,
  # and the corresponding values.
  data_frames_list <- mapply(
    FUN = function(id, list_of_values) {
      data.frame(
        id = rep(id, times = length(list_of_values)),
        values = unlist(list_of_values)
      )
    },
    ids,
    nested_list,
    SIMPLIFY = FALSE
  )

  # Combine the list of data frames into a single data frame
  combined_df <- do.call(rbind, data_frames_list)
  rownames(combined_df) <- NULL  # Remove row names for clarity

  return(combined_df)
}

#' Plot Boxplot Statistics
#'
#' This function creates a boxplot using ggplot2 based on the boxplot statistics dataframe.
#'
#' @param stats A dataframe containing boxplot statistics.
#' @param xlab,ylab axis title
plot_boxplot_stats <- function(stats, xlab = "ID", ylab = "Value"){
  requireNamespace("ggplot2", quietly = TRUE)

  if ("id" %isNOTin% names(stats)){
    stats$id = "no_id_supplied"
  }

  df_outliers <- unnest(stats$id, stats$outliers)

  ggplot2::ggplot(stats) +
    ggplot2::geom_boxplot(
      ggplot2::aes(
        x = .data[["id"]],
        ymin = .data[["outlier_low_threshold"]],
        ymax = .data[["outlier_high_threshold"]],
        middle = .data[["median"]],
        lower = .data[["q1"]],
        upper = .data[["q3"]]
      ),
      stat = "identity"
    ) +
    ggplot2::geom_point(
      data = df_outliers,
      ggplot2::aes(
        x=.data[["id"]],
        y=.data[["values"]],
        )
      ) +
    ggplot2::xlab(xlab) +
    ggplot2::ylab(ylab) +
    ggplot2::theme_bw()
}
