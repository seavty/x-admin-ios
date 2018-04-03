//
//  ItemGallery.swift
//  X-Admin
//
//  Created by SeavTy on 1/22/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import OpalImagePicker
import Photos


class ItemGallery: UICollectionViewController{

    @IBOutlet var colItemGallery: UICollectionView!
    
    var imageArray:[UIImage] = []
    var item = ItemModel()
    var itemGroupWithDocument = ItemGroupWithDocumentModel()
    
    var isFromItemGroup:Bool = false
    
    //check this mode
    var mode = Mode.view
    var cameraImagePicker: UIImagePickerController!
    
    
    var countDocument = 0
    
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    @IBOutlet weak var btnGallery: UIBarButtonItem!
    
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
        colItemGallery.dataSource = self
        colItemGallery.delegate = self
        configCellLocal()
        
        //print("hello world")
        //print(itemGroupWithDocument.toJSONString())
        //--need to remove reduntant code from here
        if(isFromItemGroup) {
            countDocument = itemGroupWithDocument.documents.count
        }
        else{
            countDocument = item.documents.count
        }
        
        if(countDocument > 0) {
            LoadingOverlay.shared.showOverlay(view: self.view);
            //-> recursive function
            loadImage(index: 0)
        }
        
        buttonVisibility()
    }
    
    fileprivate func buttonVisibility() {
        print("mode=" + mode.rawValue )
        if(mode == Mode.view ) {
            btnCamera.isEnabled = false
            btnGallery.isEnabled = false
        }
    }
    
    fileprivate func  loadImage(index: Int) {
        var myIndex = index
        var url = CustomeHelper().apiBaseURL()
        if(isFromItemGroup) {
            url = url + itemGroupWithDocument.documents[myIndex].path
        }
        else {
           url = url +  item.documents[myIndex].path
        }
        
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                self.imageArray.append(image)
                myIndex = index + 1
                
                if index < self.countDocument - 1 {
                    self.loadImage(index: myIndex)
                }
                else {
                    LoadingOverlay.shared.hideOverlayView()
                    self.colItemGallery.reloadData()
                }
            }
        }
    }
    
    fileprivate func configCellLocal() {
        // tmp do not delete or touch it 
        
        let collectionViewWidth = colItemGallery.frame.width
        let itemWidth = (collectionViewWidth - StoryBoardInfo.leftAndRight) / StoryBoardInfo.numberOfrow
        let layout = colItemGallery.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        colItemGallery.collectionViewLayout = layout
 
        
        
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
                                            self.colItemGallery.reloadData()
                                            imagePicker.dismiss(animated: true, completion: nil)
        }, cancel: {
            //Cancel
        })
    }
    
    @IBAction func btnDone(_ sender: UIBarButtonItem) {
        done()
    }
    
    fileprivate func done(){
        //--need to check and remove redundanct code
        if(isFromItemGroup){
            guard let vc = self.navigationController!.viewControllers[1] as? ItemGroupSummary else { return }
            vc.images = imageArray
            self.navigationController?.popToViewController(vc, animated: true)
        }
        else {
            guard let vc = self.navigationController!.viewControllers[1] as? ItemSummary else { return }
            vc.imageGallery = imageArray
            self.navigationController?.popToViewController(vc, animated: true)
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
}



//-- this extension for Using Camera
extension ItemGallery: OpalImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //-- camera
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            self.imageArray.append(image)
            self.colItemGallery.reloadData()
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



