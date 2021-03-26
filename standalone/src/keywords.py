from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from subprocess import Popen, PIPE
from termcolor import colored
import re
import os
import sys
import nltk
read_files = False
call_tokenize = True
# Creating a list of custom stopwords and adding to stop words
other_stop_words = ["step", "Step", "bin", "sh", "returned", "non", "zero", "code", "manifest", "unknown", "invalid", "reference", "format",
                    "process", "command", "me", "mthe", "for", "from", "0mthe", "91me", "91mE", "...", ":", "-", ".", ")", "(", "]", "[", "91m",
                    "\x1b", "working", "done", "\'", ",", "E", "RUN", "Running", "kB/s", '0m\x1b']

'''
Tokenize input strings and remove stop words
'''


def tokenize(str):
    stop_words = set(stopwords.words('english'))
    word_tokens = word_tokenize(str)
    possible_keys = [w for w in word_tokens if not w in stop_words]
    tmp_keys = [w for w in possible_keys if not w in other_stop_words]
    keys = []

    for w in tmp_keys:
        if re.search('[0-9]+/[0-9]+', w):
            continue  # removing Step status like: 17/25

        w = re.sub('[0-9]+m', '', w)  # 91m, 0m, 91mChecking
        keys.append(w)

    return keys


def read_errors(run_error_lines, last_fifteen, docker_error):
    global call_tokenize

    # checking if the word 'error' is explicit and return
    for l in last_fifteen:
        if 'E: ' in l or 'Error: ' in l or 'ERROR:' in l:
            # check if was Warning too
            warning = [l for l in last_fifteen if "W: " in l]
            if len(warning) > 0:
                # stderror, explict_error + last warning
                return docker_error, l+' '+warning[-1]
            else:
                if "ERROR: unsatisfiable constraints:" in l:
                    # for cases on alpine, geting two lines
                    return docker_error, (l+last_fifteen[last_fifteen.index(l) + 1])
                # stderror, explict_error
                return docker_error, l

    # check if the fault is explicit
    # for example: [91menv: can't execute 'bash': No such file or directory - [91m/bin/sh: pip3: not found
    regex = re.compile("^\x1b\[91m.*:.*")
    for line in last_fifteen:
        match = regex.match(line)
        if match is not None:
            call_tokenize = False   # no call the function 'tokenize'
            return docker_error, line[10:]

    # experiment
    index = 0
    for i, line in enumerate(run_error_lines):
        if line.startswith('\x1b\[91'):
            index = i
            print('OPA Index Mudou')
            break

    # if NOT explicit, filters the output
    run_error = []
    for line in run_error_lines[index:]:
        if line.startswith(" --->") or line.startswith("Removing intermediate") or line.startswith("  Cleanup    : "):
            continue
        run_error.append(line)

    run_error = ' '.join(run_error)
    return docker_error, run_error


'''
Grep for the string err using 4 lines above and below as context
'''


def read_files(fname):
    # read the last line of docker error, the last 20 lines of output and the last 4 lines of output
    docker_error_file = fname[:-7]
    docker_error_file += f'error.log'
    with open(docker_error_file, 'r') as file:
        docker_error = file.read().splitlines()[-1]  # last line

    with open(fname, 'r') as file:
        lines = file.read().splitlines()
        run_error_lines = lines[-4:]  # last 4
        try:
            last_fifteen = lines[-20:]
        except IndexError as _:
            last_fifteen = lines
    return run_error_lines, last_fifteen, docker_error


def grep(fname):

    # fname is a dict
    run_error_lines = fname['raw_stdout_log'].split('\n')[-4:]
    try:
        last_fifteen = fname['raw_stdout_log'].split('\n')[-20:]
    except IndexError as _:
        last_fifteen = fname['raw_stdout_log'].split('\n')
    docker_error = fname['raw_stderr_log'].split('\n')[-1]

    docker_error, run_error = read_errors(
        run_error_lines, last_fifteen, docker_error)
    if "The command '/bin/sh" in docker_error or "The command '/bin/bash" in docker_error:
        return run_error

    return docker_error


def keys(fname):
    global call_tokenize
    call_tokenize = True  # the function read_errors can change the value of this variable
    keys = grep(fname)
    if call_tokenize:
        return tokenize(keys)
    else:
        return [keys]


if __name__ == "__main__":
    print(keys(sys.argv[1]))
    # print(keys("/home/dgs/DockerFixRecom/logs/fail/27457221.out.log"))  # debug mook
    # debug mook
    # print(keys("/home/denini/DockerFixRecom/logs/fail/199264735.out.log"))
