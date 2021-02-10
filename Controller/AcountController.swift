//
//  AccountController.swift
//  LoginDemo
//
//  Created by Tommy on 2021/2/1.
//

import Foundation
import UIKit

class AccountController {
    
    static var shared = AccountController()
    private let baseURL = URL(string: "https://dev-40537348.okta.com/api/v1")!
    private let apiKey = "00p4kzo44RipZP5xPYLNXIiNL9GINK8WgNYXo8Ne4Y"
    
    // 註冊帳號
    func createAccount(forAccount account: Account, completion: @escaping (Result<Profile, CustomError>) -> Void) {
        let baseCreateURL = baseURL.appendingPathComponent("users")
        var components = URLComponents(url: baseCreateURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "activate", value: "true")]
        let createURL = components.url!
        print(createURL)
        var request = URLRequest(url: createURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("SSWS \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try? JSONEncoder().encode(account)
        request.httpBody = jsonData
        print(String(data: jsonData!, encoding: .utf8))
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                print(String(data: data, encoding: .utf8)!)
                do {
                    // 利用statusCode判斷接收的response
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            let successResponse = try JSONDecoder().decode(CreateAndUpdateResponse.self, from: data)
                            completion(.success(successResponse.profile))
                        } else {
                            let failResponse = try JSONDecoder().decode(FailCreateAccountResponse.self, from: data)
                            if let errorSummary = failResponse.errorCauses.first?.errorSummary {
                                completion(.failure(CustomError.error(errorSummary)))
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
            } else if let error = error {
                print(error)
            }
        }.resume()
    }
    
    // 登入帳號
    func loginAccount(username: String, password: String, completion: @escaping (Result<SuccessLoginResponse, Error>) -> Void) {
        
        let loginURL = baseURL.appendingPathComponent("authn")
        print(loginURL)
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("SSWS \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let logInAccount = LoginAccount(username: username, password: password)
        let jsonData = try? JSONEncoder().encode(logInAccount)
        request.httpBody = jsonData
        print(String(data: jsonData!, encoding: .utf8))
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(SuccessLoginResponse.self, from: data)
                    completion(.success(response))
                } catch  {
                    completion(.failure(error))
                }
            } else {
                print(error)
            }
        }.resume()
    }
    
    // 修改個人資訊
    func updateProfile(update profile: Profile, for userId : String, completion: @escaping(Result<Profile,Error>) -> Void) {
        let updateURL = baseURL.appendingPathComponent("users/\(userId)")
        print(updateURL)
        var request = URLRequest(url: updateURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("SSWS \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let updateUser = UpdateUser(profile: profile)
        let jsonData = try? JSONEncoder().encode(updateUser)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // 利用statusCode判斷接收的response
            if let data = data,
               let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("update success")
                    do {
                        let successResponse = try JSONDecoder().decode(CreateAndUpdateResponse.self, from: data)
                        completion(.success(successResponse.profile))
                    } catch  {
                        completion(.failure(error))
                    }
                    
                } else {
                    print(error)
                }
            }
        }.resume()
    }
    
}
