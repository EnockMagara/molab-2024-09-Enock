// import Foundation
// import Alamofire

// class NetworkManager {
//     static let shared = NetworkManager()
    
//     private init() {}
    
//     func fetchSuggestions(for input: String, completion: @escaping ([String], Error?) -> Void) {
//         let url = "https://api.openai.com/v1/your-endpoint" // Replace with actual endpoint
//         let headers: HTTPHeaders = [
//             "Authorization": "Bearer YOUR_API_KEY", // Replace with your API key
//             "Content-Type": "application/json"
//         ]
        
//         let parameters: [String: Any] = [
//             "prompt": input,
//             "max_tokens": 50 // Adjust as needed
//         ]
        
//         AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//             .responseDecodable(of: [String].self) { response in
//                 switch response.result {
//                 case .success(let value):
//                     completion(value, nil) // Return the parsed suggestions and no error
//                 case .failure(let error):
//                     // Directly check if the error is an AFError
//                     if let afError = error as? AFError, afError.responseCode == 401 {
//                         print("Error: Invalid API key")
//                         completion([], error) // Return empty and the error
//                     } else {
//                         print("Error: \(error)")
//                         completion([], error) // Return empty and the error
//                     }
//                 }
//             }
//     }
// }