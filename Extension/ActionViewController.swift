//
//  ActionViewController.swift
//  Extension
//
//  Created by Rodrigo on 17-11-24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers


class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
                if let itemProvider = inputItem.attachments?.first {
                    itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier as String) { [weak self] (dict, error) in
                        
                        guard let itemDictionary = dict as? NSDictionary else { return }
                        
                        guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return}
                        
                        self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                        self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                        
                        // update UI in main thread
                        DispatchQueue.main.async {
                            self?.title = self?.pageTitle
                        }
                    }
                }
            }
    }

    @IBAction func done() {
        // object to hold the items
        let item = NSExtensionItem()
        // set argument from script.text
        let argument: NSDictionary = ["customJavaScript": script.text ?? ""]
        // insert it in the finalize dictionary
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        
        // Place that NSItemProvider into our NSExtensionItem as its attachments.
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier as String)
            item.attachments = [customJavaScript]
        
        // return items to previous window
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        // as NSValue because we can't get cgRectValue directly
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        // gets the size of the keyboard
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        // corrected size of the keyboard if it's rotated
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            // if keyboard is hidding show script from edge to edge
            script.contentInset = .zero
        } else {
            // if its showing resize to be above the keyboard
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        // adjust insets of the scroll indicator to be the same as the content
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
        
    }

}
