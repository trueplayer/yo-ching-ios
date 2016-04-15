//
//  WrexegramViewController.swift
//  YoChing
//
//  Created by Juan Wellington Moreno on 11/11/15.
//  Copyright © 2015 Gary.com. All rights reserved.
//

import AromaSwiftClient
import Foundation
import UIKit

class WrexagramViewController : UITableViewController {
    
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var wrexegramImage: UIImageView!
    @IBOutlet weak var wrexagramTitle: UILabel!

    
    var wrexagramNumber: Int = -1
    var wrexagram: Wrexagram?
    
    private var heights: [NSIndexPath : CGFloat] = [ : ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard wrexagramNumber > 0 else {
            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        if let wrexagram = self.wrexagram ?? determineWrexagramFromNumber(wrexagramNumber) {
            
            defer { self.wrexagram = wrexagram }
            
            AromaClient.begin()
                .withTitle("Wrexagram Viewed")
                .withBody("\(wrexagram.asString)\n\nBy \(UIDevice.currentDevice().name)")
                .send()
        }
        else {
            AromaClient.begin()
                .withTitle("Wrexagram Viewed")
                .withBody("Wrexagram \(wrexagramNumber)\n\nBy \(UIDevice.currentDevice().name)")
                .send()
        }
        
        loadTitle()
        loadImage()
        loadMessage()
    }
    
    private func loadTitle() {
        navTitle.text = "Wrexagram \(wrexagramNumber)"
        wrexagramTitle.text = wrexagram?.title ?? ""
    }
    
    private func loadImage() {
        if let image = WrexagramLibrary.imageForWrexagram(wrexagramNumber) {
            self.wrexegramImage.image = image
        }
    }
    
    private func loadMessage() -> String {
        
        let formattedOutcome = String(format: "wrexagram%02d", wrexagramNumber)
        let filename = "txt/\(formattedOutcome)"
        
        if let text = NSBundle.mainBundle().pathForResource(filename, ofType: "txt") {
            do {
                let string = try String(contentsOfFile: text, encoding: NSUTF8StringEncoding)
                
                return string
//                webView.loadHTMLString(htmlString, baseURL\ : NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath))
                
            } catch let ex {
                AromaClient.begin()
                    .withTitle("Operation Failed")
                    .withBody("\(ex)\n\(UIDevice.currentDevice().name)")
                    .send()
              
            }
        }
        
        return ""
    }
    
}

//MARK: Table View Data Methods
extension WrexagramViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //One for the Body, another for the What's Up
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            return createBodyCell(tableView, forIndexPath: indexPath)
        }
        else {
            return createWhatsUpCell(tableView, forIndexPath: indexPath)
        }
    }
    
    private func createBodyCell(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("BodyCell", forIndexPath: indexPath) as? BodyCell
        else {
              return UITableViewCell()
        }
        
        let body = loadMessage()
        cell.textView.text = body
        
        let size = cell.textView.sizeThatFits(CGSize(width: cell.textView.bounds.width, height: CGFloat(FLT_MAX)))
        
        let height = size.height + 24
        heights[indexPath] = height
        
        return cell
    }
    
    private func createWhatsUpCell(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("WhatsUpCell", forIndexPath: indexPath) as? WhatsUpCell
        else {
            return UITableViewCell()
        }
        
        let whatsUpText = wrexagram?.whatsUp ?? ""
        cell.textView.text = whatsUpText
        
//        
//        let tempTextView = UITextView()
//        tempTextView.text = whatsUpText
        let size = cell.textView.sizeThatFits(CGSize(width: cell.textView.bounds.width, height: CGFloat(FLT_MAX)))
        
        let height = size.height + cell.whatsUpLabel.bounds.height + 24
        heights[indexPath] = height
        
        return cell
    }
}

//MARK : Table View Delegate Methods
extension WrexagramViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return heights[indexPath] ?? 44
    }
}


//MARK: Utility Methods
extension WrexagramViewController {
    
    private func toAttributedString(html: String) -> NSAttributedString? {
        
        guard let data = html.dataUsingEncoding(NSUnicodeStringEncoding) else { return nil }
        
        let options: [String : String] = [
            NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType
        ]
        
        guard let string = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else { return nil }
        
        if let font = UIFont.init(name: "Exo-Bold", size: 24) {
            string.addAttribute(NSFontAttributeName, value: font, range: NSRangeFromString(string.string))
            print("Font Loaded")
            
        }
        
        return string
    }
    
    private func determineWrexagramFromNumber(number: Int) -> Wrexagram? {
        let index = number - 1
        
        guard index < WrexagramLibrary.wrexagrams.count else { return nil }
        
        return WrexagramLibrary.wrexagrams[index]
    }
}

//MARK: Cells
class BodyCell : UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
}

class WhatsUpCell : UITableViewCell {
    
    @IBOutlet weak var whatsUpLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
}