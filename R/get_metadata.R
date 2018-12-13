#' Get meta data
#'
#' Get meta data on a Data Frame, Data Table, Tibble etc.
#'
#' This function will return a table with relevant meta data on your input in a nice
#' tidy table structure including name, class, number of empty cells, percents
#' empty cells, number of unique values, percents of unique values and examples of
#' data for each column in the inputtet dataset.
#'
#' @param data The data you want meta data on - can be in the form of a
#' Data Frame, Data Table or Tibble (possible others).
#' @param dataExample Logical Vector; If TRUE (default) it will add a colum in
#' the return with an example of an averagely selected (non NA) data point.
#'
#' @return A data vector of type input (if data is Data Table, the returned
#' value is Data Table, if input is Data Frame the returned value is Data Frame etc.)
#'
#' The returned data will include the following columns:
#' \itemize{
#'   \item \strong{name:} The name of the column
#'   \item \strong{colNo:} The position of the column, counting fom the left
#'   \item \strong{class:} The class type of the column
#'   \item \strong{na_count:} The number of NA values in the column
#'   \item \strong{null_count:} The number of NULL values in the column
#'   \item \strong{empty_count:} The number of NA and/or NULL values in the column
#'   \item \strong{empty_pct:} The percentage of empty values in the column
#'   \item \strong{uniqueValues_count:} The number of unique values in the column
#'   \item \strong{uniqueValues_pct:} The percentage of unique values in the column
#'   \item \strong{dataExample:} (optional) Examples of data in the column. For numeric data
#'   selected by mean and for text data, selected by the avg. length of the text.
#' }
#'
#' @examples
#'
#' df <-
#'   data.frame(
#'     letters = letters,
#'     num = 1:26,
#'     letters2 = c(rep("a", 4),rep(NA_character_, 6), rep("b", 10), rep(NA_character_, 6)),
#'     date = as.POSIXct("2010-01-01"))
#'
#' df_meta <- get_metadata(df)
#'
#' print(df_meta)
#'
#' @import data.table magrittr
#'
#' @export
get_metadata <- function(data, dataExample = TRUE){

  inputclass <- class(data)

  if(!data.table::is.data.table(data)) data <- data.table::as.data.table(data)

  metaDT <- data.table::data.table(name = names(data))

  metaDT[, colNo := .I]

  metaDT[, class := sapply(data, function(x) paste(class(x), collapse = ", "))]

  metaDT[, na_count := NA_integer_]
  metaDT[, null_count := NA_integer_]

  metaDT[class != "list", na_count := sapply(name, function(x) sum(is.na(data[[get("x")]])))]
  metaDT[class != "list", null_count := sapply(name, function(x) sum(is.null(data[[get("x")]])))]

  metaDT[class == "list", na_count := sapply(name, function(x) sum(sapply(data[[get("x")]], function(y) sum(is.na(y)))) )]
  metaDT[class == "list", null_count := sapply(name, function(x) sum(sapply(data[[get("x")]], function(y) sum(is.null(y)))) )]

  metaDT[, empty_count := na_count + null_count]
  metaDT[, c("na_count", "null_count") := NULL]


  metaDT[, empty_pct := (empty_count / nrow(data)) * 100]
  metaDT[, empty_pct := round(empty_pct, digits = 2)]


  metaDT[, uniqueValues_count := NA_integer_]
  metaDT[, uniqueValues_count := sapply(name, function(x) data[[get("x")]] %>% unique() %>% length() )]

  metaDT[, uniqueValues_pct := (uniqueValues_count / nrow(data)) * 100]
  metaDT[, uniqueValues_pct := round(uniqueValues_pct, digits = 2)]


  if(dataExample){

    metaDT[, dataExample := NA_character_]

    metaDT[class == "character", dataExample := sapply(name, function(x){
      nchars <- na.omit(data[[get("x")]]) %>% nchar()
      return(na.omit(data[[get("x")]])[!is.na][which.min(abs(nchars - mean(nchars, na.rm = TRUE)))])
    })]

    metaDT[class == "list", dataExample := sapply(name, function(x){
      length <- sapply(data[[!is.na(get("x"))]], length)
      na.omit(data[[get("x")]])[which.min(abs(length - mean(length, na.rm = TRUE)))] %>%
        paste() %>%
        return()
    })]

    metaDT[class == "integer" | class == "numeric", dataExample := sapply(name, function(x){
      meanX <- data[[get("x")]] %>% mean(na.rm = TRUE)
      na.omit(data[[get("x")]])[which.min(abs(meanX - mean(meanX, na.rm = TRUE)))] %>%
        as.character() %>%
        return()
    })]

    metaDT[class != "list" & class != "character" & class != "integer" & class != "numeric",
           dataExample := sapply(name, function(x){
             if(na.omit(data[[get("x")]]) %>% length() == 0) return(NA_character_) else {
               data[[get("x")]] %>% na.omit() %>% sample(1) %>% as.character() %>% return()
             }
           })]

  }

  if(!any(inputclass %in% "data.table")) class(metaDT) <- inputclass[1]

  return(metaDT)

}