import googlesearch
from termcolor import colored
from keywords import keys
import os
from time import sleep
import ddmin
import random
from utils import is_external_failure
from utils import is_external_failure_outputerror
from utils import is_in_whitelist
from utils import check_have_silent

DEBUG = False      # print URLs
RESULT_SET_LEN = 5
NUM_URLS = 10      # number of urls returned by google in one query
NUM_MAX_DDMIN = 5  # maximum number of iterations in ddmin
# for internal control in spreadsheet
HASH_ANALYZED = []
count = 20

is_alpine = False

with open(os.path.dirname(os.path.abspath(__file__)) + '/analyzed.txt', 'r') as file:
    HASH_ANALYZED = file.read().splitlines()


def analyze_dir(logdir):
    global count  # TODO: @Denini, I did not understand why this limit -marcelo #I did this for my internal control when filling out the spreadsheet -denini
    for filename in os.listdir(logdir):
        # not in HASH_ANALYZED:
        if filename.endswith("out.log") and filename.startswith("217892319"):
            if count == 0:
                exit(0)
            fname = os.path.join(logdir, filename)
            analyze_file(fname)


# TODO: @Denini, this should return a list of URLs.
# Now, we are running for its side-effects (print) -marcelo
def analyze_file(fname):
    global count
    print("\n***********\nfile name: ", fname)
    outputlog = ""
    outputlogerror = ""
    with open(fname) as f:
        outputlog = f.read()
    fname_error = fname[:-8] + ".error.log"
    with open(fname_error) as f:
        outputlogerror = f.read()
    # compile error
    if is_external_failure(outputlog) or is_external_failure_outputerror(outputlogerror) or check_have_silent(outputlog):
        return
    check_if_is_alpine(outputlog)
    keywords = keys(fname)
    search_string = search_strings(keywords)
    # misconfiguration
    if("COPY" in search_string or "ADD" in search_string):  # for MISCONFIGURATION
        print(colored(
            "Misconfiguration: Problem with COPY/ADD. Please check your Dockerfile environment.", "green"))
        return

    print("-----> search string: %s\n" % search_string)
    result_set = search(search_string, NUM_URLS)
    if len(result_set) == 0:
        print(colored(
            "Empty result set. This may take a while. Simplifying string with DDMin.", "magenta"))
        # searching for a string with ddmin, but it will stop on first success or in no more than 5 calls
        ddmin.max = NUM_MAX_DDMIN
        keywords = ddmin.ddrmin(keywords, dd_predicate, pre=[], post=[
        ], stop_on_max=True, stop_on_first=True)
        # make final query with results ddmin reports.
        # this could be avoided (as ddmin already made the query) -marcelo
        search_string = search_strings(keywords)
        result_set = search(search_string, NUM_URLS)
        print("-----> NEW search string: %s\n" % search_string)

    # print some output
    if len(result_set) == 0:
        print(colored("Could not find any recommendation URL!", "red"))
    else:
        # @Denini, we may want to sort these URLs based on error.log our out.log.
        # Assuming Google did not do a great job at that task as we needed to
        # trash some keywords. -marcelo
        printResults(result_set)
    count -= 1


'''
this is the predicate used to drive Delta Debugging. 
It checks whether a good search string can be delivered 
from keywords. The answer is yes, if the search API 
answers with 5 or more URLs.
'''


def dd_predicate(keywords):
    # if too smal it can return trash. we want it to return related stuff
    ss = search_strings(keywords)
    result_set = search(ss, NUM_URLS)
    response = len(result_set) >= 5
    if DEBUG:
        print("Search String {0}, Number of results {1}".format(
            ss, len(result_set)))
    return response


def search_strings(keywords):
    global is_alpine
    search_string = " ".join(keywords)
    search_string = search_string + " Docker"
    if is_alpine:
        search_string += " alpine"
    return search_string


def search(search_string, numURLs):
    sleep(random.uniform(10, 20))  # pretending not to be a bot to avoid ban
    user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36"
    tmp_results = googlesearch.search(search_string, tld="com", lang="en",
                                      num=numURLs, start=0, stop=numURLs, pause=5, user_agent=user_agent)
    return filter(tmp_results)


def filter(urls):
    result_list = []
    for url in urls:
        color = "yellow"
        # add url to the result list if domain is white listed
        if is_in_whitelist(url):
            result_list.append(url)
            color = "white"
        if len(result_list) == RESULT_SET_LEN:
            return result_list
        if DEBUG:
            print(colored(url, color))
    return result_list


def check_if_is_alpine(log):
    global is_alpine

    is_alpine = True if "alpine" in log else False


def printResults(urls):
    for u in urls:
        print(colored("    %s" % u, "green"))


if __name__ == "__main__":
    logdir = "/home/denini/DockerFixRecom/logs/fail/"
    # logdir = "debug/"  # add files here for debugging
    analyze_dir(logdir)
