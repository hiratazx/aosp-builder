#!/bin/bash

function tg_sendText() {
curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
-d "parse_mode=html" \
-d text="${1}" \
-d chat_id=$CHAT_ID \
-d "disable_web_page_preview=true"
}

function tg_sendFile() {
curl -F chat_id=$CHAT_ID -F document=@${1} -F parse_mode=markdown https://api.telegram.org/bot$BOT_TOKEN/sendDocument
}

BUILD_START=$(date +"%s");

mkdir -p ~/.config/rclone
echo "$rclone_config" > ~/.config/rclone/rclone.conf
mkdir -p ~/.ssh
chmod 700 ~/.ssh
git config --global user.email "$user_email"
git config --global user.name "$user_name"

tg_sendText "Syncing rom"
mkdir -p /tmp/rom
cd /tmp/rom
repo init --no-repo-verify --depth=1 -u https://github.com/RisingTechOSS/android -b fourteen -g default,-device,-mips,-darwin,-notdefault
git clone https://github.com/hiratazx/local_manifest --depth=1 .repo/local_manifests
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j6 || repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j8

tg_sendText "Lunching"
# Normal build steps
. build/envsetup.sh
export BUILD_USERNAME=hiratazx
riseup beyond0lte userdebug
export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 20G
ccache -o compression=true
ccache -z

tg_sendText "Starting Compilation.."

rise b | tee build-ota.txt
rise fb | tee build-fastboot.txt

tg_sendText "Build completed! Uploading rom to gdrive"
rclone copy out/target/product/beyond0lte/*fastboot.zip hiratazx:ItzKaguya -P || rclone copy out/target/product/beyond0lte/*ota.zip hiratazx:ItzKaguya -P

(ccache -s && echo " " && free -h && echo " " && df -h && echo " " && ls -a out/target/product/beyond0lte/) | tee final_monitor.txt
tg_sendFile "final_monitor.txt"
tg_sendFile "build-fastboot.txt"
tg_sendFile "build-ota.txt"

#tg_sendText "Uploading new ccache to gdrive"
#cd /tmp
#tar --use-compress-program="pigz -k -1 " -cf corvus_ccache.tar.gz ccache
#rclone copy corvus_ccache.tar.gz aosp: -P

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
