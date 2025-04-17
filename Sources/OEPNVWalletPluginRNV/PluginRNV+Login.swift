//
//  PluginRNV+Login.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginRNV {
    
    func login(with email: String, and password: String, using client: OEPNVWalletClient) async throws -> LoginData {
        
        struct LoginRequestBody: Encodable {
            let credentials: Credentials
            
            struct Credentials: Encodable {
                let username: String
                let password: String
            }
        }
        
        struct LoginResponseBody: Decodable {
            let authorization_types: [AuthType]
            
            struct AuthType: Decodable {
                let name: String
                let type: String
                let header: Header
                
                struct Header: Decodable {
                    let name: String
                    let type: String
                    let value: String
                }
            }
        }
        
        let loginRequestBody = LoginRequestBody(credentials: LoginRequestBody.Credentials(username: email, password: password))
        let loginRequestBodyJSON = try JSONEncoder().encode(loginRequestBody)
        
        guard let bodyString = String(data: loginRequestBodyJSON, encoding: .utf8) else {
            throw OEPNVWalletPluginError.internalFailed(description: "HTTP-Body konnte nicht erstellt werden.")
        }
        
        let timestamp = Timestamp.generate()
        let contentType = "application/json"
        
        let xApiSignature = XAPISignature.generate(
            body: bodyString,
            path: "/index.php/mobileService/login",
            eosDate: timestamp,
            contentType: contentType
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
            ],
            url: "https://tickets.rnv-online.de/index.php/mobileService/login",
            body: loginRequestBodyJSON
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard let loginResponseBody = clientResponse.body else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein HTTP-Body vorhanden: \(clientResponse.status), \(clientResponse.headers)")
        }
                
        guard let loginResponseBodyJSON = try? JSONDecoder().decode(LoginResponseBody.self, from: loginResponseBody) else {
            if let error = try? JSONDecoder().decode(APIError.self, from: loginResponseBody) {
                throw OEPNVWalletPluginError.authenticationFailed(description: "\(error.message)")
            } else {
                throw OEPNVWalletPluginError.parsingFailed(description: "Keine lesbare Antwort vorhanden: \(String(data: loginResponseBody, encoding: .utf8) ?? "Fehler")")
            }
        }
        
        guard let authorization = loginResponseBodyJSON.authorization_types.first else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein Auth-Token vorhanden: \(String(data: loginResponseBody, encoding: .utf8) ?? "Fehler")")
        }
        
        return LoginData(authToken: "\(authorization.header.type) \(authorization.header.value)")
        
    }
    
}
