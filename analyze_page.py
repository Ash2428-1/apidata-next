import json,sys
d=json.load(sys.stdin)
tree=d.get('data',{}).get('tree',[])
print('ok:', d.get('ok'))
print('title:', d.get('data',{}).get('title'))

# Search for all heading names (connector names)
def find_headings(node, depth=0):
    results = []
    if isinstance(node, dict):
        if node.get('role') == 'heading':
            name = node.get('name', '')
            if name and name not in ['Connectors', 'Xtend Hub', 'API Management', 'Create New Connector']:
                results.append(name)
        for v in node.values():
            if isinstance(v, (dict, list)):
                results.extend(find_headings(v, depth+1))
    elif isinstance(node, list):
        for item in node:
            results.extend(find_headings(item, depth+1))
    return results

headings = find_headings(tree)
print('Connector names found:', headings)

# Also check for any error messages
def find_errors(node):
    results = []
    if isinstance(node, dict):
        text = node.get('name', '') or ''
        if 'error' in text.lower() or 'fail' in text.lower() or 'invalid' in text.lower():
            results.append(text)
        for v in node.values():
            if isinstance(v, (dict, list)):
                results.extend(find_errors(v))
    elif isinstance(node, list):
        for item in node:
            results.extend(find_errors(item))
    return results

errors = find_errors(tree)
print('Error messages:', errors)