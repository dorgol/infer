% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rep_sample_n.R
\name{rep_sample_n}
\alias{rep_sample_n}
\title{Perform repeated sampling}
\usage{
rep_sample_n(tbl, size, replace = FALSE, reps = 1, prob = NULL)
}
\arguments{
\item{tbl}{Data frame of population from which to sample.}

\item{size}{Sample size of each sample.}

\item{replace}{Should sampling be with replacement?}

\item{reps}{Number of samples of size n = \code{size} to take.}

\item{prob}{A vector of probability weights for obtaining the elements of the
vector being sampled.}
}
\value{
A tibble of size \code{rep} times \code{size} rows corresponding to \code{rep}
samples of size n = \code{size} from \code{tbl}.
}
\description{
\Sexpr[results=rd, stage=render]{lifecycle::badge("questioning")}

Perform repeated sampling of samples of size n. Useful for creating sampling
distributions.
}
\examples{
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggplot2))

# A virtual population of N = 10,010, of which 3091 are hurricanes
population <- dplyr::storms \%>\%
  select(status)

# Take samples of size n = 50 storms without replacement; do this 1000 times
samples <- population \%>\%
  rep_sample_n(size = 50, reps = 1000)
samples

# Compute p_hats for all 1000 samples = proportion hurricanes
p_hats <- samples \%>\%
  group_by(replicate) \%>\%
  summarize(prop_hurricane = mean(status == "hurricane"))
p_hats

# Plot sampling distribution
ggplot(p_hats, aes(x = prop_hurricane)) +
  geom_density() +
  labs(x = "p_hat", y = "Number of samples",
  title = "Sampling distribution of p_hat from 1000 samples of size 50")

}
