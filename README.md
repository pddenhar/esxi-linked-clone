esxi-linked-clone
=================

A utility script to create linked clones of a base virtual machine.

To run this script, you must first have created (and presumably installed an OS on) a base virtual machine. A single snapshot of the machine must be taken from within the vSphere client prior to running the script.

After creating and snapshotting the base machine, it must be left alone. 

SSH into your ESXi host and copy clone.sh to your datastore. Run clone.sh with the first argument being the folder name of your base image and the second argument being the name of the folder you want the clone output to. 

For example:

```ShellSession
/vmfs/volumes/521bbe8d-709fe0eb-baca-0015c5e15f7c # ls
32bit Server Clone 1                    Server Clone 1                          Ubuntu Server Base (Don't Touch)
32bit Server Clone 2                    Server Clone 2                          clone.sh
Fast Controller                         Server Clone 3
Peter Test Adserver                     Ubuntu 32bit Server Base (Don't Touch)
/vmfs/volumes/521bbe8d-709fe0eb-baca-0015c5e15f7c # ./clone.sh Ubuntu\ Server\ Base\ \(Don\'t\ Touch\)/ Server\ Clone\ 4
/vmfs/volumes/521bbe8d-709fe0eb-baca-0015c5e15f7c # ls
32bit Server Clone 1                    Server Clone 1                          Ubuntu 32bit Server Base (Don't Touch)
32bit Server Clone 2                    Server Clone 2                          Ubuntu Server Base (Don't Touch)
Fast Controller                         Server Clone 3                          clone.sh
Peter Test Adserver                     Server Clone 4
```