#!/bin/bash
NBS=$1
TMP_PATH="/tmp"

usage() {
  echo "./${0##*/} add 'num_1 num_2 num_3 ...'"
  echo "sample ./${0##*/} '10 7 4 3 1' for bubble sort from small to big number"
  exit 2
}

bubble_sort() {
  local sort_a=$1
  local sort_b=""
  local a_nb=""
  local b_nb=""
  local buf=""

  sort_b=$((sort_a + 1))
  a_nb=$(cat $TMP_PATH/$sort_a)
  b_nb=$(cat $TMP_PATH/$sort_b)

  if [[ "$a_nb" -gt "$b_nb" ]]; then
    buf=$a_nb
    echo "$b_nb" > $TMP_PATH/$sort_a
    echo "$buf" > $TMP_PATH/$sort_b
  fi
  #a_nb=$(cat $TMP_PATH/$sort_a)
  #b_nb=$(cat $TMP_PATH/$sort_b)
  #echo "$TMP_PATH/$sort_a:$a_nb;  $TMP_PATH/$sort_b:$b_nb"
}

sort() {
  local nbs=$1
  local i=1
  local sort_nb=1
  local sort_max=""
  local result=""

  for nb in $nbs; do
    echo $nb > $TMP_PATH/$i
    echo "i:$i  $TMP_PATH/$i:$nb"
    i=$((i+1))
  done
  # last one no need i++, so -1
  i=$((i-1))

  for((sort_nb=1;sort_nb<i;sort_nb++)); do
    sort_max=$((i-sort_nb+1))
    #echo "sort_max:$sort_max"
    for ((sort_n=1;sort_n<sort_max;sort_n++)); do
      bubble_sort "$sort_n"
    done
  done

  for((sort_nb=1;sort_nb<=i;sort_nb++)); do
    result=$(cat $TMP_PATH/$sort_nb)
    echo "$result"
  done
}

[[ -n "$NBS" ]] || usage
sort "$NBS"
