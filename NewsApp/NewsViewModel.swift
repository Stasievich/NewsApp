//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Victor on 3/31/21.
//

import Foundation
import UIKit
import CoreData

class NewsViewModel: NSObject {
    
    var apiService: APIService!
    private(set) var newsData : News?
    {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    var currentPage = 0
    let maximumPages = 6
    var fetchingData = false
    var articles: [Article] = []
    var newsFromCoreData: [NewsData] = []
    var dateDifference: [String: String] = [:]
    let queue = DispatchQueue(label: "thread-safe-obj", attributes: .concurrent)
    
    // MARK: - Closure
        
        // Through these closure, our view model will execute code while we refresh our table
        // It will be set up by the view controller
    var reloadTableViewClosure: (()->())?
    
    // MARK: - Constructor
    override init() {
        super.init()
        
        self.apiService = APIService()
        callFuncToGetNewsData()
    }
    // MARK: - Functions for downloading and updating news
    fileprivate func callFuncToGetNewsData() {
        let dateParameters = calculateDate(pageNumber: currentPage)
        self.apiService.getNewsData(param: dateParameters) { (newsData, error) in
            guard error == nil else { print("\(String(describing: error?.localizedDescription))"); return}
            
            self.updateNewsData(receivedData: newsData)
            self.newsData = newsData
            self.fetchFromContext()
            self.addDataToCoreData()
        }
    }
    
    func updateNewsData(receivedData: News?) {
        queue.async(flags: .barrier) {
            if let articles = receivedData?.articles {
                self.articles.append(contentsOf: articles)
                
                for article in articles {
                    if let title = article.title {
                        self.dateDifference[title] = self.getDateDifference(publishedAt: article.publishedAt)
                    }
                }
            }
        }
    }
    
    func getDataAfterSearch(searchText: String) {
        if let newsArticles = newsData?.articles {
            if searchText == "" {
                articles = newsArticles
            }
            else {
                articles = newsArticles.filter({
                    ($0.title?.lowercased().contains(searchText.lowercased()) ?? false)
                })
            }
        }
    }
    
    func getNextPage() {
        if currentPage < maximumPages {
            currentPage += 1
            getNextNews(pageNumber: currentPage)
        }
    }
    
    func getNextNews(pageNumber: Int) {
        if fetchingData == true {
            return
        }
        
        fetchingData = true
        
        let dateParameters = calculateDate(pageNumber: pageNumber)
        self.apiService.getNewsData(param: dateParameters) { (newsData, error) in
            guard error == nil else { print("\(String(describing: error?.localizedDescription))"); return}
            
            if let newArticles = newsData?.articles {
                self.newsData?.articles?.append(contentsOf: newArticles)
                self.updateNewsData(receivedData: newsData)
                self.fetchFromContext()
                self.addDataToCoreData()
                self.fetchingData = false
            }
        }
    }
    
    func calculateDate(pageNumber: Int) -> [String: String] {
        let secondsInHour = 3600
        let fromDate = Date
            .numberOfDaysBefore(number: pageNumber + 1)
            .numberOfHoursBefore(number: TimeZone.current.secondsFromGMT() / secondsInHour)
        let toDate = Date
            .numberOfDaysBefore(number: pageNumber)
            .numberOfHoursBefore(number: TimeZone.current.secondsFromGMT() / secondsInHour)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let fromDateString = formatter.string(from: fromDate)
        let toDateString = formatter.string(from: toDate)
        return ["from": fromDateString, "to": toDateString]
    }
    
    func getDateDifference(publishedAt: String?) -> String? {
        guard let date = publishedAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let formattedDate = formatter.date(from: date){
            return Date() - formattedDate
        }
        return nil
    }
    
    // MARK: - Functions for Core Data
    
    func addDataToCoreData() {
        DispatchQueue.main.async {
            if let articles = self.newsData?.articles {
                for article in articles {
                    var nonExistingArticle = 0
                    for i in self.newsFromCoreData {
                        if article.title != i.title {
                            nonExistingArticle += 1
                        }
                        else { break }
                    }
                    if nonExistingArticle == self.newsFromCoreData.count {
                        self.saveToContext(news: article)
                    }
                }
            }
        }
    }
    
    func saveToContext(news: Article) {
        DispatchQueue.main.async {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "NewsData", in: managedContext)!
            
            let newsData = NSManagedObject(entity: entity, insertInto: managedContext)
            
            newsData.setValue(news.title, forKeyPath: "title")
            newsData.setValue(news.urlToImage, forKeyPath: "imageUrl")
            newsData.setValue(news.description, forKey: "newsDescription")
            
            do {
                try managedContext.save()
                self.newsFromCoreData.append(newsData as! NewsData)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchFromContext() {
        DispatchQueue.main.async {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsData")

            do {
                self.newsFromCoreData = try managedContext.fetch(fetchRequest) as! [NewsData]
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
}
