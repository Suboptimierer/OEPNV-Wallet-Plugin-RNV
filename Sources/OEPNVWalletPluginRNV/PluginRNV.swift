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
    
    public let gitRepositoryURL = URL(string: "https://github.com/Suboptimierer/OEPNV-Wallet-Plugin-RNV")!
    public let authorName = "Jonas Sannewald"
    public let authorURL = URL(string: "https://sannewald.com")!
    
    public let associationName = "Rhein-Neckar-Verkehr GmbH"
    public let associationAbbreviation = "rnv"
    public let associationSpecialNotice: String? = nil
    public let associationAuthURLs = [
        URL(string: "https://abo.rnv-online.de")!,
        URL(string: "https://apps.apple.com/de/app/rnv-vrn-handy-ticket/id1259806111")!
    ]
    public let associationAuthType = OEPNVWalletPluginAuthType.emailAndPassword
    
    public let supportedTickets = ["Deutschlandticket", "D-Ticket JugendBW"]
    
}
