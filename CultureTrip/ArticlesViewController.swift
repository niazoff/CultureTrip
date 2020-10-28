//
//  ArticlesViewController.swift
//  CultureTrip
//
//  Created by Natanel Niazoff on 10/28/20.
//

import UIKit
import Combine

class ArticlesViewController: UIViewController {
  private typealias CollectionViewDataSource = UICollectionViewDiffableDataSource<Section, Article>
  
  private let session = URLSession.shared
  private let articlesURL = URL(string: "https://cdn.theculturetrip.com/home-assignment/response.json")!
  private let articlesDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
  
  private lazy var collectionViewDataSource: CollectionViewDataSource = .init(collectionView: collectionView) {
    collectionView, indexPath, article in
    guard let articleCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellIdentifier.articleCell.rawValue,
            for: indexPath) as? ArticleCollectionViewCell
    else { return nil }
    articleCell.article = article
    return articleCell
  }
  
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      let size = NSCollectionLayoutSize(
        widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
        heightDimension: NSCollectionLayoutDimension.estimated(100)
      )
      let item = NSCollectionLayoutItem(layoutSize: size)
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 20
      collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
      collectionView.dataSource = collectionViewDataSource
    }
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  enum Section: Int, CaseIterable {
    case articles
  }
  
  enum CellIdentifier: String {
    case articleCell
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Articles"
    loadArticles()
  }
  
  private func loadArticles() {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = articlesDateFormat
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    session.dataTaskPublisher(for: articlesURL).map(\.data)
      .decode(type: [String: [Article]].self, decoder: decoder).compactMap { $0["data"] }
      .receive(on: DispatchQueue.main)
      .replaceError(with: []).sink { [weak self] in
        self?.articlesDidLoad($0)
      }.store(in: &cancellables)
  }
  
  private func articlesDidLoad(_ articles: [Article]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Article>()
    snapshot.appendSections(Section.allCases)
    snapshot.appendItems(articles, toSection: .articles)
    collectionViewDataSource.apply(snapshot)
  }
}
