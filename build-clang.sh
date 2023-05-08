#!/bin/bash
# AOSP Builder by ItzKaguya.

function tg_sendText() {
curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
-d "parse_mode=html" \
-d text="${1}" \
-d chat_id=$CHAT_ID \
-d "disable_web_page_preview=true"
}

BUILD_START=$(date +"%s");

apt update --fix-missing
apt install git -y
apt install sudo -y
sudo apt update --fix-missing
sudo apt install git -y
git clone https://github.com/TianWalkzzMiku/llvmTC/
cd llvmTC
export LLVM_NAME=ItzKaguya-YukiClang
export TG_TOKEN=$TG_TOKEN
export TG_CHAT_ID=$TG_CHAT_ID
export GH_TOKEN=$GH_TOKEN
export GH_EMAIL=$GH_EMAIL
export GH_USERNAME=Hirozuto
export GH_PUSH_REPO_URL=https://github.com/Hirozuto/ItzKaguya-YukiClang.git
bash build-tc.sh

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));

tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
