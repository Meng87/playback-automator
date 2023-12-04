# This script automatically plays Youtube, Vimeo or Netflix videos

# Please specify the video url, duration to play video and login credentials
youtube_url= # TODO
youtube_time= # TODO

vimeo_url= # TODO
vimeo_time= # TODO

netflix_username= # TODO
netflix_password= # TODO
netflix_url= # TODO
netflix_time= # TODO
temp_folder= # TODO

function play_video {
    package=${1:?"Specify package name."}
    url=${2:?"Specify url."}
    playback_time=${3:?"Specify playback time."}
    is_tv=${4:?"Specify whether device is Android TV"}

    adb shell pm clear $package # Clear app data

    if [[ $is_tv -eq 1 ]]
    then
        adb shell am start -a android.intent.action.VIEW -d $url $package
    else
        adb shell am start -a android.intent.action.VIEW -d $url
    fi

    sleep $playback_time

    adb shell pm clear $package # Clear app data
}

function play_netflix {
    username=${1:?"Specify username."}
    pw=${2:?"Specify password."}
    url=${3:?"Specify url."}
    playback_time=${4:?"Specify playback time."}
    tmp_folder=${5:?"Specify folder where temporary files reside."}

    # Clear app data
    adb shell pm clear com.netflix.mediaclient

    # Open Netflix app
    adb shell am start -n com.netflix.mediaclient/com.netflix.mediaclient.acquisition.screens.signupContainer.SignupNativeActivity

    # Navigate to log in page
    adb shell uiautomator dump
    adb pull /sdcard/window_dump.xml $tmp_folder/mainpage.xml
    python3 $tmp_folder/parse.py mainpage.xml "SIGN IN" | xargs -I {} adb shell input tap {}

    # Log in
    adb shell input text $username
    adb shell input keyevent KEYCODE_TAB
    adb shell input text $pw

    adb shell uiautomator dump
    adb pull /sdcard/window_dump.xml $tmp_folder/login.xml
    python3 $tmp_folder/parse.py login.xml "Sign In" | xargs -I {} adb shell input tap {}

    # Play video
    adb shell am start -a android.intent.action.VIEW -d $url
    sleep $playback_time

    # Clear app data
    adb shell pm clear com.netflix.mediaclient

    # Remove files from pc
    rm $tmp_folder/mainpage.xml
    rm $tmp_folder/login.xml
}

function play_netflix_tv {
    username=${1:?"Specify username."}
    pw=${2:?"Specify password."}
    url=${3:?"Specify url."}
    playback_time=${4:?"Specify playback time."}

    # Clear app data
    adb shell pm clear com.netflix.ninja

    # Open Netflix app
    adb shell am start -n com.netflix.ninja/.MainActivity
    sleep 16

    # Navigate to log in page
    adb shell input keyevent KEYCODE_DPAD_LEFT
    adb shell input press
    sleep 1
    adb shell input keyevent KEYCODE_DPAD_RIGHT
    adb shell input press
    sleep 1

    # Log in
    adb shell input text $username
    adb shell input press
    sleep 1
    adb shell input text $pw
    adb shell input text x
    adb shell input keyevent KEYCODE_DEL
    adb shell input keyevent KEYCODE_DPAD_DOWN
    adb shell input press
    sleep 15

    # Play video
    adb shell am start -c android.intent.category.LEANBACK_LAUNCHER -a android.intent.action.VIEW -d $url -e source 30 -n com.netflix.ninja/.MainActivity
    sleep $playback_time

    # Clear app data
    adb shell pm clear com.netflix.ninja
}

# Phone
# play_video com.google.android.youtube $youtube_url $youtube_time 0
# play_video com.vimeo.android.videoapp $vimeo_url $vimeo_time 0
# play_netflix $netflix_username $netflix_password $netflix_url $netflix_time $temp_folder

# TV
# play_video com.google.android.youtube.tv $youtube_url $youtube_time 1
play_netflix_tv $netflix_username $netflix_password $netflix_url $netflix_time