//
//  ArticlesView.swift
//  CultureTrip
//
//  Created by Natanel Niazoff on 4/2/21.
//

import SwiftUI
import Combine

class ArticlesViewModel: ObservableObject {
  @Published private(set) var articles = [Article]()
  let imageDataCache = DictionaryImageDataCache()
  
  private let session = URLSession.shared
  private let articlesURL = URL(string: "https://cdn.theculturetrip.com/home-assignment/response.json")!
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    session.dataTaskPublisher(for: articlesURL)
      .receive(on: DispatchQueue.main)
      .map(\.data)
      .decode(type: [String: [Article]].self, decoder: decoder).compactMap { $0["data"] }
      .replaceError(with: []).sink { [weak self] in self?.articles = $0 }
      .store(in: &cancellables)
  }
}

struct ArticlesView: View {
  @ObservedObject private(set) var model: ArticlesViewModel
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(model.articles) {
          ArticleRowView(model: .init(article: $0, imageDataCache: model.imageDataCache))
        }
      }
    }.background(
      Color(UIColor.systemGray5)
        .edgesIgnoringSafeArea(.all)
    ).navigationTitle("Articles")
  }
}

struct ArticlesView_Previews: PreviewProvider {
  static var previews: some View {
    ArticlesView(model: .init())
  }
}
