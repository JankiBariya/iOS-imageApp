//
//  NetworkModule.swift
//  imageApp
//
//  Created by PMCLAP1240 on 08/02/23.
//

import Foundation
import Alamofire

class NetworkModule {

    
    static let shared = NetworkModule()
    public init() {}
    
    
    func fetchData(word: String, pagination: Bool = false,pageNo: Int, completion: @escaping (Data?, Error?) -> Void) {
        
        let url = URL(string: "https://api.pexels.com/v1/search?query=\(word)&per_page=10&page=\(pageNo)")!
               
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)

         request.addValue("7mZrVnVvfFYQVzoJ3ToEVDrySzC2qKcdfJKUPyUxLVSS3rhx6HD2Hhet", forHTTPHeaderField: "Authorization")

         request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
              completion(nil,error)
            return
          }
            completion(data,nil)
            
          print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
        
        
    }
    
}
