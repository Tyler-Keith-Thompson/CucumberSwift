#!/bin/sh

#  copy_snippets.sh
#  CucumberSwift
#
#  Created by Tyler Thompson on 3/3/19.
#  Copyright © 2019 Tyler Thompson. All rights reserved.

mkdir -p ~/Library/Developer/Xcode/UserData/CodeSnippets/
find . -name "*.codesnippet" -exec cp -f {} ~/Library/Developer/Xcode/UserData/CodeSnippets/ \;

echo "Please restart xcode to get gherkin snippets"
