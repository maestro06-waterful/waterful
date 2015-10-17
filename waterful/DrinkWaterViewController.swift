//
//  DrinkWaterViewController.swift
//  waterful
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//

import UIKit

class DrinkWaterViewController: UIViewController {
    
    @IBOutlet weak var waterInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func button1Pressed(sender: AnyObject) {
        waterInput.text = String(Int(waterInput.text!)! as Int + 40)
    }
    @IBAction func button2Pressed(sender: AnyObject) {
        waterInput.text = String(Int(waterInput.text!)! as Int + 120)
    }
    @IBAction func button3Pressed(sender: AnyObject) {
        waterInput.text = String(Int(waterInput.text!)! as Int + 400)
    }
    @IBAction func button4Pressed(sender: AnyObject) {
        waterInput.text = String(Int(waterInput.text!)! as Int + 500)
    }
    
}

