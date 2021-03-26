from sys import path
from sys import argv
from query import search_strings

import keywords
SHOULD_PRINT = True


def read_log(fname):
    with open(f'../{project}/{fname}') as f:
        return f.read()


if __name__ == "__main__":
    project = "project"  # argv[1]
    out = {}
    out["raw_stdout_log"] = read_log("out.log")
    out["raw_stderr_log"] = read_log("error.log")
    s_string = search_strings(keywords.keys(out))
    # line 64 of https://github.com/STAR-RG/shipwright/blob/main/rq3/shipwright.py
    if SHOULD_PRINT:
        print(f'string: {s_string}')
