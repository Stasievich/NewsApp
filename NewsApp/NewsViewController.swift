//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Victor on 3/31/21.
//

import UIKit
import Kingfisher

class NewsViewController: UIViewController {

    var newsViewModel: NewsViewModel!
    var newsTableView = UITableView.init(frame: .zero, style: .grouped)
    let cellReuseIdentifier = "news"
    let placeholderImage = UIImage(named: "placeholder")
    var refreshControl = UIRefreshControl()
    var newsSearchBar = UISearchBar()
    
    let indent: CGFloat = 12
    let cellHeight: CGFloat = 164

    var animationDuration: TimeInterval = 0.25
    var delay: TimeInterval = 0.005
    lazy var currentTableAnimation: TableAnimation = .moveUpWithFade(rowHeight: cellHeight, duration: animationDuration, delay: delay)
    
    fileprivate func configureMainView() {
        view.backgroundColor = .white
        
    }
    
    fileprivate func configureNewsSearchBar() {
        view.addSubview(newsSearchBar)
        newsSearchBar.placeholder = " Search..."
        newsSearchBar.clearBackgroundColor()
        newsSearchBar.searchTextField.backgroundColor = .white
        
        newsSearchBar.sizeToFit()
        newsSearchBar.delegate = self
        newsSearchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            newsSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newsSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            newsSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    fileprivate func addGradientBasedOnSearchBar() {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: newsSearchBar.frame.width, height: newsSearchBar.frame.height + view.safeAreaLayoutGuide.layoutFrame.height)
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    fileprivate func configureNewsTableView() {
        view.addSubview(newsTableView)
        newsTableView.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.8)
        newsTableView.separatorColor = .clear
        newsTableView.rowHeight = cellHeight
        newsTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        newsTableView.layer.cornerRadius = 10
        newsTableView.translatesAutoresizingMaskIntoConstraints = false
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.register(NewsTableViewCell.self, forCellReuseIdentifier: (cellReuseIdentifier))
        //        newsTableView.tableHeaderView = newsSearchBar
        view.addConstraints([
            newsTableView.topAnchor.constraint(equalTo: newsSearchBar.bottomAnchor),
            newsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    fileprivate func configureRefreshControl() {
        newsTableView.refreshControl = UIRefreshControl()
        newsTableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        newsTableView.refreshControl?.addTarget(self, action: #selector(refreshNews), for: UIControl.Event.valueChanged)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMainView()
        
        configureNewsSearchBar()
        
        addGradientBasedOnSearchBar()
        
        configureNewsTableView()
        
        configureRefreshControl()
        
        callToViewModelForUIUpdate()
        
    }
    
    @objc func refreshNews() {
        callToViewModelForUIUpdate()
        DispatchQueue.main.async {
            self.newsTableView.refreshControl?.endRefreshing()
            self.newsSearchBar.searchTextField.text = ""
        }
    }
    
    
    func callToViewModelForUIUpdate() {
        newsViewModel = NewsViewModel()
        
        self.newsViewModel.reloadTableViewClosure = { [self] () in
            DispatchQueue.main.async {
                    self.newsTableView.reloadDataWithAutoSizingCell()
            }
        }
    }
}


extension NewsViewController: UITableViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((newsTableView.contentOffset.y + newsTableView.frame.size.height) >= newsTableView.contentSize.height) && (newsSearchBar.text == "" || newsSearchBar.text == nil)
        {
            newsViewModel.queue.sync {
                self.newsViewModel.getNextPage()
            }
        }
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! NewsTableViewCell
        
        let news: Article?
        if newsSearchBar.text != nil && newsSearchBar.text != "" {
            news = newsViewModel.articles[indexPath.row]
        }
        else {
            news = newsViewModel.newsData?.articles?[indexPath.row]
        }
        
        cell.mainCellView.bounds = CGRect(x: 0, y: indent, width: view.bounds.width - 2 * indent, height: cellHeight - 2*indent)
        cell.mainCellView.addShadowBased(on: cell.mainCellView.bounds)
        
        cell.newsTitle.text = news?.title
        newsViewModel.queue.sync {
            if let title = news?.title {
                cell.newsPublishedTime.text = newsViewModel.dateDifference[title]
            }
        }
        
        cell.newsDescription.collapsedAttributedLink = NSAttributedString(string: "Show More", attributes: [.foregroundColor: UIColor.blue])
        cell.newsDescription.ellipsis = NSAttributedString(string: "...")
        cell.newsDescription.collapsed = true
        cell.newsDescription.text = news?.description?.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
        
        if let imageUrl = news?.urlToImage {
            cell.newsImage.kf.setImage(with: URL(string: imageUrl), placeholder: placeholderImage, options: [.cacheOriginalImage])
        }
        else {
            cell.newsImage.image = placeholderImage
        }
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newsSearchBar.searchTextField.text != nil {
            return newsViewModel.articles.count
        }
        else {
            return newsViewModel.newsData?.articles?.count ?? 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        newsSearchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = currentTableAnimation.getAnimation()
        let animator = TableViewAnimator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
}

extension NewsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let newsArticles = newsViewModel.newsData?.articles {
            if searchText == "" {
                newsViewModel.articles = newsArticles
            }
            else {
                newsViewModel.articles = newsArticles.filter({
                    ($0.title?.lowercased().contains(searchText.lowercased()) ?? false)
                })
            }
            newsTableView.reloadData()
        }

    }
}
