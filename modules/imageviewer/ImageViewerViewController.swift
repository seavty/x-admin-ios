//
//  ImageViewerViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 6/25/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class ImageViewerViewController: UIViewController {

    @IBOutlet var bbiDelete: UIBarButtonItem!
    var imageViewerDTO = DocumentImageViewerDTO()
    var deletedImageListener: OnDeletedImageListener?
    
    @IBOutlet fileprivate var imageViewer: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    @IBAction func deleteClick(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Photo", message: "Do you want to this delete this photo?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive , handler:{ (UIAlertAction)in
            self.deletePhoto()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler:{ (UIAlertAction)in
            //print("User click Dismiss button")
        }))
        
        let popver = alert.popoverPresentationController
        
        popver?.barButtonItem = bbiDelete
        self.present(alert, animated: true, completion: {
            //print("completion block")
        })
    }
}

extension ImageViewerViewController {
    //-> initializeComponents
    fileprivate func initializeComponents() {
        imageViewer.image = imageViewerDTO.image
    }
    
    //-> deletePhoto
    fileprivate func deletePhoto() {
        print(self.imageViewerDTO.documentID!.toString)
        let url = ApiHelper.documentEndPoint + self.imageViewerDTO.documentID!.toString
        print(url)
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.delete)
        IndicatorHelper.showIndicator(view: self.view)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                self.deletedImageListener?.deletedImage()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
