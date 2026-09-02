import json,sys
d=json.load(sys.stdin)
print('ok:', d.get('ok'))
print('title:', d.get('data',{}).get('title'))
tree=d.get('data',{}).get('tree',[])
print(json.dumps(tree[:10], indent=2))