readonly NUMARGS=$#
readonly INFOLDER=$1
readonly OUTFOLDER=$2

usage() {
  echo "USAGE: ./clone.sh base_image_folder out_folder"
}
makeandcopy() {
  mkdir "$OUTFOLDER"
  cp "$INFOLDER"/*-000001* "$OUTFOLDER"/
  cp "$INFOLDER"/*.vmx "$OUTFOLDER"/
}
main() {
  if [  $NUMARGS -le 1 ]
  then
    usage
    exit 1
  fi

  makeandcopy

  local fullbasepath=$(readlink -f "$INFOLDER")/
  cd "$OUTFOLDER"/
  sed -i '/sched.swap.derivedName/d' ./*.vmx #delete swap file line, will be auto recreated
  sed -i -e '/displayName =/ s/= .*/= "Server Clone"/' ./*.vmx #Change display name config value
  local escapedpath=$(echo "$fullbasepath" | sed -e 's/[\/&]/\\&/g')
  sed -i -e '/parentFileNameHint=/ s/="/="'"$escapedpath"'/' ./*-000001.vmdk #change parent disk path
}

main
