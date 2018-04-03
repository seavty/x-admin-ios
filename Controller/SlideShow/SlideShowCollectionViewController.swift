//
//  SlideShowCollectionViewController.swift
//  X-Admin
//
//  Created by SeavTy on 1/31/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import OpalImagePicker
import Photos

class SlideShowCollectionViewController: UICollectionViewController {

    var baseURL = CustomeHelper().apiURL() + "slideshows/"
    var slideShowWithDocument = SlideShowWithDocumentModel()
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnGallery: UIBarButtonItem!
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    
    @IBOutlet var clvSlideShow: UICollectionView!
    var imageArray:[UIImage] = []
    var cameraImagePicker: UIImagePickerController!
    var countDocument = 0
    
    struct StoryBoardInfo {
        static let collectionViewCell = "cell"
        static let leftAndRight :CGFloat = 10.0
        static let numberOfrow : CGFloat = 3.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
    }
    
    fileprivate func initComp() {
        clvSlideShow.dataSource = self
        clvSlideShow.delegate = self
        configCellLocal()
        loadSummary()
        buttonEnable(isEnable: true)
    }
    
    fileprivate func buttonEnable(isEnable:Bool) {
        btnCancel.isEnabled = !isEnable
        btnGallery.isEnabled = !isEnable
        btnCamera.isEnabled = !isEnable
    }
    
    fileprivate func loadSummary() {
        imageArray.removeAll()
        let url = baseURL + String(CustomeHelper().getSlideShowID())// -1 defined by myself
        //print(url)
        let request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.get)
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            response in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                if let value = response.result.value {
                    //print(value)
                    // should create function that map or decode jason
                    // do not write like this, bad practice
                    let json = JSON(value)
                    //print(json)
                    
                    let documentJson = json["documents"]
                    let slideShowWithDocument = SlideShowWithDocumentModel()
                    var documents = [DocumentModel]()
                    
                    for i in 0 ..< documentJson.count {
                        let document = DocumentModel()
                        document.id = documentJson[i]["id"].intValue
                        document.name = documentJson[i]["name"].stringValue
                        document.path = documentJson[i]["path"].stringValue
                        documents.append(document)
                        
                        //print(documentJson[i]["id"].intValue)
                    }
                    slideShowWithDocument.documents = documents
                    
                    self.countDocument = slideShowWithDocument.documents.count
                    
                    self.slideShowWithDocument = slideShowWithDocument
                    
                    
                    if(slideShowWithDocument.documents.count > 0) {
                        LoadingOverlay.shared.showOverlay(view: self.view)
                        //-> recursive function
                        self.loadImage(index: 0)
                    }
 
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
        
    }
    
    fileprivate func  loadImage(index: Int) {
        var myIndex = index
        let url = CustomeHelper().apiBaseURL() + "/" +  slideShowWithDocument.documents[myIndex].path
        //print(url)
        
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                self.imageArray.append(image)
                myIndex = index + 1
                
                if index < self.slideShowWithDocument.documents.count - 1 {
                    self.loadImage(index: myIndex)
                }
                else {
                    LoadingOverlay.shared.hideOverlayView()
                    self.clvSlideShow.reloadData()
                }
            }
        }
    }
    
    
    
    fileprivate func configCellLocal() {
        // tmp do not delete or touch it
        
        let collectionViewWidth = clvSlideShow.frame.width
        let itemWidth = (collectionViewWidth - StoryBoardInfo.leftAndRight) / StoryBoardInfo.numberOfrow
        let layout = clvSlideShow.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        clvSlideShow.collectionViewLayout = layout
        
        
        
        /* me wrong
         let itemSize = UIScreen.main.bounds.width/3 - 3
         let layout = UICollectionViewFlowLayout()
         layout.sectionInset = UIEdgeInsetsMake(20, 0, 10, 0)
         layout.itemSize = CGSize(width: itemSize, height: itemSize)
         layout.minimumInteritemSpacing = 3
         layout.minimumLineSpacing = 3
         
         
         colItemGallery.collectionViewLayout = layout
         */
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryBoardInfo.collectionViewCell, for: indexPath) as! ItemGalleryCollectionViewCell
        cell.image.image = imageArray[indexPath.row]
        return cell
    }
    
    @IBAction func btnGallery(_ sender: UIBarButtonItem) {
        openGalley()
    }
    fileprivate func openGalley() {
        let imagePicker = OpalImagePickerController()
        imagePicker.maximumSelectionsAllowed = 5
        
        presentOpalImagePickerController(imagePicker, animated: true,
                                         select: { (assets) in
                                            var img: UIImage?
                                            let manager = PHImageManager.default()
                                            let options = PHImageRequestOptions()
                                            options.version = .original
                                            options.isSynchronous = true
                                            
                                            for myAsset in assets {
                                                manager.requestImageData(for: myAsset, options: options) { data, _, _, _ in
                                                    if let data = data {
                                                        img = UIImage(data: data)
                                                        self.imageArray.append(img!)
                                                    }
                                                }
                                            }
                                            self.clvSlideShow.reloadData()
                                            imagePicker.dismiss(animated: true, completion: nil)
        }, cancel: {
            //Cancel
        })
    }
    
    @IBAction func btnEdit(_ sender: UIBarButtonItem) {
        buttonEnable(isEnable: false)
        
        if( btnEdit.title == "Upload") {
            upload()
        }
        btnEdit.title = "Upload"
    }
    
    @IBAction func btnCancel(_ sender: UIBarButtonItem) {
        btnEdit.title = "Edit"
        buttonEnable(isEnable: true)
        if(imageArray.count > countDocument) {
            imageArray.removeSubrange(countDocument ..< imageArray.count)
        clvSlideShow.reloadData()
        }
    }
    
    @IBAction func btnCamera(_ sender: UIBarButtonItem) {
        camera()
    }
    
    fileprivate func camera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    fileprivate func upload() {
        if(imageArray.count <=  countDocument) {
            CustomeHelper().alertMsg(vc: self, message: "No images to upload!")
            return
        }
        
        let submitImages = Array(imageArray[countDocument..<imageArray.count])
        countDocument = imageArray.count
        
        let slideShowWithUploadImages = SlideShowWithUploadImagesModel()
        slideShowWithUploadImages.id = CustomeHelper().getSlideShowID()
        slideShowWithUploadImages.images = CustomeHelper().convertImagesToBase64(images: submitImages)
        
        let url = baseURL + String(CustomeHelper().getSlideShowID())
        var request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.put)
        let json = slideShowWithUploadImages.toJSONString()!
        
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            print(response)
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                self.btnEdit.title = "Edit"
                self.buttonEnable(isEnable: true)
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
}


//-- this extension for Using Camera
extension SlideShowCollectionViewController: OpalImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //-- camera
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            self.imageArray.append(image)
            self.clvSlideShow.reloadData()
        }
        else{
            print("Something went wrong")
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Add image to Library after taking photo from camera
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        /*
         if let error = error {
         // we got back an error!
         let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "OK", style: .default))
         present(ac, animated: true)
         } else {
         let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "OK", style: .default))
         present(ac, animated: true)
         }
         */
    }
    
    
}
