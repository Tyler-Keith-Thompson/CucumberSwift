# get the latest code
git reset --hard origin/master
git clean -df

# do the podspec stuff
# npm install -g podspec-bump #uncomment if you need the node package
npm install simple-plist
podspec-bump -w

# commit the podspec bump
node edit-plist.js `podspec-bump --dump-version`
git commit -am "[CI-Skip] publishing pod version: `podspec-bump --dump-version`" 
git tag "`podspec-bump --dump-version`"
git push origin HEAD -u $(podspec-bump --dump-version)
git reset --hard
git clean -df
pod trunk push CucumberSwift.podspec