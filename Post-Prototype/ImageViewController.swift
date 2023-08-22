//
//  ImageViewController.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/8.
//

import UIKit
import SDWebImage

class ImageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var defaultImage = UIImage(named: "select")
    private var originalImage: UIImage?
    
    private var imageSelected = false
    private var chosenImage: UIImage?
    
    private var filterTypeArray = ["Chrome", "Fade", "Instant", "Mono", "Noir", "Process", "Tonal", "Transfer", "None"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavButton()
        setHeader()
        
        originalImage = defaultImage
    }
    
}

// MARK: Setting

extension ImageViewController {
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
    }
    
    private func setNavButton() {
//        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(chosePhoto))
        let nextButton = UIBarButtonItem(title: "Text", style: .done, target: self, action: #selector(nextStep))
        
        self.navigationItem.rightBarButtonItems = [nextButton]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(cancel))
        
        self.navigationController?.navigationBar.tintColor = .label
    }
    
    private func setHeader() {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        headerView.imageView.image = defaultImage!.resizeImageWithAspect(image: defaultImage!, scaledToMaxWidth: 300, maxHeight: 350)
        
        self.tableView.tableHeaderView = headerView
        self.tableView.tableHeaderView!.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(chosePhoto))
        self.tableView.tableHeaderView!.addGestureRecognizer(tap)
    }
    
}


// MARK: Objc Func

extension ImageViewController {
    
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
        defaultImage = UIImage(named: "select")
        setHeader()
        self.imageSelected = false
    }
    
    @objc func nextStep() {
        shouldSelectImage()
    }
    
    @objc func chosePhoto() {
        imagePicker()
    }
    
}


// MARK: Switch Filter Type

extension ImageViewController {
    
    private func addFilter(type: String) {
        swithFilterType(filterType: type)
        setHeader()
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
            resetImage()
        default:
            return
        }
    }
    
    private func resetImage() {
        defaultImage = originalImage
    }
    
}

// MARK: Step Check

extension ImageViewController {
    
    private func shouldSelectImage()  {
        if imageSelected {
            self.performSegue(withIdentifier: "nextStepVC", sender: nil)
        } else {
            makeAlert(title: "Wait！", message: "請先選擇圖片", self: self)
        }
    }
    
}


// MARK: Segue

extension ImageViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextStepVC" {
            let nav = segue.destination as! UINavigationController
            let destinationVC = nav.topViewController as! UploadViewController
            
            destinationVC.selectedImage = defaultImage
        }
    }
}


// MARK: Table View Delegate

extension ImageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! ImageFilterCell
        
        cell.filterTypeLabel.text = filterTypeArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addFilter(type: filterTypeArray[indexPath.row])
    }
    
}

extension ImageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private func imagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        defaultImage = image.resizeImageWithAspect(image: image, scaledToMaxWidth: 300, maxHeight: 350)
        originalImage = defaultImage
        
        setHeader()
        imageSelected = true
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}


// MARK: ScrollView Delegate

extension ImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = self.tableView.tableHeaderView as! StretchyTableHeaderView
        headerView.scrollViewDidScroll(scrollView: scrollView)
    }
}




