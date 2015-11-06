//
//  SettingTableViewController.swift
//  waterful
//
//  Created by suz on 10/27/15.
//  Copyright © 2015 suz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingTableViewController: UITableViewController{

    @IBOutlet weak var fromUIView: UIView!
    @IBOutlet weak var fromText: UILabel!
    @IBOutlet weak var toText: UILabel!
    @IBOutlet weak var intervalText: UILabel!
    @IBOutlet weak var goalText: UILabel!
    @IBOutlet weak var unitText: UILabel!
    
    
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
    }
    override func viewDidLoad() {
        let setting_info : Setting = fetchSetting()
        fromText.text = setting_info.alarmStartTime?.description
        toText.text = setting_info.alarmEndTime?.description
        intervalText.text = setting_info.alarmInterval?.description
        goalText.text = setting_info.goal?.description
        unitText.text = setting_info.unit?.description
        
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchSetting() -> Setting! {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [Setting]
        
        if (fetchResults!.count == 0){
            return nil
        }
            
        else{
            return fetchResults![0]
        }
    }
    
    
}
