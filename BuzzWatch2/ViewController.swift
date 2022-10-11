//
//  ViewController.swift
//  BuzzWatch2
//
//  Created by Billy Lo on 2022-10-04.
//

import UIKit
import SafariServices

class ViewController: UIViewController, SessionCommands {

    private func timedColor() -> [String: Any] {
        let red = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let green = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let blue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        let randomColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        let data = try? NSKeyedArchiver.archivedData(withRootObject: randomColor, requiringSecureCoding: false)
        guard let colorData = data else { fatalError("Failed to archive a UIColor!") }
    
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        let timeString = dateFormatter.string(from: Date())
        
        return [PayloadKey.timeStamp: timeString, PayloadKey.colorData: colorData]
    }
    
    // Generate an app context for updateApplicationContext.
    //
    var appContext: [String: Any] {
        return timedColor()
    }

    var currentCommand: Command = .updateAppContext // Default to .updateAppContext.

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // .dataDidFlow notification handler.
    // Update the UI using the userInfo dictionary of the notification.
    //
    @objc
    func dataDidFlow(_ notification: Notification) {
        
        print("dataDidFlow")
        guard let commandStatus = notification.object as? CommandStatus else { return }
        
        // defer { noteLabel.isHidden = logView.text.isEmpty ? false: true }
        
        // If an error occurs, show the error message and return.
        //
        if let errorMessage = commandStatus.errorMessage {
            // log("! \(commandStatus.command.rawValue)...\(errorMessage)")
            return
        }
        
        guard let timedColor = commandStatus.timedColor else { return }
        
    }
    
    @IBAction func githubLink(_ sender: Any) {
        
        if let url = URL(string: "https://github.com/billylo1/BuzzWatch") {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    @IBAction func updateAction(_ sender: Any) {
        
        updateAppContext()
        
    }
    
    func updateAppContext() {
        
        print("updateAppContext")
        
        switch currentCommand {
            case .updateAppContext: updateAppContext(appContext);
            default: print("unknown command")
        }
    }
    
}

