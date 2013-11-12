#!/bin/bash

#
# This script tests that playbook steps are running fine
# The Vagrant machines must be up and running, and the host provisionned
#
# The script runs the whole suite when called without arguments:
#
#   $ test/run.sh 
#   Checking playbook apache for step-04         success
#   Checking playbook apache for step-05         success
#   ...
#   Checking playbook site for step-12           success
#   Ran 11 : 11 ok, 0 failures
#   $
#
# The script will run a specific step if called with an argument :
#
#   $ test/run.sh step-12/site.yml 
#   Checking playbook site for step-12           success
#   Ran 1 : 1 ok, 0 failures
#   $
#

errors=0
success=0

result=""

RED="\033[31m"
GREEN="\033[32m"
NORMAL="\033[0m"

# Check current directory
if [[ $0 != "test/run.sh" ]]; then
  echo Sorry, I can only be run from the top level directory
fi

# Remove old logs
rm -f test/step-*.log

default=$(grep -A1 ^default test/expectations 2> /dev/null | tail -1 | sed -e 's/^[ \t]*//')

list=$1

if [[ -z $1 ]]; then
  list=$(find . -maxdepth 2 -name *.yml | grep -v "step-00" | sort)
fi

for pbook in $list; do
  # Find base step directory name and playbook name
  step=$(basename $(dirname $pbook))
  book=$(basename $pbook)
  book=${book%.*}

  log="test/"$step"_"$book".log"

  # Execute playbook at step
  printf "%-45s%s" "Checking playbook $book for $step "
  ansible-playbook -i ./$step/hosts $pbook 2>&1 > $log

  # Get output
  got=$(grep "ok=.*changed=.*unreachable=.*failed=" $log | tr '\n' ' ')

  # Get expectation
  expect=$(grep -A1 "$step.*:" test/expectations 2> /dev/null | tail -1 | sed -e 's/^[ \t]*//')

  # Use default if no expectation is found
  if [[ "x$expect" == "x" ]]; then
    expect=$default
  fi
    
  echo -e "TEST expected : ($expect)" >> $log
  echo -e "TEST got      : ($got)" >> $log

  # Check if an error occured
  if ! cat $log | grep "$expect" >> $log 2>&1; then
    errors=$[errors+1]
    echo -e $RED"failed"$NORMAL"...please check log ($log)"
    echo -e "\texpected : ($expect)" | tee -a $log
    echo -e "\tgot      : ($got)" | tee -a $log
  else
#    rm $log
    success=$[success + 1]
    echo -e $GREEN"success"$NORMAL
  fi
done

echo -e "Ran $((success + errors)) : $GREEN$success ok$NORMAL, $RED$errors failures$NORMAL"

