#!/bin/bash

#  check-localadmin.sh
#  localadmin-mac-140306
#
#  Created by Yngve Åström on 2014-03-07.
#
#

# This is dependent on a configuration profile with the user_short_name key in it.
# If you want to use something else line 20 is your key target.



# Test if file exist if not quit.
if [[ -f "/private/var/tmp/fuzzy/JagvillbliADMIN" ]]; then
# Gather some basic info
  FILETIME=$(echo $(stat -f "%m" "/private/var/tmp/fuzzy/JagvillbliADMIN") + 7200 | bc)
  LUSER=$(stat -f "%Su" /private/var/tmp/fuzzy/JagvillbliADMIN)
  OWNER=$(/usr/bin/python -c 'from Foundation import CFPreferencesCopyAppValue; print CFPreferencesCopyAppValue('\""user_long_name"\"', "com.makemeadmin.computer")')
else
    exit 0
fi

# Check if the current user is assigned to the computer
if [[ "$LUSER" != "$OWNER" ]]; then
  logger "Non owner $LUSER Tried to become admin!"
  echo "$(date) Non owner $LUSER Tried to become admin!" >> /var/log/fuzzy.log
  su $LUSER -c '/Library/Management/MakeMeAdmin/NotOwnerDialog'
  rm "/private/var/tmp/fuzzy/JagvillbliADMIN"
  exit 0
else
  # Nice a valid user how is assigned the computer is running this.
  # TEST IF GROUP EXISTS
  if [[ -z $(dscl . readall /groups RecordName | grep "ladmins" | awk '{print $2}') ]]; then
    # Create group
    sudo /usr/sbin/dseditgroup -o create -n /Local/Default -r "Local Admins" ladmins
    sudo /usr/sbin/dseditgroup -o edit -a ladmins -t group admin
  fi

  # Add user to ladmin group
  if [[ $( /usr/sbin/dseditgroup -o checkmember -m $LUSER ladmins | awk '{print $1;}' ) = "no" ]]; then
    sudo /usr/sbin/dseditgroup -o edit -a $LUSER -t user ladmins
    echo "$(date) $LUSER Granted admin access $(date)" >> /var/log/fuzzy.log
    logger "$LUSER Granted admin access $(date)"

    # Add an admin count
    if [[ ! -e /var/fuzzycount ]]; then
      touch /var/fuzzycount
      echo "1" >> /var/fuzzycount
    fi

    # Track how manytimes the user has used the admin function.
    if [[ $FILETIME < $( date +%s ) ]]; then
      A=""
      A=$(cat /var/fuzzycount)
      A=$(echo $A + 1 | bc)
      rm /var/fuzzycount
      echo $A >> /var/fuzzycount
    fi
  fi

fi

# Remove the tracker file after 2h.
if [[ $FILETIME < $( date +%s ) ]]; then
  # Revoke the admin access
  if [[ $( /usr/sbin/dseditgroup -o checkmember -m $LUSER ladmins | awk '{print $1;}' ) = "yes" ]]; then
    sudo /usr/sbin/dseditgroup -o edit -d $LUSER -t user ladmins
    echo "$(date) $LUSER Admin access for user: $LUSER revoked"  >> /var/log/fuzzy.log
    logger "Admin access for user: $LUSER revoked"
    # Just incase the user added themself to admin...
    if [[ $( /usr/sbin/dseditgroup -o checkmember -m $LUSER admin | awk '{print $1;}' ) = "yes" ]]; then
      sudo /usr/sbin/dseditgroup -o edit -d $LUSER -t user admin
    fi
  fi
  rm "/private/var/tmp/fuzzy/JagvillbliADMIN"
fi

exit 0
