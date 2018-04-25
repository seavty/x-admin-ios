//
//  ImageHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/25/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

final class ImageHelper{
    
    //-> convertImageToBase64
    static func convertImageToBase64(images: [UIImage]) -> [String] {
        var base64s = [String]()
        for image in images {
            var imageData: Data?
            imageData = UIImageJPEGRepresentation(image, 0.5)
            base64s.append(imageData!.base64EncodedString())
        }
        return base64s
    }
}
