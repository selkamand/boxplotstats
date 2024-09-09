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
      stat = "identity",
      show.legend = show_legend
    ) +
    ggplot2::labs(fill = col_fill, colour = col_colour) +
    ggplot2::geom_point(
      data = df_outliers,
      ggplot2::aes(
        y = .data[["id"]],
        x = .data[["outliers"]],
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

exemplar_atypical_boxplot_stats <- function(){
  data.frame(
    id = c(
      "DBS1", "DBS2", "DBS3", "DBS4", "DBS5", "DBS6", "DBS7", "DBS8", "DBS9",
      "DBS10", "DBS11", "DBS12", "DBS13", "DBS14", "DBS15", "DBS16", "DBS17",
      "DBS18", "DBS19", "DBS20"
    ),
    min = rep(c(0.745974663600526, 0, 0.0804990328515112, 0), c(1L, 17L, 1L, 1L)),
    max = c(
      0.859019097425731, 0, 0.0133807174770039, 0.0157221182654402,
      0.00138241524310118, 0, 0.0218789408672799, 0.0128856990801577,
      0.0129452155059133, 0, 0.0687392522996058, 0, 0.0617953245729304, 0, 0,
      0.0419835308804205, 0.0136062431190621, 0, 0.227778128777924,
      0.0107101314060447
    ),
    q1 = rep(c(0.785240692509856, 0, 0.150732258064238, 0), c(1L, 17L, 1L, 1L)),
    q3 = c(
      0.817164265768725, 0, 0, 0.0027455272694302, 0, 0, 0, 0, 0, 0,
      0.00179679927962786, 0, 0.023940387671411, 0, 0, 0, 0, 0, 0.194720698495768,
      0
    ),
    iqr = c(
      0.0319235732588699, 0, 0, 0.0027455272694302, 0, 0, 0, 0, 0, 0,
      0.00179679927962786, 0, 0.023940387671411, 0, 0, 0, 0, 0, 0.0439884404315294,
      0
    ),
    median = rep(
      c(
        0.801742784494087, 0, 1.65551905387648e-05, 0, 0.00893562550451462, 0,
        0.172290387535388, 0
      ),
      c(1L, 2L, 1L, 8L, 1L, 5L, 1L, 1L)
    ),
    outlier_low_threshold = c(
      0.737355332621551, 0, 0, -0.0041182909041453, 0, 0, 0, 0, 0, 0,
      -0.00269519891944179, 0, -0.0359105815071165, 0, 0, 0, 0, 0,
      0.0847495974169444, 0
    ),
    outlier_high_threshold = c(
      0.86504962565703, 0, 0, 0.00686381817357549, 0, 0, 0, 0, 0, 0,
      0.00449199819906964, 0, 0.0598509691785274, 0, 0, 0, 0, 0, 0.260703359143062,
      0
    ),
    outliers = c(
      "", "",
      "0.00127531011826544|0.0113430525624179|0.00460840736479423|0.00807357161629435|0.000576890932982917|0.002764984234908|0.0133807174770039|0.00222073981603154|0.00516537187910644|0.00141217214377421|0.002138496717659|0.00512068988173456|0.00414724704336399|0.00331715900131406",
      "0.00801057424441524|0.00721226806833114|0.00758430354796321|0.00829456241787122|0.00828723258869908|0.0157221182654402|0.00978126018396846|0.00832587648925871|0.00922035084202319|0.0108085085413929|0.00736674375821288",
      "0.00138241524310118", "", "0.0218789408672799|0.00320889093298292",
      "0.00247054664914586|0.00216709198707896|0.0128856990801577|0.00646356504599212|0.00713529830109763|0.00433861498028909|0.000241013140287762|0.00155070302030131|0.00248676872536137|0.00623440473880999|0.00782363338741607",
      "0.00365291327201051|0.00451384756898817|0.00209610775295664|0.00313013665817328|0.000492865966482084|0.00184949277509789|0.000574406044678055|0.0129452155059133",
      "",
      "0.00953501708278581|0.0145097477003942|0.0387802378959004|0.00883840473061761|0.0540405360656498|0.016348963184824|0.0122338186435824|0.0553133482260184|0.00613291327201051|0.00591566885676741|0.0314955309218075|0.0284600788062285|0.0100593613798415|0.0265980565045992|0.0233564980289093|0.0072148147079963|0.00846142048822415|0.0176802851743499|0.00950639291656556|0.0335905597897503|0.0170438672574982|0.0687392522996058|0.00583718527485258",
      "", "0.0617953245729304", "", "",
      "0.0419835308804205|0.00747054007884363|0.0136405729482793|0.0124646070959264|0.0122572207621551|0.015296802890933|0.00539268199737188|0.00955382654402103|0.0144103416367801|0.000238252299605782|0.0202213889353201|0.00645145466491459|0.0164961340558425|0.00221328909620669|0.0132771143407058|0.00995572536136662|0.0112103810775296|0.0246227923784494|0.0312878961892247",
      "0.005373185282523|0.00991228909329829|0.0136062431190621|0.00352574375357984",
      "", "0.0804990328515112",
      "0.0107101314060447|0.00153181077328277|0.0019632049934297|0.00118441787122208|0.000210201051248357|0.000558159001314061|0.00214920367936925"
    ),
    experimental_pval = rep(c(0, 1, 0.97, 1, 0.98, 1, 0, 1), c(1L, 9L, 1L, 1L, 1L, 5L, 1L, 1L)),
  )
}
