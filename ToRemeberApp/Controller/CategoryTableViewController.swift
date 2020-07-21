//
//  CategoryTableViewController.swift
//  ToRemeberApp
//
//  Created by Amna Amna on 7/9/20.
//  Copyright © 2020 Amna Amna. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryTableViewController: UITableViewController {

    var categoryList = [Category]()
    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
       getItems()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.category_CellIdentifier, for: indexPath)
        cell.textLabel?.text = categoryList[indexPath.row].name
            let bgColor = categoryList[indexPath.row].color
            cell.backgroundColor = UIColor(hexString: bgColor!)
            cell.textLabel?.textColor  = ContrastColorOf(UIColor(hexString: bgColor!)!,returnFlat: true)
        
    
        return cell
    }
    
    //MARK:  add new Categoty in list

    var textfield  = UITextField()

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action)  in
                     if let addItem = self.textfield.text{
                      let newItem = Category(context: self.context)
                      newItem.name = addItem
                      newItem.color = RandomFlatColor().hexValue()
                      self.categoryList.append(newItem)
                      self.saveItems()
                      self.tableView.reloadData()
                      
                  }
              }
              
              alert.addAction(action);
              alert.addTextField { (txt) in
                  txt.placeholder = "New item to remember"
                  self.textfield = txt;
                  
              }
              present(alert,animated: true)
    }
    //MARK:  Manipulate DataModel
       
       
       func saveItems() {
           do{
               try context.save()
           }
           catch{
               print("there is a error \(error)")
           }
       }
       
       func getItems() {
          let request : NSFetchRequest<Category> = Category.fetchRequest();
           do{
              categoryList = try context.fetch(request)
           }
           catch{
               print("there is a error  in fetching \(error)")

           }
           tableView.reloadData()

       }
       

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            context.delete(categoryList[indexPath.row])
            categoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveItems()

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
   
    // MARK: - Navigation

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier : K.SegueIdentifier, sender: self)
            

        }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destinatin = segue.destination as! TodoTableViewController
        
        if let currentIndex = tableView.indexPathForSelectedRow{
            destinatin.selectedCategory = categoryList[currentIndex.row]
        }
     }
    


}
