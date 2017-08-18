//
//  ConfirmationOptionalTableViewCell.swift
//  FDA
//
//  Created by Arun Kumar on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit


let kDeleteButtonTag = 11220
let kRetainButtonTag = 11221

let kConfirmationOptionalDefaultTypeRetain = "retain"
let kConfirmationOptionalDefaultTypeDelete = "delete"


protocol ConfirmationOptionalDelegate {
    func confirmationCell(cell:ConfirmationOptionalTableViewCell , forStudy study:Study, deleteData:Bool)
}
class ConfirmationOptionalTableViewCell: UITableViewCell {

    @IBOutlet var buttonDeleteData:UIButton?
    @IBOutlet var buttonRetainData:UIButton?
    @IBOutlet var labelTitle:UILabel?
    @IBOutlet var imageViewDeleteCheckBox: UIImageView?
    @IBOutlet var imageViewRetainCheckBox: UIImageView?
    var study:Study!
    var delegate:ConfirmationOptionalDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//MARK:IBActions
    
    @IBAction func deleteOrRetainDataButtonAction(_ sender:UIButton?){
        
        var deleteData = false
        if sender?.tag == kDeleteButtonTag {
            if (imageViewDeleteCheckBox?.image?.isEqual(#imageLiteral(resourceName: "notChecked")))! {
                imageViewDeleteCheckBox?.image = #imageLiteral(resourceName: "checked")
                imageViewRetainCheckBox?.image = #imageLiteral(resourceName: "notChecked")
                deleteData = true;
            }
//            else{
//                imageViewDeleteCheckBox?.image = #imageLiteral(resourceName: "notChecked")
//                imageViewRetainCheckBox?.image = #imageLiteral(resourceName: "checked")
//                deleteData = false;
//            }
        }
        else{
            if (imageViewRetainCheckBox?.image?.isEqual(#imageLiteral(resourceName: "notChecked")))! {
                imageViewRetainCheckBox?.image = #imageLiteral(resourceName: "checked")
                imageViewDeleteCheckBox?.image = #imageLiteral(resourceName: "notChecked")
                deleteData = false;
            }
//            else{
//                imageViewRetainCheckBox?.image = #imageLiteral(resourceName: "notChecked")
//                imageViewDeleteCheckBox?.image = #imageLiteral(resourceName: "checked")
//                deleteData = true;
//            }
        }
        
        self.delegate?.confirmationCell(cell: self, forStudy: study, deleteData: deleteData)
       
    }
   
    //MARK:Utility methods
    
    func setDefaultDeleteAction(defaultValue:String){
        
        if defaultValue == kConfirmationOptionalDefaultTypeRetain {
            imageViewRetainCheckBox?.image = #imageLiteral(resourceName: "notChecked")
            imageViewDeleteCheckBox?.image = #imageLiteral(resourceName: "checked")

        }
        else{
            imageViewDeleteCheckBox?.image = #imageLiteral(resourceName: "checked")
            imageViewRetainCheckBox?.image = #imageLiteral(resourceName: "notChecked")
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
