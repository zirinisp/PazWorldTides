// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "PazWorldTides",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 17)
    ],
    exclude: ["Makefile", "Package-Builder", "Carthage", "build", "Pods"])
