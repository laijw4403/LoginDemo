//
//  EditProfileTableViewController.swift
//  LoginDemo
//
//  Created by Tommy on 2021/2/5.
//

import UIKit

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var profile: Profile?
    var userinfo: UserInfo?
    
    let formatter = DateFormatter()
    let datePicker = UIDatePicker()
    var imageUrl: URL?
    var userImage: UIImage?
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white // 設定navigation back button color
        initUI()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: Set TextField
    func initUI() {
        createDatePicker()
        updateUserPhoto()
        firstNameTextField.attributedPlaceholder = NSAttributedString(string: firstNameTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        lastNameTextField.attributedPlaceholder = NSAttributedString(string: lastNameTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        guard let profile = profile else { return }
        firstNameTextField.text = profile.firstName
        lastNameTextField.text = profile.lastName
        emailTextField.text = profile.email
        let date = profile.birthdayDate
        birthdayTextField.text = date
    }
    
    func updateUserPhoto() {
        let name = "userPhoto"
        if let userImage = ImageController.shared.readImage(name: name + ".jpg") {
            print("get userImage")
            userPhotoImageView.contentMode = .scaleAspectFill
            userPhotoImageView.image = userImage
        }
    }
//    func updateUserPhoto(from url: URL) {
//
//        ImageController.shared.fetchImage(url: url) { (image) in
//            guard let image = image else { return }
//            self.userimage = image
//            DispatchQueue.main.async {
//                self.userPhotoImageView.contentMode = .scaleAspectFill
//                self.userPhotoImageView.image = image
//            }
//        }
//    }
    
    func createDatePicker() {
        
        formatter.dateFormat = "yyyy-MM-dd"
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        // 將textfield的輸入視圖更改為UIDatePicker
        birthdayTextField.inputView = datePicker
        
        // 設定選擇日期後觸發事件
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
    }
    
    @objc func dateChanged() {
        birthdayTextField.text = formatter.string(from: datePicker.date)
    }
    
    @IBAction func changeUserPhoto(_ sender: Any) {
        print("change user photo")
        let controller = UIAlertController(title: "Select Image", message: "", preferredStyle: .actionSheet)
        
        // 相機
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.selectPhoto(mode: .camera)
        }
        
        // 照片
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.selectPhoto(mode: .photoLibrary)
        }
        
        // 圖庫
        let savePhotosAlbumAction = UIAlertAction(title: "Album", style: .default) { (_) in
            self.selectPhoto(mode: .savedPhotosAlbum)
        }
        
        // 取消
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // 將四個Action加入Alert
        controller.addAction(cameraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(savePhotosAlbumAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
        
    }
    
    // 選擇照片，參數為選擇方式
    func selectPhoto(mode: SelectImageMode) {
        
        let controller = UIImagePickerController()
        controller.delegate = self
        
        // 三種選擇照片方式
        switch mode {
        
        case .camera:
            controller.sourceType = .camera // 相機
        case .photoLibrary:
            controller.sourceType = .photoLibrary // 照片
        case .savedPhotosAlbum:
            controller.sourceType = .savedPhotosAlbum // 圖庫
        }
        
        present(controller, animated: true, completion: nil)
        
    }
    
    // 選擇照片後要做的事
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            userPhotoImageView.image = image
            userPhotoImageView.contentMode = .scaleAspectFill
            // 縮小圖片
            userImage = ImageController.shared.resizeImage(image: image, width: 320)
            guard let userImage = userImage else { return }
            // 上傳照片
            ImageController.shared.uploadImage(uiImage: userImage, completion: { (result) in
                switch result {
                case .success(let url):
                    print("image upload success")
                    self.imageUrl = url
                case .failure(let error):
                    print("image upload fail")
                    print(error)
                }
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Update Profile
    @IBAction func doneButtonPressed(_ sender: Any) {
        print("doneButton")
        if let firstName = firstNameTextField.text,
           let lastName = lastNameTextField.text,
           let email = emailTextField.text,
           let birthdayDate = birthdayTextField.text,
           let url = imageUrl,
           let id = userinfo?.id,
           let sessionToken = userinfo?.sessionToken{
            profile = Profile(firstName: firstName, lastName: lastName, email: email, login: email, birthdayDate: birthdayDate, profileUrl: url)
            guard let profile = profile else { return }
            AccountController.shared.updateProfile(update: profile, for: id) { (result) in
                switch result {
                case .success(let profile):
                    self.userinfo = UserInfo(sessionToken: sessionToken, id: id, profile: profile)
                    guard let userImage = self.userImage else { return }
                    // 儲存圖片
                    ImageController.shared.storeImage(image: userImage, name: "userPhoto", compressionQuality: 1)
                    // 儲存修改後的user profile
                    UserInfo.saveToFile(userInfo: self.userinfo!)
                    // 回到個人主頁
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    print("update account fail")
                    print(error)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section, indexPath.row)
        // 取消cell選取狀態
        tableView.deselectRow(
            at: indexPath, animated: true)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.separatorColor = .lightGray
        if indexPath.section == 0 {
            cell.separatorInset = UIEdgeInsets.zero
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        }
        
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
