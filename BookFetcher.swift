import Foundation
import SwiftUI

final class BookFetcher: ObservableObject {
    private let url = "https://api.syosetu.com/novelapi/api/?order=hyoka&out=json&type=er&of=t-n-w-s-k-g-ga&lim=100"//"https://{***}?input_text=aaa"
    private let options = [
    ["order=hyoka"],
    ["out=json"],
    ["type=er"],
    ["of=t-n"]
    ]
    
    @Published var books: [Book] = []
    
    init() {
        
        fetchBooks()
    }
    
    private func fetchBooks() {
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            do {
                // JSON全体をまず配列としてデコード
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                    print("Invalid JSON format")
                    return
                }
                // 二つ目以降の要素を抽出
                let subArray = Array(jsonArray.dropFirst())
                // subArrayをJSONデータに再度変換
                let subArrayData = try JSONSerialization.data(withJSONObject: subArray, options: [])
                // subArrayDataをBook配列としてデコード
                let books = try decoder.decode([Book].self, from: subArrayData)
                // メインスレッドで books プロパティを更新
                DispatchQueue.main.async {
                    self.books = books
                }
                
            } catch {
                print("FAILED DECODER:", error.localizedDescription)
            }
        }.resume()
    }
}
