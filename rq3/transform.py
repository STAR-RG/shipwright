import csv
import json
import os
import re
import copy
from pathlib import Path
from config import SHOULD_PRINT

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = HERE + "/../"
FIXED = BASE + "FIXED/"
cOUNT = 0
SAVE_DOCKER_FIX = False


def read_json(file):
    with open(file) as json_file:
        # data = list of dict --> filename: str, search_string: str, urls: list of str
        data = json.load(json_file)
        return data


def read_dockerfile(filename):
    file = BASE + 'data_verify/' + filename
    with open(file, encoding="utf8", errors='ignore') as f:
        lines = f.readlines()
        return lines


def read_csv(file):
    mycsv = open(file, 'r')
    reader = csv.DictReader(x.replace('\0', '') for x in mycsv)
    dict_list = []
    for line in reader:
        dict_list.append(line)
    return dict_list


def save_docker_fix(filename, lines, dir=''):
    global git
    if not SAVE_DOCKER_FIX:
        return

    dirname = f'{FIXED}{dir}'
    Path(dirname).mkdir(parents=True, exist_ok=True)
    with open(f'{dirname}{filename}.git', "w") as f:
        f.write(git)

    filename = str(filename)
    if not filename.endswith(".Dockerfile"):
        filename = filename + ".Dockerfile"

    if os.path.isfile(FIXED + dir + filename):
        return
    message(filename)
    with open(FIXED + dir + filename, "w") as f:
        f.write('\n'.join(lines))


def transform_1(filename, lines):
    # change the image to ubuntu:18.04
    pos = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):
            pos = i
            break
    if pos == None:
        message("Could not find %s" % filename)
        return
    lines[pos] = "FROM ubuntu:18.04\n"
    save_docker_fix(filename, lines, '1/')


def transform_1_2(filename, lines):
    # change the image to ubuntu:18.04
    pos = None
    pos_word = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):
            pos = i
        if "python-pip" in line:
            pos_word = i
            break

    if pos == None:
        message("Could not find %s" % filename)
        return

    lines[pos_word] = lines[pos_word].replace('python-pip', '')

    new_commands = 'ARG DEBIAN_FRONTEND=noninteractive\n' + \
        'RUN apt-get update -y' + \
        'RUN apt-get -y install python2 curl software-properties-common\n' + \
        'RUN add-apt-repository universe\n' + \
        'RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py\n' + \
        'RUN python2 get-pip.py'
    new_lines = lines[:pos+1] + \
        [new_commands] + lines[pos+1:]

    save_docker_fix(filename, new_lines, '1_2/')


def transform_2(filename, lines, group):
    pos = None
    new_version = group.split(' ')[-1]
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM RUBY"):
            pos = i
            break
    if pos == None:
        message("Could not find %s" % filename)
        return
    a = ""
    if "alpine" in ' '.join(lines):  # check if is a alpine version
        a = "-alpine"
    lines[pos] = "FROM ruby:" + new_version + a
    save_docker_fix(filename, lines, '2/')


def transform_3(filename, lines):
    # after 'FROM' add a new command 'RUN'
    pos = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):
            pos = i
            break
    new_lines = lines[:pos+1] + \
        ["RUN yum install -y yum-plugin-ovl\n"] + lines[pos+1:]
    # save_docker_fix(filename, new_lines, '3/')


def transform_4(filename, lines, group):  # 51089865
    # rename 'libpng12-dev' to 'libpng-dev'
    package = group.split(' ')[1].replace("'", "")
    new_packages = {'python-software-properties': 'software-properties-common',
                    'python-imaging': 'python-pil',
                    'libpng12-dev': 'libpng-dev',
                    'openjdk-7-jre': 'openjdk-8-jre',
                    'libreadline': 'libreadline-dev',
                    }
    try:
        new_package = new_packages[package]
    except KeyError:
        message('WARNING: file: %s package is not defined: %s' %
                (filename, package))
        return

    pos = None
    for i, line in enumerate(lines):
        if package in line:
            pos = i
            break
    if pos == None:
        message("Could not find package: %s" % filename)
        return
    message(filename)
    lines[pos] = lines[pos].replace(package, new_package)
    save_docker_fix(filename, lines, '4/')


