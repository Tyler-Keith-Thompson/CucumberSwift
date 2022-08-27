// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CucumberSwift",
    platforms: [.iOS(.v10), .macOS(.v10_12), .tvOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CucumberSwift",
            targets: ["CucumberSwift_ObjC", "CucumberSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/Tyler-Keith-Thompson/CucumberSwiftExpressions.git", from: "0.0.7"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
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
            dependencies: [
                "CucumberSwiftExpressions",
                "CucumberSwift_ObjC"
            ],
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
            ])
    ]
)
