#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

read -p "Enter the URL from email: " https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdownload.llamameta.net%2F*%3FPolicy%3DeyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoibVA~Pz80P1x1MDAwZiIsIlJlc291cmNlIjoiaHR0cHM6XC9cL2Rvd25sb2FkLmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2OTA0MjU4NjZ9fX1dfQ__%26Signature%3Do3n~muqxFZtz2yBrjIziKURqoxqwb0doe~rBv1v1yormWRtmQ9s-SUlZkoXq-RXRsl2vSZPmC32KEioBvurs0DIVnEo1B3-~o2Hfihe2oy0gQxT8d2CM91vZHkPzI99JAVplD7tdturSf4SngtVdv~18a9rTbmqrxq~~ud0CkaDrBLZvpX0ZWfEjSzU-1vyH7-PB4~U4RT6rFuvO5~HRrx4S4GPDa4QT3VdjSUSDA-LywG3MsmcOmJ72BZ~yxb9-YeF~uOQWxAOIUdP1Uqitf3ZQPfLVmvPy2E-GMDTRk~jydmGWoo0jZVEjJ0KRB8BSWVODJnM64UrUXUPpkjnx1Q__%26Key-Pair-Id%3DK15QRJLYKIFSLZ&data=05%7C01%7C%7C45e9adfe749a44515f5e08db8d823ce2%7C84df9e7fe9f640afb435aaaaaaaaaaaa%7C1%7C0%7C638259362729543226%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=QdhkOcux5BiCM0qkTvD6pfb%2FsOE8oaY8oKj9dDLXxmo%3D&reserved=0
echo ""
read -p "Enter the list of models to download without spaces (7B,13B,70B,7B-chat,13B-chat,70B-chat), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE="7B,13B,70B,7B-chat,13B-chat,70B-chat"
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"

echo "Downloading tokenizer"
wget ${PRESIGNED_URL/'*'/"tokenizer.model"} -O ${TARGET_FOLDER}"/tokenizer.model"
wget ${PRESIGNED_URL/'*'/"tokenizer_checklist.chk"} -O ${TARGET_FOLDER}"/tokenizer_checklist.chk"
(cd ${TARGET_FOLDER} && md5sum -c tokenizer_checklist.chk)

for m in ${MODEL_SIZE//,/ }
do
    if [[ $m == "7B" ]]; then
        SHARD=0
        MODEL_PATH="llama-2-7b"
    elif [[ $m == "7B-chat" ]]; then
        SHARD=0
        MODEL_PATH="llama-2-7b-chat"
    elif [[ $m == "13B" ]]; then
        SHARD=1
        MODEL_PATH="llama-2-13b"
    elif [[ $m == "13B-chat" ]]; then
        SHARD=1
        MODEL_PATH="llama-2-13b-chat"
    elif [[ $m == "70B" ]]; then
        SHARD=7
        MODEL_PATH="llama-2-70b"
    elif [[ $m == "70B-chat" ]]; then
        SHARD=7
        MODEL_PATH="llama-2-70b-chat"
    fi

    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
done

