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
temp_folder= # TODO # where temporary files will be generated

function play_video {
    package=${1:?"Specify package name."}
    url=${2:?"Specify url."}
    playback_time=${3:?"Specify playback time."}

    adb shell pm clear $package # Clear app data

    adb shell am start -a android.intent.action.VIEW -d $url
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
    
    # Click on sign in button
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

play_video com.google.android.youtube $youtube_url $youtube_time
play_video com.vimeo.android.videoapp $vimeo_url $vimeo_time
play_netflix $netflix_username $netflix_password $netflix_url $netflix_time $temp_folder