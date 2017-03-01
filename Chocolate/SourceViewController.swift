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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SourceViewController.adjustForKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SourceViewController.adjustForKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let source = try? NSString(contentsOfFile: localShaderPath(), encoding: String.Encoding.ascii.rawValue) as String {
            sourceView.attributedText = decoratedAttributedSource(source)
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    func adjustForKeyboard(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            sourceView.contentInset = UIEdgeInsets.zero
        } else {
            sourceView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        sourceView.scrollIndicatorInsets = sourceView.contentInset
        
        let selectedRange = sourceView.selectedRange
        sourceView.scrollRangeToVisible(selectedRange)
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        do {
            if let source = sourceView.text {
                try source.write(toFile: localShaderPath(), atomically: true, encoding: String.Encoding.utf8)
                sourceView.attributedText = decoratedAttributedSource(source)
                self.performSegue(withIdentifier: "show", sender: nil)
            }
        } catch {
            print("Error \(error)")
        }
    }
    
}
