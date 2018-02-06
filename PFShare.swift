//
//  PFShare.swift
//  PocketFriend
//
//  Created by Manish Parihar on 08/12/16.
//

import UIKit

@objc protocol PFShareDelegate{
    @objc optional func mailSentUsingSMTPSuccessfully(success:Bool,message:String)
}
class PFShare: NSObject,SKPSMTPMessageDelegate {

    enum ContentType : Int {
        
        case TextHtmlType
        case TextPlainType
        case TextDirectoryType
        case JPGType
        case PNGType
        case CSVType
    }
    var delegate: PFShareDelegate?
    
    var smtpMessage:SKPSMTPMessage!
    
    func sendMailUsingSMTP(subject:String,from:String,to:String,bcc:String,cc:String,body:String,attachment:Data,attachmentContentType:ContentType,fileName:String,isHTML:Bool,hasAttachment:Bool){
       
        smtpMessage=SKPSMTPMessage()
        smtpMessage.delegate=self
        smtpMessage.fromEmail = from
        smtpMessage.toEmail = to
        if cc.characters.count != 0{
            smtpMessage.ccEmail = cc
        }
        if bcc.characters.count != 0{
            smtpMessage.bccEmail = bcc
        }
        //Set Your mail server setting here
        smtpMessage.relayHost = "smtp.gmail.com";
        smtpMessage.requiresAuth = true;
        if smtpMessage.requiresAuth {
            smtpMessage.login = "soniya.vishwakarma@epictenet.com";
            smtpMessage.pass = "@Soni321!";
        }

        smtpMessage.wantsSecure = true; // smtp.gmail.com doesn't work without TLS!
        
        
        smtpMessage.subject = subject;
        
        // Only do this for self-signed certs!
        // smtpMessage.validateSSLChain = NO;
        
        var mimeType:String = "text/plain"
        if attachmentContentType == .TextHtmlType{
             mimeType = "text/html"
        }
        else if attachmentContentType == .TextDirectoryType{
             mimeType = "text/directory"
        }
        else if attachmentContentType == .JPGType{
            mimeType = "text/jpeg"
        }

        else if attachmentContentType == .PNGType{
            mimeType = "text/png"
        }
        else if attachmentContentType == .CSVType{
            mimeType = "text/csv"
        }
        
        
        //  FOR Sending Attachments
        if hasAttachment {
         let plainPart = [kSKPSMTPPartContentTypeKey:mimeType,kSKPSMTPPartMessageKey:body,kSKPSMTPPartContentTransferEncodingKey:"8bit"]
        let htmlPart = [kSKPSMTPPartContentTypeKey:"\(mimeType);\r\n\tx-unix-mode=0644;\r\n\tname=\(fileName)",kSKPSMTPPartContentDispositionKey:"attachment;\r\n\tfilename=\(fileName)",kSKPSMTPPartMessageKey: attachment.base64EncodedString(),kSKPSMTPPartContentTransferEncodingKey:"base64"]
         
         smtpMessage.parts = [plainPart,htmlPart]
    }
        else{
            let htmlPart = [kSKPSMTPPartContentTypeKey:mimeType,kSKPSMTPPartMessageKey:body,kSKPSMTPPartContentTransferEncodingKey:"8bit"]
            smtpMessage.parts = [htmlPart]
        }

        DispatchQueue.main.async {
            self.smtpMessage.send()
        }
        
    }
    func messageSent(_ message:SKPSMTPMessage){
        delegate?.mailSentUsingSMTPSuccessfully!(success:true,message:"Message sent")
    }
    func messageFailed(_ message:SKPSMTPMessage,error:Error){
        delegate?.mailSentUsingSMTPSuccessfully!(success:false,message:error.localizedDescription)
    }

}
