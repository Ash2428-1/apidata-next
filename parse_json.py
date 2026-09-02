import json,sys
d=json.load(sys.stdin)
print('ok:', d.get('ok'))
print('title:', d.get('data',{}).get('title'))
print('tree preview:', json.dumps(d.get('data',{}).get('tree',[])[:3]))