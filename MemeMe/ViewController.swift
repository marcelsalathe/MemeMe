//
//  ViewController.swift
//  MemeMe
//
//  Created by Marcel Salathé on 6/9/15.
//  Copyright (c) 2015 Marcel Salathé. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var pickedImageView: UIImageView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    
    let memeTextAttributes = [
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.view.backgroundColor = UIColor.blackColor()
        // top text field
        topTextField.delegate = self
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        topTextField.textAlignment = NSTextAlignment.Center;
        // bottom text field
        bottomTextField.delegate = self
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.Center;
        // share button
        if (pickedImageView.image == nil) {
            shareButton.enabled = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Unsubscribe
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    @IBAction func dismissViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    ///////////////////////////////////////////////////
    // SOME FUNCTIONS TO DEAL WITH VIEW MOVING
    ///////////////////////////////////////////////////
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    
    
    ///////////////////////////////////////////////////
    // IMAGE PICKER FUNCTIONS
    ///////////////////////////////////////////////////
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        pickImage(UIImagePickerControllerSourceType.Camera)
    }

    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        pickImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    func pickImage(sourceType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pickedImageView.image = image
            shareButton.enabled = true
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    ///////////////////////////////////////////////////
    // TEXT FIELD DELEGATE FUNCTIONS
    ///////////////////////////////////////////////////
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString = textField.text
        newText = newText.stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
        textField.text = String(newText)
        return false
    }
    
    
    
    
    
    ///////////////////////////////////////////////////
    // MEME SHARING
    ///////////////////////////////////////////////////
    
    @IBAction func shareMeme(sender: AnyObject) {
        var memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // setting up dismissal of the activity view once the meme is successfully shared:
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            if (success) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(activityViewController, animated: true, completion: saveMeme)
    }
    
    func saveMeme() {
        //Create the meme
        var meme = Meme(topText:topTextField.text, bottomText:bottomTextField.text, image:pickedImageView.image!, memedImage:generateMemedImage())
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        toolBar.hidden = true
        navigationBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolBar.hidden = false
        navigationBar.hidden = false
        
        return memedImage
    }
    
    
    

}

