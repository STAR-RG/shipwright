import re
from termcolor import colored
SHOULD_PRINT = False


def is_external_failure(outputlog):  # messagemend
    regex = re.compile("repository \'.*\' not found")
    match = regex.search(outputlog)
    if (match is not None) or ("could not read" in outputlog and "No such device or address" in outputlog) \
            or ("Could not read from remote repository" in outputlog) or ("remote error: access denied" in outputlog) \
            or "Remote branch  not found in upstream origin" in outputlog:
        message("Git error: Maybe the url you are using no longer exists")
        return 100
    if " mix" in outputlog and "(Code.LoadError)" in outputlog:
        message(
            "Build error: Problem running mix on Elixir project. Please check stacktrace on log and fix your environment.")
        return 101
    if "tsc" in outputlog and ": error TS" in outputlog:
        message(
            "Compilation error: Problem compiling with TypeScript (tsc). Please check your files.")
        return 102
    if "CMake Error at " in outputlog or "make: ***" in outputlog or "syntax error: unexpected word" in outputlog:
        message(
            "Compilation error: Problem compiling with 'CMake' or 'make'. Please check your files.")
        return 103
    if "npm ERR!" in outputlog:
        message("NPM Error. Maybe in command `npm install`. Please check your files.")
        return 104
    if "error: Could not compile " in outputlog or 'Build did NOT complete successfully' in outputlog:
        message("Compilation or build problem. Please check the log.")
        return 105
    if ("Traceback (most recent call last):" in outputlog) or (" but the running Python is " in outputlog) \
            or ('ERROR: Command errored out with exit status 1:' in outputlog) or ('Could not find a version that satisfies the requirement' in outputlog) \
            or ('setup.py egg_info failed with error code' in outputlog) or ('There are incompatible versions in the resolved dependencies' in outputlog) \
            or ('error: Setup script exited with' in outputlog):
        message(
            "Error in python files, maybe error on 'pip install' or 'python setup.py install'. Please check stacktrace on log.")
        return 106
    if 'SyntaxError: ' in outputlog:  # for case -> 51038900.out.log
        message(
            "SyntaxError in files, maybe on js file or NPM. Please check stacktrace on log.")
        return 107
    if 'Visit https://yarnpkg.com/en/docs/cli/install for documentation' in outputlog:
        message("YARN Error. Please check your files.")
        return 108

    regex = re.compile("\.go:[0-9]+:[0-9]+:")
    match = regex.search(outputlog)
    if ': unrecognized import path' in outputlog or 'go get: error' in outputlog \
            or ('cannot find package "github.com/' in outputlog and 'go get' in outputlog) \
            or ('error loading module requirements' in outputlog) \
            or ('go: inconsistent vendoring in ') in outputlog \
            or ('godep: Error' in outputlog) \
            or (match is not None):
        message(
            "Go language problem, maybe in 'go get' command, 'go mod download' or 'godep'. Please check your files.")
        return 109
    if 'Testing [FAIL]' in outputlog or "Tests Failed" in outputlog:
        message("Your tests failed. Please check the log.")
        return 110
    if 'wget: server returned error: ' in outputlog or 'wget: unable to resolve host address' in outputlog \
            or "tar: invalid magic" in outputlog or " ERROR 404: Not Found." in outputlog:  # TODO has more, see $> grep "wget: " logs/fail/*
        message(
            "Error in 'wget'. Maybe the url you are using no longer exists. Please check the log.")
        return 111
    if "dependencies couldn't be built" in outputlog:
        message("Some dependency couldn't be built. Please check the log.")
        return 112
    if "Plan construction failed." in outputlog:
        message("Error in a external tool. Please check the log.")
        return 113
    regex = re.compile("curl:\s\([0-9]+\).*")
    match = regex.search(outputlog)
    if match is not None:
        message(
            "Error in curl. Maybe the url you are using no longer exists. Please check the log.")
        return 114
    # for cases in cluster 125
    regex = re.compile("(bundle|rb):[0-9]+:in|.pp:[0-9]+:.*:")
    match = regex.search(outputlog)
    if match is not None:
        message(
            "Error in bundle. Maybe in command `blundle rake`. Please check the log to more infos.")
        return 115
    # cluster 18
    if "gpg: keyserver receive failed:" in outputlog or "gpg: no valid" in outputlog:
        message("Error in gpg")  # TODO improve this message
        return 116
    if "Your requirements could not be resolved to an installable set of packages" in outputlog \
        or "Your lock file does not contain a compatible set of packages." in outputlog \
            or ("Exception" in outputlog and "composer" in outputlog) or "Composer could not find a composer.json" in outputlog:
        message("Php Compose failed to install your requirements")
        return 117

    if "Could not open input file:" in outputlog:
        message("Could not open file, probably your installation is corrupted")
        return 118

    if "fdLock: invalid argument" in outputlog:
        message("Error in cabal update, please check the output")
        return 119
    if "build failed" in outputlog and "cargo" in outputlog:
        message("Error in cargo build,  Please check the log and fix your environment")
        return 120

    if "Maybe you misspelled it?" in outputlog:
        message("Maybe you made a typo")
        return 121

    regex = re.compile("\s\(missing\)")
    match = regex.search(outputlog)
    if (match is not None) or ("Unable to locate package" in outputlog):
        message("The package you tried to install was not found. Maybe it has been replaced or it no longer exists")
        return 122
    if "For more information about the errors" in outputlog:
        message("error during installation, please see the log")
        return 123
    if "'gcc' failed with exit status" in outputlog:
        message('erro in gcc compiler, please see the log')
        return 124
    if "ERROR: lazy loading failed for package" in outputlog:
        message('failed to load package, please see the log')
        return 125
    if "does not have a Release file" in outputlog:
        message('probably the version of the base image you use is at the end of the line (EOF) please consider updating')
        return 126
    if "This may mean that the package is missing" in outputlog:
        message(
            'a package you are trying to install is deprecated or no longer exists please see the log')
        return 127
    if "Failed to download metadata" in outputlog:
        message("Failed to download, are you using an old version?")
        return 128
    if "zip: stdin: not in gzip" in outputlog:
        message(
            "you are trying to unzip a broken file, probably the download source has gone down")
        return 129

    if ("Error:  Dependencies missing in" in outputlog) or ("TypeError:" in outputlog) \
            or (" conflicts for:\\" in outputlog) or (" certificate verify failed " in outputlog)\
            or ("ResolvePackageNotFound" in outputlog):
        message("error during conda process, please check the output")
        return 130
    if ' exec user process caused \"exec format error' in outputlog:
        message("The architecture of the image base used in the Dockerfile, does not match the one of your system, see: https://stackoverflow.com/a/63020738")
        return 131

    return False


