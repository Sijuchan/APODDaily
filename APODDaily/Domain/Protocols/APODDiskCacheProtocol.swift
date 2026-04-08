//
//  APODDiskCacheProtocol.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

protocol APODDiskCacheProtocol {
    
    func save(dto: APODDTO, image: Data?, key: String) throws
    func loadLatest() throws -> (dto: APODDTO, image: Data?)
    
}
