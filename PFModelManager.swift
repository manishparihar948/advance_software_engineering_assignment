
//
//  PFModelManager.swift
//  PocketFriend
//
//  Created by Manish Parihar on 20/10/16.
//

import UIKit

let sharedInstance = PFModelManager()
enum TimeSpan : Int {
    
    case CurrentTimeSpan
    case Last7DaysTimeSpan
    case Last30DaysTimeSpan
    case HalfYearTimeSpan
    case YearTimeSpan
}

class PFModelManager: NSObject {
    
    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
    
    var database : FMDatabase? = nil
    
    @IBOutlet weak var questionLabel: UILabel!
    
    class func getInstance() -> PFModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: PFUtility.getPath("PocketFriend.sqlite"))
        }
        return sharedInstance
    }
    
    
    /**
     *** EMOTION SET
     **/
    //*********************** Level -> One Question ******************//
    func getQuestion(trackID:NSInteger,subTrackID:NSInteger,levelID:NSInteger,sequence:NSInteger,pickAnyRandom:Bool) -> PFQuestionInfo
    {
        sharedInstance.database!.open()
        
        var query = "SELECT * FROM QUESTION WHERE TRACK_ID=? AND SUB_TRACK_ID=?AND LEVEL_ID=? AND SEQUENCE=?"
        if pickAnyRandom {
            query += " order by RANDOM()"
        }
        
        let quesResultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn:[trackID,subTrackID,levelID,sequence])
        //[TrackID,SubTrack_ID,Level_ID_One])
        
        let questionInfo : PFQuestionInfo = PFQuestionInfo()
        
        if (quesResultSet != nil)
        {
            while quesResultSet.next()
            {
                questionInfo.Id = Int(quesResultSet.int(forColumn: "ID"))
        
                questionInfo.Q_Desc = quesResultSet.string(forColumn: "Q_DESC")
                
                questionInfo.Level_ID = Int(quesResultSet.int(forColumn: "LEVEL_ID"))
                questionInfo.TrackID = Int(quesResultSet.int(forColumn: "TRACK_ID"))
                questionInfo.SubTrack_ID = Int(quesResultSet.int(forColumn: "SUB_TRACK_ID"))
                questionInfo.Sequence = Int(quesResultSet.int(forColumn: "SEQUENCE"))
                questionInfo.ShowInputField = Int(quesResultSet.int(forColumn: "SHOWINPUTFIELD"))
                questionInfo.FieldType = quesResultSet.string(forColumn: "FIELDTYPE")
                questionInfo.MoveToLevel = Int(quesResultSet.int(forColumn: "MOVETOLEVEL"))
           
                //print(questionInfo.Q_Desc)
                
               // questionArray.add(questionInfo)
                //break
            }
        }
        sharedInstance.database!.close()
        return questionInfo
    }
    /**
     *** EMOTION SET
     **/
    //*********************** Level -> One Question ******************//
    //*********************** Level -> One Question ******************//
    func getSubtracks(limit:NSInteger,userid:NSInteger) -> NSMutableArray
    {
        sharedInstance.database!.open()
        let optionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery("select subtrack_id from user_answer where subtrack_id > 0 and user_id=1 order by date desc, time desc limit ?", withArgumentsIn: [limit,userid])
        
        let subtrackArray : NSMutableArray = NSMutableArray()
        
        if (optionsResultSet != nil)
        {
            while optionsResultSet.next()
            {
                let subtrackInfo : PFSubTrackInfo = PFSubTrackInfo()
                
                subtrackInfo.subTrack_id = Int(optionsResultSet.int(forColumn: "subtrack_id"))
         
                subtrackArray.add(subtrackInfo)
            }
        }
        sharedInstance.database!.close()
        
        return subtrackArray
    }
    

    //*********************** Level -> One Question ******************//
    func getOption(ofQuesID:NSInteger) -> NSMutableArray
    {
        sharedInstance.database!.open()
        let optionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT OPTION_TEXT FROM QUES_OPTION WHERE QUES_ID=?", withArgumentsIn: [ofQuesID])
        
        let optionArray : NSMutableArray = NSMutableArray()
        
        if (optionsResultSet != nil)
        {
            while optionsResultSet.next()
            {
                let str:String = optionsResultSet.string(forColumnIndex: 0)
                
                //print(subtrackInfo.subTrack_description)
                
                optionArray.add(str)
            }
        }
        sharedInstance.database!.close()
        
        return optionArray
    }
    
    // **************************** Fetch Data From Database ****************************//
    // Fetch Track Wise Data From Database
    func getAllTracks() -> NSMutableArray {
        
        sharedInstance.database!.open()
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM TRACK", withArgumentsIn: nil)
        
        let trackArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let trackInfo : PFTrackInfo = PFTrackInfo()
                
                trackInfo.Description = isLevelOneResult.string(forColumn: "DESCRIPTION")
                trackInfo.Id = Int(isLevelOneResult.int(forColumn: "ID"))
                
                //  print(trackInfo.Description)
                
                trackArray.add(trackInfo)
            }
        }
        sharedInstance.database!.close()
        return trackArray
    }
    
    // Fetch SubTrack Wise Data From Database
    func getSubTracksOfTrack(trackID:NSInteger) -> NSMutableArray {
        
        sharedInstance.database!.open()
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM SUB_TRACK WHERE TRACK_ID=?", withArgumentsIn: [trackID])
        
        let subTrackArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let subtrackInfo : PFSubTrackInfo = PFSubTrackInfo()
                
                subtrackInfo.subTrack_description = isLevelOneResult.string(forColumn: "DESC")
                subtrackInfo.subTrack_id = Int(isLevelOneResult.int(forColumn: "ID"))
                subtrackInfo.subTrack_trackId = Int(isLevelOneResult.int(forColumn: "TRACK_ID"))
                
                //print(subtrackInfo.subTrack_description)
                
                subTrackArray.add(subtrackInfo)
            }
        }
        sharedInstance.database!.close()
        
        return subTrackArray
    }
    func getTimeSpan(timeSpan:TimeSpan)->String{
        var query:String=""
        if timeSpan == .CurrentTimeSpan {
            query += "a.date = date('now')"
        }
        else if timeSpan == .Last7DaysTimeSpan {
            query += "a.date between date('now','-7 day') and date('now')"
        }
        else if timeSpan == .Last30DaysTimeSpan {
            query += "a.date between date('now','-30 day') and date('now')"
        }
        else if timeSpan == .HalfYearTimeSpan {
            query += "a.date between date('now','-90 day') and date('now')"
        }
        else if timeSpan == .YearTimeSpan {
            query += "a.date between date('now','-365 day') and date('now')"
        }
        return query
    }
    // Fetch SubTrack Wise Data From Database
    func getEmotionsOfUser(userID:NSInteger, timeSpan:TimeSpan ) -> NSMutableArray {
        
        var query = "select  a.subtrack_id,b.desc,count(*) from USER_ANSWER a, Sub_track b where a.subtrack_id>0 and a.User_id=?  and a.subtrack_id = b.id and "
        query += self.getTimeSpan(timeSpan: timeSpan)
        query += "group by subtrack_id"
        
          sharedInstance.database!.open()
        let emotionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn: [userID])
        
        let subTrackEmotionsArray : NSMutableArray = NSMutableArray()
        
        if (emotionsResultSet != nil)
        {
            while emotionsResultSet.next()
            {
                let subtrackInfo : PFAboutEmotionsInfo = PFAboutEmotionsInfo()
                
                subtrackInfo.subTrack_id = Int(emotionsResultSet.int(forColumnIndex: 0))
                subtrackInfo.subTrack_description = emotionsResultSet.string(forColumnIndex: 1)
                
                subtrackInfo.subTrack_recordCount = Int(emotionsResultSet.int(forColumnIndex: 2))
                
                //print(subtrackInfo.subTrack_description)
                
                subTrackEmotionsArray.add(subtrackInfo)
            }
        }
        sharedInstance.database!.close()
        
        return subTrackEmotionsArray
    }
    
    
    // Fetch SubTrack Wise Data From Database
    func getDescriptionOfEmotion(subtrackID:NSInteger,userID:NSInteger, timeSpan:TimeSpan ) -> NSMutableArray {
        
        var query = "select  text  from USER_ANSWER a, QUESTION b where b.sub_track_id=? and a.User_id=? and b.FieldType='TextField' and a.q_id = b.id and  "
         query += self.getTimeSpan(timeSpan: timeSpan)
        
        sharedInstance.database!.open()
        let emotionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn: [subtrackID,userID])
        
        let subTrackEmotionsArray : NSMutableArray = NSMutableArray()
        
        if (emotionsResultSet != nil)
        {
            while emotionsResultSet.next()
            {
                
                let str:String = emotionsResultSet.string(forColumnIndex: 0)
                
                               //print(subtrackInfo.subTrack_description)
                
                subTrackEmotionsArray.add(str)
            }
        }
        sharedInstance.database!.close()
        
        return subTrackEmotionsArray
    }
    
    // Fetch SubTrack Wise Date Data From Database
    func getDatesOfEmotion(subtrackID:NSInteger,userID:NSInteger, timeSpan:TimeSpan ) -> NSMutableArray {
        
        var query = "select  distinct a.date  from USER_ANSWER a, QUESTION b where b.sub_track_id=? and a.User_id=? and b.FieldType='TextField' and a.q_id = b.id and  "
         query += self.getTimeSpan(timeSpan: timeSpan)
        query += " order by a.date desc"
        sharedInstance.database!.open()
        let emotionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn: [subtrackID,userID])
        
        let subTrackEmotionsArray : NSMutableArray = NSMutableArray()
        
        if (emotionsResultSet != nil)
        {
            while emotionsResultSet.next()
            {
                let detailObj : PFDetailObj = PFDetailObj()
                // let str:String = emotionsResultSet.string(forColumnIndex: 0)
                
                detailObj.dateString = emotionsResultSet.string(forColumnIndex: 0)
                detailObj.arrDetails = self.getDescriptionOfDate(subtrackID: subtrackID, userID: userID, date: detailObj.dateString)
                // print(str)
                
                subTrackEmotionsArray.add(detailObj)
            }
        }
        sharedInstance.database!.close()
        
        return subTrackEmotionsArray
    }
    // Fetch SubTrack Wise Data From Database
    func getDescriptionOfQuestion(quesID:NSInteger,userID:NSInteger) -> String {
        
              sharedInstance.database!.open()
        let emotionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery("select  text  from USER_ANSWER where User_id=? and q_id =?", withArgumentsIn: [userID,quesID])
        
        var desc : String = String()
        
        if (emotionsResultSet != nil)
        {
            while emotionsResultSet.next()
            {
                
                desc = emotionsResultSet.string(forColumnIndex: 0)
                
//                //print(subtrackInfo.subTrack_description)
//                
//                subTrackEmotionsArray.add(str)
            }
        }
        sharedInstance.database!.close()
        
        return desc
    }
    
    // Fetch SubTrack Wise Data From Database
    func getDescriptionOfDate(subtrackID:NSInteger,userID:NSInteger, date:String ) -> NSMutableArray {
        
        
        sharedInstance.database!.open()
        let emotionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery("select  distinct a.time,a.text  from USER_ANSWER a, QUESTION b where b.sub_track_id=? and a.User_id=? and b.FieldType='TextField' and a.q_id = b.id and a.date = ?  order by a.time desc", withArgumentsIn: [subtrackID,userID,date])
        
        let subTrackEmotionsArray : NSMutableArray = NSMutableArray()
        
        if (emotionsResultSet != nil)
        {
            while emotionsResultSet.next()
            {
                let detailChildObj : PFEmotionSubDetailObj = PFEmotionSubDetailObj()
                
                //let str:String = emotionsResultSet.string(forColumnIndex: 0)
                
                detailChildObj.timeString = emotionsResultSet.string(forColumnIndex: 0)
                
                detailChildObj.descriptionString = emotionsResultSet.string(forColumnIndex: 1)
                
                //print(detailChildObj.displayString)
                
                subTrackEmotionsArray.add(detailChildObj)
            }
        }
      //  sharedInstance.database!.close()
        
        return subTrackEmotionsArray
    }
    func getDayOfMaxSelectedSubtrack(subTrackID:NSInteger ,userID:NSInteger,timeSpan:TimeSpan) -> String
    {
        sharedInstance.database!.open()
        
        var query:String = "select case cast (strftime('%w', date) as integer) when 0 then 'Sunday' when 1 then 'Monday'when 2 then 'Tuesday'when 3 then 'Wednesday' when 4 then 'Thursday' when 5 then 'Friday' else 'Saturday' end as servdayofweek from user_answer where subtrack_id=? and user_id=? and "
         query += (self.getTimeSpan(timeSpan: timeSpan)).replacingOccurrences(of: "a.", with: "")
        query += "group by date order by count(*) desc limit 1"
        
        let quesResultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn:[subTrackID,userID])
        //[TrackID,SubTrack_ID,Level_ID_One])
        
        var info : String = ""
        
        if (quesResultSet != nil)
        {
            while quesResultSet.next()
            {
               info = quesResultSet.string(forColumnIndex: 0)
                
                }
        }
        sharedInstance.database!.close()
        return info
    }
    func getTimeOfMaxSelectedSubtrack(subTrackID:NSInteger ,userID:NSInteger,timeSpan:TimeSpan) -> String
    {
        sharedInstance.database!.open()
        
        var query:String = "select strftime('%H', time) , count(*) from user_answer where subtrack_id=? and user_id=? and "
       query += (self.getTimeSpan(timeSpan: timeSpan)).replacingOccurrences(of: "a.", with: "")
        query += "group by strftime('%H', time) order by count(*) desc limit 1"
        
        let quesResultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn:[subTrackID,userID])
        //[TrackID,SubTrack_ID,Level_ID_One])
        
        var info : String = ""
        
        if (quesResultSet != nil)
        {
            while quesResultSet.next()
            {
                info = quesResultSet.string(forColumnIndex: 0)
                
            }
        }
        sharedInstance.database!.close()
        return info
    }
    
    // Fetch user answer Data From Database
    func getCompleteUserData(userID:NSInteger,fromDate:String) -> String {
    
        let query:String = "SELECT ID,USER_ID,Q_ID, A_ID, TEXT, A_OPTS_ID, DATE, TIME, SUBTRACK_ID, TRACK_ID from USER_ANSWER where USER_ID =? and date between ? and date('now')"
       
        
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn: [userID,fromDate])
        
        var csvString : String = "\"ID\",\"USER_ID\",\"Q_ID\",\"A_ID\",\"TEXT\",\"A_OPTS_ID\",\"DATE\",\"TIME\",\"SUBTRACK_ID\",\"TRACK_ID\""
        
        if (resultSet != nil)
        {
            while resultSet.next()
            {
                csvString += "\n"
                csvString += "\(Int(resultSet.int(forColumnIndex: 0))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 1))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 2))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 3))),"
               
                var text:String? = resultSet.string(forColumnIndex: 4)
                if text == nil {
                    text = ""
                }
                csvString += "\"\(text!)\","
               
                csvString += "\(Int(resultSet.int(forColumnIndex: 5))),"
                
               text = resultSet.string(forColumnIndex: 6)
                if text == nil {
                    text = ""
                }
                csvString += "\"\(text!)\","
                
                text = resultSet.string(forColumnIndex: 7)
                if text == nil {
                    text = ""
                }
                csvString += "\"\(text!)\","
                
                csvString += "\(Int(resultSet.int(forColumnIndex: 8))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 9)))"
                
              }
        }
        sharedInstance.database!.close()
        
        return csvString
    }
    
    // Fetch user answer Data From Database
    func getCompleteUserData(userID:NSInteger,afterID:NSInteger ) -> String {
        
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT ID,USER_ID,Q_ID, A_ID, TEXT, A_OPTS_ID, DATE, TIME, SUBTRACK_ID, TRACK_ID from USER_ANSWER where USER_ID =? and ID>?", withArgumentsIn: [userID,afterID])
        
        var csvString : String = "\"ID\",\"USER_ID\",\"Q_ID\",\"A_ID\",\"TEXT\",\"A_OPTS_ID\",\"DATE\",\"TIME\",\"SUBTRACK_ID\",\"TRACK_ID\""
        
        if (resultSet != nil)
        {
            while resultSet.next()
            {
                csvString += "\n"
                csvString += "\(Int(resultSet.int(forColumnIndex: 0))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 1))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 2))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 3))),"
                
                var text:String? = resultSet.string(forColumnIndex: 4)
                if text == nil {
                    text = ""
                }
                csvString += "\"\(text!)\","
                
                csvString += "\(Int(resultSet.int(forColumnIndex: 5))),"
                
                text = resultSet.string(forColumnIndex: 6)
                if text == nil {
                    text = ""
                }
                csvString += "\"\(text!)\","
                
                text = resultSet.string(forColumnIndex: 7)
                if text == nil {
                    text = ""
                }
                csvString += "\"\(text!)\","
                
                csvString += "\(Int(resultSet.int(forColumnIndex: 8))),"
                csvString += "\(Int(resultSet.int(forColumnIndex: 9)))"
                
            }
        }
        sharedInstance.database!.close()
        
        return csvString
    }
    
    // Fetch user answer Data From Database
    func getLastRowID(userID:NSInteger) -> NSInteger {
        
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT ID from USER_ANSWER where USER_ID =? order by ID desc Limit 1", withArgumentsIn: [userID])
        
        var rowID:NSInteger = 0
        if (resultSet != nil)
        {
            while resultSet.next()
            {
                rowID = Int(resultSet.int(forColumnIndex: 0))
            }
        }
        sharedInstance.database!.close()
        
        return rowID
    }
    
