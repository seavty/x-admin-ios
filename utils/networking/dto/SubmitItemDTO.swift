//
//  SubmitItemDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/22/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class SubmitItemDTO<T:Codable>: Codable {
    var warehouseID: Int?
    var remarks: String?
    var items: [T]?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case warehouseID
        case remarks
        case items
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        warehouseID = try container.decode(Int?.self, forKey: .warehouseID)
        remarks = try container.decode(String?.self, forKey: .remarks)
        items = try container.decode([T]?.self, forKey: .items)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(warehouseID, forKey: .warehouseID)
        try container.encode(remarks, forKey: .remarks)
        try container.encode(items, forKey: .items)
    }
    
    required init() {
        
    }
    
}
