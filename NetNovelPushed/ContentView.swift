//
//  ContentView.swift
//  NetNovelPushed
//
//  Created by 清水瞭平 on 2024/05/14.
//

import SwiftUI

struct Book: Decodable, Identifiable{
    var id: String { ncode }
    
    let title: String
    let ncode: String
    let writer: String
    let story: String
    let keyword: String
    let genre: Int
    let general_all_no: Int
    //    let url: String
}

struct ContentView: View {
    @ObservedObject private var fetcher = BookFetcher()
    @State private var fullStorys: [String] = []
    @State private var bookmarkBooks: [String] = UserDefaults.standard.stringArray(forKey: "bookmarkBooks") ?? []
    @State private var hiddenBooks: [String] = UserDefaults.standard.stringArray(forKey: "hiddenBooks") ?? []
    @State private var finishBooks: [String] = UserDefaults.standard.stringArray(forKey: "finishBooks") ?? []
    @State private var navigationTitle: String = "ホーム"
    @State private var scene: String = "search" //search,bookmark,finish,hiddenの四つのシーン
    //    let book: [Book] = fetcher.books
    //    @State var book: [Book] = [
    //        Book(title: "iphone",ncode: "test", url: "https://zenn.dev/oka_yuuji/articles/d97eaac0bde564"),
    //        Book(title: "android", url: "https://zenn.dev/rikutosato/books/6cee0a2b8aa796/viewer/66ae20"),
    //       Book(title: "あ", ncode: "testNN"),
    //        Book(title: "https://", url: "https://"),
    //        Book(title: "book", url: "book")
    //    ]
    
    
    private func isValidURL(_ urlString: String) -> Bool {
        if let url = URL(string: urlString),
           let _ = url.scheme, let _ = url.host {
            return true
        }
        return false
    }
    
    private func bookUrl(for book: Book) -> URL? {
        let urlString = "https://ncode.syosetu.com/" + book.ncode.lowercased()
        return isValidURL(urlString) ? URL(string: urlString) : nil
    }
    
    //fullStorysの変更:ストーリーをフルで見せるかショートで見せるか
    private func handleFullStory(book: Book) {
        if let index = fullStorys.firstIndex(of: book.id) {
            fullStorys.remove(at: index)
        } else {
            fullStorys.append(book.id)
        }
    }
    
    //UserDefaultsへの保存関数
    private func saveBookmarkBooks() {
        UserDefaults.standard.set(bookmarkBooks, forKey: "bookmarkBooks")
    }
    
    private func saveHiddenBooks() {
        UserDefaults.standard.set(hiddenBooks, forKey: "hiddenBooks")
    }
    
    private func saveFinishBooks() {
        UserDefaults.standard.set(finishBooks, forKey: "finishBooks")
    }
    
    private func handleBookmark(book: Book) {
        if let index = bookmarkBooks.firstIndex(of: book.id) {
            bookmarkBooks.remove(at: index)
        } else {
            bookmarkBooks.append(book.id)
        }
        saveBookmarkBooks()
    }
    
    private func handleHidden(book: Book) {
        if let index = hiddenBooks.firstIndex(of: book.id) {
            hiddenBooks.remove(at: index)
        } else {
            hiddenBooks.append(book.id)
        }
        saveHiddenBooks()
    }
    
    private func handleFinish(book: Book) {
        if let index = finishBooks.firstIndex(of: book.id) {
            finishBooks.remove(at: index)
        } else {
            finishBooks.append(book.id)
        }
        saveFinishBooks()
    }
    
    
    var body: some View {
        NavigationStack{
            VStack {
                //本の一覧表示
                List(fetcher.books){ book in
                    let isFullStory = fullStorys.contains(book.id)
                    let isBookmarked = bookmarkBooks.contains(book.id)
                    let isHidden = hiddenBooks.contains(book.id)
                    let isFinished = finishBooks.contains(book.id)
                    
                    if scene == "search" && !isHidden && !isFinished ||
                        scene == "bookmark" && isBookmarked ||
                        scene == "hidden" && isHidden ||
                        scene == "finish" && isFinished {
                        
                        BookView(book: book,
                                 isFullStory: isFullStory,
                                 isBookmarked: isBookmarked,
                                 isHidden: isHidden,
                                 isFinished: isFinished,
                                 onFullStory: { handleFullStory(book: book)},
                                 onBookmark: { handleBookmark(book: book) },
                                 onHidden: { handleHidden(book: book) },
                                 onFinish: { handleFinish(book: book) })
                    }
                }
                if scene == "mypage" {
                    VStack{
                        Button(action: { scene = "hidden";
                            navigationTitle = "非表示"}){
                            Text("非表示")
                        }
                        Button(action: { scene = "finish";
                            navigationTitle = "読了"}){
                            Text("読了")
                        }
                    }
                    
//                    TabButton(title: "非表示", icon: "minus.circle", action: )
//                    TabButton(title: "読了", icon: "book", action: { scene = "finish" })
                }
                
                //タブ切り替えのボタン
                HStack {
                    TabButton(title: "ブックマーク", icon: "bookmark", action: { scene = "bookmark";                navigationTitle = "ブックマーク" })
                    TabButton(title: "ホーム", icon: "magnifyingglass", action: { scene = "search";
                        navigationTitle = "ホーム" })
                    TabButton(title: "設定", icon: "gearshape", action: { scene = "mypage";
                        navigationTitle = "設定"})
                    
                }
                    .padding()

            }
                .buttonStyle(.plain)
                .background(Color(.systemGray6))
                .navigationTitle(navigationTitle)
        }
        //アプリ起動時にUserDefaultsに保存したデータを読み込み
        .onAppear {
            bookmarkBooks = UserDefaults.standard.stringArray(forKey: "bookmarkBooks") ?? []
            hiddenBooks = UserDefaults.standard.stringArray(forKey: "hiddenBooks") ?? []
            finishBooks = UserDefaults.standard.stringArray(forKey: "finishBooks") ?? []
        }
    }
}

