//
//  NewsData+CoreDataProperties.swift
//  
//
//  Created by Victor on 4/3/21.
//
//

import Foundation
import CoreData


extension NewsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsData> {
        return NSFetchRequest<NewsData>(entityName: "NewsData")
    }

    @NSManaged public var title: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var imageUrl: String?

}
