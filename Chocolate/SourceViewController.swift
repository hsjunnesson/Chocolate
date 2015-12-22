//
//  SourceViewController.swift
//  Chocolate
//
//  Created by Hans Sjunnesson on 21/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

import UIKit



class SourceViewController: UIViewController {
    
    @IBOutlet weak var sourceView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let source = try? NSString(contentsOfFile: localShaderPath(), encoding: NSASCIIStringEncoding) as String {
            sourceView.attributedText = decoratedAttributedSource(source)
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
    }
    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
            sourceView.contentInset = UIEdgeInsetsZero
        } else {
            sourceView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        sourceView.scrollIndicatorInsets = sourceView.contentInset
        
        let selectedRange = sourceView.selectedRange
        sourceView.scrollRangeToVisible(selectedRange)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        do {
            let source = sourceView.text
            try source.writeToFile(localShaderPath(), atomically: true, encoding: NSUTF8StringEncoding)
            sourceView.attributedText = decoratedAttributedSource(source)
            self.performSegueWithIdentifier("show", sender: nil)
        } catch {
            print("Error \(error)")
        }
    }
    
}
