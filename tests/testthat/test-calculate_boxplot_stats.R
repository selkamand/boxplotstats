# Mock data for testing
set.seed(123)
vec <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100)
values <- c(1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 22, 23, 8, 8, 8, 12, 13, 14, 15, 30, 31)
ids <- c("b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b2", "b2", "b2", "b2", "b2", "b2", "b2", "b2", "b2")

# Define the expected outputs for tests
expected_single_group <- data.frame(
  min = 1,
  max = 100,
  median = 6,
  q1 = 4,
  q3 = 9,
  iqr = 5,
  outlier_low_threshold = -2.5,
  outlier_high_threshold = 15.5,
  outliers = I(list(100)),
  id = NA
)

expected_multiple_groups <- data.frame(
  min = c(1, 8),
  max = c(23, 31),
  q1 = c(1.5, 8),
  q3 = c(8.5, 15),
  iqr = c(7, 7),
  median = c(5, 13),
  outlier_low_threshold = c(-9, -2.5),
  outlier_high_threshold = c(19, 25.5),
  outliers = I(list(c(22, 23), c(30, 31))),
  id = c("b1", "b2")
)

# Unit tests for calculate_boxplot_stats
test_that("calculate_boxplot_stats works correctly", {
  result <- calculate_boxplot_stats(vec, return_dataframe = FALSE)
  expect_type(result, "list")
  expect_equal(result$min, 1, ignore_attr = TRUE)
  expect_equal(result$max, 100, ignore_attr = TRUE)
  expect_equal(result$median, 6, ignore_attr = TRUE)
  expect_equal(result$q1, 3.5, ignore_attr = TRUE)
  expect_equal(result$q3, 8.5, ignore_attr = TRUE)
  expect_equal(result$iqr, 5, ignore_attr = TRUE)
  expect_equal(result$outlier_low_threshold, -4, ignore_attr = TRUE)
  expect_equal(result$outlier_high_threshold, 16, ignore_attr = TRUE)
  expect_equal(unlist(result$outliers), 100, ignore_attr = TRUE)
})


test_that("calculate_boxplot_stats returns dataframe when specified", {
  result_df <- calculate_boxplot_stats(vec, return_dataframe = TRUE)
  expect_s3_class(result_df, "data.frame")
  expect_equal(result_df$min, 1, ignore_attr = TRUE)
  expect_equal(result_df$max, 100, ignore_attr = TRUE)
  expect_equal(result_df$median, 6, ignore_attr = TRUE)
  expect_equal(result_df$q1, 3.5, ignore_attr = TRUE)
  expect_equal(result_df$q3, 8.5, ignore_attr = TRUE)
  expect_equal(result_df$iqr, 5, ignore_attr = TRUE)
  expect_equal(result_df$outlier_low_threshold, -4, ignore_attr = TRUE)
  expect_equal(result_df$outlier_high_threshold, 16, ignore_attr = TRUE)
  expect_equal(unlist(result_df$outliers), 100, ignore_attr = TRUE)

})

# Unit tests for calculate_boxplot_stats_for_multiple_groups
test_that("calculate_boxplot_stats_for_multiple_groups works correctly", {
  result <- calculate_boxplot_stats_for_multiple_groups(values, ids)
  expect_s3_class(result, "data.frame")

  expect_equal(nrow(result), 2)
  expect_equal(colnames(result), c("min", "max", "q1", "q3", "iqr", "median", "outlier_low_threshold", "outlier_high_threshold", "outliers", "id"))
  expect_equal(result$min, expected_multiple_groups$min)
  expect_equal(result$max, expected_multiple_groups$max)
  expect_equal(result$median, expected_multiple_groups$median)
  expect_equal(result$q1, expected_multiple_groups$q1)
  expect_equal(result$q3, expected_multiple_groups$q3)
  expect_equal(result$iqr, expected_multiple_groups$iqr)
  expect_equal(result$outlier_low_threshold, expected_multiple_groups$outlier_low_threshold)
  expect_equal(result$outlier_high_threshold, expected_multiple_groups$outlier_high_threshold)
  expect_equal(result$outliers, expected_multiple_groups$outliers)
})


# # Unit tests for list_column_to_delim
test_that("list_column_to_delim converts list column correctly", {
  df <- data.frame(outliers = I(list(c(100, 101), c(102, 103))))
  result <- list_column_to_delim(df$outliers)
  expect_equal(result, c("100|101", "102|103"))
})

# Unit tests for write_boxplot_stats_tsv
test_that("write_boxplot_stats_tsv writes data to TSV file", {
  tmp_file <- tempfile(fileext = ".tsv")
  write_boxplot_stats_tsv(expected_multiple_groups, tmp_file)
  written_data <- read.table(tmp_file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  expect_equal(nrow(written_data), nrow(expected_multiple_groups))
  expect_equal(colnames(written_data), colnames(expected_multiple_groups))

  written_outliers <- lapply(strsplit(written_data$outliers, split = "\\|"), as.numeric)
  expect_equal(written_outliers, unclass(expected_multiple_groups$outliers))
})


# Unit tests for unnest
test_that("unnest function works correctly", {
  ids <- c(1, 2, 3)
  nested_list <- list(
    c(1, 2, 3),
    c(4, 5),
    c(6, 7, 8, 9)
  )
  result <- unnest(ids, nested_list)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 9)
  expect_equal(colnames(result), c("id", "values"))
  expect_equal(result$id, rep(ids, times = sapply(nested_list, length)))
  expect_equal(result$values, unlist(nested_list))
})


