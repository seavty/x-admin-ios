//
//  OnMassSavedListener.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/22/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

protocol OnMassSavedListener {
    func massSaved<T>(data:[T])
}
