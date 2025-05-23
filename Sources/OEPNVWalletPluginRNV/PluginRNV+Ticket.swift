//
//  PluginRNV+Ticket.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginRNV {
    
    func ticket(for id: String, auth: String, using client: OEPNVWalletClient) async throws -> TicketData {
        
        struct TicketRequestBody: Encodable {
            let tickets: [String]
            let details = true
            let provide_aztec_content = true
            let parameters = true
        }
        
        struct TicketResponseBody: Decodable {
            let tickets: [String: Ticket]
            
            struct Ticket: Decodable {
                let meta: String
                let template: String
                let certificate: String
                let meta_signature: String
                let template_signature: String
            }
        }
        
        struct TicketResponseMeta: Decodable {
            let title: String
            let validity_begin: String
            let validity_end: String
        }
        
        struct TicketResponseTemplate: Decodable {
            let purchase_id: String
            let content: Content
            
            struct Content: Decodable {
                let images: Images
                let pages: [String]
                
                struct Images: Decodable {
                    let background: String
                    let logo: String
                }
            }
        }
        
        let ticketRequestBody = TicketRequestBody(tickets: [id])
        let ticketRequestBodyJSON = try JSONEncoder().encode(ticketRequestBody)
        
        guard let bodyString = String(data: ticketRequestBodyJSON, encoding: .utf8) else {
            throw OEPNVWalletPluginError.internalFailed(description: "HTTP-Body konnte nicht erstellt werden.")
        }
        
        let timestamp = Timestamp.generate()
        let contentType = "application/json"
        
        let xApiSignature = XAPISignature.generate(
            body: bodyString,
            path: "/index.php/mobileService/ticket",
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
            url: "https://tickets.rnv-online.de/index.php/mobileService/ticket",
            body: ticketRequestBodyJSON
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard let ticketResponseBody = clientResponse.body else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein HTTP-Body vorhanden: \(clientResponse.status), \(clientResponse.headers)")
        }
        
        guard let ticketResponseBodyJSON = try? JSONDecoder().decode(TicketResponseBody.self, from: ticketResponseBody) else {
            if let error = try? JSONDecoder().decode(APIError.self, from: ticketResponseBody) {
                throw OEPNVWalletPluginError.authenticationFailed(description: "\(error.message)")
            } else {
                throw OEPNVWalletPluginError.parsingFailed(description: "Keine lesbare Antwort vorhanden: \(String(data: ticketResponseBody, encoding: .utf8) ?? "Fehler")")
            }
        }
        
        guard let ticketData = ticketResponseBodyJSON.tickets[id] else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Ticket-ID nicht vorhanden: \(String(data: ticketResponseBody, encoding: .utf8) ?? "Fehler")")
        }
        
        guard let metaDataRaw = ticketData.meta.data(using: .utf8) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Umwandlung in Data nicht möglich: \(ticketData.meta)")
        }
        
        guard let templateDataRaw = ticketData.template.data(using: .utf8) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Umwandlung in Data nicht möglich: \(ticketData.template)")
        }
        
        guard let metaData = try? JSONDecoder().decode(TicketResponseMeta.self, from: metaDataRaw) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Keine lesbare Antwort vorhanden: \(ticketData.meta)")
        }
        
        guard let templateData = try? JSONDecoder().decode(TicketResponseTemplate.self, from: templateDataRaw) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Keine lesbare Antwort vorhanden: \(ticketData.template)")
        }
        
        guard templateData.content.pages.count >= 1 else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Keine Pages vorhanden: \(ticketData.template)")
        }
        
        let firstPage = templateData.content.pages[0]
        let secondPage = templateData.content.pages[1]
        
        let nameStartMarker = "<p class='caps small-font label'>Vor & Nachname</p><p class='small-font'>"
        let nameEndMarker = "</p>"
        
        let aztecCodeStartMarker = "<img class='barcode' style='z-index: 100;' src='data:image/jpg;base64,"
        let aztecCodeEndMarker = "'"
        
        guard let name = firstPage.slice(from: nameStartMarker, to: nameEndMarker) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Name nicht gefunden: \(firstPage)")
        }
        
        guard let aztecCode = secondPage.slice(from: aztecCodeStartMarker, to: aztecCodeEndMarker) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Aztec-Code nicht gefunden: \(secondPage)")
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let validFromDate = formatter.date(from: metaData.validity_begin),
              let validUntilDate = formatter.date(from: metaData.validity_end) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Datum kann nicht umgewandelt werden: \(metaData.validity_begin) / \(metaData.validity_end)")
        }
        
        return TicketData(
            id: id,
            type: metaData.title,
            validFrom: validFromDate,
            validUntil: validUntilDate,
            holder: name,
            aztecCode: aztecCode
        )
        
    }
    
}
