//
//  Account.swift
//  LoginDemo
//
//  Created by Tommy on 2021/2/1.
//

import Foundation

struct Account: Codable {
    let profile: Profile
    let credentials: Credential
}

struct Profile: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var login: String
    var birthdayDate: String
    var profileUrl: URL
}

struct Credential: Codable {
    let password: Password
    let recovery_question: RecoveryQuestion
    struct Password: Codable {
        var value: String
    }
    struct RecoveryQuestion: Codable {
        var question: String
        var answer: String
    }
}

struct LoginAccount: Codable {
    let username: String
    let password: String
}

struct UserInfo: Codable {
    var sessionToken: String
    var id: String
    var profile: Profile
    
    // 宣告為static 可直接用型別呼叫func. ex: UserInfo.saveToFile()
    static func saveToFile(userInfo: UserInfo) {
        if let data = try? JSONEncoder().encode(userInfo) {
            let userDefault = UserDefaults.standard
            userDefault.set(data, forKey: "userInfo")
        }
    }
    
    static func readFile() -> UserInfo? {
        let userDefault = UserDefaults.standard
        if let data = userDefault.data(forKey: "userInfo"),
           let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) {
            return userInfo
        } else {
            return nil
        }
    }
    
    static func removeFile() {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: "userInfo")
    }
}

struct UpdateUser: Codable {
    var profile: Profile
}