def is_external_failure_outputerror(outputerror):

    if "error during connect: Post" in outputerror:
        message("ERROR: Maybe you Dockerfile is not valid")
        return 201

    if re.match(r"The command '\/bin\/sh -c pip install -r .*.txt' returned a non-zero code:", outputerror) is not None \
            or ("The command '/bin/sh -c python3 setup.py install' returned a non-zero code:" in outputerror):
        message(
            "Error in python files, maybe error on 'pip install'. Please check stacktrace on log.")
        return 106

    if re.match("The command '/bin/sh -c go (install|get) .*/.*/.+' returned a non-zero code:", outputerror) is not None:
        message(
            "Go language problem, maybe in 'go get' command. Please check your files.")
        return 109

    if ("unauthorized: access to the requested resource is not authorized" in outputerror) or \
            ("no matching manifest for " in outputerror and "in the manifest list entries" in outputerror) or \
            ("manifest for " in outputerror and "not found" in outputerror) or \
            ("Get" in outputerror and ": no basic auth credentials" in outputerror) or \
            ("unauthorized: authentication required" in outputerror) or \
            ("unauthorized: You don't have the needed permissions" in outputerror) or \
            ("Get" in outputerror and "dial tcp" in outputerror):
        message(
            "the base image repository no longer exists or a `docker login` is required")
        return 202

    if "No image was generated. Is your Dockerfile empty" in outputerror:
        message("ERROR: maybe you are using the `FROM` command in the wrong way")
        return 203

    if "invalid reference format" in outputerror:
        if "repository name must be lowercase":
            message("Problems with the comannd `FROM`, maybe the name is wrong")
            return 203
        else:
            message(
                "Refernecie error: you have not initialized or passed the value to the `ARG` command and are using this variable.")
            return 204
    if "request canceled while waiting for connection" in outputerror or "The command '/bin/sh -c nuget restore -NonInteractive' returned a non-zero code: 1" in outputerror:
        message(
            "Error in command `FROM` maybe the server of image base no longer exists, please check.")
        return 205
    if "ADD failed: failed to GET" in outputerror:
        message("ADD command fails: the URL or file passed probably no longer exists")
        return 206
    if "Error response from daemon: the Dockerfile" in outputerror and "cannot be empty" in outputerror:
        message("ERROR: your dockerfile is probably empty")
        return 207
    if re.search("swift build (--configuration|-c) release' returned a non-zero code:", outputerror) is not None or \
            "The command '/bin/sh -c swift build' returned a non-zero code: 1" in outputerror:
        message("Error in swift build, please check the output")
        return 208
    if "The command '/bin/sh -c cabal update' returned a non-zero code:" in outputerror:
        message("Error in cabal update, please check the output")
        return 119
    if "Error response from daemon: No build stage in current context" in outputerror:
        message("Error: the first non-comment line of your Dockerfile must be the FROM")
        return 209
    if "Error response from daemon: Dockerfile parse error" in outputerror and "Unknown flag" in outputerror:
        message("Maybe you are using a experimental fature for docker?. Note: experimental fatures are not supported \
        on all versions of docker")
        return 210
    if "Error response from daemon:" in outputerror and "FROM requires either" in outputerror:
        message("the FROM command is wrong, please fix it")
        return 211
    if "The command '/bin/sh -c go build .' returned a non-zero code:" in outputerror:
        message("Error to build with the 'go build'")
        return 212
    if "failed to process" in outputerror:
        message("Error when processing your Dockerfile, is there any wrong command?")
        return 213
    if "OCI runtime create failed:" in outputerror:
        message("expect a build argument to be supplied, but not received. Ideally we suggest that you do not create \
            your Dockerfile waiting for arguments")
        return 214
    if "The command '/bin/sh -c docker-php-ext-install" in outputerror and "returned a non-zero code: 1" in outputerror:
        message(
            "Error installing packages with docker-php-ext-install, check output")
        return 215
    if "The command '/bin/sh -c stack build' returned a non-zero code: 1" in outputerror \
            or "The command '/bin/sh -c stack setup' returned a non-zero code: 1" in outputerror:
        message(
            "You are having errors when compiling the files or when installing packages using stack")
        return 216

    if "The command '/bin/sh -c dotnet restore' returned a non-zero code: 1" in outputerror:
        message("Erro with dotnet, are you using the correct version of dotnet?")
        return 217
    if "returned a non-zero code: 255" in outputerror:
        message("some executable or script in your project is faulty")
        return 218

    return False


