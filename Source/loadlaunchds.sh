#!/bin/sh

#  loadlaunchds.sh
#  localadmin-mac-140306
#
#  Created by Yngve Åström on 2014-03-31.
#
/bin/ln -fs /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession /Library/Management/CGCSession
/bin/launchctl load /Library/LaunchDaemons/com.astrom.makemeadmin.plist
exit 0
