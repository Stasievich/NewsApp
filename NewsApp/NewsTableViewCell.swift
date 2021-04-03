//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Victor on 3/31/21.
//

import Foundation
import UIKit
import ExpandableLabel


class NewsTableViewCell: UITableViewCell {
    let indent: CGFloat = 12
    
    var newsImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    var newsTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "TimesNewRomanPSMT", size: 18)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 3
        return lbl
    }()
    
    var newsDescription: ExpandableLabel = {
       let lbl = ExpandableLabel()
        lbl.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        lbl.textColor = .gray
        lbl.numberOfLines = 3
        lbl.shouldExpand = false
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var newsPublishedTime: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Futura-Medium", size: 10)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var mainCellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layer.backgroundColor = UIColor.clear.cgColor
        backgroundColor = .clear
        selectionStyle = .none
        
        mainCellView.backgroundColor = .white
        mainCellView.layer.cornerRadius = 8
        newsImage.layer.cornerRadius = 8
        newsImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        contentView.addSubview(mainCellView)
        contentView.addConstraints([
            mainCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: indent),
            mainCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -indent),
            mainCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: indent),
            mainCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -indent)
        ])
                
        mainCellView.addSubview(newsImage)
        mainCellView.addConstraints([
            newsImage.leadingAnchor.constraint(equalTo: mainCellView.leadingAnchor),
            newsImage.widthAnchor.constraint(equalToConstant: 100),
            newsImage.topAnchor.constraint(equalTo: mainCellView.topAnchor, constant: indent),
            newsImage.bottomAnchor.constraint(equalTo: mainCellView.bottomAnchor, constant: indent)
        ])
        
        mainCellView.addSubview(newsTitle)
        mainCellView.addConstraints([
            newsTitle.leadingAnchor.constraint(equalTo: newsImage.trailingAnchor, constant: 20),
            newsTitle.trailingAnchor.constraint(equalTo: mainCellView.trailingAnchor, constant: -30),
            newsTitle.topAnchor.constraint(equalTo: mainCellView.topAnchor, constant: 5 + indent)
        ])
        
        mainCellView.addSubview(newsDescription)
        mainCellView.addConstraints([
            newsDescription.leadingAnchor.constraint(equalTo: newsImage.trailingAnchor, constant: 20),
            newsDescription.trailingAnchor.constraint(equalTo: mainCellView.trailingAnchor, constant: -40),
            newsDescription.topAnchor.constraint(equalTo: mainCellView.bottomAnchor, constant: -50 + indent),
            newsDescription.bottomAnchor.constraint(equalTo: mainCellView.bottomAnchor, constant: -5 + indent)
        ])
        
        mainCellView.addSubview(newsPublishedTime)
        mainCellView.addConstraints([
            newsPublishedTime.leadingAnchor.constraint(equalTo: newsDescription.trailingAnchor, constant: 5),
            newsPublishedTime.trailingAnchor.constraint(equalTo: mainCellView.trailingAnchor, constant: -5),
            newsPublishedTime.topAnchor.constraint(equalTo: mainCellView.bottomAnchor, constant: -20 + indent),
            newsPublishedTime.bottomAnchor.constraint(equalTo: mainCellView.bottomAnchor, constant: -8 + indent)
        ])
        
        contentView.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
