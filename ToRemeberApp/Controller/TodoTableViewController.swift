//
//  ViewController.swift
//  ToRemeberApp
//
//  Created by Amna Amna on 7/8/20.
//  Copyright © 2020 Amna Amna. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoTableViewController: UITableViewController {
    
    
    @IBOutlet weak var saerchBR: UISearchBar!
    var todoList = [Item]();
    let defualt = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    var selectedCategory : Category?{
        didSet{
            getItems()

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if let savedtodoList = defualt.array(forKey: "todoListItems") as? [String] {
        //            todoList = savedtodoList
        //        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedColor = selectedCategory?.color {
            title = selectedCategory!.name
            navigationController?.navigationBar.backgroundColor = UIColor(hexString: selectedColor)
            navigationController?.navigationBar.tintColor =
                ContrastColorOf(UIColor(hexString: selectedColor)!,returnFlat: true)
                      navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(UIColor(hexString: selectedColor)!,returnFlat: true)]

            saerchBR.barTintColor = UIColor(hexString: selectedColor)
            
        }
        
        
       }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItem", for: indexPath)
        cell.textLabel?.text = todoList[indexPath.row].itemName
        let currentcell = todoList[indexPath.row]
        cell.accessoryType = currentcell.isDone == true ?.checkmark : .none
        let percentage =  CGFloat(indexPath.row)/CGFloat(todoList.count)
                if let currentCategory = selectedCategory{
                    
                    let bgColor = UIColor(hexString:currentCategory.color!)!.darken(byPercentage:percentage)
                    cell.backgroundColor = bgColor
                    cell.textLabel?.textColor  = ContrastColorOf(bgColor!,returnFlat: true)
                    cell.tintColor = ContrastColorOf(bgColor!,returnFlat: true)
                    
                
            }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todoList[indexPath.row].isDone = !todoList[indexPath.row].isDone
        tableView.deselectRow(at: indexPath, animated: true)
//        context.delete(todoList[indexPath.row])
//        todoList.remove(at: indexPath.row)
        saveItems()
        
        self.tableView.reloadData()
        
    }
    
    //MARK:  add new item in list
    
    var textfield  = UITextField()
    @IBAction func newItemAction(_ sender: Any) {
        
        let alert = UIAlertController.init(title: "Add New Item to remember", message: "", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "add item", style: .default) { (action) in
            
            if let addItem = self.textfield.text{
                let newItem = Item(context: self.context)
                newItem.itemName = addItem
                newItem.parentCategory = self.selectedCategory
                self.todoList.append(newItem)
                self.saveItems()
                self.tableView.reloadData()
                // self.defualt.setValue(self.todoList, forKey: "todoListItems")
                
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
    
    func getItems(with request : NSFetchRequest<Item> = Item.fetchRequest(),predicate :NSPredicate? = nil) {
       // let request : NSFetchRequest<Item> = Item.fetchRequest();
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addtionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[addtionalPredicate,categoryPredicate])
        }
        else{
            request.predicate = categoryPredicate

        }
        do{
           todoList = try context.fetch(request)
        }
        catch{
            print("there is a error  in fetching \(error)")

        }
        tableView.reloadData()

    }
    
}
extension TodoTableViewController :UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request :NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "itemName CONTAINS[cd] %@", searchBar.text!);
        request.predicate = predicate
        let sort = NSSortDescriptor(key: "itemName", ascending: true)
        request.sortDescriptors = [sort]
        getItems(with: request,predicate: predicate)
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("clicked")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            getItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()

            }
        }
    }
}

