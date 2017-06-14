#!/bin/bash
# Control the state of my AWS instances

# Requirements:
# Install & configure AWS CLI using following method

# sudo apt-get install python-pip
# sudo pip install --upgrade pip
# pip install --upgrade --user setuptools
# pip install --upgrade --user awscli
# aws configure
# Supply your AWS instances credentials

export PATH=${PATH}:~/.local/bin

scriptname=$(basename $0)
USAGE="Usage : ${scriptname} -a list|show|start|stop [-i \"instance_id(s)\"] [-h]"
HELP="Performs simple actions on AWS EC2 instances.
\n${USAGE}\n
  -a = Action (list/show/start/stop)
  -i = Instance ID(s) as space-separated inside \"\" (Defaults to stored value in script)
  -h = Show usage
\nExamples:
\nList all instance IDs
${scriptname} -a list
\nShow status of instance id i-abcdefghijklmnopq
${scriptname} -a show -i i-abcdefghijklmnopq
\nShutdown instance i-abcdefghijklmnopq
${scriptname} -a stop -i i-abcdefghijklmnopq"

while getopts a:i:h name
do
  case ${name} in
  a)    export action=${OPTARG};;
  i)    export instance_ids=${OPTARG};;
  h)    echo -e "\n${HELP}\n"; exit;;
  \?)   echo -e "\nBad usage!\n${USAGE}\n"; exit 1;;
  esac
done 2>/dev/null

#Default instance IDs unless specified
instance_ids=${instance_ids:-i-abcdefghijklmnopq}

case ${action} in
  list)
    aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text ;;
  show)
    for id in ${instance_ids}
    do
      echo -e "${id} $(aws ec2 describe-instances --instance-ids ${id} --query "Reservations[*].Instances[*].State.Name" --output text)"
    done ;;
  start)
    aws ec2 start-instances --instance-ids ${instance_ids} --output text ;;
  stop)
    aws ec2 stop-instances --instance-ids ${instance_ids} --output text ;;
  *)
    echo -e "\nUnknown actions!\n${USAGE}\n"; exit 1;;
esac

