# Deletes a cloned VM created by clone.sh.
if [ $# -le 0 ]
then
  echo "USAGE: ./deleteclone.sh vm_name"
  exit 1
fi
readonly VMNAME=$1

VMID=$(vim-cmd vmsvc/getallvms | awk "/^[0-9]+ +$VMNAME /{print \$1}")
vim-cmd vmsvc/power.off $VMID
vim-cmd vmsvc/unregister $VMID
rm -rf $VMNAME
