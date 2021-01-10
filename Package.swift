// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CucumberSwift",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CucumberSwift",
            targets: ["CucumberSwift_ObjC", "CucumberSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CucumberSwift_ObjC",
            dependencies: [],
            path: "Sources/Obj-C BS",
            publicHeadersPath: "Include"),
        .target(
            name: "CucumberSwift",
            dependencies: ["CucumberSwift_ObjC"],
            path: "Sources/CucumberSwift",
            exclude: ["Info.plist"],
            resources: [
                .copy("Gherkin/XCode-Specific/"),
                .copy("Gherkin/gherkin-languages.json")
            ]),
        .testTarget(
            name: "CucumberSwiftTests",
            dependencies: ["CucumberSwift"],
            exclude: ["Info.plist", "CucumberTests/CucumberSwift.xctestplan"],
            resources: [
                .copy("testdata"),
                .copy("Features")
            ]),
        .testTarget(
            name: "CucumberSwiftConsumerTests",
            dependencies: ["CucumberSwift"],
            exclude: ["Info.plist"],
            resources: [
                .copy("Features")
            ]),
        .testTarget(
            name: "CucumberSwiftDSLConsumerTests",
            dependencies: ["CucumberSwift"],
            exclude: ["Info.plist"],
            resources: [
                .copy("Features")
            ]),
    ]
)
