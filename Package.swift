// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "PazWorldTides",
    dependencies: [
    .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", majorVersion: 3)
    ],
    exclude: ["Makefile", "Package-Builder", "Carthage", "build", "Pods"])
