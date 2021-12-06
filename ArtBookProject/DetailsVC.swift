//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Hüseyin BAKAR on 5.12.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet var saveButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var artistText: UITextField!
    @IBOutlet var year: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        
        let imagePickerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        
        view.addGestureRecognizer(imagePickerGestureRecognizer)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard()
    {
        view.endEditing(true)
    }
    
    @objc func pickImage()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func saveButtonClicked(_ sender: Any)
    {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(year.text!)
        {
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do
{
           try context.save()
            print("success")
    
    
        }
        catch
        {
            print("Hata var")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
