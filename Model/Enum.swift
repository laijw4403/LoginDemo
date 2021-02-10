//
//  Enum.swift
//  LoginDemo
//
//  Created by Tommy on 2021/2/1.
//

import Foundation

enum UserProfile: CaseIterable {
    case userHeader
    case userInfo
}

enum SelectImageMode {
    case camera
    case photoLibrary
    case savedPhotosAlbum
}

enum CustomError: Error {
    case error(String)
}

