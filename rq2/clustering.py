#!/usr/bin/env python3

import gzip
import hdbscan
import json
import numpy as np
import os
import sys
import tqdm

from sentence_transformers import SentenceTransformer

DATA_PREFIX=(
    os.environ['DATA_PREFIX'] if 'DATA_PREFIX' in os.environ else '/app/data'
)

print('Loading gzipped data...')
data = []
for file in tqdm.tqdm(os.listdir(DATA_PREFIX + '/for-clustering'), desc="Loading:>"):
    with gzip.GzipFile(DATA_PREFIX + '/for-clustering/' + file, 'r') as fin:
        data.append(json.loads(fin.read().decode('utf-8')))
print('  + Done!')

data = sorted(data, key=lambda x: x['clean_stderr_log'])

print('Printing details:')
print('  + Number of records: {}'.format(len(data)))
print('  + Available fields:')
for key in data[0].keys():
    print('    + data[n].{}'.format(key))
print('  + Example of pre-processed data we used for clustering:\n    {}'.format(data[0]['clean_stderr_log']))

if len(sys.argv) > 1 and sys.argv[1] == '--do-clustering':
    print('WARNING: doing clustering (very slow)', flush=True)
    print('Loading model...')
    model = SentenceTransformer('bert-large-nli-stsb-mean-tokens')
    print('  + Done!')

    print('Embedding pre-processed error logs...')
    embeddings = {}
    for row in tqdm.tqdm(data, desc="Embedding:>"):
        embeddings[f"{row['meta']['repo_name']}@{row['meta']['repo_commit']}"] = \
            model.encode(' '.join(row['clean_stderr_log']))
    print('  + Done!')

    print('Starting grid search over HDBSCAN params:')
    MIN_CLUSTER = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
    MIN_SAMPLES = [1,2,3,4,5,6,7,8,9,10]

    counts = []
    for min_c in tqdm.tqdm(MIN_CLUSTER, desc="Searching:>"):
        print("  + min_cluster:={}".format(min_c))
        for min_s in MIN_SAMPLES:
            print("    + min_sample:={}".format(min_s))
            clusterer = hdbscan.HDBSCAN(min_cluster_size=min_c, min_samples=min_s)
            cluster_labels = clusterer.fit_predict(list([ x for x in embeddings.values() ]))
            count = sum([ 1 if x != -1 else 0 for x in cluster_labels ])
            print("      - num_clusters_generated:={}".format(count))
            counts.append(count)
