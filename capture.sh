set -u 


set_env1(){
export PATH="$PATH:/usr/games/"
export dir_product=/tmp/session
export dir_artifacts=${CIRCLE_ARTIFACTS:-$HOME}
}
ensure1(){
test -d $dir_product || { mkdir -p $dir_product; }
}

apt1(){
commander sudo apt-get -y -q update
commander npm install -g image-to-ascii
#libnotify-bin firefox 
#imagemagick
#cp: https://github.com/brownman/install_config_test/blob/master/install/apt.sh
while read line;do
commander "sudo apt-get install -y -q ${line}"
done <<START
graphicsmagick
firefox
xcowsay
xvfb
x11-utils
x11-apps
dbus-x11 
START
#imagemagick
}

print_single(){
local file=$1
node <<SETVAR
require("image-to-ascii")("$file", function (err, result) {
    console.log(err || result);
});
SETVAR

}

print_many(){
  local list_png=$( ls -1 $dir_product/*.png )
    for item in $list_png;do
    file=$dir_product/$item
    test -f $file
    print_single $file
    done


}

capture1(){
  local file="$dir_product/session_$(date +%s).png"
  commander "import -window root $file"
}
capture2(){
  local file
  
  while true;do
  file="$dir_product/session_$(date +%s).png"
  commander "import -window root $file"
  sleep 1
  done
}

debug_screen(){
#commander xwininfo -root -tree
firefox &
xcowsay -t 3  "x11 test" &
}

ensure_apt(){
commander which xcowsay 
commander whereis xcowsay 
}

steps(){
  set_env1
  ensure1
  
  apt1
  ensure_apt
  
  debug_screen
  capture2 &
  sleep 5
  print_many
  cp $dir_product/*.png $dir_artifacts
}

steps
