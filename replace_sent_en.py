#!/bin/python3
# replace a word per source sentence using the save lex dictionary

import pickle
from random import shuffle

with open('lex_dict_en2hi.pickle', 'rb') as handle:
    lex_dict = pickle.load(handle)  

with open('bi_pt_dict_en2hi.pickle', 'rb') as handle:
    bi_dict = pickle.load(handle)

with open('tri_pt_dict_en2hi.pickle', 'rb') as handle:
    tri_dict = pickle.load(handle)

outfile = open('mono_replaced.en', 'w', encoding='utf-8')
c_t = 0
c_b = 0
c_u = 0

def get_bigrams(a):
    # a is a list
    if len(a) < 2:
        return [tuple(a)]

    return [(a[i], a[i+1]) for i in range(0, len(a)-1)]

def get_trigrams(a):
    # a is a list
    if len(a) < 3:
        return [tuple(a)]

    return [(a[i], a[i+1], a[i+2]) for i in range(0, len(a)-2)]

# print(get_bigrams([3,4, 5, 6]))
i=0
for line in open('mono.en', encoding='utf-8'):
    line = line.rstrip().lstrip()
    words = line.split(' ')

    repl = ''
    i += 1
    # First Try Trigrams
    all_trigrams = get_trigrams(words)
    shuffle(all_trigrams)
    for tri in all_trigrams:
        tri_phrase = ' '.join(tri)
        if tri_phrase in tri_dict:
            repl = tri_dict.get(tri_phrase)
            orig = tri_phrase
            c_t += 1
            break

    if repl == '':
        # Next Bigrams if No Trigram found in dict
        all_bigrams = get_bigrams(words)
        shuffle(all_bigrams)
        for bi in all_bigrams:
            bi_phrase = ' '.join(bi)
            if bi_phrase in bi_dict:
                orig = bi_phrase
                repl = bi_dict.get(bi_phrase)
                c_b += 1
                break
    
    if repl == '':
        all_words = line.split(' ')
        shuffle(all_words)
        for uni in all_words:
            if uni in lex_dict:
                repl = lex_dict.get(uni) # single value
                orig = uni
                c_u += 1
                break
    if repl:
        # new_words = [w if w != word  else repl for w in words]
        # new_hi_words = [w if w != hi_w else en_common + '(' + w + ')' for w in hi_words]
        # new_sent = ' '.join(new_words)
        new_line = line.replace(orig, repl)
        outfile.write(new_line + '\t' + line + '\n')

        repl = ''
    

outfile.close()
print('trigrams replaced ' + str(c_t))
print('bigrams replaced ' + str(c_b))
print('unigrams replaced ' + str(c_u))


            

