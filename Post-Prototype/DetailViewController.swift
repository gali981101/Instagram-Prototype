//
//  DetailViewController.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/11.
//

import UIKit
import Firebase
import SDWebImage
import IQKeyboardManagerSwift


class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var thePostUserEmail = ""
    var currentUser = Auth.auth().currentUser?.email
    
    var postID = ""
    
    private var postContents = ""
    private var imageURL = ""
    private var filterTypeArray = ["Chrome", "Fade", "Instant", "Mono", "Noir", "Process", "Tonal", "Transfer"]
    
    private var defaultImage: UIImage?
    private var originalImage: UIImage?
    
    var toggleEdit = false
    
    var changeImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getPostData()
        navBarSetting()
        setHeaderView()
        settingToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if changeImage {
            updateImageRef()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("cleanText"), object: nil)
    }
    
}


//MARK: Setting

extension DetailViewController {
    
    private func navBarSetting() {
        if currentUser == thePostUserEmail {
            let editButton = UIBarButtonItem(title: "編輯文字", style: .done, target: self, action: #selector(editButtonClicked))
            let changeImageButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(imagePicker))
            
            navigationItem.rightBarButtonItems = [editButton, changeImageButton]
            navigationController?.navigationBar.tintColor = .label
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post by \(thePostUserEmail)", style: .done, target: nil, action: nil)
        }
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        adjustCellHeight()
    }
    
    private func adjustCellHeight() {
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setHeaderView() {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        
        headerView.imageView.sd_setImage(with: URL(string: imageURL)) { [self] image, error, _, _ in
            if error == nil {
                let highQualityImage = image?.resizeImageWithAspect(image: image!, scaledToMaxWidth: 300, maxHeight: 350)
                
                headerView.imageView.image = highQualityImage
                
                originalImage = highQualityImage
            }
        }
        
        self.tableView.tableHeaderView = headerView
    }
    
    private func settingToolBar() {
        if currentUser == thePostUserEmail {
            let addFilterButton = UIBarButtonItem(title: "圖片濾鏡", image: nil, primaryAction: nil, menu: filterMenu)
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            toolbarItems = [spacer, addFilterButton]
            navigationController?.toolbar.tintColor = .label
            
            setToolbarItems(toolbarItems, animated: true)
        }
    }
    
    private func changeHeaderView() {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        headerView.imageView.image = defaultImage
        self.tableView.tableHeaderView = headerView
    }
    
    private func cleanHeaderView() {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        headerView.imageView.image = nil
        self.tableView.tableHeaderView = headerView
    }
    
}


// MARK: TableView Delegate

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
        
        cell.selectionStyle = .none
        
        cell.detailID = postID
        cell.textView.text = postContents
        
        return cell
    }
    
}


// MARK: Get Post Data

extension DetailViewController {
    
    private func getPostData() {
        let db = Firestore.firestore()
        
        db.collection("Posts").document(postID).getDocument { [self] document, error in
            filterData(document: document, error: error)
            tableView.reloadData()
            setHeaderView()
        }
    }
    
    private func filterData(document: DocumentSnapshot?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "找不到資料")
        } else {
            updateUI(document: document!)
        }
    }
    
    private func updateUI(document: DocumentSnapshot) {
        imageURL = document.get("picURL") as! String
        postContents = document.get("content") as! String
    }
    
}


// MARK: @Objc Func

extension DetailViewController {
    
    @objc func editButtonClicked() {
        
        toggleEdit.toggle()
        tableView.isScrollEnabled.toggle()
        
        if toggleEdit {
            self.cleanHeaderView()
            
            navigationItem.rightBarButtonItems![0].title = "完成"
            navigationItem.rightBarButtonItems![1].isEnabled = false
            
            NotificationCenter.default.post(name: NSNotification.Name("intoEdit"), object: nil)
        } else {
            self.setHeaderView()
            
            navigationItem.rightBarButtonItems![0].title = "編輯文字"
            navigationItem.rightBarButtonItems![1].isEnabled = true
            
            NotificationCenter.default.post(name: NSNotification.Name("outEdit"), object: nil)
        }
        
    }
    
    @objc func imagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true)
    }
    
}


