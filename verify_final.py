import json,sys
d=json.load(sys.stdin)
tree=d.get('data',{}).get('tree',[])
print('ok:', d.get('ok'))
print('title:', d.get('data',{}).get('title'))
# Flatten tree to string and search for connector names
tree_str = json.dumps(tree)
for name in ['Cartrack', 'Flickswitch']:
    print(f'{name} found:', name in tree_str)