struct BookView: View {
    let book: Book
    let isFullStory: Bool
    let isBookmarked: Bool
    let isHidden: Bool
    let isFinished: Bool
    let onFullStory: () -> Void
    let onBookmark: () -> Void
    let onHidden: () -> Void
    let onFinish: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
                .font(.headline)
            VStack(alignment: .leading){
                Text(book.writer)
                HStack{
                    Text("完結済(全\(book.general_all_no)話)")
                    Text(genreToString(genre: book.genre))
                }
            }
                .foregroundColor(.gray)
      
            StoryButton(story: isFullStory ? book.story :book.story.prefix(40)+"...", action: onFullStory)
            if let url = bookUrl(for: book) {
                Link("この作品を読む", destination: url)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.gray)
            } else {
                Text("無効なリンク").foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
            }
            HStack {
                ActionButton(title: "ブックマーク", icon: isBookmarked ? "bookmark.fill" : "bookmark", action: onBookmark)
                ActionButton(title: "非表示", icon: isHidden ? "minus.circle.fill" : "minus.circle", action: onHidden)
                ActionButton(title: "読了", icon: isFinished ? "book.fill" : "book", action: onFinish)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.vertical, 5)
    }
    
    //bookから各小説のホームへのurlを作成
    private func bookUrl(for book: Book) -> URL? {
        let urlString = "https://ncode.syosetu.com/" + book.ncode.lowercased()
        return URL(string: urlString)
    }
    
    //biggenreを数字から文字列に変換
    private func biggenreToString(biggenre: Int) -> String {
        var res: String = "無効なジャンル"
        if biggenre == 1 {
            res = "恋愛"
        } else if biggenre == 2 {
            res = "ファンタジー"
        } else if biggenre == 3 {
            res = "文芸"
        } else if biggenre == 4 {
            res = "SF"
        } else if biggenre == 99 {
            res = "その他"
        } else if biggenre == 98 {
            res = "ノンジャンル"
        }
        return res
    }
    
    //genreを数字から文字列に変換
    private func genreToString(genre: Int) -> String {
        var res: String = "無効なジャンル"
        if genre == 101 {
            res = "異世界恋愛"//[恋愛]"
        } else if genre == 102 {
            res = "現実世界恋愛"//[恋愛]"
        } else if genre == 201 {
            res = "ハイファンタジー"//[ファンタジー]"
        } else if genre == 202 {
            res = "ローファンタジー"//[ファンタジー]"
        } else if genre == 301 {
            res = "純文学"//[文芸]"
        } else if genre == 302 {
            res = "ヒューマンドラマ"//[文芸]"
        } else if genre == 303 {
            res = "歴史"//[文芸]"
        } else if genre == 304 {
            res = "推理"//[文芸]"
        } else if genre == 305 {
            res = "ホラー"//[文芸]"
        } else if genre == 306 {
            res = "アクション"//[文芸]"
        } else if genre == 307 {
            res = "コメディー"//[文芸]"
        } else if genre == 401 {
            res = "VRゲーム"//[SF]"
        } else if genre == 402 {
            res = "宇宙"//[SF]"
        } else if genre == 403 {
            res = "空想科学"//[SF]"
        } else if genre == 404 {
            res = "パニック"//[SF]"
        } else if genre == 9901 {
            res = "童話"//[その他]"
        }  else if genre == 9902 {
            res = "詩"//[その他]"
        }  else if genre == 9903 {
            res = "エッセイ"//[その他]"
        }  else if genre == 9904 {
            res = "リプレイ"//[その他]"
        }  else if genre == 9999 {
            res = "その他"//[その他]"
        } else if genre == 9801 {
            res = "ノンジャンル"//[ノンジャンル]"
        }
        return res
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack{
                Image(systemName: icon)
                Text(title)
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct StoryButton: View {
    let story: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(story)
                .padding(5)
                .foregroundColor(.black)
                .cornerRadius(5)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack{
                Image(systemName: icon)
                Text(title)
            }
            .padding(5)
            .foregroundColor(.gray)
            .cornerRadius(5)
        }
    }
}

#Preview {
    ContentView()
}

