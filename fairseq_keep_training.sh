#!/bin/sh 

# multi-lingal NMT in a many->many setting;
# but should be easily reusable in many->one, one->many and one->one settings
# Note that one side of the parallel data is always assumed to be en

if [[ $# -lt 4 ]]; then
    echo 'format: fairseq.sh src_lang dest_lang voc_size ckpt_dir'
    exit
fi

SRC=$1
TGT=$2
VOCS=$3
CKPT_DIR=/ssd_scratch/cvit/jas/checkpoints/$4

src_train=''
tgt_train=''

lang_list="hi bn ml ta te"
splits="train test dev"

# for lang in ${lang_list[@]}; do
#   echo $lang;
# 
#   if [ -d "data/$lang/$lang-en" ]; then
#      lang_dir=data/$lang/$lang-en
#      # tokenize files
#      python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/train.$lang $lang_dir/train.tok.$lang $lang
#      python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/train.en $lang_dir/train.tok.en en
#      src_train="$src_train $lang_dir/train.tok.$lang"
#      tgt_train="$tgt_train $lang_dir/train.tok.en"
#   fi
# 
#   if [ -d "data/$lang/en-$lang" ]; then
#      lang_dir=data/$lang/en-$lang 
#      # tokenize files
#      python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/train.$lang $lang_dir/train.tok.$lang $lang
#      python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/train.en $lang_dir/train.tok.en en
#      src_train="$src_train $lang_dir/train.tok.en"
#      tgt_train="$tgt_train $lang_dir/train.tok.$lang"
#   fi
# 
#   if [ -d "data/$lang/en-mono" ]; then
#      lang_dir=data/$lang/en-mono
#      # mono directory is assumed to have only train data 
#      # tokenize files
#      python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/mono.en $lang_dir/mono.tok.en en
#      src_train="$src_train $lang_dir/mono.tok.en"
#      tgt_train="$tgt_train $lang_dir/mono.tok.en"
#   fi
# 
#   if [ -d "data/$lang/$lang-mono" ]; then
#      lang_dir=data/$lang/$lang-mono
#      # only contains monolingual train data
#      # tokenize files
#      python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/mono.$lang $lang_dir/mono.tok.$lang $lang
#      src_train="$src_train $lang_dir/mono.tok.$lang"
#      tgt_train="$tgt_train $lang_dir/mono.tok.$lang"
#   fi
# done;
# 
# # create a combined train data
# cat $src_train > data/train.all.$SRC
# cat $tgt_train > data/train.all.$TGT
# 
spm_dir=data/spm
# mkdir -p $spm_dir
# # Train a Joint Sentencepiece Model
# spm_train --input data/train.all.$SRC --model_prefix $spm_dir/spm_$SRC --vocab_size $VOCS
# spm_train --input data/train.all.$TGT --model_prefix $spm_dir/spm_$TGT --vocab_size $VOCS

# # We have to append target token (__en__,  __ml__ etc.) before each sentence
src_train=''
src_test=''
src_dev=''
tgt_train=''
tgt_test=''
tgt_dev=''

for lang in ${lang_list[@]}; do
  echo $lang;

  if [ -d "data/$lang/$lang-en" ]; then
     lang_dir=data/$lang/$lang-en 
     # tokenize files
     for f in test dev; do
       python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/$f.$lang $lang_dir/$f.tok.$lang $lang
       python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/$f.en $lang_dir/$f.tok.en en
     done  
     # Apply spm
     for f in $splits; do
       spm_encode --model $spm_dir/spm_$SRC.model < $lang_dir/$f.tok.$lang > $lang_dir/$f.sp.$lang
       spm_encode --model $spm_dir/spm_$TGT.model < $lang_dir/$f.tok.en > $lang_dir/$f.sp.en
       prefix="__2en__"
       sed -i "s/^/$prefix /" $lang_dir/$f.sp.$lang
     done
     src_train="$src_train $lang_dir/train.sp.$lang"
     src_test="$src_test $lang_dir/test.sp.$lang" 
     src_dev="$src_dev $lang_dir/dev.sp.$lang"
     tgt_train="$tgt_train $lang_dir/train.sp.en"
     tgt_test="$tgt_test $lang_dir/test.sp.en" 
     tgt_dev="$tgt_dev $lang_dir/dev.sp.en"
  fi

  if [ -d "data/$lang/en-$lang" ]; then
     lang_dir=data/$lang/en-$lang
     # tokenize files
     for f in test dev; do
       python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/$f.$lang $lang_dir/$f.tok.$lang $lang
       python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/$f.en $lang_dir/$f.tok.en en
     done  
     # Apply spm
     for f in $splits; do
       spm_encode --model $spm_dir/spm_$SRC.model < $lang_dir/$f.tok.en > $lang_dir/$f.sp.en
       spm_encode --model $spm_dir/spm_$TGT.model < $lang_dir/$f.tok.$lang > $lang_dir/$f.sp.$lang
       prefix="__2$lang"; prefix+="__"
       sed -i "s/^/$prefix /" $lang_dir/$f.sp.en
     done
     src_train="$src_train $lang_dir/train.sp.$lang"
     src_test="$src_test $lang_dir/test.sp.$lang" 
     src_dev="$src_dev $lang_dir/dev.sp.$lang"
     tgt_train="$tgt_train $lang_dir/train.sp.en"
     tgt_test="$tgt_test $lang_dir/test.sp.en" 
     tgt_dev="$tgt_dev $lang_dir/dev.sp.en"
  fi

  if [ -d "data/$lang/en-mono" ]; then
     lang_dir=data/$lang/en-mono
     # mono directory now has tokenized mono data
     cp $lang_dir/mono.tok.en $lang_dir/copy.tok.en
     spm_encode --model $spm_dir/spm_$SRC.model < $lang_dir/mono.tok.en > $lang_dir/mono.sp.en
     spm_encode --model $spm_dir/spm_$TGT.model < $lang_dir/copy.tok.en > $lang_dir/copy.sp.en
     prefix="__2en__"
     sed -i "s/^/$prefix /" $lang_dir/mono.sp.en
     src_train="$src_train $lang_dir/mono.sp.en"
     tgt_train="$tgt_train $lang_dir/copy.sp.en"
  fi

  if [ -d "data/$lang/$lang-mono" ]; then
     lang_dir=data/$lang/$lang-mono
     # only contains monolingual tokenized data
     cp $lang_dir/mono.tok.$lang $lang_dir/copy.tok.$lang
     spm_encode --model $spm_dir/spm_$SRC.model < $lang_dir/mono.tok.$lang > $lang_dir/mono.sp.$lang
     spm_encode --model $spm_dir/spm_$TGT.model < $lang_dir/copy.tok.$lang > $lang_dir/copy.sp.$lang
     prefix="__2$lang"; prefix+="__"
     sed -i "s/^/$prefix /" $lang_dir/mono.sp.$lang
     src_train="$src_train $lang_dir/mono.sp.$lang"
     tgt_train="$tgt_train $lang_dir/copy.sp.$lang"
  fi
  
#  if [ -d "data/$lang/en-en" ]; then
#     lang_dir=data/$lang/en-en
#     # en-en directory has phraseout parallel data
#     python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/original.en $lang_dir/original.tok.en en
#     python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/phraseout.en $lang_dir/phraseout.tok.en en
#     spm_encode --model $spm_dir/spm_$SRC.model < $lang_dir/phraseout.tok.en > $lang_dir/phraseout.sp.en
#     spm_encode --model $spm_dir/spm_$TGT.model < $lang_dir/original.tok.en > $lang_dir/original.sp.en
#     prefix="__2en__"
#     sed -i "s/^/$prefix /" $lang_dir/phraseout.sp.en
#     src_train="$src_train $lang_dir/phraseout.sp.en"
#     tgt_train="$tgt_train $lang_dir/original.sp.en"
#  fi
  
  if [ -d "data/$lang/$lang-$lang" ]; then
     lang_dir=data/$lang/$lang-$lang
     # hi-hi directory contains monolingual phraseout data
     python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/original.$lang $lang_dir/original.tok.$lang $lang
     python ~/lib/indicnlp/indicnlp/tokenize/indic_tokenize.py $lang_dir/phraseout.$lang $lang_dir/phraseout.tok.$lang $lang
     spm_encode --model $spm_dir/spm_$SRC.model < $lang_dir/phraseout.tok.$lang > $lang_dir/phraseout.sp.$lang
     spm_encode --model $spm_dir/spm_$TGT.model < $lang_dir/original.tok.$lang > $lang_dir/original.sp.$lang
     prefix="__2$lang"; prefix+="__"
     sed -i "s/^/$prefix /" $lang_dir/phraseout.sp.$lang
     src_train="$src_train $lang_dir/phraseout.sp.$lang"
     tgt_train="$tgt_train $lang_dir/original.sp.$lang"
  fi
done;

create combined train, test and dev data
cat $src_train > data/train.sp.$SRC
cat $src_test > data/test.sp.$SRC
cat $src_dev > data/dev.sp.$SRC
cat $tgt_train > data/train.sp.$TGT
cat $tgt_test > data/test.sp.$TGT
cat $tgt_dev > data/dev.sp.$TGT


FAIR=~/lib/fairseq
# python $FAIR/preprocess.py -s $SRC -t $TGT --trainpref data/train.sp --validpref data/dev.sp --testpref data/test.sp --destdir data-bin/

python $FAIR/preprocess.py  -s $SRC -t $TGT \
--srcdict data-bin/dict.$SRC.txt --tgtdict data-bin/dict.$TGT.txt \
--trainpref data/train.sp --validpref data/dev.sp --testpref data/test.sp

mkdir -p $CKPT_DIR
# ConvS2S model
# python $FAIR/train.py data-bin/  
#       --lr 0.25 --clip-norm 0.1 --dropout 0.2 --max-tokens 4000 
#       --arch fconv_iwslt_de_en --save-dir $CKPT_DIR

# ConvS2S wmt_en_de
python $FAIR/train.py data-bin/ \
      --reset-optimizer --reset-lr-scheduler \
      --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
      --lr-scheduler inverse_sqrt \
      --lr 0.001 --min-lr 1e-09 --update-freq 16 \
      --clip-norm 0.0 --dropout 0.2 --max-tokens 4000 \
      --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
      --arch fconv_wmt_en_de --save-dir $CKPT_DIR --restore-file "checkpoint_last.pt" \
      # --no-progress-bar
      # --lr-scheduler fixed --force-anneal 50  
      # --reset-optimizer # --reset-lr-scheduler \
      # --reset-lr-scheduler \
      # --warmup-init-lr 1e-05 --warmup-updates 4000 \

# Transformer Model
#python $FAIR/train.py data-bin/ --arch transformer \
#  --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
#  --lr-scheduler inverse_sqrt --warmup-init-lr 1e-07 --warmup-updates 4000 \
#  --lr 0.001 --min-lr 1e-09 \
#  --dropout 0.3 --weight-decay 0.0 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
#  --max-tokens 3584 --update-freq 32 --save-dir $CKPT_DIR

mkdir -p gen
CKPT=$CKPT_DIR/checkpoint_best.pt
python $FAIR/generate.py data-bin/ --path $CKPT --beam 5 --batch-size 128 > gen/gen.out

grep ^H gen/gen.out | cut -f3 | sed 's/ //g' | sed 's/▁/ /g' | sed 's/^ //g' > gen/gen.sys
grep ^T gen/gen.out | cut -f2 | sed 's/ //g' | sed 's/▁/ /g' | sed 's/^ //g' > gen/gen.ref
python $FAIR/score.py --ref gen/gen.ref --sys gen/gen.sys
                       
# copy checkpoint to local directory
# mkdir -p $4
# cp $CKPT/checkpoint_best.pt $4/

# for lang in $lang_list; do
#   bash bleus.sh $SRC $TGT $lang $CKPT;
# done;