def is_in_whitelist(url):
    '''
    TODO: capture title on URL (as group): it may have useful keys!
    '''
    # stackoverflow
    regex = re.compile("https://stackoverflow.com/questions/\d*/*")
    match = regex.match(url)
    if match is not None:
        return True
    # github
    regex = re.compile("https://github.com/.*/issues/\d*")
    match = regex.match(url)
    if match is not None:
        return True
    # superuser
    regex = re.compile("https://superuser.com/questions/\d*/.*")
    match = regex.match(url)
    if match is not None:
        return True
    # digitalocean
    regex = re.compile("https://www.digitalocean.com/community/questions/.*")
    match = regex.match(url)
    if match is not None:
        return True
    # askubunbtu
    regex = re.compile("https://askubuntu.com/questions/\d*/.*")
    match = regex.match(url)
    if match is not None:
        return True
    # unixstackexchange
    regex = re.compile("https://unix.stackexchange.com/questions/\d*/.*")
    match = regex.match(url)
    if match is not None:
        return True
    # forums centOS
    regex = re.compile("https://forums.centos.org/viewtopic.php.*")
    match = regex.match(url)
    if match is not None:
        return True
    # superuser
    regex = re.compile("https://superuser.com/questions/\d*/.*")
    match = regex.match(url)
    if match is not None:
        return True

    # superuser
    regex = re.compile("https://www.reddit.com/r/.*")
    match = regex.match(url)
    if match is not None:
        return True

    # if none of those cases
    return False


def check_have_silent(outputlog):
    # geting the last command
    last_command = ""
    regex = re.compile("Step [0-9]+/[0-9]+")
    lines = outputlog.splitlines()
    for line in reversed(lines):
        match = regex.match(line)
        if match is not None:
            last_command = line
            break

    # check if have silent command
    if "--silent" in last_command or ("wget" in last_command and "-q" in last_command):
        print(colored(
            "Warning: the last command has a tag for silence. Please remove and run again.", "red"))
        return True


def message(m):
    if SHOULD_PRINT:
        print(colored(m, "green"))
