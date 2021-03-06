from sys import argv
import json
import csv
import os
import re
import tqdm
from config import SHOULD_PRINT
from utils import is_external_failure
from utils import is_external_failure_outputerror
import keywords
from query import search_strings
from query import search
from transform import transform
keywords.read_files = False
results = []
pattern_clusters = []
cob = 0
total = 0
results_sum = {'count_rec': 0, 'count_fix': 0, 'count_uknow': 0}


def salve_results(id, count_rec, count_fix, count_uknow, l):
    global total
    global cob
    global results_sum
    results_sum['count_rec'] += count_rec
    results_sum['count_fix'] += count_fix
    results_sum['count_uknow'] += count_uknow

    cob += count_fix + count_rec
    total += l

    count_rec = round(count_rec/l, 2)
    count_fix = round(count_fix/l, 2)
    count_uknow = round(count_uknow/l, 2)

    res = {'id': id, 'rec': count_rec, 'fix': count_fix,
           'uknow': count_uknow, 'size': l}
    results.append(res)


def check_shipwright(cluster, id, progress=False):
    if SHOULD_PRINT:
        print(f"cluster id: {id}")
    l = len(cluster)
    count_rec = 0
    count_fix = 0
    count_uknow = 0
    pattern_set = set()
    cluster_iter = (
        tqdm.tqdm(cluster, desc='Processing:>') if progress else cluster
    ) 
    for c in cluster_iter:
        rid = c['repo_id'] if 'repo_id' in c else c['meta']['repo_id']
        hurl = c['html_url'] if 'repo_id' in c else c['meta']['html_url']
        if SHOULD_PRINT:
            print('--*--\n%s' % c['html_url'])
        outputlog = c["raw_stdout_log"]
        outputerror = c["raw_stderr_log"]
        s_string = search_strings(keywords.keys(c))
        if SHOULD_PRINT:
            print(f'string: {s_string}')

        cod_transform = transform(s_string, c['raw_dockerfile'],
                                  rid, c['raw_stdout_log'], hurl)
        cod_exter = is_external_failure(outputlog)
        cod_exter_error = is_external_failure_outputerror(outputerror)

        if cod_transform:
            count_fix += 1
            pattern_set.add(cod_transform)
        elif cod_exter:
            count_rec += 1
            pattern_set.add(cod_exter)
        elif cod_exter_error:
            count_rec += 1
            pattern_set.add(cod_exter_error)
        elif "RUN exit 1" in outputlog:
            count_rec += 1
            pattern_set.add(200)

        else:
            if SHOULD_PRINT:
                print("nao entrou %d" % rid)
            count_uknow += 1
    pattern_clusters.append(len(pattern_set))

    salve_results(id, count_rec, count_fix, count_uknow, l)


def read_json(file):
    with open(file) as json_file:
        # data = list of dict --> filename: str, search_string: str, urls: list of str
        cluster = json.load(json_file)
        return cluster


def print_artefact_results():
    print('  + Done!\nResults:')
    perc = cob/total * 100
    print('  + Total Dockerfiles: %d.\n  + Shipwright coverage: %d (%.2f %%).' %
          (total, cob, perc))
    c_fix = results_sum["count_fix"]
    c_rec = results_sum["count_rec"]
    c_unk = results_sum["count_uknow"]

    p_fix = c_fix / total * 100
    p_rec = c_rec / total * 100
    p_unk = c_unk / total * 100

    print('  + Repairs: %d (%.2f%%).\n  + Suggestions: %d (%.2f%%).\n  + Unknown: %d (%.2f%%).' %
          (c_fix, p_fix, c_rec, p_rec, c_unk, p_unk))


