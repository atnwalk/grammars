#
# Copyright 2023 Maik Betka
# Copyright 2021 Prashast Srivastava
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import sys
import re
import copy
import json
from string import ascii_uppercase
from itertools import combinations
from collections import defaultdict

NONTERMINALSET = []
COUNT = 0

def main(grammar_file, out, start):
    grammar = None
    # If grammar file is a preprocessed NT file, then skip preprocessing
    if '.json' in grammar_file:
        with open(grammar_file, 'r') as fd:
            grammar = json.load(fd)
    elif '.g4' in grammar_file:
        with open(grammar_file, 'r') as fd:
            data = fd.readlines()
        grammar = preprocess(data)
    else:
        raise('Unknwown file format passed. Accepts (.g4/.json)')

    with open('debug_preprocess.json', 'w+') as fd:
        json.dump(grammar, fd)
    grammar = remove_unit(grammar) # eliminates unit productions
    with open('debug_unit.json', 'w+') as fd:
        json.dump(grammar, fd)
    grammar = remove_mixed(grammar) # eliminate terminals existing with non-terminals
    with open('debug_mixed.json', 'w+') as fd:
        json.dump(grammar, fd)
    grammar = break_rules(grammar) # eliminate rules with more than two non-terminals
    with open('debug_break.json', 'w+') as fd:
        json.dump(grammar, fd)
    grammar = gnf(grammar)

    # Dump GNF form of the grammar with only reachable rules 
    # reachable_grammar = get_reachable(grammar, start)
    # with open('debug_gnf_reachable.json', 'w+') as fd:
    #     json.dump(reachable_grammar, fd)
    with open('debug_gnf.json', 'w+') as fd:
        json.dump(grammar, fd)

    grammar["Start"] = [start]
    with open(out, 'w+') as fd:
        json.dump(grammar, fd)

def get_reachable(grammar, start):
    '''
    Returns a grammar without dead rules
    '''
    reachable_nt = set()
    worklist = list()
    processed = set()
    reachable_grammar = dict()
    worklist.append(start)

    while worklist:
        nt = worklist.pop(0)
        processed.add(nt)
        reachable_grammar[nt] = grammar[nt]
        rules = grammar[nt]
        for rule in rules:
            tokens = gettokens(rule)
            for token in tokens:
                if not isTerminal(token):
                    if token not in processed:
                        worklist.append(token)
    return reachable_grammar


# def gettokens(rule):
#     pattern = re.compile("([^\s\"\']+)|\"([^\"]*)\"|\'([^\']*)\'")
#     return [matched.group(0) for matched in pattern.finditer(rule)]


def gettokens(txt):
    tokens = []
    while len(txt) > 0:
        txt = txt.lstrip()
        if txt.startswith("'"):
            offset = 1
            end = -1
            while True:
                end = txt[offset:].index("'")
                offset += end + 1
                count = 0
                for i in range(offset - 2, 0, -1):
                    if txt[i] == '\\':
                        count += 1
                    else:
                        break
                if count % 2 == 1:
                    continue
                break
            tokens.append(txt[:offset])
            txt = txt[offset:]
            continue
        match = re.search(r'^([A-Za-z][A-Za-z0-9_]*)', txt)
        if match:
            tokens.append(match.group(1))
            txt = txt[len(match.group(1)):]
            continue
        else:
            raise Exception(f"token match must've failed for txt: {txt}")
    return tokens

def gnf(grammar):
    old_grammar = copy.deepcopy(grammar)
    new_grammar = defaultdict(list)
    isgnf = False
    while not isgnf:
        for lhs, rules in old_grammar.items():
            for rule in rules:
                tokens = gettokens(rule) 
                if len(tokens) == 1 and isTerminal(rule):
                    new_grammar[lhs].append(rule)
                    continue
                startoken = tokens[0]
                endrule = tokens[1:]
                if not isTerminal(startoken):
                    newrules = []
                    extendrules = old_grammar[startoken]
                    for extension in extendrules:
                        temprule = endrule[:]
                        temprule.insert(0, extension)
                        newrules.append(temprule)
                    for newnew in newrules:
                        new_grammar[lhs].append(' '.join(newnew))
                else:
                    new_grammar[lhs].append(rule)
        isgnf = True
        for lhs, rules in new_grammar.items():
            for rule in rules:
                # if "\' \'" or isTerminal(rule):
                tokens = gettokens(rule)
                if len(tokens) == 1 and isTerminal(tokens[0]):
                    continue
                startoken = tokens[0]
                if not isTerminal(startoken):
                    isgnf = False
                    break
        if not isgnf:
            old_grammar = copy.deepcopy(new_grammar)
            new_grammar = defaultdict(list)
    return new_grammar
                

def preprocess(data):
    productions = []
    production = []
    for line in data:
        if line != '\n': 
            production.append(line)
        else:
            productions.append(production)
            production = []
    final_rule_set = {}
    for production in productions:
        rules = []
        init = production[0]
        nonterminal = init.split(':')[0]
        rules.append(strip_chars(init.split(':')[1]).strip('| '))
        for production_rule in production[1:]:
            rules.append(strip_chars(production_rule.split('|')[0]))
        final_rule_set[nonterminal] = rules
    # for line in data:
    #     if line != '\n':
    #         production.append(line)
    return final_rule_set

