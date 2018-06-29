//
//  ItemGalleryCollectionViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/25/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import OpalImagePicker
import Photos

class ItemGalleryCollectionViewController: UICollectionViewController {

    @IBOutlet var clvItemGallery: UICollectionView!
    
    fileprivate var images = [UIImage]()
    fileprivate var selectImages = [UIImage]()
    fileprivate var documents = [DocumentViewDTO]()
    
    var item = ItemViewDTO()
    var itemGroup = ItemGroupViewDTO()
    var isFromItemGroupController = false
    
    struct StoryboardInfo {
        static let collectionViewCell = "cell"
        static let leftAndRight :CGFloat = 10.0
        static let numberOfrow : CGFloat = 3.0
        static let imageViewerSegue = "ImageViewerSegue"
    }
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //openGallery()
    }
    
    @IBAction func uploadActionClick(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Upload photo", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "From camera", style: .default , handler:{ (UIAlertAction)in
            //print("User click Approve button")
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "From gallery", style: .default , handler:{ (UIAlertAction)in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            //print("User click Dismiss button")
        }))
        
        
        let popver = alert.popoverPresentationController
        //popver?.sourceView = self.view
        popver?.barButtonItem = bbiUpload
        self.present(alert, animated: true, completion: {
            //print("completion block")
        })
    }
    
    @IBOutlet var bbiUpload: UIBarButtonItem!
}

//*** function ***//
extension ItemGalleryCollectionViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupCollectionView()
        setupData()
    }
    
    //-> setupCollectionView
    fileprivate func setupCollectionView() {
        clvItemGallery.dataSource = self
        clvItemGallery.delegate = self
        
        let collectionViewWidth = clvItemGallery.frame.width
        let itemWidth = (collectionViewWidth - StoryboardInfo.leftAndRight) / StoryboardInfo.numberOfrow
        let layout = clvItemGallery.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        clvItemGallery.collectionViewLayout = layout
    }
    
    //-> setupData
    fileprivate func setupData(){
        self.images.removeAll()
        IndicatorHelper.showIndicator(view: self.view)
        var url = ""
        
        //var url = ApiHelper.itemEndPoint + self.item.id!.toString
        if isFromItemGroupController {
            url = ApiHelper.itemGroupEndPoint + self.itemGroup.id!.toString
        }
        else {
           url = ApiHelper.itemEndPoint + self.item.id!.toString
        }
        
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.get)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                do {
                    guard let data = response.data as Data! else { return }
                    if self.isFromItemGroupController {
                        let json = try JSONDecoder().decode(ItemGroupViewDTO.self, from: data)
                        self.documents = json.documents!
                    }
                    else {
                        let json = try JSONDecoder().decode(ItemViewDTO.self, from: data)
                        self.documents = json.documents!
                    }
                    
                    if self.documents.count > 0  {
                        IndicatorHelper.showIndicator(view: self.view)
                        self.loadImage(index: 0)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    //-> loadImage
    fileprivate func loadImage(index: Int) {
        var myIndex = index
        //let url = ApiHelper.apiBaseURL() + documents[myIndex].path!
        let url = documents[myIndex].path! //logic change, document will return full path 
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                self.images.append(image)
                myIndex = index + 1
                if index < self.documents.count - 1 {
                    self.loadImage(index: myIndex)
                }
                else {
                    IndicatorHelper.hideIndicator()
                    self.clvItemGallery.reloadData()
                }
            }
        }
    }
    
    
    //-> openCamera
    fileprivate func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    //-> openGallery
    fileprivate func openGallery() {
        let imagePicker = OpalImagePickerController()
        imagePicker.maximumSelectionsAllowed = 1
        
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
                                                        self.selectImages.append(img!)
                                                        self.images.append(img!)
                                                        
                                                    }
                                                }
                                                imagePicker.dismiss(animated: true, completion: nil)
                                                self.uploadImage()
                                            }
        }, cancel: {
            //Cancel
        })
    }
    
    //-> uploadImage
    fileprivate func uploadImage() {
        do {
            if isFromItemGroupController {
                let itemGroup = ItemGroupUploadImagesDTO()
                itemGroup.id = self.itemGroup.id
                itemGroup.base64s = ImageHelper.convertImageToBase64(images: self.selectImages)
                self.selectImages.removeAll()
                let url = ApiHelper.itemGroupEndPoint + itemGroup.id!.toString + "/uploadimages"
                var request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.post )
                request.httpBody = try JSONEncoder().encode(itemGroup)
                IndicatorHelper.showIndicator(view: self.view)
                Alamofire.request(request).responseJSON {
                    (response) in
                    IndicatorHelper.hideIndicator()
                    if  ApiHelper.isSuccessful(vc: self, response: response){
                        self.setupData()
                        self.clvItemGallery.reloadData()
                    }
                }
            }
            else {
                let item = ItemUploadImagesDTO()
                item.id = self.item.id
                item.base64s = ImageHelper.convertImageToBase64(images: self.selectImages)
                self.selectImages.removeAll()
                let url = ApiHelper.itemEndPoint + item.id!.toString + "/uploadimages"
                var request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.post )
                request.httpBody = try JSONEncoder().encode(item)
                IndicatorHelper.showIndicator(view: self.view)
                Alamofire.request(request).responseJSON {
                    (response) in
                    IndicatorHelper.hideIndicator()
                    if  ApiHelper.isSuccessful(vc: self, response: response){
                        self.setupData()
                        self.clvItemGallery.reloadData()
                    }
                }
            }
        }
        catch {
            self.navigationController?.view.makeToast(ConstantHelper.errorOccurred)
        }
    }
}
//*** end function ***//

