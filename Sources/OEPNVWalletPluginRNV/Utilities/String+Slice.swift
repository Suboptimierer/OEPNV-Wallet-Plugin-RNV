//
//  String+Slice.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation

extension String {
    
    func slice(from: String, to: String) -> String? {
        guard let startRange = self.range(of: from) else { return nil }
        let substringFrom = self[startRange.upperBound...]
        guard let endRange = substringFrom.range(of: to) else { return nil }
        return String(substringFrom[..<endRange.lowerBound])
    }
    
}
