globalVariables(c(".data"))

#' Calculate Boxplot Summary Statistics for a Numeric Vector
#'
#' This function calculates the summary statistics typically used in a boxplot,
#' including the minimum, maximum, median, first quartile (Q1), third quartile (Q3),
#' interquartile range (IQR), and outliers.
#'
#' @param numeric_vector A numeric vector for which to calculate boxplot summary statistics.
#' @param id An optional string to add as an ID column to the dataframe
#' @param return_dataframe Logical, if TRUE, returns a dataframe; otherwise returns a list.
#' @param outliers_as_strings Logical. Return outliers as a character vector of '|' delimited strings rather than as a list-column (ignored if \code{return_dataframe = FALSE}).
#' Can customise the delimiter using the \code{delim} argument
#' @param delim the delimiter separating different outliers. Used when outlier column is a character vector where each element describes a set of outliers delimited by some character, usually '|'.
#'
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
#'   \item{outliers}{A list-column of outlier values that are either below the lower threshold or above the upper threshold. Can also be a '|' delimited character vector of outliers}
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
calculate_boxplot_stats <- function(numeric_vector, id = NULL, return_dataframe = TRUE, outliers_as_strings = FALSE, delim="|"){
  # Initialize an empty list to store summary statistics
  boxplot_stats <- list()
  boxplot_stats$min <- min(numeric_vector, na.rm = TRUE)
  boxplot_stats$max <- max(numeric_vector, na.rm = TRUE)
  boxplot_stats$median <- stats::median(numeric_vector, na.rm = TRUE)
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

    # Convert Outlier List-Column to pipe-separated strings
    if(outliers_as_strings){
      boxplot_stats_df$outliers <- list_column_to_delim(boxplot_stats_df$outliers, delim = delim)
    }

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
#' @inheritParams calculate_boxplot_stats
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
calculate_boxplot_stats_for_multiple_groups <- function(values, ids, outliers_as_strings = FALSE, delim="|"){

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

  # Convert Outlier List-Column to pipe-separated strings
  if(outliers_as_strings){
    result_df$outliers <- list_column_to_delim(result_df$outliers, delim=delim)
  }

  return(result_df)
}

#' Convert List Column to Delimited String
#'
#' This function converts list columns in a dataframe to delimited strings.
#'
#' @param list_column A list column to convert.
#' @param delim the character used as a delimiter to separate the outlier values (defaults to '|')
#' @return A character vector with delimited strings.
list_column_to_delim <- function(list_column, delim="|"){
  unlist(lapply(list_column, function(x) {paste0(x, collapse = delim)}))
}

#' Convert Delimited String to List Column
#'
#' This function converts a character vector with delimited strings into a list column of numeric vectors.
#'
#' @param char_vector A character vector containing delimited numeric strings to convert.
#' @param delim The character used as a delimiter to separate the values in the string (defaults to '|').
#' @return A list column where each element is a numeric vector extracted from the delimited string.
#'
#' @details
#' \code{delim_to_list_column(c("1|2|3", "4|5"), delim = "|")}
delim_to_list_column <- function(char_vector, delim = "|") {

  # Check if the vector contains any delimiter; if not, return as numeric vector
  if (!any(grepl(pattern = delim, x = char_vector, fixed = TRUE))) {
    return(as.numeric(char_vector))
  }

  # Split each element of the character vector based on the delimiter
  split_list <- strsplit(char_vector, split = delim, fixed = TRUE)

  # Convert each list element from a character vector to numeric
  numeric_list <- lapply(split_list, as.numeric)

  return(numeric_list)
}

#' Write Boxplot Statistics to TSV File
#'
#' This function writes the boxplot statistics dataframe to a TSV file.
#'
#' @param df A dataframe containing boxplot statistics.
#' @param file The file path where the TSV file will be written.
write_boxplot_stats_tsv <- function(df, file){

  if ("list" %in% typeof(df$outliers))
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
#' This function creates an interactive boxplot using `ggplot2` and `ggiraph`, based on a dataframe
#' that contains boxplot statistics. The user can specify additional options for aesthetics, sorting,
#' and interactivity.
#'
#' @param stats A dataframe containing boxplot statistics with required columns: 'outlier_low_threshold',
#' 'outlier_high_threshold', 'median', 'q1', 'q3', and 'outliers'.
#' @param xlab A character string specifying the x-axis label. Default is "Value".
#' @param ylab A character string specifying the y-axis label. Default is "ID".
#' @param delim The delimiter used in the 'outliers' column for splitting string-based outliers into numeric values.
#' Default is "|".
#' @param sort Logical, whether to sort boxplots by the 'median' column. Default is TRUE.
#' @param descending Logical, if sorting, whether to sort in descending order. Default is TRUE.
#' @param col_fill Optional column name for determining the fill color of the boxplot.
#' @param col_colour Optional column name for determining the outline color of the boxplot.
#' @param col_tooltip Optional column name for custom tooltips in the interactive plot. Default is a generated tooltip.
#' @param col_data_id Optional column name for the `data_id` used in interactivity.
#' @param col_onclick Optional column name for specifying the `onclick` actions in the interactive plot.
#' @param show_legend Logical, whether to show the legend for color and fill. Default is TRUE.
#' @param dotsize Size of outlier points. Default is 1.
#' @param dotstroke Stroke width of outlier points. Default is 1.
#' @param dotshape Shape of outlier points. Default is 1.
#' @param linewidth Width of the boxplot outlines. Default is 0.5.
#' @param width Width of the boxplots (value between 0 and 1).
#' @inheritParams ggplot2::geom_boxplot
#' @return A `ggplot` object with interactive boxplots.
#' @export
#' @examples
#' # Example usage:
#' # df_stats <- some_dataframe_with_stats
#' # plot_boxplot_stats(df_stats, xlab = "X Label", ylab = "Y Label")
plot_boxplot_stats <- function(stats, xlab = "Value", ylab = "ID", delim = "|",
                               sort = TRUE, descending = TRUE,
                               col_fill = NULL, col_colour = NULL,
                               col_tooltip = NULL, col_data_id = NULL,
                               col_onclick = NULL, show_legend = TRUE,
                               dotsize = 1, dotstroke = 1, dotshape = 1,
                               width = 0.6,
                               staplewidth = 0.8,
                               linewidth = 0.5) {

  # Ensure required packages are loaded
  requireNamespace("ggplot2", quietly = TRUE)
  requireNamespace("ggiraph", quietly = TRUE)

  # Check if the 'id' column exists, otherwise generate default IDs
  show_ids = TRUE
  if (!"id" %in% names(stats)) {
    stats$id <- paste0("id: ", seq_len(nrow(stats)))
    if(nrow(stats) > 1){
      message("plot_boxplot_stats: No 'id' column found. Adding numbered IDs based on row order.\n",
              "We strongly suggest adding an 'id' column to the stats dataframe.")
    }
    else{
      show_ids = FALSE
    }
  }

  # Validate that required columns are present
  required_columns <- c("outlier_low_threshold", "outlier_high_threshold", "median", "q1", "q3", "outliers")
  missing_columns <- setdiff(required_columns, colnames(stats))
  if (length(missing_columns)) {
    stop("plot_boxplot_stats: boxplot stats dataframe MUST contain the column(s): [",
         paste0(missing_columns, collapse = ", "), "]")
  }

  # If 'id' is a character, convert the 'outliers' column from a delimited string to a numeric list
  if (is.character(stats$outliers)) {
    stats$outliers <- delim_to_list_column(char_vector = stats$outliers, delim = delim)
  }

  # Unnest the 'outliers' for plotting points
  df_outliers <- unnest(stats$id, stats$outliers)

  # Add back in the columns from stats data.frame so we can colour outlier points by any custom columns
  df_outliers <- merge(x = df_outliers, y = dropcols(stats, c("outliers", "values")), by = "id", all.x = TRUE)

  # Optionally sort the 'id' based on the 'median' column
  if (sort) {
    stats$id <- stats::reorder(stats$id, stats[["median"]], decreasing = !descending)
  }

  # If no tooltip column is provided, generate a default tooltip
  if (is.null(col_tooltip)) {
    stats$default_tooltip <- with(stats,
                                  paste0('<strong>', id, '</strong> <br/>',
                                         'q1: ', q1, '<br/>',
                                         'median: ', median, '<br/>',
                                         'q3: ', q3, '<br/>',
                                         'median: ', median, '<br/>'))
    col_tooltip <- "default_tooltip"
  }

  # Create the ggplot2 object with interactive boxplots using ggiraph
  gg <- ggplot2::ggplot(stats) +
    ggiraph::geom_boxplot_interactive(
      ggplot2::aes(
        y = .data[["id"]],
        xmin = .data[["outlier_low_threshold"]],
        xmax = .data[["outlier_high_threshold"]],
        xmiddle = .data[["median"]],
        xlower = .data[["q1"]],
        xupper = .data[["q3"]],
        fill = colval(.data, col_fill),
        colour = colval(.data, col_colour),
        onclick = colval(.data, col_onclick),
        data_id = colval(.data, col_data_id),
        tooltip = colval(.data, col_tooltip)
      ),
      linewidth = linewidth,
      width = width,
      staplewidth = staplewidth,
      stat = "identity",
      show.legend = show_legend
    ) +
    ggplot2::labs(fill = col_fill, colour = col_colour) +
    ggplot2::geom_point(
      data = df_outliers,
      ggplot2::aes(
        y = .data[["id"]],
        x = .data[["values"]],
        fill = colval(.data, col_fill),
        colour = colval(.data, col_colour)
      ),
      size = dotsize,
      stroke = dotstroke,
      shape = dotshape,
      show.legend = FALSE
    ) +
    ggplot2::xlab(xlab) +
    ggplot2::ylab(ylab) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_line(linetype = "longdash", colour = "grey"),
      panel.grid.minor.x = ggplot2::element_blank()
      )

  if(!show_ids){
    gg <- gg + ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank()
      )
  }

  return(gg)
}

# Helper function to safely extract values from columns
colval <- function(df, colname) {
  if (is.null(colname)) return(NULL)
  else return(df[[colname]])
}

dropcols <- function(df, cols){
  df[setdiff(colnames(df),cols)]
}

#' Make boxplots interactive
#'
#' Make boxplots interactive.
#'
#' @inheritParams ggiraph::girafe
#' @inheritDotParams ggiraph::girafe
#'
#' @export
#'
make_interactive <- function(ggobj, ...){
  requireNamespace("ggiraph", quietly = TRUE)
  ggiraph::girafe(ggobj = ggobj, ...)
}
