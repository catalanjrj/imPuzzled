//
//  NewGameViewController.swift
//  imPuzzled
//
//  Created by Tom Williamson on 5/17/16.
//  Copyright © 2016 Steve Graff. All rights reserved.
//

import UIKit
import CoreData

class NewGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var gameOption: gameOptions!
    var game: Game?
    var managedObjectContext: NSManagedObjectContext!


    
    //
    //  build a list of field names / values to be used in first section
    //  of the table
    //
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // MARK: - Table view data source

    //
    //  two sections:
    //  the first is the list of field values
    //  the second in the list of capabilities
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 2
    }

    //
    //  first section count is from field value dictionary
    //  second section count is from capabilities array
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return gameOption.settings.count
        }
        else {
            return gameOption.capabilities.count
        }
        
    }
    

   
    //
    //  build right cell
    //
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //
        //  first section uses custom cell that has a label and text field
        //
        if indexPath.section == 0 {
           let cell = tableView.dequeueReusableCellWithIdentifier("fieldCell", forIndexPath: indexPath) as! FieldCell
            
            cell.fieldType.text = gameOption.settings[indexPath.row].name
            let svalue = "\(gameOption.settings[indexPath.row].value)"
            cell.fieldValue.placeholder = svalue
            cell.fieldValue.keyboardType = .NumberPad
            cell.fieldValue.tag = indexPath.row
            cell.fieldValue.delegate = self

            return cell
            
        }
        
            //
            //  second section uses standard cell with just a label
            //
            
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("capabilityCell", forIndexPath: indexPath)
            let dict = gameOption.capabilities[indexPath.row]
            cell.textLabel?.text = dict["name"] as? String
            cell.detailTextLabel!.text = dict["description"] as? String
            
            return cell
        }
        
     
    }
    
    //
    //  save new value in game options
    //
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if let newInt = Int32(textField.text!) {
            gameOption.settings[textField.tag].value = newInt
        }
        
        return true
    }
    
    
    //
    //  for second section flip the checkmark flag
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
            self.view.endEditing(true)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if cell.accessoryType == .Checkmark {
                    cell.accessoryType = .None
                    gameOption.capabilities[indexPath.row]["used"] = false as Bool
                } else {
                    cell.accessoryType = .Checkmark
                    gameOption.capabilities[indexPath.row]["used"] = true as Bool
                }
            }
        }
    }
    
    //
    //  set section title
    //
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Game Settings"
        }
        else {
            return "Choose atleast one option below"
        }
        
    }
    
    
    //
    //  create a new game and unwind the seque
    //
    @IBAction func playButtonPushed(sender: AnyObject) {
        
        let entity = NSEntityDescription.entityForName("Game", inManagedObjectContext: self.managedObjectContext)
        self.game = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: nil) as? Game
        self.game?.buildGame(gameOption)
        performSegueWithIdentifier("unwindNewGame", sender: self)
        
    }
    
}
