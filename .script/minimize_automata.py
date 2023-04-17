import sys
import json

def main(argv):
    data = None
    if len(argv) > 1:
        with open(argv[1], 'r') as f:
            data = json.loads(f.read())
    else:
        data = json.loads(sys.stdin.read())

    new_pda = dict()
    for state, transitions in data['pda'].items():
        new_pda[state] = list(set(tuple(t) for t in transitions))
    data['pda'] = new_pda

    print(json.dumps(data))

if __name__ == '__main__':
    main(sys.argv)
