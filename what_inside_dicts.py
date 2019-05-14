#!/bin/python

import pickle

with open('bi_pt_dict_en2hi.pickle', 'rb') as handle:
    bi_dict = pickle.load(handle)

all_keys = bi_dict.keys()

print(list(all_keys)[:10])
