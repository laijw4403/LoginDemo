//
//  ImageController.swift
//  LoginDemo
//
//  Created by Tommy on 2021/2/1.
//

import Foundation
import UIKit
import Alamofire

class ImageController {
    static var shared = ImageController()
    private var clientId = "2dd98a167d9115a"
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
               let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func uploadImage(uiImage: UIImage, completion: @escaping (Result<URL,Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID \(clientId)",
        ]
        AF.upload(multipartFormData: { (data) in
            let imageData = uiImage.jpegData(compressionQuality: 1)
            data.append(imageData!, withName: "image")
            
        }, to: "https://api.imgur.com/3/image", headers: headers).responseDecodable(of: ImageUpLoadResponse.self, queue: .main, decoder: JSONDecoder()) { (response) in
            //print(String(data: response.data!, encoding: .utf8))
            switch response.result {
            case .success(let result):
                completion(.success(result.data.link))
                print(result.data.link)
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
    // 縮小圖片
    func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
        // 設定縮小後的圖片尺寸
        let size = CGSize(width: width, height: image.size.height * width / image.size.width)
        // 生成GraphicsImageRenderer物件，設定繪製圖片大小
        let renderer = UIGraphicsImageRenderer(size: size)
        // 呼叫func image(actions:)產生縮小的UIImage
        let newImage = renderer.image { (context) in
            // 繪製圖片
            image.draw(in: renderer.format.bounds)
        }
        return newImage
    }
    
    // 將圖片儲存至documents資料夾
    func storeImage(image: UIImage, name: String, compressionQuality: CGFloat) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsDirectory.appendingPathComponent(name).appendingPathExtension("jpg")
        do {
            print(documentsDirectory)
            print(url)
            print(url.path)
            print(url.absoluteURL)
            print("store image success")
            try image.jpegData(compressionQuality: compressionQuality)?.write(to: url)
        } catch  {
            print("store image fail")
        }
    }
    
    // 讀取存在documents資料夾的圖片
    func readImage(name: String) -> UIImage? {
        print("讀取存在documents資料夾的圖片")
        let documentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        let imageUrl = documentsDirectory.appendingPathComponent(name)
        return UIImage(contentsOfFile: imageUrl.path)
    }
    
}
