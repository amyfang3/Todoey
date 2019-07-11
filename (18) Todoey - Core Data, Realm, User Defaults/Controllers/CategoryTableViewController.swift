//
//  CategoryTableViewController.swift
//  (18) Todoey - Core Data, Realm, User Defaults
//
//  Created by Amy Fang on 7/10/19.
//  Copyright © 2019 Amy Fang. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        // grabs the indexPath for the row that was tapped (since we're not in the didSelectRowAt function)
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    func loadCategories(){
        
        let request:NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context in categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveCategories(){
        do {
            try context.save()
        } catch {
            print("Error saving context in categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // creates new NSManagedObject aka a row
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text ?? ""
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }

}