def transform_5(filename, lines, raw_dockerfile, search_string):
    is_alpine = "alpine" in raw_dockerfile
    new_libs = {'npm': 'npm'}
    new_libs_alpine = {'npm': 'nodejs-npm', 'pip3': 'py-pip'}
    log_lib = search_string.split(':')[-2].strip()
    # for cases like ./configure: not found Docker
    if '/' in log_lib or 'cd' in log_lib or log_lib.endswith('.sh') or 'sudo' in log_lib:
        message('EXTERNAL FAILURE: %s -> %s' % (filename, log_lib))
        return
    if is_alpine:
        new_libs = {**new_libs, **new_libs_alpine}
        new_code = 'RUN apk add --no-cache '
    else:
        # TODO find to agt-get and add more this
        new_code = 'RUN apt-get -y update && apt-get -y install '

    if log_lib in new_libs.keys():
        lib = new_libs[log_lib]
        new_code += lib + '\n'
    else:
        lib = log_lib
        new_code += lib + '\n'

    # finding 'from'
    pos = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM "):
            pos = i
            break
    if pos == None:
        message("Could not find 'from' %s" % filename)
        return
    new_lines = lines[:pos+1] + [new_code] + lines[pos+1:]
    message('new code: %s -> %s' % (new_code, filename))
    save_docker_fix(filename, new_lines, '5/')


def transform_6(filename, lines, path='6/'):
    pos = None
    new_image = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):
            image = line.replace('\t', ' ').split(' ')[-1].split(':')[0]
            if image == 'ubuntu':
                new_image = 'ubuntu:18.04'
            elif image == 'debian':
                new_image = 'debian:10'
            else:
                message(f'INVALID IMGAEEEE {image}. {filename}')
            pos = i
            break
    if pos == None or new_image == None:
        message("Could not find %s" % filename)
        return

    lines[pos] = "FROM " + new_image + "\n"

    # to avoid problems with apt-get and is a good practice in docker
    lines_join = ''.join(lines)
    if "DEBIAN_FRONTEND" not in lines_join:
        code = "ARG DEBIAN_FRONTEND=noninteractive\n"
        pos += 1
        lines = lines[:pos] + [code] + lines[pos:]

    if "apt-key" in lines_join and "gnupg2" not in lines_join:
        code = "RUN apt-get -y update && apt-get install -y gnupg2"
        pos += 1
        lines = lines[:pos] + [code] + lines[pos:]

    save_docker_fix(filename, lines, path)


def transform_7(filename, lines, group):
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):

            pos = i
            break
    if pos == None:
        message("Could not find %s" % filename)
        return
    version = group.split(' ')[-1]
    new_image = "ruby:" + version
    lines[pos] = "FROM " + new_image + "\n"
    save_docker_fix(filename, lines, '7/')


def transform_8(filename, lines):
    # after 'FROM' add a new command 'ENV'
    pos = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):
            pos = i
            break
    new_lines = lines[:pos+1] + ["ENV LANG C.UTF-8\n"] + lines[pos+1:]
    save_docker_fix(filename, new_lines, '8/')


def transform_8_2(filename, lines):
    # after 'FROM' add a new command 'ENV'
    pos = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):
            pos = i
            break
    lines[pos] = "FROM ruby:2.5.8\n"
    save_docker_fix(filename, lines, '8_2/')


def transform_9(filename, lines):
    for i, line in enumerate(lines):
        if "bzr" in line:
            pos = i
            break
    lines[pos] = lines[pos].replace("bzr", "")
    save_docker_fix(filename, lines, '9/')


def transform_11(filename, lines):
    for i, line in enumerate(lines):
        if line.lower().strip().startswith("run curl -o"):
            pos = i
            break
    if pos == None:
        message("Could not find %s" % filename)
        return

    line = lines[pos].strip()
    line = line[:8] + " -L" + line[8:]
    lines[pos] = line
    save_docker_fix(filename, lines, '11/')


def transform_12(filename, lines):
    pos = None
    for i, line in enumerate(lines):
        if line.upper().startswith("FROM"):
            pos = i
            break
    if pos == None:
        message("Could not find %s" % filename)
        return
    new_commands = "RUN sed -i.bak -r 's/(archive|security).ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list\nRUN apt-get -y update\n"
    new_lines = lines[:pos+1] + [new_commands] + lines[pos+1:]
    save_docker_fix(filename, new_lines, '12/')


def transform13(filename, lines, group, version):
    #python-dev (missing)
    package = group.split(' ')[0]
    new_package = {"python-dev": f"python{version}-dev",
                   "py2-pip": "py3-pip", "python": f"python{version}"}
    if package == "py2-pip" and version == "2":
        return

    pos = None
    for i, line in enumerate(lines):
        if package in line and "from" not in line.lower():
            pos = i
            break
    if pos == None:
        message("Could not find %s" % filename)
        return
    for p in new_package.keys():
        lines[pos] = lines[pos].replace(p, new_package[p])
    if version == '2':
        save_docker_fix(filename, lines, '13/')
    else:
        save_docker_fix(filename, lines, '13_2/')


