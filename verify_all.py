import json,sys
d=json.load(sys.stdin)
tree_str = json.dumps(d.get('data',{}).get('tree',[]))
names = ['Cartrack', 'Flickswitch', 'Wesbank', 'Supabase']
for name in names:
    print(f'{name} found:', name in tree_str)