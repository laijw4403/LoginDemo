//
//  ResponseModels.swift
//  LoginDemo
//
//  Created by Tommy on 2021/2/1.
//

import Foundation

struct ImageUpLoadResponse: Codable {
    struct Data: Codable {
        let link: URL
    }
    let data: Data
}

struct CreateAndUpdateResponse: Codable {
    let profile: Profile
}

struct FailCreateAccountResponse: Codable {
    let errorCauses: [ErrorCause]
    struct ErrorCause: Codable {
        let errorSummary: String
    }
}

struct SuccessLoginResponse: Codable {
    let sessionToken: String
    let status: String
    let _embedded: Embeded
    struct Embeded: Codable {
        let user: User
        struct User: Codable {
            let id: String
        }
    }
}


