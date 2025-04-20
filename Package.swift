// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OEPNV-Wallet-Plugin-RNV",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "OEPNVWalletPluginRNV", targets: ["OEPNVWalletPluginRNV"]),
    ],
    dependencies: [
        // TODO: Vor Veröffentlichung branch entfernen
        .package(url: "https://github.com/Suboptimierer/OEPNV-Wallet-Plugin-API.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "4.0.0"),
    ],
    targets: [
        .target(name: "OEPNVWalletPluginRNV", dependencies: [
            .product(name: "OEPNVWalletPluginAPI", package: "OEPNV-Wallet-Plugin-API"),
            .product(name: "Crypto", package: "swift-crypto")
        ], resources: [ .process("Resources") ]),
        .testTarget(name: "OEPNVWalletPluginRNVTests", dependencies: ["OEPNVWalletPluginRNV"]),
    ]
)
