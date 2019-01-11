#! /bin/sh

# get kubernetes token bash script
# tomoncle

if [ -z $1 ]||[ -z $2 ]
then
   echo -e "\033[5;31mInput error, Usage: get_token.sh {namespace} {username}\033[0m"
   exit
fi

str='No resources found.'
res=`kubectl get secret -n $1 | grep $2 | awk '{print $1}'`

if [ "$str" == "$res" ]||[ -z "$res" ] 
then
   echo -e "\033[5;31m$str\033[0m"
   exit
fi

#kubectl describe secret -n $1 $res
echo -e "\033[32m$(kubectl describe secret -n $1 $res)\033[0m"
