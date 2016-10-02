#!/bin/bash

# Get options
tname="cloud.json"
tfile="$(cd "$(dirname "${tname}")"; pwd)/$(basename "${tname}")"
kname="minecraft"

# Determine if running on Windows (affects template file argument to aws cli)
platform=`uname`
if [[ ${platform} == *"MINGW"* ]]; then
  echo "Using Windows file path"
  tfile=`cygpath -w ${tfile} | sed -e 's/[\/]/\/\//g'`
else
  echo "Using Linux file path"
fi

echo $tfile

# Delete old keypair
aws ec2 delete-key-pair --key-name ${kname} --region us-east-1

# Create and save EC2 key pair
aws ec2 create-key-pair --key-name ${kname} --output text --region us-east-1 | sed 's/.*BEGIN.*-$/-----BEGIN RSA PRIVATE KEY-----/' | sed "s/.*${kname}$/-----END RSA PRIVATE KEY-----/" > ${kname}.pem
chmod 600 ${kname}.pem

# Load file content
cdata0=`./encode.sh install/common0.sh`
cdata1=`./encode.sh install/common1.sh`
cdata2=`./encode.sh install/common2.sh`
idata=`./encode.sh install/install.sh`

# Build command
cmd="aws cloudformation create-stack --stack-name minecraft --template-body \"file://${tfile}\" --capabilities CAPABILITY_IAM --region us-east-1 --parameters ParameterKey=KeyName,ParameterValue=${kname}"

if [[ -n "$cdata0" ]]; then
  cmd="${cmd} ParameterKey=CommonData0,ParameterValue=\"${cdata0}\""
fi

if [[ -n "$cdata1" ]]; then
  cmd="${cmd} ParameterKey=CommonData1,ParameterValue=\"${cdata1}\""
fi

if [[ -n "$cdata2" ]]; then
  cmd="${cmd} ParameterKey=CommonData2,ParameterValue=\"${cdata2}\""
fi

if [[ -n "$idata" ]]; then
  cmd="${cmd} ParameterKey=InstallData,ParameterValue=\"${idata}\""
fi

# Execute cmd
eval $cmd
