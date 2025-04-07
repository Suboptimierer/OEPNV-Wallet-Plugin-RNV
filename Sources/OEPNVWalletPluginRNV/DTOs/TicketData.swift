//
//  TicketData.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation

struct TicketData {
    let id: String
    let type: String
    let validFrom: Date
    let validUntil: Date
    let holder: String
    let scanCode: String
}
