//
//  PluginRNV.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 10.02.25.
//

import Foundation
import OEPNVWalletPluginAPI

public struct PluginRNV: OEPNVWalletPlugin {
    
    public init() {}
    
    public let information = OEPNVWalletPluginInformation(
        gitRepositoryURL: URL(string: "https://github.com/Suboptimierer/OEPNV-Wallet-Plugin-RNV")!,
        authorName: "Jonas Sannewald",
        authorURL: URL(string: "https://sannewald.com")!,
        associationName: "Rhein-Neckar-Verkehr GmbH",
        associationAbbreviation: "rnv",
        associationSpecialNotice: nil,
        associationAuthURLs: [
            URL(string: "https://abo.rnv-online.de")!,
            URL(string: "https://apps.apple.com/de/app/rnv-vrn-handy-ticket/id1259806111")!
        ],
        associationAuthType: OEPNVWalletPluginAuthType.emailAndPassword,
        supportedTickets: ["Deutschlandticket", "D-Ticket JugendBW"]
    )
    
}

// TODO: Weitere Funktionalitäten über Extensions in separaten Files...