// MARK: Switch Filter Type

extension DetailViewController {
    
    private func addFilter(type: String) {
        changeImage = true
        
        swithFilterType(filterType: type)
        changeHeaderView()
    }
    
    private func swithFilterType(filterType: String) {
        switch filterType {
        case "Chrome":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Chrome)
        case "Fade":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Fade)
        case "Instant":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Instant)
        case "Mono":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Mono)
        case "Noir":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Noir)
        case "Process":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Process)
        case "Tonal":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Tonal)
        case "Transfer":
            resetImage()
            defaultImage = defaultImage!.addFilter(filter: .Transfer)
        case "None":
            changeImage = false
            resetImage()
        default:
            return
        }
    }
    
    private func resetImage() {
        defaultImage = originalImage
    }
    
}


// MARK: Menu

extension DetailViewController {
    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Chrome", image: UIImage(systemName: ""), handler: { [] (_) in
                self.addFilter(type: "Chrome")
            }),
            UIAction(title: "Fade", image: UIImage(systemName: ""), handler: { (_) in
                self.addFilter(type: "Fade")
            }),
            UIAction(title: "Instant", image: UIImage(systemName: ""), handler: { (_) in
                self.addFilter(type: "Instant")
            }),
            UIAction(title: "Mono", image: UIImage(systemName: ""), handler: { (_) in
                self.addFilter(type: "Mono")
            }),
            UIAction(title: "Noir", image: UIImage(systemName: ""), handler: { (_) in
                self.addFilter(type: "Noir")
            }),
            UIAction(title: "Process", image: UIImage(systemName: ""), handler: { (_) in
                self.addFilter(type: "Process")
            }),
            UIAction(title: "Tonal", image: UIImage(systemName: ""), handler: { (_) in
                self.addFilter(type: "Tonal")
            }),
            UIAction(title: "Transfer", image: UIImage(systemName: ""), handler: { (_) in
                self.addFilter(type: "Transfer")
            }),
            UIAction(title: "None", image: UIImage(systemName: ""), handler: { [self] (_) in
                self.addFilter(type: "None")
            })
        ]
    }
    
    var filterMenu: UIMenu {
        return UIMenu(title: "Filter Type", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
}

// MARK: Segue

extension DetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}


// MARK: ScrollView Delegate

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = self.tableView.tableHeaderView as! StretchyTableHeaderView
        headerView.scrollViewDidScroll(scrollView: scrollView)
    }
}


// MARK: ImagePickerControllerDelegate

extension DetailViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        defaultImage = image.resizeImageWithAspect(image: image, scaledToMaxWidth: 300, maxHeight: 350)
        originalImage = defaultImage
        
        changeHeaderView()
        changeImage = true
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}


// MARK: Update Image To Storage

extension DetailViewController {
    
    private func updateImageRef() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: imageURL)
        
        deleteImageRef(ref: storageRef)
    }
    
    private func deleteImageRef(ref: StorageReference) {
        ref.delete { [self] error in
            if (error != nil) {
                print("刪除失敗")
            } else {
                createNewImageRef()
            }
        }
    }
    
    private func createNewImageRef() {
        let imagesRef = Storage.storage().reference().child("images")
        
        if let newData = defaultImage?.pngData() {
            let newRef = imagesRef.child("\(UUID().uuidString).png")
            putNewData(newPicRef: newRef, data: newData)
        }
    }
    
    private func putNewData(newPicRef: StorageReference, data: Data) {
        newPicRef.putData(data) { [self] _, error in
            successOrNot(picRef: newPicRef, error: error)
        }
    }
    
    private func successOrNot(picRef: StorageReference, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "發生錯誤")
        } else {
            downloadStoragePicURL(picRef: picRef)
        }
    }
    
    private func downloadStoragePicURL(picRef: StorageReference)  {
        picRef.downloadURL { [self] url, error in
            if error == nil {
                let newPictureURL = url?.absoluteString
                writeDataIntoFirestore(url: newPictureURL!)
            }
        }
    }
    
    private func writeDataIntoFirestore(url: String) {
        let db = Firestore.firestore()
        db.collection("Posts").document(postID).setData(["picURL": url], merge: true)
    }
    
}
