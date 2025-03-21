// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CountdownKit",
  platforms: [.iOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "CountdownKit",
      targets: ["CountdownKit"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/malcommac/SwiftDate.git", from: "7.0.0"),
    .package(url: "https://github.com/imthath-m/mi-data-store", from: "0.1.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "CountdownKit",
      dependencies: [
        .product(name: "SwiftDate", package: "SwiftDate"),
        .product(name: "MIDataStore", package: "mi-data-store"),
      ]),
    .testTarget(
      name: "CountdownKitTests",
      dependencies: ["CountdownKit"]),
  ]
)
