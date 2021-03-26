import random
import string
import pathlib
import re


''' 
 Python implementation of ddmin algorithm, originally written by
 Rahul Gopinath. https://rahul.gopinath.org/post/2019/12/03/ddmin/ 
'''

def remove_check_each_fragment(instr, start, part_len, causal):
    for i in range(start, len(instr), part_len):
        stitched =  instr[:i] + instr[i+part_len:]
        if causal(stitched): return i, stitched
    return -1, instr

# iterative ddmin implementation
def ddmin(cur_str, causal_fn):
    start, part_len = 0, len(cur_str) // 2
    while part_len >= 1:
        start, cur_str = remove_check_each_fragment(cur_str, start, part_len, causal_fn)
        if start != -1:
            if not cur_str: return ''
        else:
            start, part_len = 0, part_len // 2
    return cur_str

# recursive implementation
max = 5 # -marcelo
def ddrmin(cur_str, causal_fn, pre='', post='', stop_on_max=False, stop_on_first=False):
    global max # -marcelo
    if stop_on_max and max == 0: return cur_str # to avoid google blocking search -marcelo
    max = max - 1 # -marcelo
    if len(cur_str) == 1: return cur_str    
    part_i = len(cur_str) // 2
    string1, string2 = cur_str[:part_i], cur_str[part_i:]
    if causal_fn(pre + string1 + post):
        if stop_on_first: return pre + string1 + post # success => stop -marcelo
        return ddrmin(string1, causal_fn, pre, post, stop_on_max=stop_on_max, stop_on_first=stop_on_first)
    elif causal_fn(pre + string2 + post):
        if stop_on_first: return pre + string2 + post # success => stop -marcelo
        return ddrmin(string2, causal_fn, pre, post, stop_on_max=stop_on_max, stop_on_first=stop_on_first)
    s1 = ddrmin(string1, causal_fn, pre, string2 + post, stop_on_max=stop_on_max, stop_on_first=stop_on_first)
    s2 = ddrmin(string2, causal_fn, pre + s1, post, stop_on_max=stop_on_max, stop_on_first=stop_on_first)
    return s1 + s2
   
## these are predicate functions used at different ddmin examples.
## this function is passed around as argument on the ddmin algo.
count = 0
def test(s):
    global count
    count = count + 1
    #print("%s %d" % (s, len(s)))
    return set('()') <= set(s)

def testList(inputs):
    global count
    count = count + 1
    res = any('()' in t for t in inputs)
    return res


if __name__ == "__main__":
    ## example of use of ddmin
    # options = string.digits + string.ascii_letters + string.punctuation
    # inputs = ''.join(random.choices(options, k=1024))
    # assert test(inputs)
    # #solution = ddmin(inputstring, test)
    # max = 10
    # solution = ddrmin(inputs, test, stop_on_max=True)
    # print(solution)
    # print("number of tests %s" %


    # using vectors instead of string
    randomstr = "Before Python 3.6, you had two main ways of embedding Python expressions inside string literals for formatting: %-formatting and str.format(). You’re about to see how to use them and what their limitations are."
    inputs = randomstr.split(" ")
    assert testList(inputs)    
    solution = ddrmin(inputs, testList, pre=[], post=[])
    print("number of tests %s" % count)
    print(solution)
