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
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory:Category? {
        // triggered once selectedCategory is assigned a value
        // will only load items once selectedCategory is set
        didSet{
            loadItems()
        }
    }
    
    // === USER DEFAULTS ===
    // adding User Defaults
    //let defaults = UserDefaults.standard
    
    // to find the location of where plist files are stored on each device (needed for adding data to plists)
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    //print(dataFilePath)
    
    // === CORE DATA ===
    // we're tapping into the UIApplication class, getting the shared singleton object, which corresponds to the app as an object
    // tapping into its delegate which we cast into our AppDelegate class. Now that we have AppDelegate as an object, we can tap into
    // the persistentContainer and its viewContext
    // doing AppDelegate.persistentContainer.viewContext doesn't work because AppDelegate is just a class (a blueprint) and not an object
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set itemArray to the User Defaults' itemArray if it exists
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
    
    }
    
    //MARK: - TableView DataSource Methods
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
        
        // can be used to update your NSManagedObject (which represents a row in a table, or an object in class)
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        // can be used to delete a row both in the table and Core Data
        // must delete in context first because if you delete an item in the itemArray at indexPath.row, then try to delete it in context, it'll crash
        // because indexPath.row won't work anymore
        //context.delete(itemArray[indexPath.row]) // removes item from context
        //itemArray.remove(at: indexPath.row) // removes item from itemArray which is used to load the tableView
        
        
        // used to check/uncheck a row
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // update the DB with new checked status
        saveItems()
        
        // creates the flash highlight when the row is selected
        tableView.deselectRow(at: indexPath, animated: true)

        
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text ?? ""
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
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
    
    //MARK: - Model Manipulation Methods
    func saveItems() {
        // === CODABLE METHOD ===
        // encoding allows you to save custom classes (containing standard data types) inside of a plist/json
        //let encoder = PropertyListEncoder()
        
//        do {
//            let data = try encoder.encode(itemArray)
//            try data.write(to: dataFilePath!)
//        } catch {
//            print("Error encoding item array, \(error)")
//        }
        
        // === CORE DATA METHOD ===
        do {
            // saving context is like transferring changes from our scratch pad into CoreData
            // any changes that you do in the code that affects the NSManagedObjects only changes the context, not the actual DB itself
            // so you must save it
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        // to refresh so that the updated checkmarks reflect
        // calls cellForRowAt func again
        tableView.reloadData()
    }
    
    // loads items from itemArray fetched from Core Data, usually done after adding an item or searching an item (which creates a new array)
    // "with" is the external variable
    // "request" is the internal variable
    // Item.fetchRequest() is the default value if no request is given
    // Item.fetchRequest() is a blank request that pulls everything from the persistent container (which represents a database)
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        // === CODABLE METHOD ===
//        if let data = try? Data(contentsOf: dataFilePath!){
//            let decoder = PropertyListDecoder()
//
//            do {
//                itemArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Error decoding item array: \(error)")
//            }
//        }
        
        // === Core Data Method ===
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        // adding searchBar predicate, add it to request.predicate. If not, leave it with categoryPredicate
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            // saves the results in our itemArray
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(context)")
        }
        
        tableView.reloadData()
    }
    
    

}

//MARK: - Search Bar methods
// extensions help organize and modularize among the different parent classes/delegates/protocols/etc.
extension TodoListViewController: UISearchBarDelegate {
    
    // query our Core Data DB
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // predicate = query
        // %@ represents the arguments (ex. searchBar.text) so the format = title CONTAINS searchBar.text
        // can find NSPredicate language cheat sheets online for more advanced queries
        // [cd] means that it will be case or diacritic insensitive
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // determines order of the query results
        // can have an array of sorting descriptors, but for now we only have one
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // save context to DB
        loadItems(with: request, predicate: predicate)
    }
    
    // triggers when any changes happen in the text field
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // when cancel button is clicked, original list comes back
        if searchBar.text?.count == 0 {
            loadItems()
            
            // manager that dispatches queues to different threads
            // here it's asking to run this code on the main thread (foreground) so that it's immediate
            DispatchQueue.main.async {
                // removes the cursor in the search bar and then dismisses the keyboard
                searchBar.resignFirstResponder()
            }
            
            
        }
    }
}
