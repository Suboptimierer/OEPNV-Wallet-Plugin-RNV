// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OEPNV-Wallet-Plugin-RNV",
    products: [
        .library(name: "OEPNVWalletPluginRNV", targets: ["OEPNVWalletPluginRNV"]),
    ],
    dependencies: [
        .package(url: "../OEPNV-Wallet-Plugin-API", branch: "main"),
    ],
    targets: [
        .target(name: "OEPNVWalletPluginRNV", dependencies: [
            .product(name: "OEPNVWalletPluginAPI", package: "OEPNV-Wallet-Plugin-API")
        ]),
        .testTarget(name: "OEPNVWalletPluginRNVTests", dependencies: ["OEPNVWalletPluginRNV"]),
    ]
)
