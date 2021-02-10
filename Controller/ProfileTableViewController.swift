//
//  ProfileTableViewController.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/27.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    var profile: Profile?
    var userinfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black // for setting status bar color
        tableView.separatorStyle = .singleLine // 設定分隔線樣式
        tableView.separatorColor = .lightGray // 設定分隔線顏色
        tableView.allowsSelection = false // 設定無法點選cell
        tableView.separatorInset = UIEdgeInsets.zero // 讓分隔線到最左邊
        tableView.tableFooterView = UIView() // 移除多餘的separator
        navigationController?.navigationBar.barTintColor = .black // 設定navBar background color
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userinfo = .readFile()
        profile = userinfo?.profile
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return UserProfile.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let profileType = UserProfile.allCases[section]
        switch profileType {
        case .userHeader:
            return 1
        case .userInfo :
            return 2
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("indexPath:\(indexPath)")
        let profileType = UserProfile.allCases[indexPath.section]
        
        switch profileType {
        case .userHeader:
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(userHeaderTableViewCell.self)", for: indexPath) as! userHeaderTableViewCell
            configureUserHeader(cell)
            return cell
        case .userInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(userInfoTableViewCell.self)", for: indexPath) as! userInfoTableViewCell
            configureUserInfo(cell, forItemAt: indexPath)
            return cell
        
        }
    }
    
    
    func configureUserHeader(_ cell: userHeaderTableViewCell) {
        let name = "userPhoto"
        cell.userNameLabel.text = profile?.firstName
        if let userImage = ImageController.shared.readImage(name: name + ".jpg") {
            print("get userImage")
            cell.userPhotoImageView.contentMode = .scaleAspectFill
            cell.userPhotoImageView.image = userImage
        }
//        guard let url = profile?.profileUrl else { return }
//        ImageController.shared.fetchImage(url: url) { (image) in
//            guard let image = image else { return }
//            DispatchQueue.main.async {
//                cell.userPhotoImageView.contentMode = .scaleAspectFill
//                cell.userPhotoImageView.image = image
//            }
//        }
    }
    
    func configureUserInfo(_ cell: userInfoTableViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.userInfoImageView.image = UIImage(systemName: "envelope")
            cell.userInfoLabel.text = profile?.email
        } else {
            cell.userInfoImageView.image = UIImage(systemName: "calendar")
            cell.userInfoLabel.text = profile?.birthdayDate
        }
    }
    
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? EditProfileTableViewController {
            controller.profile = profile
            controller.userinfo = userinfo
            controller.imageUrl = profile?.profileUrl
        }
    }
    

}
