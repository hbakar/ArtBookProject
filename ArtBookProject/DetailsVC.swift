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
    
    var  chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""
        {
            saveButton.isHidden = false
            //Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
               let results = try context.fetch(fetchRequest)
                
                if results.count > 0
                {
                    for result in results as! [NSManagedObject]
                    {
                        if let name = result.value(forKey: "name") as? String
                        {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String
                        {
                            artistText.text = artist
                        }
                        
                        if let yil = result.value(forKey: "year") as? Int
                        {
                            year.text = String(yil)
                        }
                        
                        if let imageData = value(forKey: "image") as? Data
                        {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }
            catch
            {
                
            }
            
        }
        else
        {
            saveButton.isHidden = false
            saveButton.isEnabled = true
            nameText.text = ""
            artistText.text = ""
            year.text = ""
            
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        
        let imagePickerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        
        view.addGestureRecognizer(imagePickerGestureRecognizer)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
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
