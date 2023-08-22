//
//  DetailCell.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/11.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
    var detailID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.isEditable = false
        textView.isScrollEnabled = false
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(editText), name: NSNotification.Name("intoEdit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeText), name: NSNotification.Name("outEdit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clean), name: NSNotification.Name("cleanText"), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


// MARK: Update Text Content

extension DetailCell {
    
    @objc func editText() {
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.becomeFirstResponder()
    }
    
    @objc func completeText() {
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.resignFirstResponder()
        
        let db = Firestore.firestore()
        db.collection("Posts").document(detailID).setData(["content": textView.text!], merge: true)
    }
    
    @objc func clean() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("outEdit"), object: nil)
    }
    
}


// MARK: TextView Delegate

extension DetailCell: UITextViewDelegate {
    
    
}
