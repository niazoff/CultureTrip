//
//  ArticleRowView.swift
//  CultureTrip
//
//  Created by Natanel Niazoff on 4/2/21.
//

import SwiftUI
import Combine

class ArticleRowViewModel: ObservableObject {
  let article: Article
  
  @Published private(set) var imageData: Data?
  @Published private(set) var authorImageData: Data?
  
  private let session = URLSession.shared
  private var cancellables = Set<AnyCancellable>()
  
  init(article: Article,
       imageDataCache: ImageDataCache? = nil) {
    self.article = article
    if let data = imageDataCache?.data(for: article.imageUrl) {
      imageData = data
    } else {
      session.dataTaskPublisher(for: article.imageUrl)
        .receive(on: DispatchQueue.main)
        .map(\.data).map(Optional.some)
        .replaceError(with: nil)
        .sink { [weak self] in
          self?.imageData = $0
          imageDataCache?.set($0, for: article.imageUrl)
        }.store(in: &cancellables)
    }
    if let data = imageDataCache?.data(for: article.author.avatar.imageUrl) {
      authorImageData = data
    } else {
      session.dataTaskPublisher(for: article.author.avatar.imageUrl)
        .receive(on: DispatchQueue.main)
        .map(\.data).map(Optional.some)
        .replaceError(with: nil)
        .sink { [weak self] in
          self?.authorImageData = $0
          imageDataCache?.set($0, for: article.author.avatar.imageUrl)
        }.store(in: &cancellables)
    }
  }
}

struct ArticleRowView: View {
  @ObservedObject private(set) var model: ArticleRowViewModel
  
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM, yyyy"
    return formatter
  }()
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Group {
        if let uiImage = model.imageData.flatMap(UIImage.init) {
          Image(uiImage: uiImage)
            .resizable().aspectRatio(contentMode: .fill)
            .animation(.easeInOut)
        } else { Color(UIColor.systemGray3) }
      }.frame(height: 219)
      .clipped()
      .overlay(HStack {
        Image(model.article.isSaved ? "saved" : "save")
        Spacer()
        Text("\(model.article.likesCount)").bold()
          .foregroundColor(.white)
        Image(model.article.isLiked ? "liked" : "like")
      }.shadow(radius: 10).padding(18), alignment: .top)
      VStack(alignment: .leading, spacing: 16) {
        Text(model.article.category.uppercased())
          .font(.system(size: 17)).foregroundColor(.blue)
        Text(model.article.title)
          .font(.system(size: 18)).bold()
        HStack {
          Group {
            if let uiImage = model.authorImageData.flatMap(UIImage.init) {
              Image(uiImage: uiImage)
                .resizable().aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .animation(.easeInOut)
            } else { Circle().foregroundColor(Color(UIColor.systemGray3)) }
          }.frame(width: 40, height: 40)
          VStack(alignment: .leading) {
            Text(model.article.author.name)
              .font(.system(size: 16)).foregroundColor(.blue)
            Text(dateFormatter.string(from: model.article.metaData.creationTime))
              .font(.system(size: 16)).foregroundColor(.gray)
          }
        }
      }.padding(18)
    }.background(Color(UIColor.systemBackground))
  }
}

struct ArticleRowView_Previews: PreviewProvider {
  static let article = Article(id: "123", title: "Title", author: .init(id: "123", name: "Author", avatar: .init(imageUrl: URL(string: "https://source.unsplash.com/random/80x80")!)), category: "Category", imageUrl: URL(string: "https://source.unsplash.com/random/400x400")!, likesCount: 123, isSaved: true, isLiked: false, metaData: .init(creationTime: .init(), updateTime: .init()))
  
  static var previews: some View {
    Group {
      ArticleRowView(model: .init(article: article))
        .previewLayout(.sizeThatFits)
    }
  }
}
