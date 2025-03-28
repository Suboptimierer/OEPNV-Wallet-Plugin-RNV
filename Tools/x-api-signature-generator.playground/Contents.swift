import Foundation
import CryptoKit


// MARK: - Eingabewerte

let secret = "6xVKJuwLEwFhAwRSz2Ed"

let body = ""
let host = "tickets.rnv-online.de"
let port = "443"
let path = "/index.php/mobileService/resource_list"
let eosDate = "Fri, 28 Mar 2025 22:57:00 GMT"
let contentType = ""
let authorization = ""
let anonymous = ""
let sso = ""
let userAgent = "RNV AND/3.22.0/2022.03/rnv-live (Google emu64a - 'sdk_gphone64_arm64'; Android; 13, SDK: 33)"


// MARK: - Body hashen

let hashedBody = hmacSHA512(body, key: secret)


// MARK: - Rohdaten der Signatur zusammenbauen

let signature = [
    hashedBody,
    host,
    port,
    path,
    eosDate,
    contentType,
    authorization,
    anonymous,
    sso,
    userAgent
].joined(separator: "|")


// MARK: - Rohdaten der Signatur zusammenbauen

let apiSignature = hmacSHA512(signature, key: secret)
print(apiSignature)


// MARK: - Hilfsfunktionen

func hmacSHA512(_ message: String, key: String) -> String {
    let keyData = Data(key.utf8)
    let messageData = Data(message.utf8)
    let keySym = SymmetricKey(data: keyData)
    let signature = HMAC<SHA512>.authenticationCode(for: messageData, using: keySym)
    return signature.map { String(format: "%02x", $0) }.joined()
}
