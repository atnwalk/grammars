import sys
import json

aux_rule_ctr = 1

def create_nautilus_python_rules(rule_name, elements):
    main_rule = "ctx.rule(u'" + rule_name.upper() + "', u'"
    aux_rules = []
    for ele in elements:
        # i.e. 'string' or RULENAME
        item = ele[0]

        # cardinalities e.g. 0..1 --> left: 0; right: 1
        left = ele[1][0]
        right = ele[1][1]
        if left == 1 and right == 1:
            if item.startswith("'"):
                main_rule += (item[1:-1]
                .replace('{', '\\\\{')
                .replace('}', '\\\\}'))
                continue
            else:
                main_rule += '{' + item.upper() + '}'
                continue

        global aux_rule_ctr
        aux_rule_name = "AUX_" + str(aux_rule_ctr)
        aux_rule_ctr += 1

        # 0, 1: aux: empty; aux: item;
        if left == 0 and right == 1:
            aux_rules.append("ctx.rule(u'" + aux_rule_name + "', u'')\n")
            aux_rules.append("ctx.rule(u'" + aux_rule_name + "', u'{" + item.upper() + "}')\n")
            main_rule += '{' + aux_rule_name + '}'
            continue

        # 0, inf: aux: empty; aux: item aux
        if left == 0 and right is None:
            aux_rules.append("ctx.rule(u'" + aux_rule_name + "', u'')\n")
            aux_rules.append("ctx.rule(u'" + aux_rule_name + "', u'{" + item.upper() + "}{" + aux_rule_name + "}')\n")
            main_rule += '{' + aux_rule_name + '}'
            continue

        # 1, inf: aux: item; aux: item aux
        if left == 1 and right is None:
            aux_rules.append("ctx.rule(u'" + aux_rule_name + "', u'{" + item.upper() + "}')\n")
            aux_rules.append("ctx.rule(u'" + aux_rule_name + "', u'{" + item.upper() + "}{" + aux_rule_name + "}')\n")
            main_rule += '{' + aux_rule_name + '}'
            continue

    return main_rule + "')\n" + "".join(aux_rules)


def main(argv):
    rules = json.loads(sys.stdin.read())
    result = ""
    for rule, alternatives in rules.items():
        for elements in alternatives:
            # ctx.rule(u'PROGRAM',u'{STATEMENT}\n{PROGRAM}')
            # TODO: fix this tomorrow
            result += create_nautilus_python_rules(rule, elements)
    print(result)


if __name__ == '__main__':
    main(sys.argv)
