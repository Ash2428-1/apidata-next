import json,sys
d=json.load(sys.stdin)
tree=json.dumps(d.get('data',{}).get('tree',[]))
print('Has Flickswitch:', 'Flickswitch' in tree)
print('Has Cartrack:', 'Cartrack' in tree)