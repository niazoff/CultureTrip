//
//  Article.swift
//  CultureTrip
//
//  Created by Natanel Niazoff on 10/28/20.
//

import Foundation

struct Article: Decodable {
  let id: String
  let title: String
  let author: Author
  let category: String
  let imageUrl: URL
  let likesCount: UInt64
  let isSaved: Bool
  let isLiked: Bool
  let metaData: MetaData
  
  struct Author: Decodable {
    let id: String
    let name: String
    let avatar: Avatar
    
    enum CodingKeys: String, CodingKey {
      case id
      case name = "authorName"
      case avatar = "authorAvatar"
    }
    
    struct Avatar: Decodable {
      let imageUrl: URL
    }
  }
  
  struct MetaData: Decodable {
    let creationTime: Date
    let updateTime: Date
  }
}

extension Article: Equatable {
  static func ==(lhs: Article, rhs: Article) -> Bool {
    lhs.id == rhs.id &&
      lhs.likesCount == rhs.likesCount &&
      lhs.isSaved == rhs.isSaved &&
      lhs.isLiked == rhs.isLiked
  }
}

extension Article: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
