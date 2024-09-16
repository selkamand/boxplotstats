
<!-- README.md is generated from README.Rmd. Please edit that file -->

# boxplotstats

<!-- badges: start -->

[![R-CMD-check](https://github.com/selkamand/boxplotstats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/selkamand/boxplotstats/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/selkamand/boxplotstats/branch/main/graph/badge.svg)](https://app.codecov.io/gh/selkamand/boxplotstats?branch=main)
![GitHub Issues or Pull
Requests](https://img.shields.io/github/issues-closed/selkamand/boxplotstats)
[![CodeSize](https://img.shields.io/github/languages/code-size/selkamand/boxplotstats.svg)](https://github.com/selkamand/boxplotstats)
![GitHub last
commit](https://img.shields.io/github/last-commit/selkamand/boxplotstats)
<!-- badges: end -->

The `boxplotstats` package provides functions to calculate and visualize
boxplot summary statistics for numeric data, including handling grouped
data.

The most common use-case for this package is you have lots of data
e.g. from. bootstrapping experiments that you don’t want to store, but
you may want to plot.

## Installation

You can install the development version of boxplotstats from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("selkamand/boxplotstats")
```

## Usage

### Calculate Boxplot Summary Statistics

To calculate boxplot summary statistics for a single numeric vector:

``` r
library(boxplotstats)

# Example numeric vector
vec <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100)

# Calculate boxplot statistics
boxplot_stats <- calculate_boxplot_stats(vec)

# Print the results
print(boxplot_stats)
#>     min max  q1  q3 iqr median outlier_low_threshold outlier_high_threshold
#> 25%   1 100 3.5 8.5   5      6                    -4                     16
#>     outliers
#> 25%      100
```

For a more complex example with outliers:

``` r
# Numeric vector with outliers
vec_with_outliers <- c(rep(1, times = 3), 1:10, 22, 23)

# Calculate boxplot statistics
boxplot_stats_with_outliers <- calculate_boxplot_stats(vec_with_outliers)

# Print the results
print(boxplot_stats_with_outliers)
#>     min max  q1  q3 iqr median outlier_low_threshold outlier_high_threshold
#> 25%   1  23 1.5 8.5   7      5                    -9                     19
#>     outliers
#> 25%   22, 23
```

### Calculate Boxplot Summary Statistics for Multiple Groups

To calculate boxplot summary statistics for multiple groups:

``` r
# Example values and group IDs
values <- c(1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 22, 23, 8, 8, 8, 12, 13, 14, 15, 30, 31)
ids <- c("b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b1", "b2", "b2", "b2", "b2", "b2", "b2", "b2", "b2", "b2")

# Calculate boxplot statistics for multiple groups
group_stats <- calculate_boxplot_stats_for_multiple_groups(values, ids)

# Print the results
print(group_stats)
#>   min max  q1   q3 iqr median outlier_low_threshold outlier_high_threshold
#> 1   1  23 1.5  8.5   7      5                  -9.0                   19.0
#> 2   8  31 8.0 15.0   7     13                  -2.5                   25.5
#>   outliers id
#> 1   22, 23 b1
#> 2   30, 31 b2
```

### Visualise Boxplots

``` r
# Plot a single boxplot
plot_boxplot_stats(boxplot_stats_with_outliers)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

``` r

# Plot multiple boxplots
plot_boxplot_stats(group_stats, ylab = "Identifiers")
```

<img src="man/figures/README-unnamed-chunk-4-2.png" width="100%" />

### Render interactive boxplots

Add a tooltip to your plot with `make_interactive()`

``` r
plot <- plot_boxplot_stats(group_stats, ylab = "Identifiers")
make_interactive(plot)
#> PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.
```

<div class="girafe html-widget html-fill-item" id="htmlwidget-cfe4c1fe4a2c8cb73a3b" style="width:100%;height:288px;"></div>
<script type="application/json" data-for="htmlwidget-cfe4c1fe4a2c8cb73a3b">{"x":{"html":"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='ggiraph-svg' role='graphics-document' id='svg_97184601_f41d_444a_a410_c520220562c5' viewBox='0 0 432 216'>\n <defs id='svg_97184601_f41d_444a_a410_c520220562c5_defs'>\n  <clipPath id='svg_97184601_f41d_444a_a410_c520220562c5_c1'>\n   <rect x='0' y='0' width='432' height='216'/>\n  <\/clipPath>\n  <clipPath id='svg_97184601_f41d_444a_a410_c520220562c5_c2'>\n   <rect x='33.27' y='5.48' width='393.25' height='178.79'/>\n  <\/clipPath>\n <\/defs>\n <g id='svg_97184601_f41d_444a_a410_c520220562c5_rootg' class='ggiraph-svg-rootg'>\n  <g clip-path='url(#svg_97184601_f41d_444a_a410_c520220562c5_c1)'>\n   <rect x='0' y='0' width='432' height='216' fill='#FFFFFF' fill-opacity='1' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.75' stroke-linejoin='round' stroke-linecap='round' class='ggiraph-svg-bg'/>\n   <rect x='0' y='0' width='432' height='216' fill='#FFFFFF' fill-opacity='1' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='round'/>\n  <\/g>\n  <g clip-path='url(#svg_97184601_f41d_444a_a410_c520220562c5_c2)'>\n   <rect x='33.27' y='5.48' width='393.25' height='178.79' fill='#FFFFFF' fill-opacity='1' stroke='none'/>\n   <polyline points='42.21,184.27 42.21,5.48' fill='none' stroke='#BEBEBE' stroke-opacity='1' stroke-width='1.07' stroke-dasharray='7,3' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='131.58,184.27 131.58,5.48' fill='none' stroke='#BEBEBE' stroke-opacity='1' stroke-width='1.07' stroke-dasharray='7,3' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='220.96,184.27 220.96,5.48' fill='none' stroke='#BEBEBE' stroke-opacity='1' stroke-width='1.07' stroke-dasharray='7,3' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='310.33,184.27 310.33,5.48' fill='none' stroke='#BEBEBE' stroke-opacity='1' stroke-width='1.07' stroke-dasharray='7,3' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='399.71,184.27 399.71,5.48' fill='none' stroke='#BEBEBE' stroke-opacity='1' stroke-width='1.07' stroke-dasharray='7,3' stroke-linejoin='round' stroke-linecap='butt'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e1' x1='301.39' y1='155.01' x2='301.39' y2='116' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e2' x1='51.14' y1='155.01' x2='51.14' y2='116' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e3' x1='207.55' y1='135.51' x2='301.39' y2='135.51' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e4' x1='144.99' y1='135.51' x2='51.14' y2='135.51' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <polygon id='svg_97184601_f41d_444a_a410_c520220562c5_e5' points='207.55,159.89 144.99,159.89 144.99,111.13 207.55,111.13 207.55,159.89' fill='#FFFFFF' fill-opacity='1' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='miter' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e6' x1='176.27' y1='159.89' x2='176.27' y2='111.13' stroke='#333333' stroke-opacity='1' stroke-width='2.13' stroke-linejoin='miter' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e7' x1='359.49' y1='73.74' x2='359.49' y2='34.74' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e8' x1='109.24' y1='73.74' x2='109.24' y2='34.74' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e9' x1='265.64' y1='54.24' x2='359.49' y2='54.24' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e10' x1='203.08' y1='54.24' x2='109.24' y2='54.24' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <polygon id='svg_97184601_f41d_444a_a410_c520220562c5_e11' points='265.64,78.62 203.08,78.62 203.08,29.86 265.64,29.86 265.64,78.62' fill='#FFFFFF' fill-opacity='1' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='miter' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <line id='svg_97184601_f41d_444a_a410_c520220562c5_e12' x1='247.77' y1='78.62' x2='247.77' y2='29.86' stroke='#333333' stroke-opacity='1' stroke-width='2.13' stroke-linejoin='miter' stroke-linecap='butt' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <circle id='svg_97184601_f41d_444a_a410_c520220562c5_e13' cx='328.21' cy='135.51' r='1.33pt' fill='none' stroke='#000000' stroke-opacity='1' stroke-width='1.42' stroke-linejoin='round' stroke-linecap='round' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <circle id='svg_97184601_f41d_444a_a410_c520220562c5_e14' cx='337.14' cy='135.51' r='1.33pt' fill='none' stroke='#000000' stroke-opacity='1' stroke-width='1.42' stroke-linejoin='round' stroke-linecap='round' title='&amp;lt;strong&amp;gt;b1&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 1&amp;lt;br/&amp;gt;q1: 1.5&amp;lt;br/&amp;gt;median: 5&amp;lt;br/&amp;gt;q3: 8.5&amp;lt;br/&amp;gt;max: 23&amp;lt;br/&amp;gt;'/>\n   <circle id='svg_97184601_f41d_444a_a410_c520220562c5_e15' cx='399.71' cy='54.24' r='1.33pt' fill='none' stroke='#000000' stroke-opacity='1' stroke-width='1.42' stroke-linejoin='round' stroke-linecap='round' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <circle id='svg_97184601_f41d_444a_a410_c520220562c5_e16' cx='408.65' cy='54.24' r='1.33pt' fill='none' stroke='#000000' stroke-opacity='1' stroke-width='1.42' stroke-linejoin='round' stroke-linecap='round' title='&amp;lt;strong&amp;gt;b2&amp;lt;/strong&amp;gt; &amp;lt;br/&amp;gt;min: 8&amp;lt;br/&amp;gt;q1: 8&amp;lt;br/&amp;gt;median: 13&amp;lt;br/&amp;gt;q3: 15&amp;lt;br/&amp;gt;max: 31&amp;lt;br/&amp;gt;'/>\n   <rect x='33.27' y='5.48' width='393.25' height='178.79' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='round'/>\n  <\/g>\n  <g clip-path='url(#svg_97184601_f41d_444a_a410_c520220562c5_c1)'>\n   <text x='18.54' y='138.66' font-size='6.6pt' font-family='Helvetica' fill='#4D4D4D' fill-opacity='1'>b1<\/text>\n   <text x='18.54' y='57.39' font-size='6.6pt' font-family='Helvetica' fill='#4D4D4D' fill-opacity='1'>b2<\/text>\n   <polyline points='30.53,135.51 33.27,135.51' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='30.53,54.24 33.27,54.24' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='42.21,187.01 42.21,184.27' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='131.58,187.01 131.58,184.27' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='220.96,187.01 220.96,184.27' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='310.33,187.01 310.33,184.27' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='399.71,187.01 399.71,184.27' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <text x='35.84' y='195.5' font-size='6.6pt' font-family='Helvetica' fill='#4D4D4D' fill-opacity='1'>-10<\/text>\n   <text x='129.13' y='195.5' font-size='6.6pt' font-family='Helvetica' fill='#4D4D4D' fill-opacity='1'>0<\/text>\n   <text x='216.06' y='195.5' font-size='6.6pt' font-family='Helvetica' fill='#4D4D4D' fill-opacity='1'>10<\/text>\n   <text x='305.44' y='195.5' font-size='6.6pt' font-family='Helvetica' fill='#4D4D4D' fill-opacity='1'>20<\/text>\n   <text x='394.81' y='195.5' font-size='6.6pt' font-family='Helvetica' fill='#4D4D4D' fill-opacity='1'>30<\/text>\n   <text x='215.83' y='208.09' font-size='8.25pt' font-family='Helvetica'>Value<\/text>\n   <text transform='translate(13.37,118.72) rotate(-90.00)' font-size='8.25pt' font-family='Helvetica'>Identifiers<\/text>\n  <\/g>\n <\/g>\n<\/svg>","js":null,"uid":"svg_97184601_f41d_444a_a410_c520220562c5","ratio":2,"settings":{"tooltip":{"css":".tooltip_SVGID_ { padding:5px;background:black;color:white;border-radius:2px;text-align:left; ; position:absolute;pointer-events:none;z-index:999;}","placement":"doc","opacity":0.9,"offx":10,"offy":10,"use_cursor_pos":true,"use_fill":false,"use_stroke":false,"delay_over":200,"delay_out":500},"hover":{"css":".hover_data_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_data_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_data_SVGID_ { fill:orange;stroke:black; }\nline.hover_data_SVGID_, polyline.hover_data_SVGID_ { fill:none;stroke:orange; }\nrect.hover_data_SVGID_, polygon.hover_data_SVGID_, path.hover_data_SVGID_ { fill:orange;stroke:none; }\nimage.hover_data_SVGID_ { stroke:orange; }","reactive":true,"nearest_distance":null},"hover_inv":{"css":""},"hover_key":{"css":".hover_key_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_key_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_key_SVGID_ { fill:orange;stroke:black; }\nline.hover_key_SVGID_, polyline.hover_key_SVGID_ { fill:none;stroke:orange; }\nrect.hover_key_SVGID_, polygon.hover_key_SVGID_, path.hover_key_SVGID_ { fill:orange;stroke:none; }\nimage.hover_key_SVGID_ { stroke:orange; }","reactive":true},"hover_theme":{"css":".hover_theme_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_theme_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_theme_SVGID_ { fill:orange;stroke:black; }\nline.hover_theme_SVGID_, polyline.hover_theme_SVGID_ { fill:none;stroke:orange; }\nrect.hover_theme_SVGID_, polygon.hover_theme_SVGID_, path.hover_theme_SVGID_ { fill:orange;stroke:none; }\nimage.hover_theme_SVGID_ { stroke:orange; }","reactive":true},"select":{"css":".select_data_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_data_SVGID_ { stroke:none;fill:red; }\ncircle.select_data_SVGID_ { fill:red;stroke:black; }\nline.select_data_SVGID_, polyline.select_data_SVGID_ { fill:none;stroke:red; }\nrect.select_data_SVGID_, polygon.select_data_SVGID_, path.select_data_SVGID_ { fill:red;stroke:none; }\nimage.select_data_SVGID_ { stroke:red; }","type":"multiple","only_shiny":true,"selected":[]},"select_inv":{"css":""},"select_key":{"css":".select_key_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_key_SVGID_ { stroke:none;fill:red; }\ncircle.select_key_SVGID_ { fill:red;stroke:black; }\nline.select_key_SVGID_, polyline.select_key_SVGID_ { fill:none;stroke:red; }\nrect.select_key_SVGID_, polygon.select_key_SVGID_, path.select_key_SVGID_ { fill:red;stroke:none; }\nimage.select_key_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"select_theme":{"css":".select_theme_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_theme_SVGID_ { stroke:none;fill:red; }\ncircle.select_theme_SVGID_ { fill:red;stroke:black; }\nline.select_theme_SVGID_, polyline.select_theme_SVGID_ { fill:none;stroke:red; }\nrect.select_theme_SVGID_, polygon.select_theme_SVGID_, path.select_theme_SVGID_ { fill:red;stroke:none; }\nimage.select_theme_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"zoom":{"min":1,"max":1,"duration":300},"toolbar":{"position":"topright","pngname":"diagram","tooltips":null,"fixed":false,"hidden":[],"delay_over":200,"delay_out":500},"sizing":{"rescale":true,"width":1}}},"evals":[],"jsHooks":[]}</script>
