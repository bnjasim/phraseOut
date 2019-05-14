#!/bin/python3

# Prune only reasonable lexical mappings using both lex.e2f & lex.f2e

import pickle

def is_char_in_hi_range(c):
    '''hindi unicode range is 0900 - 097F
       or 2304 - 2431 in integers'''
    
    ic = ord(c)
    if ic >= 2304 and ic <= 2431:
        return True
    else:
        return False

def is_hindi(word):
    '''Checks if a word is in Devanagari alphabets.
    That means avoid numbers, NULL etc.'''
    
    return all([is_char_in_hi_range(c) for c in word])
    
lex_dict = {}
# list_en = []
prev_en = ''
count = 0
mapped_hi = ''
max_prob = 0

outfile = open('lex_mappings_en2hi.txt', 'w', encoding='utf-8')

with open('lex.e2f') as e2f, open('lex.f2e') as f2e:
    for line1, line2 in zip(e2f, f2e):
        line1 = line1.rstrip().lstrip()
        line2 = line2.rstrip().lstrip()
        en, hi, prob1 = line1.split(' ')
        h2, e2, prob2 = line2.split(' ')
        assert hi==h2 and en==e2, line1
       
        # Ignore numbers, comma, english mixed words etc. 
        if not is_hindi(hi):
            continue

        count += 1
        if en != prev_en:
            # Time to update the lex_dict
            if len(mapped_hi) > 0: #  and count < 10:
                lex_dict[prev_en] = mapped_hi
                tran_line = prev_en + ' ' + mapped_hi # ' '.join(list_en)
                # print(tran_line)
                outfile.write(tran_line + '\n')
           
            mapped_hi = ''          
            count = 0
            max_prob = 0
        prev_en = en
        
        total_prob = float(prob1) * float(prob2)
        if total_prob >= 0.01 and total_prob > max_prob:
            mapped_hi = hi
            max_prob = total_prob
    
if len(mapped_hi) > 0:
    lex_dict[prev_en] = mapped_hi
    tran_line = prev_en + ' ' + mapped_hi # ' '.join(list_en)
    print(tran_line)
    outfile.write(tran_line + '\n')

outfile.close()

with open('lex_dict_en2hi.pickle', 'wb') as handle:
    pickle.dump(lex_dict, handle, protocol=pickle.HIGHEST_PROTOCOL)


print(len(lex_dict.keys()))

