//
//  FeedViewController.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/8.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var usersArray = [String]()
    var contentsArray = [String]()
    var likesArray = [Int]()
    var postImagesArray = [String]()
    var idArray = [String]()
    
    var userhadPressedLike = [String]()
    
    var detailUserEmail = ""
    var detailPostId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        setNavBar()
        siteToolBar()
    }
    
}


// MARK: Setting

extension FeedViewController {
    
    private func setNavBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登出", style: .done, target: self, action: #selector(logOutButtonClicked))
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func setTableView() {
        setDelegate()
        adjustCellHeight()
    }
    
    private func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func adjustCellHeight() {
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func siteToolBar() {
        navigationController?.isToolbarHidden = false
        
        let postButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(postButtonClicked))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbarItems = [spacer, postButton]
        navigationController?.toolbar.tintColor = .label
        
        setToolbarItems(toolbarItems, animated: true)
    }
    
}


// MARK: TableView Delegate

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        cell.selectionStyle = .none
        
        cell.userLabel.text = usersArray[indexPath.row]
        cell.likeLabel.text = String(likesArray[indexPath.row])
        cell.contentLabel.text = contentsArray[indexPath.row]
        
        cell.userImageView.sd_setImage(with: URL(string: postImagesArray[indexPath.row])) { image, error, _, _ in
            if error == nil {
                let highQualityImage = image?.resizeImageWithAspect(image: image!, scaledToMaxWidth: 300, maxHeight: 350)
                cell.userImageView.image = highQualityImage
            }
        }
            
        cell.idLabel.text = idArray[indexPath.row]
        
        return cell
        
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailPostId = idArray[indexPath.row]
        detailUserEmail = usersArray[indexPath.row]
        
        self.performSegue(withIdentifier: "toDetail", sender: nil)
    }
}


// MARK: FeedCellDelegate

extension FeedViewController: FeedCellDelegate {
    
    func deletePostClicked(cell: FeedCell) {
        
        let alert = UIAlertController(title: "Delete Post", message: "永遠刪除貼文", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "確定刪除", style: .default) { [self] _ in
            
            guard let indexPath = self.tableView.indexPath(for: cell) else { return }
            
            detailPostId = idArray[indexPath.row]
            
            let db = Firestore.firestore()
            db.collection("Posts").document(detailPostId).delete()
            
            let storage = Storage.storage()
            let url = postImagesArray[indexPath.row]
            let storageRef = storage.reference(forURL: url)
            
            storageRef.delete { [self] error in
                if (error != nil) {
                    print("刪除失敗")
                } else {
                    getDocumentCount(database: db)
                }
            }
       
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
        
    }
    
}


// MARK: Func

extension FeedViewController {
    
    private func getDocumentCount(database: Firestore) {
        database.collection("Posts").getDocuments() { [self] snapshot, error in
            if error == nil {
                if (snapshot?.documents.count)! < 1 {
                    usersArray.removeAll()
                    tableView.reloadData()
                }
            }
        }
    }
    
}

// MARK: @Objc

extension FeedViewController {
    
    @objc func logOutButtonClicked() {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logOut", sender: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func postButtonClicked() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyBoard.instantiateViewController(withIdentifier: "addNewVC") as! UINavigationController
        
        let vc = nav.topViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}


// MARK: Segue

extension FeedViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destinationVC = segue.destination as! DetailViewController
            
            destinationVC.thePostUserEmail = detailUserEmail
            destinationVC.postID = detailPostId
        }
    }
    
}

// MARK: Fetch Data

extension FeedViewController {
    
    private func getData() {
        let db = Firestore.firestore()
        
        db.collection("Posts").order(by: "date", descending: true).addSnapshotListener { [self] snapshot, error in
            handleData(snapshot: snapshot, error: error)
        }
    }
    
    private func handleData(snapshot: QuerySnapshot?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "獲取數據失敗")
        } else {
            findDocuments(snapshot: snapshot!)
        }
    }
    
    private func findDocuments(snapshot: QuerySnapshot)  {
        if snapshot.isEmpty != true {
            getDocument(snapshot: snapshot)
        }
    }
    
    private func getDocument(snapshot: QuerySnapshot) {
        cleanArray()
        
        for document in snapshot.documents {
            updateScreen(document: document)
        }
    }
    
    private func cleanArray() {
        self.idArray.removeAll()
        self.usersArray.removeAll()
        self.contentsArray.removeAll()
        self.likesArray.removeAll()
        self.postImagesArray.removeAll()
    }
    
    private func updateScreen(document: QueryDocumentSnapshot) {
        idArray.append(document.documentID)
        usersArray.append(document.get("author") as! String)
        contentsArray.append(document.get("content") as! String)
        likesArray.append(document.get("likes") as! Int)
        postImagesArray.append(document.get("picURL") as! String)
        
//        processLikeButtonColor(document: document)
        
        self.tableView.reloadData()
    }
    
    private func processLikeButtonColor(document: QueryDocumentSnapshot) {
//        let pressLikeUsers = document.get("userLikes") as! [String]
//        let currentUser = Auth.auth().currentUser?.email
//
//        for pressLikeUser in pressLikeUsers {
//            if currentUser == pressLikeUser {
//                userhadPressedLike.append("red")
//            } else {
//                userhadPressedLike.append("label")
//            }
//        }
    }
    
}






















