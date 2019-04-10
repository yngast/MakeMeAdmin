#!/bin/bash

#  removeMakeMeAdmin.sh
#
#
#  Created by Yngve Åström on 2019-03-29.
#  Copyright (c) 2029 Yngve Åström, yngve.atrom@mac.com. All rights reserved.

# Stop LaunchD
if [[ -e /Library/LaunchDaemons/com.schibsted.makemeadmin.plist ]] ; then
  /bin/launchctl stop com.schibsted.makemeadmin
  /bin/launchctl unload com.schibsted.makemeadmin
  /bin/rm -rf /Library/LaunchDaemons/com.schibsted.makemeadmin.plist
fi

# Remove App
if [[ -e /Applications/MakeMeAdmin.app ]] ; then
  /bin/rm -rf /Applications/MakeMeAdmin.app
fi

# Remove Support script
if [[ -e /Library/Management/MakeMeAdmin ]] ; then
  /bin/rm -rf /Library/Management/MakeMeAdmin
fi

# Remove Support Files
if [[ -e /private/var/tmp/fuzzy ]] ; then
  /bin/rm -rf /private/var/tmp/fuzzy
fi

if [[ -e /var/log/makemeadmin.log ]] ; then
  /bin/rm -rf /var/log/makemeadmin.log
fi
exit 0
