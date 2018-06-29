//
//  GetListDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/14/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class GetListDTO<T>: Codable {
    var metaData: MetaDataDTO?
    var results: [T]?
    
    private enum CodingKeys: String, CodingKey {
        case metaData
        case results
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metaData, forKey: .metaData)
        try container.encode(results, forKey: .results)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metaData = try container.decode(MetaDataDTO.self, forKey: .metaData)
        results = try container.decode([T].self, forKey: .results)
        
    }
}
