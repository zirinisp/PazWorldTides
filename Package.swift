// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "PazWorldTides",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 17),
        // This was causing issues with bluemix, as there were two SwiftyJSON Packages. So we had to move to IBM
        //.Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", majorVersion: 3)
        .Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0)
    ],
    exclude: ["Makefile", "Package-Builder", "Carthage", "build", "Pods"])
