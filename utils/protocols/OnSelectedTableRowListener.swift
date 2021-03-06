//
//  OnSelectTableRowListener.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/21/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

protocol OnSelectedTableRowListener {
    func selectTableRow<T>(data:T, position: Int)
}
