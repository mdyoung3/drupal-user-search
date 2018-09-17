#!/bin/bash
#This script checks for a particular user in a Drupal site. 

HOME_DIR='/home/'

echo "Please enter the name of the user you're looking for."
read -r username
echo "$username"

touch user.log || exit

cd $HOME_DIR || exit

for path in "$HOME_DIR"*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"

    ## An array of sites to skip
    #declare -a AVOID=("qa3rtd" "qa4rtdasu" "qa5rtdasu" "resacadqa" "adlrtd" "APACHE_ARCHIVES")

    ## Loop through sites to avoid and continue loop.
    containsElement () {
      local e match="$1"
      shift
      for e; do [[ "$e" == "$match" ]] && return 0; done
      return 1
    }

    AVOID=("APACHE_ARCHIVES" "clamav")

    #containsElement $dirname "${AVOID[@]}"
    if containsElement "$dirname" "${AVOID[@]}"; then
      echo "$dirname needs to be skipped"
      read -p "Press key to continue... " -n1 -s
      echo ""
      continue
    fi

    DIR_HOME=$HOME_DIR$dirname/public_html

    cd "$DIR_HOME" || return

    echo "Directory: $DIR_HOME"
    
    if drush uinf $username | grep -q "User status   :  active"; then
        echo "$username is a in $dirname" | tee -a /root/check_for_user/user.log
        drush ublk "$username"
    lse
	echo "user not found in $DIR_HOME"
        continue
    fi

    cd $HOME_DIR || return
done
