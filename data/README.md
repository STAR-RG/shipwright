# `./data`

In this directory we have included most of the raw and pre-processed/filtered data we used in our paper.

## `./data/raw-build-results`

This directory includes the (compressed) results from building thousands of Dockerfiles (in context). To view
these results, run `./extract.sh` which will populate the `./data/build-results` folder with uncompressed results.

We hope that this data (build logs / image histories / etc.) will be a valuable addition to the original Dockerfiles
and ASTs released via the `binnacle` artifact.

## `./data/build-results`

This directory should start empty and, after running `./data/raw-build-results/extract.sh`, be populated with many 
sub-directories containing our build results.

## `./data/broken-dockerfiles`

This directory includes the original source of the ~5k broken Dockerfiles we identified and further analyzed. We hope
this data is of use to anyone pursuing source-level Dockerfile repair, or similar ventures. To view more detailed data,
these source-level files can be correlated with full results by matching the file name to a corresponding directory
in the `./data/build-results/*/` folder.

## `./data/for-clustering`

This directory includes the (compressed) pre-processed version of the broken Dockerfiles that we used as input to 
our clustering algorithm (BERT + HDBSCAN). We hope that, by providing the original pre-processed data, others can
build new clustering techniques or refine the clustering approach and parameters.
