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
        associationAuthType: .emailPassword,
        supportedTickets: ["Deutschlandticket", "D-Ticket JugendBW"]
    )
    
    public let design = OEPNVWalletPluginDesign(
        backgroundColor: .init(red: 229, green: 233, blue: 237),
        headlineColor: .init(red: 238, green: 114, blue: 2),
        textColor: .init(red: 0, green: 42, blue: 78),
        associationIcon1x: try! Data(contentsOf: Bundle.module.url(forResource: "icon", withExtension: "png")!),
        associationIcon2x: try! Data(contentsOf: Bundle.module.url(forResource: "icon@2x", withExtension: "png")!),
        associationIcon3x: try! Data(contentsOf: Bundle.module.url(forResource: "icon@3x", withExtension: "png")!),
        associationLogo1x: try! Data(contentsOf: Bundle.module.url(forResource: "logo", withExtension: "png")!),
        associationLogo2x: try! Data(contentsOf: Bundle.module.url(forResource: "logo@2x", withExtension: "png")!),
        associationLogo3x: try! Data(contentsOf: Bundle.module.url(forResource: "logo@3x", withExtension: "png")!)
    )
    
    public func testAuthentication(with credentials: OEPNVWalletPluginAPI.OEPNVWalletPluginAuthCredentials, using client: OEPNVWalletPluginAPI.OEPNVWalletClient) async throws {
        
        guard case let .emailPassword(email, password) = credentials else {
            throw OEPNVWalletPluginError.internalFailed(description: "Fehlerhafte Credentials übermittelt.")
        }
        
        do {
            let loginData = try await login(with: email, and: password, using: client)
            
            try await logout(auth: loginData.authToken, using: client)
        } catch let error as OEPNVWalletPluginError {
            throw error
        } catch {
            throw OEPNVWalletPluginError.underlyingFailed(description: error.localizedDescription)
        }
        
    }
    
    public func fetchTickets(with credentials: OEPNVWalletPluginAPI.OEPNVWalletPluginAuthCredentials, using client: OEPNVWalletPluginAPI.OEPNVWalletClient) async throws -> [OEPNVWalletPluginAPI.OEPNVWalletPluginTicket] {
        
        guard case let .emailPassword(email, password) = credentials else {
            throw OEPNVWalletPluginError.internalFailed(description: "Fehlerhafte Credentials übermittelt.")
        }
        
        do {
            let loginData = try await login(with: email, and: password, using: client)
            let syncData = try await sync(auth: loginData.authToken, using: client)
            
            var pluginTickets = [OEPNVWalletPluginAPI.OEPNVWalletPluginTicket]()
            for id in syncData.ticketIds {
                let ticketData = try await ticket(for: id, auth: loginData.authToken, using: client)
                pluginTickets.append(OEPNVWalletPluginTicket(
                    id: ticketData.id,
                    type: ticketData.type,
                    validFrom: ticketData.validFrom,
                    validUntil: ticketData.validUntil,
                    holder: ticketData.holder,
                    barcode: .base64AztecCode(ticketData.aztecCode)
                ))
            }
            
            try await logout(auth: loginData.authToken, using: client)
            
            return pluginTickets
        } catch let error as OEPNVWalletPluginError {
            throw error
        } catch {
            throw OEPNVWalletPluginError.underlyingFailed(description: error.localizedDescription)
        }
        
    }
    
}
