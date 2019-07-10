//
//  ViewController.swift
//  (18) Todoey - Core Data, Realm, User Defaults
//
//  Created by Amy Fang on 7/2/19.
//  Copyright © 2019 Amy Fang. All rights reserved.
//


// USER DEFAULTS NOTES
//  only use User Defaults for small bits of data like volume or color preferences
//  when you start to store large items like arrays or dictionaries, then it gets tricky
//  because User Defaults isn't meant to be a database (it's a plist file)
//  when your app loads up, you have to load the entire User Defaults plist synchronously before you can use it
//  if the User Defaults plist file is huge, then it can take a long time to load the app
//  User Defaults can't handle custom classes/data models created

// SINGLETON NOTES
//  always retrieving the same instance of an object.
//  provides a unified access point ot a resource or service that's shared across an app

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    // adding User Defaults
    //let defaults = UserDefaults.standard
    
    // to find the location of where files are stored on each device
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)
        
        // set itemArray to the User Defaults' itemArray if it exists
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
        
        loadItems()
    
    }
    
    //MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // this won't work for checking/unchecking because once the checked cell goes off the screen,
        // it gets destroyed and then a new cell is created without the checkmark
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        
        // when you use reusable cells, then if you place a checkmark on a cell,
        // it'll reappear on the lower cell when you scroll down because the cells are reused
        // so you must assign a property using a data model
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        // adds a check mark to the cell if there is none and vice versa
        // Ternary operator
        // value = condition ? valueIfTrue : valueIfFalse
        // item.done is a bool so you can just leave it as is insteasd of item.done == true
        cell.accessoryType = item.done ? .checkmark : .none
        
        // ^--- same as
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()

        tableView.deselectRow(at: indexPath, animated: true) // creates the flash highlight when the row is selected

        
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item()
            newItem.title = textField.text ?? ""
            
            // what will happen once the user clicks the Add Item button
            self.itemArray.append(newItem)
            
            // saving the itemArray to our User Defaults
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.saveItems()
            
            // refresh the tableView to reflect the newly added row
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    func saveItems() {
        // encoding allows you to save custom classes (containing standard data types) inside of a plist/json
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        // to refresh so that the updated checkmarks reflect
        // calls cellForRowAt func again
        tableView.reloadData()
    }
    
    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array: \(error)")
            }
        }
    }
    


}

