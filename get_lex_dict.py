#!/bin/python3

# Prune only reasonable lexical mappings using both lex.e2f & lex.f2e

import pickle

def is_char_in_lang_range(c):
    '''hindi unicode range is 0900 - 097F
       or 2304 - 2431 in integers'''
    
    lb = 2304
    ub = 2431
    ic = ord(c)
    if ic >= lb and ic <= ub:
        return True
    else:
        return False

def is_lang(word):
    '''Checks if a word is in Devanagari alphabets.
    That means avoid numbers, NULL etc.'''
    
    return all([is_char_in_lang_range(c) for c in word])
    
lex_dict = {}
prev_token = ''
count = 0
mapped_tokens = ''
max_prob = 0

outfile = open('lex_mappings.txt', 'w', encoding='utf-8')

with open('lex.e2f') as e2f, open('lex.f2e') as f2e:
    for line1, line2 in zip(e2f, f2e):
        line1 = line1.rstrip().lstrip()
        line2 = line2.rstrip().lstrip()
        src1, tgt1, prob1 = line1.split(' ')
        tgt2, src2, prob2 = line2.split(' ')
        try:
            assert src1==src2 and tgt1==tgt2, line1
        except Exception:
            continue
       
        # Ignore numbers, comma, english mixed words etc. 
        if not is_lang(src1):
            print('skipped: ' + src1)
            continue

        count += 1
        if src1 != prev_token:
            # Time to update the lex_dict
            if len(mapped_tokens) > 0: #  and count < 10:
                lex_dict[prev_token] = mapped_tokens
                tran_line = prev_token + ' ' + mapped_tokens # ' '.join(list_en)
                # print(tran_line)
                outfile.write(tran_line + '\n')
           
            mapped_tokens = ''          
            count = 0
            max_prob = 0
        prev_token = src1
        
        total_prob = float(prob1) * float(prob2)
        if total_prob >= 0.01 and total_prob > max_prob:
            mapped_tokens = tgt1
            max_prob = total_prob
    
if len(mapped_tokens) > 0:
    lex_dict[prev_token] = mapped_tokens
    tran_line = prev_token + ' ' + mapped_tokens # ' '.join(list_en)
    print(tran_line)
    outfile.write(tran_line + '\n')

outfile.close()

with open('lex_dict.pickle', 'wb') as handle:
    pickle.dump(lex_dict, handle, protocol=pickle.HIGHEST_PROTOCOL)


print(len(lex_dict.keys()))

