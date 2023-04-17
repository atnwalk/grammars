import re
import sys
import json

class Parser(object):

    def __init__(self, txt):
        self.txt = txt
        self.pos = 0
        self.group_ctr = 0
        self.rules = dict()

    def parse(self):
        # skip to the part where rules start
        match = re.search(r'.*(grammar[ \t\n]+[A-Za-z0-9]+;[ \t\n]).*', self.txt, re.DOTALL)
        original = self.txt[:]
        self.txt = self.txt[match.span(1)[1]:]
        while self.pos < len(self.txt):
            self.parse_rule()
        self.txt = original
        self.pos = 0

    def parse_rule(self, name=None):
        # rule: name ':' rule_elements+;

        self.skip_whitespaces_or_comments()
        if self.pos >= len(self.txt):
            return

        # extract the name of the rule
        if name is None:
            match = re.search(r'([a-zA-Z_][a-zA-Z0-9_]*):.*', self.txt[self.pos:])
            if match is None:
                raise Exception(f"expected rule name at {str(self.pos)}: {self.txt[self.pos:self.pos+10]} but could not match it")
            name = match.group(1)
            self.pos += match.span(1)[1] + 1

        # create an empty rule object if it does not exist
        self.rules[name] = [[]]

        self.parse_rule_elements(name)
        match = re.search(r'^;.*', self.txt[self.pos:])
        if match:
            if len(self.rules[name]) == 0 or len(self.rules[name][-1]) == 0:
                raise Exception(f"rule {name} has no elements")
            self.pos += 1
        # else:
        #     raise Exception(f"rule {name} was not terminated")

    def parse_rule_elements(self, rule_name):
        # rule_elements+ ';'
        while True:
            self.skip_whitespaces_or_comments()

            # semicolon ; #
            # TODO: or EOF?
            # -> terminate rule
            if re.search(r'^(;).*', self.txt[self.pos:]):
                break

            # end of group )
            match = re.search(r'^\).*', self.txt[self.pos:])
            if match:
                self.pos += 1
                break

            # beginning of new group (
            # parse group as an "anonymous rule" '__GROUP_ctr' and continue
            match = re.search(r'^\(.*', self.txt[self.pos:])
            if match:
                self.pos += 1
                group_name = f'GROUP_{str(self.group_ctr)}'
                self.group_ctr += 1
                self.rules[group_name] = [[]]
                self.parse_rule_elements(group_name)

                cardinality = self.get_cardinality()
                self.rules[rule_name][-1].append([group_name, cardinality])
                continue

            # RULENAME
            match = re.search(r'^([A-Za-z][A-Za-z0-9_]*).*', self.txt[self.pos:])
            if match:
                self.pos += match.span(1)[1]
                cardinality = self.get_cardinality()
                self.rules[rule_name][-1].append([match.group(1), cardinality])
                continue

            # 'string'
            if self.txt[self.pos] == "'":
                # TODO: this may fail but should be fine for the moment
                #       there could be special cases like 'abc\\' which could be misjudged
                #       actually would need to count whether even or odd number of backslashes before single quote
                offset = 1
                end = -1
                while True:
                    end = self.txt[self.pos+offset:].index("'")
                    offset += end + 1
                    count = 0
                    for i in range(self.pos + offset-2, self.pos, -1):
                        if self.txt[i] == '\\':
                            count += 1
                        else:
                            break
                    if count % 2 == 1:
                        continue
                    break

                self.rules[rule_name][-1].append([self.txt[self.pos:self.pos+offset], [1, 1]])
                self.pos += offset
                # TODO: cardinality?
                continue

            # | (alternative)
            if self.txt[self.pos] == "|":
                self.pos += 1
                self.rules[rule_name].append([])
                continue

            raise Exception(f"unknown error at position {str(self.pos)}: {self.txt[self.pos:self.pos+10]}")

    def get_cardinality(self):
        cardinality = None
        # TODO: check for EOF, may cause index out of bounds exception here
        # TODO: {6} or {4, 9} cardinality syntax is missing
        c = self.txt[self.pos]
        if c == '?':
            cardinality = [0, 1]
        elif c == '*':
            cardinality = [0, None]
        elif c == '+':
            cardinality = [1, None]
        if cardinality is None:
            cardinality = [1, 1]
        else:
            self.pos += 1

        return cardinality

    def to_json(self):
        return json.dumps(self.rules, indent=4)

    def skip_whitespaces_or_comments(self):
        while self.skip_whitespaces() or self.skip_comment():
            pass

    def skip_whitespaces(self):
        # WHITESPACES: ' ' | '\t' | '\n' | '\r'
        match = re.search(r'^([ \t\n\r]+).*', self.txt[self.pos:])
        if match:
            self.pos += match.span(1)[1]
            return True
        return False

    def skip_comment(self):
        # SINGLELINE_COMMENT: '//' text '\n'
        match = re.search(r'(^//.*(\n|\S)).*', self.txt[self.pos:])
        if match:
            self.pos += match.span(1)[1]
            return True

        # MULTILINE_COMMENT: '/*' text '*/'
        if self.txt[self.pos:].startswith('/*'):
            self.pos += self.txt[self.pos+2:].find('*/') + 4
            return True


def main(argv):
    txt = ""
    with open(argv[1], 'r') as f:
        f.seek(0)
        txt = f.read()
    p = Parser(txt)
    p.parse()
    print(p.to_json())


if __name__ == '__main__':
    main(sys.argv)