//*** collectionview ***//
extension ItemGalleryCollectionViewController {
    
    //-> numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    //-> cellForItemAt
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryboardInfo.collectionViewCell, for: indexPath) as! ItemGalleryCollectionViewCell2
        cell.imgItem.image = images[indexPath.row]
        return cell
    }
    
    //-> willDisplay
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    //-> tap
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.clvItemGallery.indexPathForItem(at: location)
        guard let index = indexPath else { return }
        let image =  images[index.row]
        
        let imageViewerDTO = DocumentImageViewerDTO()
        imageViewerDTO.documentID = documents[index.row].id
        imageViewerDTO.image = image
        
        performSegue(withIdentifier: StoryboardInfo.imageViewerSegue, sender: imageViewerDTO)
    }
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryboardInfo.imageViewerSegue?:
            guard let vc = segue.destination as? ImageViewerViewController else { return }
            guard let imageViewerDTO = sender as? DocumentImageViewerDTO else { return }
            vc.deletedImageListener = self
            vc.imageViewerDTO = imageViewerDTO
        default:
            self.view.makeToast(ConstantHelper.wrongSegueName)
        }
    }
    
    
}
//*** end collectionview ***//


//*** camera delegate ***/
extension ItemGalleryCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //->  imagePickerControllerDidCancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //-> didFinishPickingMediaWithInfo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
         if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            self.selectImages.append(image)
            images.append(image)
            uploadImage()
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
//*** camera delegate ***//

//*** OpalImagePickerControllerDelegate *** //
extension ItemGalleryCollectionViewController: OpalImagePickerControllerDelegate {
    
    
}
//*** OpalImagePickerControllerDelegate ***//




//*** handel protocol **/
extension ItemGalleryCollectionViewController: OnDeletedImageListener {
    
    //*** for delete and add photo  -> consider better not reload all collection viewer , should reload at specific point
    //*** if have time need to refactor this file again, ** add , remove image .... -> take a look at ItemViewController add, and delete item
    
    //-> deletedImage
    func deletedImage() {
        self.clvItemGallery.reloadData()
        self.setupData()
    }
}
