//
//  TokenViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 8/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class TokenViewDTO: TokenBaseDTO {
    
    var toke_Name: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case toke_Name
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.toke_Name = try container.decode(String?.self, forKey: .toke_Name)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(toke_Name, forKey: .toke_Name)
    }
    
    
    
    //-- ** must use it, if not can not create object in CusotmerSummaryView Control ***/
    /*
     override required init() {
     super.init()
     }
     */
    
    required init() {
        super.init()
    }
}
