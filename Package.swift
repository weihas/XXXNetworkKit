// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XXXNetworkKit",
    platforms: [.iOS(.v13),.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "XXXNetworkKit",
            targets: ["XXXNetworkKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XXXNetworkKit",
            dependencies: ["Moya","SwiftyJSON", "XXXNetworkModel"]
        ),
        .target(
            name: "XXXNetworkModel",
        ),
        .testTarget(
            name: "XXXNetworkKitTests",
            dependencies: ["XXXNetworkKit", "XXXNetworkModel"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
