//
//  EmailSignUpViewController.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/25.
//

import UIKit

class EmailSignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let formatter = DateFormatter()
    let datePicker = UIDatePicker()
    
    var email: String!
    var imageUrl: URL?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var recoveryQTextField: UITextField!
    @IBOutlet weak var recoveryATextField: UITextField!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotification()
        
        // 設定textfield的delegate為self
        setTextField()
        
        emailLabel.text = email
        createDatePicker()
        
        // 建立tap, 點擊畫面時收起keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        
    }
    
    func setTextField() {
        
        self.firstNameTextField.tag = 0
        self.lastNameTextField.tag = 1
        self.passwordextField.tag = 2
        self.birthdayTextField.tag = 3
        self.recoveryQTextField.tag = 4
        self.recoveryATextField.tag = 5
            
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        passwordextField.delegate = self
        birthdayTextField.delegate = self
        recoveryQTextField.delegate = self
        recoveryATextField.delegate = self
        
        passwordextField.isSecureTextEntry = true
    }
    
    // MARK: Account Register
    @IBAction func tapContinue(_ sender: Any) {
        guard let imageUrl = imageUrl else {
            return self.showAleart(message: "Please choose an appropriate picture to represent yourself")
        }
        if let firstName = firstNameTextField.text,
           let lastName = lastNameTextField.text,
           let email = email,
           let birthdayDate = birthdayTextField.text,
           let passwordValue = passwordextField.text,
           let question = recoveryQTextField.text,
           let answer = recoveryATextField.text {
            let password = Credential.Password(value: passwordValue)
            let recoveryQuestion = Credential.RecoveryQuestion(question: question, answer: answer)
            let credentials = Credential(password: password, recovery_question: recoveryQuestion)
            let profile = Profile(firstName: firstName, lastName: lastName, email: email, login: email, birthdayDate: birthdayDate, profileUrl: imageUrl)
            let account = Account(profile: profile, credentials: credentials)
            print(account)
            
            // 註冊帳號
            AccountController.shared.createAccount(forAccount: account) { (result) in
                switch result {
                // 註冊成功
                case .success(let userprofile):
                    print("create account success")
                    print(userprofile)
                    
                    // 登入帳號
                    AccountController.shared.loginAccount(username: email, password: passwordValue) { (result) in
                        switch result {
                        // 登入成功
                        case .success(let userinfo):
                            print("login account success")
                            let sessionToken = userinfo.sessionToken
                            let userId = userinfo._embedded.user.id
                            // 儲存使用者個人資訊
                            UserInfo.saveToFile(userInfo: UserInfo(sessionToken: sessionToken, id: userId, profile: userprofile))
                            // 切換至個人頁面
                            DispatchQueue.main.async {
                                self.showProfileTableView()
                            }
                        // 登入失敗
                        case .failure(let error):
                            print("login account fail")
                            print(error)
                        }
                    }
                // 註冊失敗 彈出alert告知使用者錯誤訊息
                case .failure(let error):
                    print("create account fail")
                    print("error:\(error)")
                    let errorDescription = "\(error)"
                    DispatchQueue.main.async {
                        self.showAleart(message: errorDescription)
                    }
                }
            }
        }
    }
    
    // 顯示個人頁面
    func showProfileView(profile: Profile) {
        if let controller = self.storyboard?.instantiateViewController(identifier: "\(ProfileTableViewController.self)") as? ProfileTableViewController {
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen // 設定present樣式
            controller.profile = profile
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: Keyboard Setting
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contenInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contenInsets
        scrollView.scrollIndicatorInsets = contenInsets
    }
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    // MARK: Select Birthday
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
    
    // MARK: Select Image
    /// 存取使用者私密資料必須在info.plist加入使用相機和照片的描述
    @IBAction func seletImage(_ sender: Any) {
        print("tap ImageView")
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.addPhotoLabel.isHidden = true
        if let image = info[.originalImage] as? UIImage {
            userPhotoImageView.image = image
            userPhotoImageView.contentMode = .scaleAspectFill
            // 縮小圖片
            let smallImage = ImageController.shared.resizeImage(image: image, width: 320)
            // 儲存圖片
            ImageController.shared.storeImage(image: smallImage, name: "userPhoto", compressionQuality: 1)
            // 上傳圖片
            ImageController.shared.uploadImage(uiImage: smallImage, completion: { (result) in
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 點擊return跳到下一個textfield (by tag)
        print(textField.tag)
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.superview?.viewWithTag(nextTag) as? UITextField {
            print("have nextResponder:\(nextResponder)")
            nextResponder.becomeFirstResponder()
        } else {
            print("no nextResponder")
            textField.resignFirstResponder() // 離開responder
        }
        return true
    }
    
}

//extension EmailSignUpViewController: UITextFieldDelegate {
//
//}
