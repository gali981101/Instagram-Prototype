//
//  FeedCell.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/10.
//

import UIKit
import Firebase


// MARK: Protocol

protocol FeedCellDelegate: AnyObject {
    func deletePostClicked(cell: FeedCell)
}

class FeedCell: UITableViewCell {
    
    weak var delegate: FeedCellDelegate?
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        configureRemoveButton()
    }
    
   
    @IBAction func likeButtonClicked(_ sender: Any) {
        updateLikes()
    }
    
    @IBAction func removeButton(_ sender: Any) {
        removePost()
    }
    
}


// MARK: Setting

extension FeedCell {
    
    private func configureRemoveButton() {
        if userLabel.text != Auth.auth().currentUser?.email {
            removeButton.isHidden = true
        } else {
            removeButton.isHidden = false
        }
    }
    
    private func removePost() {
        self.delegate?.deletePostClicked(cell: self)
    }
    
}


// MARK: Add Likes

extension FeedCell {
    
    private func updateLikes() {
        let db = Firestore.firestore()
        getDocumnetData(db: db)
    }
    
    private func getDocumnetData(db: Firestore) {
        db.collection("Posts").document(idLabel.text!).getDocument { [self] snapshot, error in
            if error != nil {
                print("拿資料過程出問題")
            } else {
                getUserLikes(db: db, snap: snapshot!)
            }
        }
    }
    
    private func getUserLikes(db: Firestore, snap: DocumentSnapshot) {
        if let data = snap.data() {
            addElementToArray(db: db, data: data)
        }
    }
    
    private func addElementToArray(db: Firestore, data: [String: Any]) {
        var userLikes = data["userLikes"] as! [String]
        
        let currentUserEmail = Auth.auth().currentUser?.email
        
        if userLikes.count < 1 {
            
            userLikes.append(currentUserEmail!)
            addNewLike(db: db, userLikesArray: userLikes)
            print("第一筆新增")
        } else {
            for userLike in userLikes {
                if currentUserEmail == userLike {
                    if let deleteUser = userLikes.firstIndex(of: currentUserEmail!) {
                        userLikes.remove(at: deleteUser)
                        minusLike(db: db, userLikesArray: userLikes)
                    }
                    return
                }
            }
            
            userLikes.append(currentUserEmail!)
            addNewLike(db: db, userLikesArray: userLikes)
            print("新增其他筆新資料")
        }
    }
    
    private func addNewLike(db: Firestore, userLikesArray: [String]) {
        likeNumberIncrease(db: db)
        
        let updatedData = ["userLikes": userLikesArray]
        
        db.collection("Posts").document(idLabel.text!).setData(updatedData, merge: true) { error in
            if error != nil {
                print("新增按讚用戶失敗")
            }
        }
    }
    
    private func likeNumberIncrease(db:Firestore) {
        if let likeCount = Int(likeLabel.text!) {
            let likeStore = ["likes": likeCount + 1] as [String: Any]
            
            db.collection("Posts").document(idLabel.text!).setData(likeStore, merge: true) { error in
                if error != nil {
                    print("按讚失敗")
                }
            }
        }
    }
    
    private func minusLike(db: Firestore, userLikesArray: [String]) {
        likeNumberMinus(db: db)
        
        let updatedData = ["userLikes": userLikesArray]
        
        db.collection("Posts").document(idLabel.text!).setData(updatedData, merge: true) { error in
            if error != nil {
                print("刪除按讚用戶失敗")
            }
        }
    }
    
    private func likeNumberMinus(db:Firestore) {
        if let likeCount = Int(likeLabel.text!) {
            let likeStore = ["likes": likeCount - 1] as [String: Any]
            
            db.collection("Posts").document(idLabel.text!).setData(likeStore, merge: true) { error in
                if error != nil {
                    print("取消按讚失敗")
                }
            }
        }
    }
    
}


















