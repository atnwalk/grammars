import sys
import json
import re


def get_tokens(txt):
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


class Node(object):
    def __init__(self, parent, rule, alternatives):
        self.parent = parent
        self.rule = rule
        self.alternatives = []
        for alt in alternatives:
            self.alternatives.append(Alternative(get_tokens(alt)))


class Alternative(object):
    def __init__(self, tokens):
        self.symbol = tokens[0]
        self.tokens = tokens[:]
        self.todo = tokens[1:]
        self.nodes = []


def process(data, trace, node):
    max_depth = 1
    i = 0
    while i < len(node.alternatives):
        alt = node.alternatives[i]
        abandon = False
        for t in alt.tokens[1:]:
            if trace[t] >= max_depth:
                abandon = True
                break

        if abandon:
            del node.alternatives[i]
            continue

        while len(alt.todo) > 0:
            expand = alt.todo[0]
            del alt.todo[0]
            trace[expand] += 1
            new_node = Node(node, expand, data[expand])
            ok = process(data, trace, new_node)
            trace[expand] -= 1
            if not ok:
                abandon = True
                break
            alt.nodes.append(new_node)

        if abandon:
            del node.alternatives[i]
            continue

        i += 1

    if len(node.alternatives) == 0:
        return False
    return True


def main(argv):
    data = None
    if len(argv) > 1:
        with open(argv[1], 'r') as f:
            data = json.loads(f.read())
    else:
        data = json.loads(sys.stdin.read())

    trace = dict()
    for rule in data:
        trace[rule] = 0

    trace['START'] += 1
    node = Node(None, 'START', data['START'])
    process(data, trace, node)
    pass

if __name__ == '__main__':
    main(sys.argv)
