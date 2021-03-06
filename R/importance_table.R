#' importance_table
#'
#' \code{importance_table} returns a data_frame of variable importance
#'
#' This currently only works for rpart and gbm.step functions. In the
#' future more features will be added so that it works for many
#' decision trees
#'
#' @param x An rpart of gbm.step object to be turned into a tidy dataframe
#'     containing importance values
#'
#' @return A data_frame object made with the intention of turning it into a
#'     text table with `knitr` or `xtable`
#'
#'
#' @examples
#'
#' # turn a fitted object into a data_frame
#'
#'  \code{rpart} object
#' fit.rpart <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)
#'
#' importance_table(fit.rpart)
#'
#' # you can even use piping
#'
#' fit.rpart %>% importance_table
#'
#' \code{gbm.step} object
#' fit.gbm.step <- gbm.step(data = iris,
#'                          gbm.x = c(1:3),
#'                          gbm.y = 4,
#'                          tree.complexity = 1,
#'                          family = "gaussian",
#'                          learning.rate = 0.01,
#'                          bag.fraction = 0.5)
#'
#' importance_table(fit.gbm.step)
#'
#' # with piping
#' fit.gbm.step %>% importance_table
#'
#' Unfortunately it cannot yet run a \code{gbm} object:
#' \dontrun{
#'
#' gbm.fit <- gbm(Sepal.Width ~ .,
#'                distribution = "gaussian",
#'                data = iris)
#'
#' importance_table(gbm.fit)
#' }
#'
#' \code{randomForest} object
#'     set.seed(1)
#'     data(iris)
#'     iris.rf <- randomForest(Species ~ ., iris,
#'                             proximity=TRUE,
#'                             keep.forest=FALSE)
#'
#' importance_table(iris.rf)
#'
#'
#' @seealso \url{https://github.com/dgrtwo/broom}
#'
#' @export
importance_table <- function(x) UseMethod("importance_table")

#' @export
importance_table.NULL <- function(x) NULL

#' @export
importance_table.default <- function(x) {

    stop("alas, importance_table does not know how to deal with data of class ", class(x), call. = FALSE)

  }

#========
# rpart
#========

#' @export
importance_table.rpart <- function(x){

    # Some trees are stumps, we need to skip those that are NULL (stumps)
    # so here we say, "If variable importance is NOT NULL, do the following"
    # Another option would be to only include those models which are not null.

    if (is.null(x$variable.importance) == FALSE) {

    x <-
      x$variable.importance %>%
      data.frame(variable = names(x$variable.importance),
                 importance = as.vector(x$variable.importance),
                 row.names = NULL) %>%
      select(variable,
             importance) %>%
      as_data_frame()

    } else {

      # if rpart_frame just contains a decision stump, make NULL datasets.

      x <- data.frame(variable = NULL,
                      importance = NULL,
                      row.names = NULL) %>%
        as_data_frame()
    } # end else

  # no need to modify the class of the object.
    # res <- x
    # class(res) <- c("imp_tbl", class(res))
    # return(res)
  return(x)

}
#=====
# gbm
#=====

#' @export
importance_table.gbm <- function(x){

    x <-
      x$contributions %>%
        # make it a dataframe
        as_data_frame %>%
        # rename the variables
        rename(variable = var,
               importance = rel.inf) %>%
      as_data_frame()

    # no need to return this info
    # res <- x
    # class(res) <- c("imp_tbl", class(res))
    # return(res)
    return(x)
}
#================
# random forests
#================

#' @export
importance_table.randomForest <- function(x){

      # get the names of the variables used
      variable <- importance(x) %>%
        row.names %>%
        data.frame(variable = .)

      pt1 <- importance(x) %>%
        as.data.frame(row.names = F) %>%
        as_data_frame

      x <- bind_cols(variable,
                     pt1) %>%
        as_data_frame

      # no need to return this info
      # res <- x
      # class(res) <- c("imp_tbl", class(res))
      # return(res)
      return(x)

}


#============= caret

#' @export

importance_table.train <- function(x){

  x <-
  varImp(x)$importance %>%
    data.frame(variable = row.names(.),
               importance = .,
               row.names = NULL) %>%
    rename(importance = Overall) %>%
    as_data_frame()

  # no need to return this info
  # res <- x
  # class(res) <- c("imp_tbl", class(res))
  # return(res)
  return(x)


}


# future code for gbm objects, not gbm.step...
## new method for gbm to get importance value for .gbm methods (not gbm.step)
#
# view_importance <- function(x){
#
#   relative.influence(x) %>%
#     as.data.frame %>%
#     data.frame(importance = .[,1],
#                variable = row.names(.),
#                row.names = NULL) %>%
#     select(variable,
#            importance) %>%
#     arrange(-importance)
#
