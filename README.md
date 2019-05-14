# phraseOut
Code Mixed Data Augmentation for NMT

## 14 May 2019

The procedure to run the experiments is described below

**Step 1**: Run Moses to get the phrase tables with `--last-step` as 6. See [my guide to moses](http://cslab.org/blog/moses-basics).

**Step 2**: Run `get_lex_dict_en.py` to get the unigram lexical mappings.

**Step 3**: Run `anaylze_phrase_table.py` to get a unique phrase table which maps to the most probable target phrase.

**Step 4**: Run 
