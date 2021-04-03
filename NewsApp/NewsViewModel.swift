//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Victor on 3/31/21.
//

import Foundation
import UIKit

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
    var dateDifference: [String: String] = [:]
    let queue = DispatchQueue(label: "thread-safe-obj", attributes: .concurrent)

    
    // MARK: - Closure
        
        // Through these closure, our view model will execute code while some events will occure
        // It will be set up by the view controller
    var reloadTableViewClosure: (()->())?
    
    // MARK: - Constructor
    override init() {
        super.init()
        
        self.apiService = APIService()
        callFuncToGetNewsData()
    }
    
    
    
    fileprivate func callFuncToGetNewsData() {
        let dateParameters = calculateDate(pageNumber: currentPage)
        self.apiService.getNewsData(param: dateParameters) { (newsData, error) in
            guard error == nil else { print("\(String(describing: error?.localizedDescription))"); return}
            
            self.updateNewsData(receivedData: newsData)
            self.newsData = newsData
//            self.fetchFromContext()
//            self.addDataToCoreData()
            
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
}
