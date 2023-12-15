//
//  UploadViewController.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/8.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class UploadViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setTextView()
        self.textView.becomeFirstResponder()
        setToolBar()
    }
    
}

// MARK: LayOut

extension UploadViewController {
    
    private func setToolBar() {
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "X"
        IQKeyboardManager.shared.toolbarTintColor = .label
    }
    
    private func setTextView() {
        textView.delegate = self
        textView.leftSpace()
        
        textView.text = "Write Something..."
        textView.font = UIFont.preferredFont(forTextStyle: .title3)
        textView.textColor = UIColor.lightGray
        view.addSubview(textView)
    }
    
    private func setNavBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(upload))
        
        
        self.navigationController?.navigationBar.tintColor = .label
    }
    
}

// MARK: Nav

extension UploadViewController {
    
    @objc func back() {
        self.dismiss(animated: true)
    }
    
    @objc func upload() {
        if textView.text != "" && textView.textColor == .label {
            createStorageRef()
            
            self.backToFeed()
            print("儲存內容並發布")
        } else {
            makeAlert(title: "Hold On !", message: "請新增文字內容", self: self)
        }
    }
    
    private func backToFeed() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyBoard.instantiateViewController(withIdentifier: "homeVC") as! UINavigationController
        
        let vc = nav.topViewController
        vc?.navigationItem.setHidesBackButton(true, animated: true)
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}


// MARK: Delegate Extension

extension UploadViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.font = UIFont.preferredFont(forTextStyle: .body)
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write Something..."
            textView.font = UIFont.preferredFont(forTextStyle: .title3)
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}


// MARK: Firebase Storage

extension UploadViewController {
    
    private func createStorageRef() {
        // Points to the root reference
        let storageRef = Storage.storage().reference()
        
        // Points to "images"
        let imagesRef = storageRef.child("images")
        
        processImageData(imagesRef: imagesRef)
    }
    
    private func processImageData(imagesRef: StorageReference) {
        // 將 UIImage 轉換為 jpegData
        if let data = selectedImage?.pngData() {
            
            // Points to "images/space.jpg"
            let picRef = imagesRef.child("\(UUID().uuidString).png")
            
            // 將轉換過後的 imageData 放進已創建好的 imgRef
            putDataIntoRef(ref: picRef, data: data)
        }
    }
    
    
    private func putDataIntoRef(ref: StorageReference, data: Data) {
        ref.putData(data) { [self] metadata, error in
            dataOrError(ref: ref, error: error)
        }
    }
    
    private func dataOrError(ref: StorageReference, error: Error?) {
        if error != nil {
            makeAlert(title: "Error", message: error?.localizedDescription ?? "錯誤", self: self)
        } else {
            getImageURL(ref: ref)
        }
    }
    
    private func getImageURL(ref: StorageReference) {
        ref.downloadURL { [self] url, error in
            if error == nil {
                let picURL = url?.absoluteString
                database(picUrl: picURL!)
            }
        }
    }
    
}


// MARK: Cloud Firestore Database

extension UploadViewController {
    
    private func database(picUrl: String) {
        
        let db = Firestore.firestore()
        
        db.collection("Posts").addDocument(data: definePost(picUrl: picUrl)) { error in
            if error != nil {
                makeAlert(title: "Error!", message: error?.localizedDescription ?? "新增 document 發生錯誤", self: self)
            }
        }
        
    }
    
    
    private func definePost(picUrl: String) -> [String: Any] {
        let post = [
            "picURL": picUrl,
            "author": Auth.auth().currentUser!.email!,
            "content": self.textView.text!,
            "date": FieldValue.serverTimestamp(),
            "likes": 0,
            "userLikes": [String]()
        ] as [String: Any] 
        
        return post
    }
    
}



















