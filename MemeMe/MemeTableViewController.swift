//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Marcel Salathé on 6/12/15.
//  Copyright (c) 2015 Marcel Salathé. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        println("viewDidLoad")
        super.viewDidLoad()
        self.title = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "presentMemeEditor")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func presentMemeEditor() {
        var memeEditorController:ViewController
        memeEditorController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! ViewController
        self.presentViewController(memeEditorController, animated: true, completion: nil)
    }
    
}
