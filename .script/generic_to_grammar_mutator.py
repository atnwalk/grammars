import sys
import json

aux_rule_ctr = 1


def create_gramatron_python_rules(rule_name, elements):
    main_rule = []
    aux_rules = []
    for ele in elements:
        # i.e. 'string' or RULENAME
        item = ele[0]

        # cardinalities e.g. 0..1 --> left: 0; right: 1
        left = ele[1][0]
        right = ele[1][1]
        if left == 1 and right == 1:
            if item == "":
                continue
            if item.startswith("'"):
                main_rule.append(item[1:-1].encode('utf-8').decode('unicode_escape'))
                continue
            else:
                main_rule.append(f"<{item}>")
                continue

        global aux_rule_ctr
        aux_rule_name = "aux_" + str(aux_rule_ctr)
        aux_rule_ctr += 1

        main_rule.append(f"<{aux_rule_name}>")

        # TODO: test
        # 0, 1 -> aux: empty; aux: item;
        if left == 0 and right == 1:
            aux_rules.append({f"<{aux_rule_name}>": [[], [f"<{item}>"]]})
            continue

        # 0, inf -> aux: empty; aux: item aux
        if left == 0 and right is None:
            aux_rules.append({f"<{aux_rule_name}>": [[], [f"<{item}>", f"<{aux_rule_name}>"]]})
            continue

        # 1, inf -> aux: item; aux: item aux
        if left == 1 and right is None:
            aux_rules.append({f"<{aux_rule_name}>": [[f"<{item}>"], [f"<{item}>", f"<{aux_rule_name}>"]]})
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

        # need to fix left recursion for grammar_mutator, i.e., this rule:
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
            aux_alts = [[["", [1, 1]]]]
            for i in reversed(left_recursive):
                remaining_ele = alternatives[i][1:]
                del alternatives[i]

                # avoid duplicating the default auxiliary rule
                if len(remaining_ele) == 1 and remaining_ele[0] == "":
                    continue

                aux_alts.append(remaining_ele)

            global aux_rule_ctr
            aux_rule_name = "aux_" + str(aux_rule_ctr)
            aux_rule_ctr += 1

            # fix the other alternatives by appending the auxiliary rule
            for i in range(len(alternatives)):
                alternatives[i].append([aux_rule_name, [1, 1]])

            # TODO: remove this code clone... "later"

            for aux_ele in aux_alts:
                if f"<{aux_rule_name}>" not in result:
                    result[f"<{aux_rule_name}>"] = []
                main_rule, aux_rules_additional = create_gramatron_python_rules(aux_rule_name, aux_ele)
                result[f"<{aux_rule_name}>"].append(main_rule)
                for ar in aux_rules_additional:
                    for k, v in ar.items():
                        result[k] = v

    for rule, alternatives in rules.items():
        for elements in alternatives:
            if f"<{rule}>" not in result:
                result[f"<{rule}>"] = []
            main_rule, aux_rules = create_gramatron_python_rules(rule, elements)
            result[f"<{rule}>"].append(main_rule)
            for ar in aux_rules:
                for k, v in ar.items():
                    result[k] = v

    print(json.dumps(result, indent=4))


if __name__ == '__main__':
    main(sys.argv)