//    // Fetch SubTrack Wise Date Data From Database
//    func getDatesOfEmotion(subtrackID:NSInteger,userID:NSInteger, timeSpan:TimeSpan ) -> NSMutableArray {
//        
//        var query = "select  distinct a.date  from USER_ANSWER a, QUESTION b where b.sub_track_id=? and a.User_id=? and b.FieldType='TextField' and a.q_id = b.id and  "
//        if timeSpan == .CurrentTimeSpan {
//            query += "a.date = date('now')"
//        }
//        else if timeSpan == .Last7DaysTimeSpan {
//            query += "a.date between date('now','-7 day') and date('now')"
//        }
//        else if timeSpan == .Last30DaysTimeSpan {
//            query += "a.date between date('now','-30 day') and date('now')"
//        }
//        query += " order by a.date desc"
//        sharedInstance.database!.open()
//        let emotionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn: [subtrackID,userID])
//        
//        let subTrackEmotionsArray : NSMutableArray = NSMutableArray()
//        
//        if (emotionsResultSet != nil)
//        {
//            while emotionsResultSet.next()
//            {
//                
//                let str:String = emotionsResultSet.string(forColumnIndex: 0)
//                
//                //print(subtrackInfo.subTrack_description)
//                
//                subTrackEmotionsArray.add(str)
//            }
//        }
//        sharedInstance.database!.close()
//        
//        return subTrackEmotionsArray
//    }
//    // Fetch SubTrack Wise Data From Database
//    func getDescriptionOfDate(subtrackID:NSInteger,userID:NSInteger, date:String ) -> NSMutableArray {
//    
//        
//        sharedInstance.database!.open()
//        let emotionsResultSet: FMResultSet! = sharedInstance.database!.executeQuery("select  distinct a.time,a.text  from USER_ANSWER a, QUESTION b where b.sub_track_id=? and a.User_id=? and b.FieldType='TextField' and a.q_id = b.id and a.date = ?  order by a.time desc", withArgumentsIn: [subtrackID,userID,date])
//        
//        let subTrackEmotionsArray : NSMutableArray = NSMutableArray()
//        
//        if (emotionsResultSet != nil)
//        {
//            while emotionsResultSet.next()
//            {
//                
//                let str:String = emotionsResultSet.string(forColumnIndex: 0)
//                
//                //print(subtrackInfo.subTrack_description)
//                
//                subTrackEmotionsArray.add(str)
//            }
//        }
//        sharedInstance.database!.close()
//        
//        return subTrackEmotionsArray
//    }
    // ============================ SAVING FOR GOOD Or BAD TRACK ============================//
    // Save Track ID for Good or Bad Button from User Response
    func saveUserResponse(_ userResponseInfo: PFUserAnswerInfo)->Bool
    {
        sharedInstance.database!.open()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalSwift.dateStandardFormat()
        let currentDate:String = dateFormatter.string(from: Date())
        let datepart:String = GlobalSwift.getDateFormat(dateString: currentDate, from: GlobalSwift.dateStandardFormat(), to: "yyyy-MM-dd")
        let timepart:String = GlobalSwift.getDateFormat(dateString: currentDate, from: GlobalSwift.dateStandardFormat(), to: "HH:mm:ss")
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO USER_ANSWER (USER_ID, Q_ID, A_ID, TEXT, A_OPTS_ID, SUBTRACK_ID, TRACK_ID,DATE,TIME) VALUES (?,?,?,?,?,?,?,?,?)", withArgumentsIn: [userResponseInfo.USER_ID, userResponseInfo.Q_ID, userResponseInfo.A_ID, userResponseInfo.TEXT, userResponseInfo.A_OPTS_ID, userResponseInfo.SUBTRACK_ID, userResponseInfo.TRACK_ID,datepart,timepart])
        
        sharedInstance.database!.close()
        return isInserted
    }
    
    // ============================ Call UserID from Database ============================//
    func getUserIDFromTableUSER()-> NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER WHERE ID", withArgumentsIn: nil)
        
        let userIDArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserInfo = PFUserInfo()
                                
                userInfo.UserID = Int(isLevelOneResult.int(forColumn: "ID"))
                
               // print(userInfo.IDString)
                
                userIDArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userIDArray
    }
    
    // ============================ Insert Data into User DB ============================//
    // Add User Into Database
    func addUserFormData(_ userInfo: PFUserInfo) -> Bool
    {
        sharedInstance.database!.open()
        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO USER (DEVICE_ID, NAME, DOB, CITY, GENDER, DATE, TIME) VALUES (?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [userInfo.DeviceID, userInfo.Name, userInfo.DOB, userInfo.City, userInfo.Gender, userInfo.Date, userInfo.Time])
        
        sharedInstance.database!.close()
        return isInserted
    }
    
    func fetchRegisteredUserFromDB() -> NSMutableArray
    {
        sharedInstance.database!.open()
        
        let userArray : NSMutableArray = NSMutableArray()
        
        let userResultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER", withArgumentsIn:nil)
        
        let userInfo : PFUserInfo = PFUserInfo()
        
        if (userResultSet != nil)
        {
            while userResultSet.next()
            {
                userInfo.UserID = Int(userResultSet.int(forColumn: "ID"))
                
               // userInfo.FirstName = userResultSet.string(forColumn: "FNAME")
                
               // userInfo.LastName = userResultSet.string(forColumn: "LNAME")
                
                userInfo.Name = userResultSet.string(forColumn: "NAME")
                
                userInfo.DOB = userResultSet.string(forColumn: "DOB")
                
                userInfo.City = userResultSet.string(forColumn: "CITY")
                
                userInfo.Gender = userResultSet.string(forColumn: "GENDER")
                
                userInfo.Date = userResultSet.string(forColumn: "DATE")
                
                userInfo.Time = userResultSet.string(forColumn: "TIME")
                
                userArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userArray
    }
    
    //#MARK: - TO BE DELETE
 /*
    // Fetch SubTrack Wise Data From Database
    func fetchBySubTracForGoodEmotion() -> NSMutableArray {
        
        sharedInstance.database!.open()
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM SUB_TRACK WHERE TRACK_ID=1", withArgumentsIn: [subtrackInfo.subTrack_id])
        
        let goodEmotionArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let subtrackInfo : PFSubTrackInfo = PFSubTrackInfo()
                
                subtrackInfo.subTrack_description = isLevelOneResult.string(forColumn: "DESC")
                
                //print(subtrackInfo.subTrack_description)
                
                goodEmotionArray.add(subtrackInfo)
            }
        }
        sharedInstance.database!.close()
        
        return goodEmotionArray
    }
    
    // Fetch SubTrack Wise Data From Database
    func fetchBySubTracForBadEmotion() -> NSMutableArray {
        
        sharedInstance.database!.open()
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM SUB_TRACK WHERE TRACK_ID=2", withArgumentsIn: [subtrackInfo.subTrack_id])
        
        let badEmotionArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let subtrackInfo : PFSubTrackInfo = PFSubTrackInfo()
                
                subtrackInfo.subTrack_description = isLevelOneResult.string(forColumn: "DESC")
                
               // print(subtrackInfo.subTrack_description)
                
                badEmotionArray.add(subtrackInfo)
            }
        }
        sharedInstance.database!.close()
        
        return badEmotionArray
    }
    

//    
//    /**
//     *** EMOTION SET
//     **/
//    //*********************** Level -> One Question ******************//
//    func fetchDataByLevelOneQuestion() -> NSMutableArray
//    {
//        sharedInstance.database!.open()
//        
//        TrackID = appDelegate.TrackID
//        SubTrack_ID = appDelegate.SubTrack_ID
//        Level_ID_One  = appDelegate.Level_ID_One
//        
//        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM QUESTION WHERE TRACK_ID=? AND SUB_TRACK_ID=?AND LEVEL_ID=?", withArgumentsIn:[1,1,1])
//        //[TrackID,SubTrack_ID,Level_ID_One])
//        
//        let questionArray : NSMutableArray = NSMutableArray()
//        
//        if (isLevelOneResult != nil)
//        {
//            while isLevelOneResult.next()
//            {
//                let questionInfo : PFQuestionInfo = PFQuestionInfo()
//                
//                questionInfo.Q_Desc = isLevelOneResult.string(forColumn: "Q_DESC")
//                
//                questionInfo.Id = isLevelOneResult.string(forColumn: "ID")
//                
//                //print(questionInfo.Q_Desc)
//                
//                questionArray.add(questionInfo)
//            }
//        }
//        sharedInstance.database!.close()
//        return questionArray
//    }
//    
//    //*********************** Level -> Two Question ******************//
//    func fetchDataByLevelTwoQuestion()-> NSMutableArray
//    {
//        sharedInstance.database!.open()
//        
//        TrackID = appDelegate.TrackID
//        SubTrack_ID = appDelegate.SubTrack_ID
//        Level_ID_Two  = appDelegate.Level_ID_Two
//        
//        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM QUESTION WHERE TRACK_ID=? AND SUB_TRACK_ID=? AND LEVEL_ID=?", withArgumentsIn: [TrackID,SubTrack_ID,Level_ID_Two])
//       
//        let questionArray : NSMutableArray = NSMutableArray()
//        
//        if (isLevelOneResult != nil)
//        {
//            while isLevelOneResult.next()
//            {
//                let questionInfo : PFQuestionInfo = PFQuestionInfo()
//                
//                questionInfo.Q_Desc = isLevelOneResult.string(forColumn: "Q_DESC")
//                
//                questionInfo.Id = isLevelOneResult.string(forColumn: "ID")
//                
//                //print(questionInfo.Q_Desc)
//                
//                questionArray.add(questionInfo)
//            }
//        }
//        sharedInstance.database!.close()
//        return questionArray
//    }
//    
//    //*********************** Level -> Three Question ******************//
//    func fetchDataByLevelThreeQuestion()-> NSMutableArray
//    {
//        sharedInstance.database!.open()
//       
//        TrackID = appDelegate.TrackID
//        SubTrack_ID = appDelegate.SubTrack_ID
//        Level_ID_Three  = appDelegate.Level_ID_Three
//        
//        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM QUESTION WHERE TRACK_ID=? AND SUB_TRACK_ID=?AND LEVEL_ID=?", withArgumentsIn: [TrackID,SubTrack_ID,Level_ID_Three])
//
//        let questionArray : NSMutableArray = NSMutableArray()
//        
//        if (isLevelOneResult != nil)
//        {
//            while isLevelOneResult.next()
//            {
//                let questionInfo : PFQuestionInfo = PFQuestionInfo()
//                
//                questionInfo.Q_Desc = isLevelOneResult.string(forColumn: "Q_DESC")
//                
//                questionInfo.Id = isLevelOneResult.string(forColumn: "ID")
//                
//                //print(questionInfo.Q_Desc)
//                
//                questionArray.add(questionInfo)
//            }
//        }
//        sharedInstance.database!.close()
//        return questionArray
//    }
//    
//    //*********************** Level -> Four Question ******************//
//    func fetchDataByLevelFourQuestion()-> NSMutableArray
//    {
//        sharedInstance.database!.open()
//                
//        TrackID = appDelegate.TrackID
//        SubTrack_ID = appDelegate.SubTrack_ID
//        Level_ID_Four  = appDelegate.Level_ID_Four
//        
//        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM QUESTION WHERE TRACK_ID=? AND SUB_TRACK_ID=?AND LEVEL_ID=?", withArgumentsIn: [TrackID,SubTrack_ID,Level_ID_Four])
//        
//        let questionArray : NSMutableArray = NSMutableArray()
//        
//        if (isLevelOneResult != nil)
//        {
//            while isLevelOneResult.next()
//            {
//                let questionInfo : PFQuestionInfo = PFQuestionInfo()
//                
//                questionInfo.Q_Desc = isLevelOneResult.string(forColumn: "Q_DESC")
//                
//                questionInfo.Id = isLevelOneResult.string(forColumn: "ID")
//                
//               // print(questionInfo.Q_Desc)
//                
//                questionArray.add(questionInfo)
//            }
//        }
//        sharedInstance.database!.close()
//        return questionArray
//    }
//    
//    //*********************** Level -> Five Question ******************//
//    func fetchDataByLevelFiveQuestion()-> NSMutableArray
//    {
//        sharedInstance.database!.open()
//        
//        TrackID = appDelegate.TrackID
//        SubTrack_ID = appDelegate.SubTrack_ID
//        Level_ID_Five  = appDelegate.Level_ID_Five
//        
//        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM QUESTION WHERE TRACK_ID=? AND SUB_TRACK_ID=?AND LEVEL_ID=?", withArgumentsIn: [TrackID,SubTrack_ID,Level_ID_Five])
//        
//        let questionArray : NSMutableArray = NSMutableArray()
//        
//        if (isLevelOneResult != nil)
//        {
//            while isLevelOneResult.next()
//            {
//                let questionInfo : PFQuestionInfo = PFQuestionInfo()
//                
//                questionInfo.Q_Desc = isLevelOneResult.string(forColumn: "Q_DESC")
//                
//                questionInfo.Id = isLevelOneResult.string(forColumn: "ID")
//                                
//                questionArray.add(questionInfo)
//            }
//        }
//        sharedInstance.database!.close()
//        return questionArray
//    }
    
    /**
     *** FIELD SET
     **/
    //*********************** Field ******************//
    func getUIControlTypeFromFieldTable()-> NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM FIELD ", withArgumentsIn: nil)
        
        let fieldTypeArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let fieldInfo : PFFieldInfo = PFFieldInfo()
                
                fieldInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                fieldInfo.FIELD_TYPE = isLevelOneResult.string(forColumn: "TYPE")
                
                // print(fieldInfo.FIELD_TYPE)
                
                fieldTypeArray.add(fieldInfo)
            }
        }
        sharedInstance.database!.close()
        
        return fieldTypeArray
    }
    /**
     *** USER_ANSWER SET
     **/
    func getUserDataFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER ", withArgumentsIn: nil)
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")

                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getHappyUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn:["HAPPY"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.A_ID = isLevelOneResult.string(forColumn: "A_ID")
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getContentUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["CONTENT"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getExcitedUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["EXCITED"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getPeacefulUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["PEACEFUL"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getProudUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?  ", withArgumentsIn: ["PROUD"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getEnergisedUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["ENERGISED"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    /**
     *** USER_ANSWER FOR BAD EMOTION SET
     **/
    
    func getAnxiousUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn:["ANXIOUS"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.A_ID = isLevelOneResult.string(forColumn: "A_ID")
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getSadUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["SAD"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getStressedUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["STRESSED"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getBoredUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["BORED"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getFlatUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["FLAT"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
    
    func getAngryUserFromUser_AnswerTable()->NSMutableArray
    {
        sharedInstance.database!.open()
        
        let isLevelOneResult: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM USER_ANSWER WHERE TEXT=?", withArgumentsIn: ["ANGRY"])
        
        let userAnswerArray : NSMutableArray = NSMutableArray()
        
        if (isLevelOneResult != nil)
        {
            while isLevelOneResult.next()
            {
                let userInfo : PFUserAnswerInfo = PFUserAnswerInfo()
                
                userInfo.ID = isLevelOneResult.string(forColumn: "ID")
                
                userInfo.USER_ID = isLevelOneResult.string(forColumn: "USER_ID")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "TEXT")
                
                userInfo.TEXT = isLevelOneResult.string(forColumn: "A_ID")
                
                
                // print(userInfo.TEXT)
                
                userAnswerArray.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        
        return userAnswerArray
    }
 */
}
