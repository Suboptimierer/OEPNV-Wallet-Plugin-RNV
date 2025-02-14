// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OEPNV-Wallet-Plugin-RNV",
    products: [
        .library(name: "OEPNVWalletPluginRNV", targets: ["OEPNVWalletPluginRNV"]),
    ],
    dependencies: [
        // TODO: Vor Veröffentlichung branch entfernen
        .package(url: "https://github.com/Suboptimierer/OEPNV-Wallet-Plugin-API.git", branch: "main"),
    ],
    targets: [
        .target(name: "OEPNVWalletPluginRNV", dependencies: [
            .product(name: "OEPNVWalletPluginAPI", package: "OEPNV-Wallet-Plugin-API")
        ]),
        .testTarget(name: "OEPNVWalletPluginRNVTests", dependencies: ["OEPNVWalletPluginRNV"]),
    ]
)