def remove_unit(grammar):
    nounitproductions = False 
    old_grammar = copy.deepcopy(grammar)
    new_grammar = defaultdict(list)
    while not nounitproductions:
        i = 0
        for lhs, rules in old_grammar.items():
            i += 1
            for rhs in rules:
                # Checking if the rule is a unit production rule
                if len(gettokens(rhs)) == 1:
                    if not isTerminal(rhs):
                        new_grammar[lhs].extend([rule for rule in old_grammar[rhs]])
                    else:
                        new_grammar[lhs].append(rhs)
                else:
                    new_grammar[lhs].append(rhs)
        # Checking there are no unit productions left in the grammar 
        nounitproductions = True
        for lhs, rules in new_grammar.items():
            for rhs in rules:
                if len(gettokens(rhs)) == 1:
                    if not isTerminal(rhs):
                        nounitproductions = False
                        break
            if not nounitproductions:
                break
        # Unit productions are still there in the grammar -- repeat the process
        if not nounitproductions:
            old_grammar = copy.deepcopy(new_grammar)
            new_grammar = defaultdict(list)
    return new_grammar

def isTerminal(rule):
    # pattern = re.compile("([r]*\'[\s\S]+\')")
    pattern = re.compile("\'(.*?)\'")
    match = pattern.match(rule)
    if match:
        return True
    else:
        return False

def remove_mixed(grammar):
    '''
    Remove rules where there are terminals mixed in with non-terminals
    '''
    new_grammar = defaultdict(list)
    for lhs, rules in grammar.items():
        for rhs in rules:
            # tokens = rhs.split(' ')
            regen_rule = []
            tokens = gettokens(rhs)
            if len(gettokens(rhs)) == 1:
                new_grammar[lhs].append(rhs)
                continue
            for token in tokens:
                # Identify if there is a terminal in the RHS
                if isTerminal(token):
                    # Check if a corresponding nonterminal already exists
                    nonterminal = terminal_exist(token, new_grammar)
                    if nonterminal:
                        regen_rule.append(nonterminal)
                    else:
                        new_nonterm = get_nonterminal()
                        new_grammar[new_nonterm].append(token)
                        regen_rule.append(new_nonterm)
                else:
                    regen_rule.append(token)
            new_grammar[lhs].append(' '.join(regen_rule))
    return new_grammar

def break_rules(grammar):
    new_grammar = defaultdict(list)
    old_grammar = copy.deepcopy(grammar)
    nomulti = False
    while not nomulti:
        for lhs, rules in old_grammar.items():
            for rhs in rules:
                tokens = gettokens(rhs)
                if len(tokens) > 2 and (not isTerminal(rhs)):
                    split = tokens[:-1] 
                    nonterminal = terminal_exist(' '.join(split), new_grammar)
                    if nonterminal:
                        newrule = ' '.join([nonterminal, tokens[-1]])
                        new_grammar[lhs].append(newrule)
                    else:
                        nonterminal = get_nonterminal()
                        new_grammar[nonterminal].append(' '.join(split))
                        newrule = ' '.join([nonterminal, tokens[-1]])
                        new_grammar[lhs].append(newrule)
                else:
                    new_grammar[lhs].append(rhs)
        nomulti = True
        for lhs, rules in new_grammar.items():
            for rhs in rules:
                # tokens = rhs.split(' ')
                tokens = gettokens(rhs)
                if len(tokens) > 2 and (not isTerminal(rhs)):
                    nomulti = False
                    break
        if not nomulti:
            old_grammar = copy.deepcopy(new_grammar)
            new_grammar = defaultdict(list)
    return new_grammar

def strip_chars(rule):
    return rule.strip('\n\t ')

def get_nonterminal():
    global NONTERMINALSET
    if NONTERMINALSET:
        return NONTERMINALSET.pop(0)
    else:
        _repopulate()
        return NONTERMINALSET.pop(0)

def _repopulate():
    global COUNT
    global NONTERMINALSET
    NONTERMINALSET = [f"A{str(i)}" for i in range(COUNT, COUNT+100)]
    # NONTERMINALSET = [''.join(x) for x in list(combinations(ascii_uppercase, COUNT))]
    COUNT += 100

def terminal_exist(token, grammar):
    for nonterminal, rules in grammar.items():
        if token in rules:
            return nonterminal
    return None



if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description = 'Script to convert grammar to GNF form')
    parser.add_argument(
            '--gf',
            type = str,
            required = True,
            help = 'Location of grammar file')
    parser.add_argument(
            '--out',
            type = str,
            required = True,
            help = 'Location of output file')
    parser.add_argument(
            '--start',
            type = str,
            required = True,
            help = 'Start token')
    args = parser.parse_args()

    main(args.gf, args.out, args.start)
