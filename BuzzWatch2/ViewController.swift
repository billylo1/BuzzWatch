//
//  ViewController.swift
//  BuzzWatch2
//
//  Created by Billy Lo on 2022-10-04.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults(suiteName: "group.katla")
        let autostart = defaults?.bool(forKey: "autostart")
        let confidenceThreshold = defaults?.double(forKey: "confidence_threshold")

        print("\(String(describing: autostart))")
        print("\(String(describing: confidenceThreshold))")

    }


}

