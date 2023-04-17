import sys
import json


def main(argv):
    data = json.loads(sys.stdin.read())
    for state, transitions in data['pda'].items():
        for t in transitions:
            t[2] = t[2].encode('utf-8').decode('unicode_escape')
    print(json.dumps(data))


if __name__ == '__main__':
    main(sys.argv)
