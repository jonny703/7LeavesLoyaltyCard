//
//  EachTeamMemberTableViewCell.swift
//  LoyaltyCard(Simple)
//
//  Created by John Nik on 2/5/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

class EachTeamMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var redeemedText: UILabel!
    
    var friend: Team! {
        didSet {
            setImage(imageURL: friend.photoURL)
            self.name.text = friend.name
            if friend.redeemCount >= 1 {
                self.redeemedText.isHidden = false
            }
        }
    }
    
    func setImage(imageURL: String) {
        let url = URL(string: imageURL )
        self.profileImage?.kf.setImage(with: url)
        self.profileImage?.makeCircular(color: UIColor.white)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
