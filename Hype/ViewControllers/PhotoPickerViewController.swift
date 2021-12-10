//
//  PhotoPickerViewController.swift
//  Hype
//
//  Created by Ethan Perkins on 12/9/21.
//

import UIKit

protocol PhotoPickerDelegate: AnyObject {
    func photoPickerSelcted(image: UIImage)
}

class PhotoPickerViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    weak var delegate: PhotoPickerDelegate?

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
       
    }
    
    
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add a photo", message: nil, preferredStyle: .alert)
        
        let  cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
        let  cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openGallery()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func setupViews() {
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .lightGray
        imagePicker.delegate = self
    }
    
}

extension PhotoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "NO Camera Access", message: "Please allow access to the camera to use this feature", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
             
        } else {
            let alert = UIAlertController(title: "No photos access", message: "Please allow access to photos to use this feature", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            guard let delegate = delegate else { return }
            delegate.photoPickerSelcted(image: pickedImage)
            photoImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}
