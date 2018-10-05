#!/bin/bash

query_unescape()
{
s=$(echo "$1"|sed -e"s/+/ /g")
echo -n ${s%%%*}
if [ -n "$s" ] && [ "$s" != "${s#*%}" ];then
IFS=\%
set ${s#*%}
unset IFS
for i in "$@";do
echo -n -e "\\x$(echo $i|dd bs=1 count=2 2>&-)"
echo -n ${i#??}
done
fi
}

#http server - query read/protection
process_query()
{
  if [ "$REQUEST_METHOD" = "POST" ]; then
	read QUERY_STRING
  fi

  #remove shell characters
  QUERY_STRING=$(echo $QUERY_STRING | sed 's/[$`()*]//g');

  #remove all encoded shell characters: $ `
  #remove $ because $() and with spaces $ () and $((1+1)) will execute code
  QUERY_STRING=$(echo $QUERY_STRING | sed 's#%24##g');
  QUERY_STRING=$(echo $QUERY_STRING | sed 's#%60##g');

  #setup query variables
  if [ -n "$QUERY_STRING" ]; then
	IFS=\&
	for i in $QUERY_STRING
	do
		left=${i%%=*}; right=${i#*=}
		left=$(echo $left|sed s#[^[:alnum:]]#_#g)
		right=$(query_unescape $right)
		if [ "$left" != "" ]; then eval $left=\"$right\";fi
	done
	unset IFS;
  fi
  unset i
  unset left
  unset right
}
