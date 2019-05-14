#!/bin/python3
import pickle

ngrams = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
uni_f = open('unigram_unique_pt', 'w', encoding='utf-8')
bi_f = open('bigram_unique_pt', 'w', encoding='utf-8')
tri_f = open('trigram_unique_pt', 'w', encoding='utf-8')

bi_dict = {}
tri_dict = {}

with open('unique-phrase-table', encoding='utf-8') as f:
    for line in f:
        line = line.rstrip().lstrip()
        src, tgt = line.split('\t')
        
        swords = src.split(' ')
        slen = len(swords) - 1
        ngrams[slen] += 1

        if slen==0:
            uni_f.write(line + '\n')

        if slen==1:
            bi_f.write(line + '\n')
            bi_dict[src] = tgt

        if slen==2:
            tri_f.write(line + '\n')
            tri_dict[src] = tgt

print(ngrams)

uni_f.close()
bi_f.close()
tri_f.close()

with open('bi_pt_dict_en2hi.pickle', 'wb') as handle:
    pickle.dump(bi_dict, handle, protocol=pickle.HIGHEST_PROTOCOL)

with open('tri_pt_dict_en2hi.pickle', 'wb') as handle:
    pickle.dump(tri_dict, handle, protocol=pickle.HIGHEST_PROTOCOL)

