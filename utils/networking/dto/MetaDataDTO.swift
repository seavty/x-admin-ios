//
//  MetaDataDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/6/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class MetaDataDTO: Codable {
    var currentPage: Int?
    var totalPage: Int?
    var totalRecord: Int?
    var pageSize: Int?
    var orderColumn: String?
    var orderBy: String?
    var search: String?
    
    
    fileprivate enum CodingKeys: String, CodingKey {
        case currentPage
        case totalPage
        case totalRecord
        case pageSize
        case orderColumn
        case orderBy
        case search
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentPage = try container.decode(Int?.self, forKey: .currentPage)
        self.totalPage = try container.decode(Int?.self, forKey: .totalPage)
        self.totalRecord = try container.decode(Int?.self, forKey: .totalRecord)
        self.pageSize = try container.decode(Int?.self, forKey: .pageSize)
        
        self.orderColumn = try container.decode(String?.self, forKey: .orderColumn)
        self.orderBy = try container.decode(String?.self, forKey: .orderBy)
        self.search = try container.decode(String?.self, forKey: .search)
        
    }
    
    required init() {
        
    }
}
