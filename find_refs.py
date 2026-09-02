import json,sys
d=json.load(sys.stdin)
tree=d.get('data',{}).get('tree',[])

def find_refs(node, path=''):
    refs = []
    if isinstance(node, dict):
        ref = node.get('ref')
        role = node.get('role')
        name = node.get('name', '')
        if ref and role in ['textbox', 'combobox', 'button', 'option']:
            refs.append(f'{ref}: {role} = {name}')
        for k, v in node.items():
            if isinstance(v, (dict, list)):
                refs.extend(find_refs(v, path + '.' + k))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            refs.extend(find_refs(item, path + f'[{i}]'))
    return refs

refs = find_refs(tree)
for r in refs:
    print(r)