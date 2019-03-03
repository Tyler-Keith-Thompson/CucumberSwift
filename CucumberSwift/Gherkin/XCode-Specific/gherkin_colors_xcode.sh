#!/usr/bin/env bash

# Adapted 31-Mar-2013 from eero_colors_xcode.sh, which was in turn based
#  on the following...
#
# Based on a shell script provided by the Go Programming Language project
# Copyright 2012 The Go Authors.  All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Modified for Gherkin by Orson Bushnell
# Copyright 2018 Asynchrony. All rights reserved.
# Provides a way for an Gherkin language specification to be installed for Xcode 4.x to
# enable syntax coloring.

set -e

# DVTFOUNDATION_DIR may vary depending on Xcode setup. Change it to reflect
# your current Xcode setup. Find suitable path with e.g.:
#
#	find / -type f -name 'DVTFoundation.xcplugindata' 2> /dev/null
#
# Example of DVTFOUNDATION_DIR's from "default" Xcode 4.x setups;
#
#	Xcode 4.1: /Developer/Library/PrivateFrameworks/DVTFoundation.framework/Versions/A/Resources/
#	Xcode 4.3: /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/
#
DVTFOUNDATION_DIR="/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/"
PLUGINDATA_FILE="DVTFoundation.xcplugindata"

PLISTBUDDY=/usr/libexec/PlistBuddy
PLIST_FILE=tmp.plist

# Provide means of deleting the Gherkin entry from the plugindata file.
if [ "$1" = "--delete-entry" ]; then
	echo "Removing Gherkin language specification entry."
	$PLISTBUDDY -c "Delete :plug-in:extensions:Xcode.SourceCodeLanguage.Gherkin" $DVTFOUNDATION_DIR/$PLUGINDATA_FILE
	echo "Run 'sudo rm -rf /var/folders/*' and restart Xcode to update change immediately."
	exit 0
fi

GHRKN_VERSION="1.0"

GHRKN_LANG_ENTRY="
	<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
	<plist version=\"1.0\">
		<dict>
			<key>Xcode.SourceCodeLanguage.Gherkin</key>
			<dict>
				<key>conformsTo</key>
				<array>
					<dict>
						<key>identifier</key>
						<string>Xcode.SourceCodeLanguage.Generic</string>
					</dict>
				</array>
				<key>documentationAbbreviation</key>
				<string>gherkin</string>
				<key>fileDataType</key>
				<array>
					<dict>
						<key>identifier</key>
						<string>org.gherkinlanguage.gherkin-source</string>
					</dict>
				</array>
				<key>id</key>
				<string>Xcode.SourceCodeLanguage.Gherkin</string>
				<key>languageName</key>
				<string>Gherkin</string>
				<key>languageSpecification</key>
				<string>xcode.lang.gherkin</string>
				<key>name</key>
				<string>The Gherkin Testing Language</string>
				<key>point</key>
				<string>Xcode.SourceCodeLanguage</string>
				<key>version</key>
				<string>$GHRKN_VERSION</string>
			</dict>
		</dict>
	</plist>
"
  
echo "Backing up $PLUGINDATA_FILE file."
cp -p $DVTFOUNDATION_DIR/$PLUGINDATA_FILE $DVTFOUNDATION_DIR/$PLUGINDATA_FILE.bak

echo "Adding Gherkin language specification entry to $PLUGINDATA_FILE."
echo $GHRKN_LANG_ENTRY > $PLIST_FILE
$PLISTBUDDY -c "Merge $PLIST_FILE plug-in:extensions" $DVTFOUNDATION_DIR/$PLUGINDATA_FILE

rm -f $PLIST_FILE
 
echo "Copying Gherkin language specification file."
cp -p Gherkin.xclangspec $DVTFOUNDATION_DIR

echo "Now start Xcode and look for 'Gherkin' in the Editor | Syntax Coloring menu."
# echo "If Gherkin.xcplugin is properly installed, Gherkin source files will be automatically detected."
#  (Gherkin.xcplugin not yet available).
