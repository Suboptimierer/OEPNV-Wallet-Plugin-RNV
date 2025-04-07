import Foundation
import CryptoKit


// MARK: - Gleich für jeden Endpunkt
let secret = "6xVKJuwLEwFhAwRSz2Ed"
let host = "tickets.rnv-online.de"
let port = "443"
let contentType = "application/json"
let anonymous = ""
let sso = ""
let userAgent = "RNV AND/3.22.0/2022.03/rnv-live (Google komodo - 'Pixel 9'; Android; 15, SDK: 35)"


/*
// MARK: - Endpunkt Login
let body = """
{"credentials":{"password":"<password>","username":"<email>"}}
"""
let path = "/index.php/mobileService/login"
let eosDate = "Sat, 29 Mar 2025 20:17:00 GMT"
let authorization = ""
*/


/*
// MARK: - Endpunkt Logout
let body = """
{}
"""
let path = "/index.php/mobileService/logout"
let eosDate = "Sat, 29 Mar 2025 20:25:00 GMT"
let authorization = "TICKeos <token>"
*/


/*
// MARK: - Endpunkt Sync
let body = """
{"anonymous_tickets":[]}
"""
let path = "/index.php/mobileService/sync"
let eosDate = "Sat, 29 Mar 2025 20:40:00 GMT"
 let authorization = "TICKeos <token>"
*/


// MARK: - Endpunkt Ticket
let body = """
{"tickets":["<ticket-id>"],"details":true,"provide_aztec_content":false,"parameters":false}
"""
let path = "/index.php/mobileService/ticket"
let eosDate = "Sat, 29 Mar 2025 20:52:00 GMT"
let authorization = "TICKeos <token>"


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
