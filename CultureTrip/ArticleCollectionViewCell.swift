//
//  ArticleCollectionViewCell.swift
//  CultureTrip
//
//  Created by Natanel Niazoff on 10/28/20.
//

import UIKit
import Combine

class ArticleCollectionViewCell: UICollectionViewCell {
  private let session = URLSession.shared
  
  var article: Article? {
    didSet { setUp() }
  }
  var imageDataCache: ImageDataCache?
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet { titleLabel.text = article?.title }
  }
  @IBOutlet weak var authorLabel: UILabel! {
    didSet { authorLabel.text = article?.author.name }
  }
  @IBOutlet weak var categoryLabel: UILabel! {
    didSet { categoryLabel.text = article?.category.uppercased() }
  }
  @IBOutlet weak var dateLabel: UILabel! {
    didSet { dateLabel.text = (article?.metaData.creationTime).map(dateFormatter.string) }
  }
  @IBOutlet weak var likesCountLabel: UILabel! {
    didSet { likesCountLabel.text = (article?.likesCount).map(String.init) }
  }
  @IBOutlet weak var articleImageView: UIImageView! {
    didSet { articleImageView.image = articleImage }
  }
  @IBOutlet weak var authorImageView: UIImageView! {
    didSet {
      authorImageView.layer.cornerRadius = authorImageView.bounds.width/2
      authorImageView.image = authorImage
    }
  }
  @IBOutlet weak var isSavedImageView: UIImageView! {
    didSet {
      isSavedImageView.image = (article?.isSaved).flatMap { UIImage(named: $0 ? "saved" : "save") }
      isSavedImageView.layer.shadowOpacity = 0.8
      isSavedImageView.layer.shadowOffset = .zero
      isSavedImageView.layer.shadowRadius = 10
    }
  }
  @IBOutlet weak var isLikedImageView: UIImageView! {
    didSet { isLikedImageView.image = (article?.isLiked).flatMap { UIImage(named: $0 ? "liked" : "like") } }
  }
  @IBOutlet weak var likeStackView: UIStackView! {
    didSet {
      likeStackView.layer.shadowOpacity = 0.8
      likeStackView.layer.shadowOffset = .zero
      likeStackView.layer.shadowRadius = 10
    }
  }
  
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM, yyyy"
    return formatter
  }()
  private var articleImage: UIImage?
  private var authorImage: UIImage? {
    didSet { authorImageView?.image = authorImage }
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  override func prepareForReuse() {
    cancellables.removeAll()
    article = nil
    articleImage = nil
    setArticleImage()
    authorImage = nil
  }
  
  private func setUp() {
    titleLabel?.text = article?.title
    authorLabel?.text = article?.author.name
    categoryLabel?.text = article?.category.uppercased()
    dateLabel?.text = (article?.metaData.creationTime).map(dateFormatter.string)
    likesCountLabel?.text = (article?.likesCount).map(String.init)
    isSavedImageView?.image = (article?.isSaved).flatMap { UIImage(named: $0 ? "saved" : "save") }
    isLikedImageView?.image = (article?.isLiked).flatMap { UIImage(named: $0 ? "liked" : "like") }
    if let url = article?.imageUrl {
      if let data = imageDataCache?.data(for: url) {
        articleImage = UIImage(data: data)
        setArticleImage()
      } else {
        session.dataTaskPublisher(for: url)
          .map(\.data).map(Optional.some)
          .receive(on: DispatchQueue.main)
          .replaceError(with: nil).sink { [weak self] in
            self?.imageDataCache?.set($0, for: url)
            self?.articleImage = $0.flatMap(UIImage.init)
            self?.setArticleImage(animated: true)
          }.store(in: &cancellables)
      }
    }
    if let url = article?.author.avatar.imageUrl {
      if let data = imageDataCache?.data(for: url) {
        authorImage = UIImage(data: data)
      } else {
        session.dataTaskPublisher(for: url)
          .map(\.data).map(Optional.some)
          .receive(on: DispatchQueue.main)
          .replaceError(with: nil).sink { [weak self] in
            self?.imageDataCache?.set($0, for: url)
            self?.authorImage = $0.flatMap(UIImage.init)
          }.store(in: &cancellables)
      }
    }
  }
  
  private func setArticleImage(animated: Bool = false) {
    if animated {
      articleImageView.map { [articleImage] imageView in
        UIView.transition(with: imageView, duration: 0.2, options: .transitionCrossDissolve)
          { imageView.image = articleImage } }
    } else { articleImageView?.image = articleImage }
  }
}
