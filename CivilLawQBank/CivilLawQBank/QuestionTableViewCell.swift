//
//  QuestionTableViewCell.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 4. 2..
//  Copyright © 2017년 5712ya. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var myChapterLabel: UILabel!
    @IBOutlet weak var myChapterCountLabel: UILabel!
    @IBOutlet weak var myChaterImageView: UIImageView!
    @IBOutlet weak var myProgressView: UIProgressView!
    @IBOutlet weak var myProgressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
