//
//  PluginRNV+Sync.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginRNV {
    
    func sync(auth: String, using client: OEPNVWalletClient) async throws -> SyncData {
        
        struct SyncRequestBody: Encodable {
            let anonymous_tickets = [String]()
        }
        
        struct SyncResponseBody: Decodable {
            let tickets: [String]
        }
        
        let syncRequestBody = SyncRequestBody()
        let syncRequestBodyJSON = try JSONEncoder().encode(syncRequestBody)
        
        guard let bodyString = String(data: syncRequestBodyJSON, encoding: .utf8) else {
            throw OEPNVWalletPluginError.internalFailed(description: "HTTP-Body konnte nicht erstellt werden.")
        }
        
        let timestamp = Timestamp.generate()
        let contentType = "application/json"
        
        let xApiSignature = XAPISignature.generate(
            body: bodyString,
            path: "/index.php/mobileService/sync",
            eosDate: timestamp,
            contentType: contentType,
            authorization: auth
        )
        
        let clientRequest = OEPNVWalletClientRequest(
            method: .post,
            headers: [
                (name: "content-type", value: contentType),
                (name: "host", value: Constants.host),
                (name: "user-agent", value: Constants.userAgent),
                (name: "device-identifier", value: Constants.deviceIdentifier),
                (name: "x-eos-date", value: timestamp),
                (name: "x-api-signature", value: xApiSignature),
                (name: "authorization", value: auth),
            ],
            url: "https://tickets.rnv-online.de/index.php/mobileService/sync",
            body: syncRequestBodyJSON,
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard let syncResponseBody = clientResponse.body else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein HTTP-Body vorhanden.")
        }
                
        guard let syncResponseBodyJSON = try? JSONDecoder().decode(SyncResponseBody.self, from: syncResponseBody) else {
            if let error = try? JSONDecoder().decode(APIError.self, from: syncResponseBody) {
                throw OEPNVWalletPluginError.authenticationFailed(description: "\(error.message)")
            } else {
                throw OEPNVWalletPluginError.parsingFailed(description: "Keine lesbare Antwort vorhanden.")
            }
        }
        
        return SyncData(ticketIds: syncResponseBodyJSON.tickets)
        
    }
    
}
