set -e

# Deletes a cloned VM created by clone.sh.
if [ $# -le 0 ]
then
  echo "USAGE: ./deleteclone.sh vm_name"
  exit 1
fi
readonly VMNAME=$1

if echo "$VMNAME" | grep "/"
then   
  echo '$VMNAME cannot contain slashes!'
  exit 1
fi

VMID=$(vim-cmd vmsvc/getallvms | awk "/^[0-9]+ +$VMNAME /{print \$1}")
if [ -n "$VMID" ]
then
  vim-cmd vmsvc/power.off $VMID
  vim-cmd vmsvc/unregister $VMID
fi
rm -rf $VMNAME
