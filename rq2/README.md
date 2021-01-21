# Clustering

## Assumptions

If you wish to run things from this directory, you would need `python3` with the following packages installed: `hdbscan sentence-transformers tqdm`. We recommend running this through our top-level directory which utilizes a pre-configured docker container.

## Too Long Didn't Read (TLDR)

We provided the pre-processed form of our broken Dockerfiles in the `./data/for-clustering` directory (one gzipped json file per broken Dockerfile). You can use these files to run your own clustering, or our clustering, or you can use our pre-generated clusters in the `./rq3/Clusters` directory.

To spit out some quick output data (and verify things can run) run `./clustering.py` --- this is quick and should print something like the following:

```
Loading gzipped data...
Loading:>: 100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 5405/5405 [00:15<00:00, 340.25it/s]
  + Done!
Printing details:
  + Number of records: 5405
  + Available fields:
    + data[n].parsed_dockerfile
    + data[n].dirs_in_repo
    + data[n].clean_stderr_log
    + data[n].clean_dockerfile
    + data[n].raw_stdout_log
    + data[n].meta
    + data[n].files_in_repo
    + data[n].raw_stderr_log
    + data[n].raw_dockerfile
    + data[n].clean_stdout_log
  + Example of pre-processed data we used for clustering:
    ['the command / bin / sh c go wrapper download returned a non zero code : 1']
```

## Details

```
Can we cluster build failures on their (likely) root cause?
```

In this question, we sought to understand the efficacy of our clustering approach (HDBSCAN + BERT). To make this more accessible for the artifact, we have included pre-processed data that can be directly fed to the embedding + clustering procedure described in our paper. There are many things one could "tune" in this pipeline---in particular, the preprocessing, tokenization, normalization, model used for embedding, and the clustering hyper-parameters. The `clustering.py` file, when invoked with the `--do-clustering` flag, performs a small grid search over HDBSCAN hyper-parameters as one example of tuning/evaluating clustering.

**NOTE: we do not recommend running `./clustering.py --do-clustering` as part of the artifact evaluation.** The clustering process works best on a GPU enabled machine and takes considerable time (especially searching over hyper-parameters). We've provided this code so others can build on our work---but, in addition, we have simply included the outputs of clustering and the pre-processed data we used to generate clusters so that others can avoid running the actual clustering step (or, if they wish, can build new clustering methodology on similar data).

_NOTE for running locally (not using `./shipwright.sh`): we assume this script runs in a docker container with a specific environment. To override this when running local, you should set the `DATA_PREFIX` environment variable to point to this repositories `./data` directory._
