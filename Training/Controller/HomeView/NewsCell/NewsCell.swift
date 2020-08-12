//
//  NewsCell.swift
//  Training
//
//  Created by ManhLD on 12/17/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgTimer: UIImageView!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var lblDes: UILabel!
    @IBOutlet weak var backgroundStatusView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var readmoreBtn: UIButton!
    
    
    var didCLickReadMore: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgNews.roundCorners()
        containerView.setUpCardView()
    }
    
    @IBAction func handleReadmore(_ sender: Any) {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layoutIfNeeded()
        imgNews.roundCorners()
        containerView.roundCornersView(radius: 30)
        backgroundStatusView.setUpBGView()
        backgroundStatusView.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor.white
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
}

