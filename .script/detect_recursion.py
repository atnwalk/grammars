import sys
import json


def main(argv):
    rules = None
    if len(argv) > 1:
        with open(argv[1], 'r') as f:
            rules = json.loads(f.read())
    else:
        rules = json.loads(sys.stdin.read())

    reverse_look_up = dict()
    for rule, alternatives in rules.items():
        for alt in alternatives:
            if not alt[0][0].startswith("'"):
                if alt[0][0] not in reverse_look_up:
                    reverse_look_up[alt[0][0]] = set()
                reverse_look_up[alt[0][0]].add(rule)

    for rule in reverse_look_up:
        stack = [list(reverse_look_up[rule])[:]]
        visited = set()
        visited.add(rule)
        path = [rule]
        while len(stack) > 0:

            # this set of parents is empty, go down
            if len(stack[-1]) == 0:
                stack.pop()
                path.pop()
                continue

            # if we already visited that rule continue with the next one
            next_rule = stack[-1].pop()
            if next_rule in visited:
                continue

            visited.add(next_rule)
            path.append(next_rule)

            if next_rule not in reverse_look_up:
                continue

            if rule in reverse_look_up[next_rule]:
                print(f"{rule}: {' -> '.join(list(reversed(path)))}")
                continue

            stack.append(list(reverse_look_up[next_rule])[:])


if __name__ == '__main__':
    main(sys.argv)
