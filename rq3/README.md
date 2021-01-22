# Producing Repairs

## Assumptions

For this RQ, we recommend only using the `./shipwright.sh` wrapper in our top-level directory. To run this locally, you'd need the pip packages `google nltk termcolor` and to have run `nltk.download("stopwords")` and `nltk.download("punkt")`. In addition, you'd need to have the path `/not-in-clusters.json` point to the `./data/non-clustered-data/not-in-clusters.json` file and have the path `/app/data/clustered-data` point to the `./data/clustered-data` directory. We do all of this configuration for you if you use the `./shipwright.sh run-rq3` command :) 

## Too Long Didn't Read (TLDR)

We provide the full shipwright tooling in this directory --- this includes scripts we wrote for applying repairs/suggestions, generating search terms from logs, and exploring other one-off experiments (like trying `ddmin`: a technique we decided not to use in our final work).

From the root of this repository, run `./shipwright.sh run-rq3`. This should spit out a bunch of data that looks like the following:

```
Running on clustered data:
  + Done!
Results:
  + Total Dockerfiles: 1814.
  + Shipwright coverage: 1632 (89.97 %).
  + Repairs: 369 (20.34%).
  + Suggestions: 1263 (69.63%).
  + Unknown: 182 (10.03%).
-------------
Results by cluster:
cluster	repairs	suggestions	unknown
1	0	100	0
<rest of the rows elided to keep this short>
-------------
Running on non-clustered data:
Loading data...
  + Done!
Processing:>: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 3586/3586 [00:13<00:00, 267.61it/s]
  + Done!
Results:
  + Total Dockerfiles: 3586.
  + Shipwright coverage: 2324 (64.81 %).
  + Repairs: 652 (18.18%).
  + Suggestions: 1672 (46.63%).
  + Unknown: 1262 (35.19%).
```

## Details

```
How effective is shipwright in producing repairs/suggestions? 

To what extent do repairs/suggestions cover the failures from our dataset?
```

In this question, we were trying to confirm that shipwright, with it's human-in-the-loop process for analyzing clustered (broken) Dockerfiles and generating a database of repairs (and suggestions), could actually solve issues in our ground-truth data. Put another way, the bulk of this question is about measuring how many broken files shipwright can provide a repair for. Since we had both clustered and non-clustered data, the results here are broken out based on whether we are analyzing clustered data (which we used, in an offline phase, to generate repairs) or non-clustered data (which we haven't used to inform any of our repairs/suggestions).

**NOTE: please see the top-level README for instructions on running this.** We've documented this directory to be thorough---but, at the top-level of the repository we provide the tools and configuration for you to invoke these scripts without manual setup (via Docker).

