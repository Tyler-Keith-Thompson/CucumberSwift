var plist = require('simple-plist');
var data = plist.readFileSync('CucumberSwift/Info.plist');
data.CFBundleVersion = process.argv[2].toString();
plist.writeFileSync('CucumberSwift/Info.plist', data);
