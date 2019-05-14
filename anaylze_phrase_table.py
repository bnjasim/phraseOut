#!/bin/python3

prev = ''
best_tgt = ''
best_prob = 0
outfile = open('unique-phrase-table', 'w', encoding='utf-8')
count = 0

with open('phrase-table', encoding='utf-8') as f:
    for line in f:
        line = line.rstrip().lstrip()
        src, tgt, probs, _, _, _, _ = line.split('|||')
        src = src.rstrip().lstrip()
        tgt = tgt.rstrip().lstrip()
        probs = probs.rstrip().lstrip()

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




