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
        associationAuthType: OEPNVWalletPluginAuthType.emailPassword,
        supportedTickets: ["Deutschlandticket", "D-Ticket JugendBW"]
    )
    
}

extension PluginRNV {
    
    public func testAuthentication(with credentials: OEPNVWalletPluginAPI.OEPNVWalletPluginAuthCredentials, using client: OEPNVWalletPluginAPI.OEPNVWalletClient) async throws {
        
    }
    
    public func fetchTickets(with credentials: OEPNVWalletPluginAPI.OEPNVWalletPluginAuthCredentials, using client: OEPNVWalletPluginAPI.OEPNVWalletClient) async throws -> [OEPNVWalletPluginAPI.OEPNVWalletPluginTicket] {
        
        return [
            OEPNVWalletPluginAPI.OEPNVWalletPluginTicket(
                id: 0,
                type: "Deutschlandticket",
                validFrom: Date(),
                validUntil: Date(),
                updateAvailable: Date(),
                price: 0,
                holder: "",
                holderGender: "",
                holderBirthday: Date(),
                scanCode: "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"),
        ]
        
    }
    
}
