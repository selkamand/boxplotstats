# Unit tests for plot_boxplot_stats
example_stats_results <- data.frame(
  min = c(1, 8),
  max = c(23, 31),
  q1 = c(1.5, 8),
  q3 = c(8.5, 15),
  iqr = c(7, 7),
  median = c(5, 13),
  outlier_low_threshold = c(-9, -2.5),
  outlier_high_threshold = c(19, 25.5),
  outliers = I(list(c(22, 23), c(30, 31))),
  custom_column = c("Colour1", "Colour2"),
  id = c("b1", "b2")
)

test_that("plot_boxplot_stats produces a plot", {
  skip_if_not_installed("ggplot2")
  plot <- plot_boxplot_stats(example_stats_results)
  expect_s3_class(plot, "gg")
})


test_that("plot_boxplot_stats allows colouring by any column in supplied dataset", {
  skip_if_not_installed("ggplot2")
  expect_no_error(print(plot_boxplot_stats(example_stats_results, col_fill = "custom_column", col_colour = "custom_column")))
})


