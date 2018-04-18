//
//  OnBackButtonClickListener.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/18/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

protocol OnBackButtonClickListener {
    func updateTableRow<T>(data:T, position: Int)
}