def transform_15(filename, lines):

    for i, line in enumerate(lines):
        if "pip install" in line and "pip install -U pip" not in line:
            if line.endswith("&& \\"):
                lines[i] = line.replace("&& \\", " --ignore-installed && \\")
            elif line.endswith("\\"):
                lines[i] = line.replace("\\", " --ignore-installed \\")
            else:
                lines[i] = line + ' --ignore-installed '

    save_docker_fix(filename, lines, '15/')


def transform(search_string, lines, filename, log, git_):
    global git
    global cOUNT
    git = git_
    if type(lines) is str:
        raw_dockerfile = lines
        lines = lines.split('\n')

    if 'Unable to locate package python-pip' in log and "ubuntu" in raw_dockerfile:
        transform_1(filename, lines)
        message('Aentrou 1')
        cOUNT += 1
        message(f'AAAA{cOUNT}')
        return 1
    r = re.search('requires (r|R)uby version >= \d\.\d(\.\d|)', log)
    if r is not None:
        transform_2(filename, lines, r.group())
        message('entrou 2')
        return 2
    elif "Rpmdb checksum dCDPT pkg checksums" in search_string:
        # transform_3(filename, lines)
        message('entrou 3')
        return 3
    r = re.search('Package \'.* has no installation candidate', log)
    if r is not None:
        transform_4(filename, lines, r.group())
        message('entrou 4')
        return 4
    elif "conda: not found" in log and "curl" in raw_dockerfile and "conda" in raw_dockerfile:
        message('entrou 11')
        #transform_11(filename, lines)
        return 11
    elif re.match(r'sh:.*:*', search_string) is not None:
        transform_5(filename, lines, raw_dockerfile, search_string)
        message('entrou 5')
        return 5
    elif "Some index files failed download" in search_string:
        transform_6(filename, lines)
        message('entrou 6')
        return 6
    r = re.search("but your Gemfile specified [0-9|\.]+", log)
    if r is not None and "ruby:" in raw_dockerfile.lower():
        message('entrou 7')
        return 7
        # transform_7(filename, lines, r.group())
    elif "invalid byte sequence in US-ASCII" in log and "ruby:" in raw_dockerfile.lower():
        message('entrou 8')
        transform_8(filename, lines)
        transform_8_2(filename, lines)
        return 8
    elif "bzr (missing):" in log:
        message('entrou 9')
        transform_9(filename, lines)
        return 9
    elif "E: Unable to fetch some archives, maybe run apt-get" in log:
        message('entrou 12')
        transform_12(filename, lines)
        return 12

    elif "does not have a Release file" in log:
        message('entrou 14')
        #transform_6(filename, lines, path="13/")

    r = re.search("(python-dev|py2-pip|python) \(missing\)", log)
    if r is not None:
        message('entrou 13')
        lines3 = copy.deepcopy(lines)
        transform13(filename, lines, r.group(), '2')
        transform13(filename, lines3, r.group(), '3')
        return 13

    r = re.search("Cannot uninstall '.*'", log)
    if r is not None:
        transform_15(filename, lines)
        message('entrou 15')
        return 15

    else:
        # message('fail %d' % filename)
        return False


def main():
    # get all search strings
    # data = list of dict --> filename: str, search_string: str, urls: list of str
    # data = read_csv('complete.csv')
    global git
    data = read_json('../TEST/k114.json')
    for d in data:
        dockerfile_lines = d['raw_dockerfile'].split('\n')
        log = d['raw_stdout_log']
        filename = d['repo_id']
        git = d['html_url']
        transform(log, dockerfile_lines, filename, log)


git = ''
from_dict = {}


def getFrom(case_dict):
    global from_dict
    if case_dict['search_string'].startswith("Some index files failed download"):
        filename = (case_dict['filename'])[:-8] + '.Dockerfile'
        lines = read_dockerfile(filename)
        for line in lines:
            if line.strip().upper().startswith("FROM "):
                message(line)
                v = line.split(' ')[-1].split(':')[0]
                try:
                    from_dict[v] += 1
                except Exception as _:
                    from_dict[v] = 1


def message(text):
    if SHOULD_PRINT:
        print(text)


if __name__ == '__main__':
    main()
