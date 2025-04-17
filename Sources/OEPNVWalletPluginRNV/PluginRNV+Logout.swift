//
//  PluginRNV+Logout.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginRNV {
    
    func logout(auth: String, using client: OEPNVWalletClient) async throws {
        
        struct LogoutRequestBody: Encodable {}
        
        struct SyncResponseBody: Decodable {}
        
        let logoutRequestBody = LogoutRequestBody()
        let logoutRequestBodyJSON = try JSONEncoder().encode(logoutRequestBody)
        
        guard let bodyString = String(data: logoutRequestBodyJSON, encoding: .utf8) else {
            throw OEPNVWalletPluginError.internalFailed(description: "HTTP-Body konnte nicht erstellt werden.")
        }
        
        let timestamp = Timestamp.generate()
        let contentType = "application/json"
        
        let xApiSignature = XAPISignature.generate(
            body: bodyString,
            path: "/index.php/mobileService/logout",
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
            url: "https://tickets.rnv-online.de/index.php/mobileService/logout",
            body: logoutRequestBodyJSON
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard let logoutResponseBody = clientResponse.body else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein HTTP-Body vorhanden: \(clientResponse.status), \(clientResponse.headers)")
        }
                
        guard let _ = try? JSONDecoder().decode([String].self, from: logoutResponseBody) else {
            if let error = try? JSONDecoder().decode(APIError.self, from: logoutResponseBody) {
                throw OEPNVWalletPluginError.authenticationFailed(description: "\(error.message)")
            } else {
                throw OEPNVWalletPluginError.parsingFailed(description: "Keine lesbare Antwort vorhanden: \(String(data: logoutResponseBody, encoding: .utf8) ?? "Fehler")")
            }
        }
        
    }
    
}
