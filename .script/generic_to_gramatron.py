import sys
import json
import re

aux_rule_ctr = 1


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


def create_gramatron_python_rules(rule_name, elements):
    main_rule = ""
    aux_rules = []
    for ele in elements:
        # i.e. 'string' or RULENAME
        item = ele[0]

        # cardinalities e.g. 0..1 --> left: 0; right: 1
        left = ele[1][0]
        right = ele[1][1]
        if left == 1 and right == 1:
            if item.startswith("'"):
                if len(main_rule) > 0:
                    main_rule += " " + item
                else:
                    main_rule = item

                continue
            else:
                if len(main_rule) > 0:
                    main_rule += " " + item.upper()
                else:
                    main_rule = item.upper()
                continue

        global aux_rule_ctr
        aux_rule_name = "AUX_" + str(aux_rule_ctr)
        aux_rule_ctr += 1

        if len(main_rule) > 0:
            main_rule += " " + aux_rule_name
        else:
            main_rule = aux_rule_name

        # TODO: test
        # 0, 1 -> aux: empty; aux: item;
        if left == 0 and right == 1:
            aux_rules.append({aux_rule_name: ["''", item.upper()]})
            continue

        # 0, inf -> aux: empty; aux: item aux
        if left == 0 and right is None:
            aux_rules.append({aux_rule_name: ["''", item.upper() + " " + aux_rule_name]})
            continue

        # 1, inf -> aux: item; aux: item aux
        if left == 1 and right is None:
            aux_rules.append({aux_rule_name: [item.upper(), item.upper() + " " + aux_rule_name]})
            continue

    return main_rule, aux_rules


def main(argv):
    rules = None
    if len(argv) > 1:
        with open(argv[1], 'r') as f:
            rules = json.loads(f.read())
    else:
        rules = json.loads(sys.stdin.read())
    result = dict()

    for rule, alternatives in rules.items():

        # need to fix left recursion for gramatron, i.e., this rule:
        #   expr: expr '+' expr | 'abc' other | var 'a' ;
        #
        # results in these two rules:
        #   expr_aux: '' | '+' expr;
        #   expr: 'abc' other expr_aux | var 'a' expr_aux;
        left_recursive = []
        for i in range(0, len(alternatives)):
            if alternatives[i][0][0] == rule:
                left_recursive.append(i)

        if len(left_recursive) > 0:
            # create auxiliary rules
            aux_alts = [[["''", [1, 1]]]]
            for i in reversed(left_recursive):
                remaining_ele = alternatives[i][1:]
                del alternatives[i]

                # avoid duplicating the default auxiliary rule
                if len(remaining_ele) == 1 and remaining_ele[0] == "''":
                    continue

                aux_alts.append(remaining_ele)

            global aux_rule_ctr
            aux_rule_name = "AUX_" + str(aux_rule_ctr)
            aux_rule_ctr += 1
            # result[aux_rule_name] = aux_rules

            # fix the other alternatives by appending the auxiliary rule
            for i in range(len(alternatives)):
                alternatives[i].append([aux_rule_name, [1, 1]])

            # TODO: remove this code clone... "later"

            aux_rule_name = aux_rule_name.upper()
            for aux_ele in aux_alts:
                if aux_rule_name not in result:
                    result[aux_rule_name] = []
                main_rule, aux_rules_additional = create_gramatron_python_rules(aux_rule_name, aux_ele)
                result[aux_rule_name].append(main_rule)
                for ar in aux_rules_additional:
                    for k, v in ar.items():
                        result[k] = v

    for rule, alternatives in rules.items():
        rule = rule.upper()
        for elements in alternatives:
            if rule not in result:
                result[rule] = []
            main_rule, aux_rules = create_gramatron_python_rules(rule, elements)
            result[rule].append(main_rule)
            for ar in aux_rules:
                for k, v in ar.items():
                    result[k] = v

    stop = False
    while not stop:
        stop = True
        dupes = dict()
        for rule, alternatives in result.items():
            hashed = tuple(sorted(alternatives))
            if hashed not in dupes:
                dupes[hashed] = [rule]
            else:
                dupes[hashed].append(rule)
                stop = False

        if stop:
            break

        for hashed, rules in dupes.items():
            if len(rules) == 1:
                continue
            new_rule = rules[0]
            replacing_rules = set(rules[1:])
            for rule in replacing_rules:
                del result[rule]
            for rule in result:
                for i in range(len(result[rule])):
                    tokens = get_tokens(result[rule][i])
                    for j in range(len(tokens)):
                        if tokens[j] in replacing_rules:
                            tokens[j] = new_rule
                    result[rule][i] = ' '.join(tokens)

    print(json.dumps(result, indent=4))


if __name__ == '__main__':
    main(sys.argv)