def main():
    for i in range(145):
        if i == 0:
            continue
        cluster = read_json(f'/app/data/clustered-data/k{i}.json')
        check_shipwright(cluster, i)

    print_artefact_results()
    # print(f'cob{cob}. total {total}')
    # print(f'results_sum {results_sum}')
    # new_print()
    # save_overleaf_new(results)
    print('-------------\nResults by cluster:')
    new_print()
    print('-------------')
    exit(0)
    # exit(0)
    # print_pattern_clusters()
    # exit(0)
    # print_his()
    # exit(0)
    save_overleaf(results)
    exit(0)
    with open('results_paper.csv', 'w') as f:
        w = csv.DictWriter(f, results[0].keys())
        w.writeheader()
        for r in results:
            r['id'] += 1
            w.writerow(r)


def experiment():  # rq4
    cases = read_json('../srcCompletude/analyse.json')
    check_shipwright(cases, 999)
    print_artefact_results()
    # print(f'cob{cob}. total {total}')
    # print(f'results_sum {results_sum}')


def rq3_3():
    print('Loading data...')
    data = read_json('/not-in-clusters.json')
    print('  + Done!')
    check_shipwright(data, -999, progress=True)
    print_artefact_results()
    # print(f'cob{cob}. total {total}')
    # print(f'Total Dockerfiles: {total}. Shipwright coverage {cob}')
    # save_overleaf(results)


def get_urls():
    case = read_json(f'k125.json')[0]
    s_string = search_strings(keywords.keys(case))
    urls = search(s_string, 10)
    print(urls)


def print_pattern_clusters():
    for r in pattern_clusters:
        print(r)


def print_his():
    for r in results:
        print("%d" % ((r['rec']*100) + (r['fix']*100)))


def save_overleaf(results):
    # Distribution of percentages of categories covered in Dockerfiles
    print_overleaf("uknow")
    print_overleaf("rec")
    print_overleaf("fix")


def print_overleaf(name):
    print(f"% {name}")
    print('{', end='')
    for i, u in enumerate(results):
        print("(%d, %d) " % (i+1, u[name] * 100), end='')
    print('};\n\n')


def new_print():
    print('cluster\trepairs\tsuggestions\tunknown')
    for i, u in enumerate(results):
        print("%d\t%d\t%d\t%d" %
              (i+1, u['fix'] * 100, u['rec'] * 100, u['uknow'] * 100))


def save_overleaf_new(results):
    # Distribution of percentages of categories covered in Dockerfiles
    print_overleaf_new("uknow")
    print_overleaf_new("rec")
    print_overleaf_new("fix")


def print_overleaf_new(name):
    print(f"% {name}")
    print('{', end='')
    for i, u in enumerate([32, 34, 45, 46, 47, 70, 96, 99, 115, 39, 97, 120, 121, 116, 60, 125, 33, 36, 53, 119, 74, 130, 114, 44, 129, 94, 118, 123, 107, 48, 69, 98, 117, 79, 132, 63, 65, 113, 131, 38, 55, 66, 57, 88, 137, 89, 85, 67, 103, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 27, 28, 30, 31, 35, 40, 41, 43, 52, 58, 59, 62, 68, 71, 73, 76, 81, 84, 86, 87, 91, 93, 95, 100, 101, 102, 105, 106, 108, 109, 110, 111, 112, 124, 127, 128, 134, 144, 140, 49, 7, 90, 23, 133, 92, 72, 78, 82, 42, 50, 61, 75, 77, 141, 126, 142, 143, 104, 138, 25, 83, 51, 56, 135, 136, 139, 37, 29, 80, 26, 64, 54, 122]):
        print("(%d, %d) " % (i+1, results[u-1][name] * 100), end='')
    print('};\n\n')


if __name__ == "__main__":
    if len(argv) == 2:
        EXPERIMENT = argv[1]
        if EXPERIMENT == "clustered":
            print("Running on clustered data:")
            SAVE_DOCKER_FIX = False
            main()
        elif EXPERIMENT == "non-clustered":
            print("Running on non-clustered data:")
            rq3_3()
        # elif EXPERIMENT == "rq4":
        #    print("Running experiment")
        #    experiment()
        else:
            print("Unknown EXPERIMENT")
    else:
        print("Argument Error: please read the README.md")
        exit(1)
