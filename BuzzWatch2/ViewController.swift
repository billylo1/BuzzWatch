//
//  ViewController.swift
//  BuzzWatch2
//
//  Created by Billy Lo on 2022-10-04.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBAction func githubLink(_ sender: Any) {
        
        if let url = URL(string: "https://github.com/billylo1/BuzzWatch") {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }

    }
    
}

