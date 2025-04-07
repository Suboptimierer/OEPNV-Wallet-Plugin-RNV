//
//  XAPISignature.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation
import Crypto

struct XAPISignature {
    
    private init() {}
    
    private static let secret = "6xVKJuwLEwFhAwRSz2Ed"
    private static let anonymous = ""
    private static let sso = ""
    
    static func generate(
        body: String,
        path: String,
        eosDate: String,
        contentType: String,
        authorization: String = ""
    ) -> String {
        
        let hashedBody = hmacSHA512(body, key: secret)
        
        let signature = [
            hashedBody,
            Constants.host,
            Constants.port,
            path,
            eosDate,
            contentType,
            authorization,
            anonymous,
            sso,
            Constants.userAgent
        ].joined(separator: "|")
        
        return hmacSHA512(signature, key: secret)
        
    }
    
    private static func hmacSHA512(_ message: String, key: String) -> String {
        let keyData = Data(key.utf8)
        let messageData = Data(message.utf8)
        let keySym = SymmetricKey(data: keyData)
        let signature = HMAC<SHA512>.authenticationCode(for: messageData, using: keySym)
        return signature.map { String(format: "%02x", $0) }.joined()
    }
    
}
