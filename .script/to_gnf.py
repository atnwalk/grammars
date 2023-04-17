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


def main(argv):
    data = None
    if len(argv) > 1:
        with open(argv[1], 'r') as f:
            data = json.loads(f.read())
    else:
        data = json.loads(sys.stdin.read())

    result = dict()
    token2rule = dict()
    counter = 1

    # extract tokens and map each token -> rule, rule -> token, add rules to data
    for rule, alternatives in data.items():
        new_alternatives = []
        for alt in alternatives:
            tokens = get_tokens(alt)
            if len(tokens) == 1:
                new_alternatives.append(alt)
                continue
            new_tokens = [tokens[0]]
            for t in tokens[1:]:
                if t.startswith("'"):
                    if t not in token2rule:
                        new_rule = 'S' + str(counter)
                        counter += 1
                        result[new_rule] = [t]
                        token2rule[t] = new_rule
                        new_tokens.append(new_rule)
                    else:
                        new_tokens.append(token2rule[t])
                else:
                    new_tokens.append(t)
            new_alternatives.append(" ".join(new_tokens))
        result[rule] = new_alternatives

    del token2rule
    del data

    start2rules = dict()
    resolved = set()
    for rule, alternatives in result.items():
        is_resolved = True
        for alt in alternatives:
            if not alt.startswith("'"):
                is_resolved = False
                start = get_tokens(alt)[0]
                if start not in start2rules:
                    start2rules[start] = set([rule])
                else:
                    start2rules[start].add(rule)
        if is_resolved:
            resolved.add(rule)

    todo = [x for x in resolved]
    while len(todo) > 0:
        resolved_rule = todo[-1]
        del todo[-1]

        if resolved_rule not in start2rules:
            continue

        for rule in start2rules[resolved_rule]:
            i = 0
            last = len(result[rule])
            while i < last:
                tokens = get_tokens(result[rule][i])
                if tokens[0] == resolved_rule:
                    for alt in result[resolved_rule]:
                        result[rule].append(' '.join([alt] + tokens[1:]))
                    del result[rule][i]
                    last -= 1
                    continue
                i += 1

            is_resolved = True
            for alt in result[rule]:
                if not alt.startswith("'"):
                    is_resolved = False
                    break

            if is_resolved:
                todo.append(rule)

    # for rule in result:
    #     result[rule] = list(set(result[rule]))

    result['Start'] = ['START']
    print(json.dumps(result, indent=4))


if __name__ == '__main__':
    main(sys.argv)
