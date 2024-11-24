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
        // insert it in the fnalize dictionary
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier as String)
            item.attachments = [customJavaScript]
        
        // return items to previous window
        extensionContext?.completeRequest(returningItems: [item])
    }

}
