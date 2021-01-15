# Broken Dockerfiles and Existing Tools

```
How prevalent are Dockerfile build failures in projects that use Docker on GitHub? Can existing (static) tools identify the failure-inducing issues within these broken files?
```

Here, we reproduce results related to RQ1 in our paper. In particular, we include scripts to calculate the percentage of build failures in the projects we analyzed. Furthermore, we provide scripts for running two pre-existing (static) Dockerfile analysis tools and post-processing the output to look for _build failure related_ issues. This is an important step: as most of the warnings produced by static tools will be related to, more generally, Dockerfile _smells_ (that is, violations of best practices which may result in increased image size or insecure containers, for instance).

## Running Binnacle and Hadolint

Using the `./generate.sh` script we can run `binnacle` and `hadolint` on the `./data/broken-dockerfiles` repository to see which broken files are flagged by either tool. **This process is very time consuming.**

We've, in addition to providing the original tooling, simply included the results generated by that script: `results-binnacle.txt` and `results-hadolint.txt`. These result files are used by `analyze.sh` to produce the percentages that we give in our paper to answer RQ1.
