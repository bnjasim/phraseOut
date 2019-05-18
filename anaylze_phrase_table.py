#!/bin/python3

def is_char_in_hi_range(c):
    '''hindi unicode range is 0900 - 097F
       or 2304 - 2431 in integers'''
    
    lb = 2304
    ub = 2431
    ic = ord(c)
    return (ic >= lb and ic <= ub)

def is_char_ascii(c):
    ic = ord(c)
    return ic < 128

def is_hindi(word):
    '''Checks if a word is in Devanagari alphabets.
    That means avoid numbers, NULL etc.'''
    
    return all([is_char_in_hi_range(c) or is_char_ascii(c) for c in word])

def is_english(word):
    '''Checks if a word is in ascii'''
    
    return all([is_char_ascii(c) for c in word])
    

prev = ''
best_tgt = ''
best_prob = 0
outfile = open('unique-phrase-table', 'w', encoding='utf-8')
count = 0
patho = 0

with open('phrase-table', encoding='utf-8') as f:
    for line in f:
        line = line.rstrip().lstrip()
        src, tgt, probs, _, _, _, _ = line.split('|||')
        src = src.rstrip().lstrip()
        tgt = tgt.rstrip().lstrip()
        probs = probs.rstrip().lstrip()

        if not is_hindi(src) or is_english(tgt):
            patho += 1
            continue

        if prev != src and best_tgt:
            # time to add to outfile
            outfile.write(prev + '\t' + best_tgt + '\n')
            best_tgt = ''
            best_prob = 0
            count += 1
        # print(probs)
        p1, p2, p3, p4 = probs.split(' ')
        p1 = float(p1)
        p2 = float(p2)
        p3 = float(p3)
        p4 = float(p4)
        total_prob = p1 * p2 * p3 * p4

        if total_prob > best_prob and total_prob > 1e-12:
            best_prob = total_prob
            best_tgt = tgt

        prev = src

    # Final line of the file
    if best_tgt:
        outfile.write(src + '\t' + best_tgt + '\n')

outfile.close()
print(count)

print('Number of pathological phrases = ', patho)


