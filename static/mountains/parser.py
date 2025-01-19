import dateparser
''' Trasnform mountain markdown for conversion to excel'''

def read_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    return content

file_path = './mountains.md'
file_content = read_file(file_path)
lines = file_content.split('\n')

outings = list()
for line in lines:
    line = line.strip()

    if len(line) == 0:
        continue
    
    if line.startswith('## '):
        outing = dict()
        line = line.replace('## ', '').strip()
        date = line.split(',')[-1].strip()
        outing['destination'] = ','.join(line.split(',')[0:-1]).strip()
        
        date = dateparser.parse(date)
        outing['date'] = date.strftime('%d %B %Y')
        continue

    if line.startswith('![alt text]('):
        outing['image'] = line.replace('![alt text](', '').replace(')', '').strip()
        continue

    outing['description'] = line
    outings.append(outing)



lines = list()
for outing in outings:
    l = list()
    l.append(outing['date'])
    l.append(outing['destination'])
    l.append(outing['description'])
    if 'image' in outing:
        l.append(outing['image'])

    lines.append('\t'.join(l))


print('\n'.join(lines))