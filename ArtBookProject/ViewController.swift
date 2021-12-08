//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Hüseyin BAKAR on 5.12.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBook))
        
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
        
        print("en son ekledik")
    }
    

    
   @objc func getData()
    {
    nameArray.removeAll(keepingCapacity: false)
    idArray.removeAll(keepingCapacity: false)
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
           let results = try context.fetch(fetchRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let name = result.value(forKey: "name") as? String
                    {
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID
                    {
                        idArray.append(id)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
        catch
        {
            print("error")
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        self.selectedPainting = self.nameArray[indexPath.row]
        self.selectedPaintingId  = self.idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "toDetailsVC"
        {
            let vc = segue.destination as! DetailsVC
            vc.chosenPainting = self.selectedPainting
            vc.chosenPaintingId = self.selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        let idString = idArray[indexPath.row].uuidString
        
        fetchRequest.predicate = NSPredicate.init(format: "id = %@", idString)
        fetchRequest.returnsDistinctResults = false
         
        do
        {
        let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for result in results as! [NSManagedObject] {
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        
                        if id == idArray[indexPath.row]
                        {
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            
                            idArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            do
                            {
                            try context.save()
                            }
                            catch
                            {
                                print("error")
                            }
                            break
                        }
                        
                    }
                }
            }
        }
        catch
        {
            print("error")
        }
    }
    
    
  @objc func addBook()
    {
    selectedPainting = ""
    performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
}

