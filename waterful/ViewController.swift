//
//  ViewController.swift
//  waterful
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var plant: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plant.setBackgroundImage(UIImage(named: "2_sprout.png"), forState: UIControlState.Normal)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

