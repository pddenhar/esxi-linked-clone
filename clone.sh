set -e

readonly NUMARGS=$#
readonly INFOLDER=$1
readonly OUTFOLDER=$2

usage() {
  echo "USAGE: ./clone.sh base_image_folder out_folder"
}
makeandcopy() {
  mkdir "$OUTFOLDER"
  cp "$INFOLDER"/*-"$VMFILE"* "$OUTFOLDER"/
  cp "$INFOLDER"/*.vmx "$OUTFOLDER"/
}
main() {
  if [ $NUMARGS -le 1 ]
  then
    usage
    exit 1
  fi
  
  if echo "$INFOLDER" | grep "[[:space:]]"
  then
    echo '$INFOLDER cannot contain spaces!'
    exit 1
  fi
  
  if echo "$INFOLDER" | grep "/"
  then
    echo '$INFOLDER cannot contain slashes!'
    exit 1
  fi 
  
  VMFILE=`grep -E "(scsi|sata)0\:0\.fileName" "$INFOLDER"/*.vmx | grep -o "[0-9]\{6,6\}"`
  if [ -z "$VMFILE" ]
  then
    echo "No $VMFILE found!"
    exit 1
  fi  

  makeandcopy

  #reference snapshot
  SNAPSHOT=`grep -o "[^\"]*.vmsn" "$INFOLDER"/*.vmx || (cd "$INFOLDER" && ls -r *.vmsn) | tail -1`
  if [ -n "$SNAPSHOT" ]
  then
    sed -i -e '/checkpoint.vmState =/s/= .*/= "..\/'$INFOLDER'\/'$SNAPSHOT'"/' $OUTFOLDER/*.vmx
    sed -i -e 's/checkpoint.vmState.readOnly = "FALSE"/checkpoint.vmState.readOnly = "TRUE"/' $OUTFOLDER/*.vmx
  fi

  local fullbasepath=$(readlink -f "$INFOLDER")/
  cd "$OUTFOLDER"/
  sed -i '/sched.swap.derivedName/d' ./*.vmx #delete swap file line, will be auto recreated
  sed -i -e '/displayName =/ s/= .*/= "'$OUTFOLDER'"/' ./*.vmx #Change display name config value
  local escapedpath=$(echo "$fullbasepath" | sed -e 's/[\/&]/\\&/g')
  sed -i -e '/parentFileNameHint=/ s/="/="'"$escapedpath"'/' ./*-"$VMFILE".vmdk #change parent disk path

  # Forces generation of new MAC + DHCP, I think.
  sed -i '/ethernet0.generatedAddress/d' ./*.vmx
  sed -i '/ethernet0.addressType/d' ./*.vmx

  # Forces creation of a fresh UUID for the VM.  Obviates the need for the line
  # commented out below:
  #echo 'answer.msg.uuid.altered="I copied it" ' >>./*.vmx
  sed -i '/uuid.location/d' ./*.vmx
  sed -i '/uuid.bios/d' ./*.vmx

  # Things that ghetto-esxi-linked-clones.sh did that we might want.  I can only guess at their use/value.
  #sed -i '/scsi0:0.fileName/d' ${STORAGE_PATH}/$FINAL_VM_NAME/$FINAL_VM_NAME.vmx
  #echo "scsi0:0.fileName = \"${STORAGE_PATH}/${GOLDEN_VM_NAME}/${VMDK_PATH}\"" >> ${STORAGE_PATH}/$FINAL_VM_NAME/$FINAL_VM_NAME.vmx
  #sed -i 's/nvram = "'${GOLDEN_VM_NAME}.nvram'"/nvram = "'${FINAL_VM_NAME}.nvram'"/' ${STORAGE_PATH}/$FINAL_VM_NAME/$FINAL_VM_NAME.vmx
  #sed -i 's/extendedConfigFile = "'${GOLDEN_VM_NAME}.vmxf'"/extendedConfigFile = "'${FINAL_VM_NAME}.vmxf'"/' ${STORAGE_PATH}/$FINAL_VM_NAME/$FINAL_VM_NAME.vmx

  # delete machine id
  sed -i '/machine.id/d' *.vmx

  # add machine id
  sed -i -e "\$amachine.id=$OUTFOLDER" *.vmx
 
  # Register the machine so that it appears in vSphere.
  FULL_PATH=`pwd`/*.vmx
  VMID=`vim-cmd solo/registervm $FULL_PATH`

  # Power on the machine.
  vim-cmd vmsvc/power.on $VMID
}

main
