//
//  HypeController.swift
//  Hype
//
//  Created by Ethan Perkins on 12/6/21.
//

import UIKit
import CloudKit


class HypeController {
    
    static let shared = HypeController()
    
    var hypes: [Hype] = []
    
    //constant to access our public database
    let publicDB = CKContainer.default().publicCloudDatabase
    
    
    // crud functions
    
    
    func saveHype(with text: String, photo: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { completion(false) ; return}
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        let newHype = Hype(body: text, hypePhoto: photo, userReference: reference)
        
        let hypeRecord = CKRecord(hype: newHype)
        
        publicDB.save(hypeRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let record = record,
                  let savedHype = Hype(ckRecord: record) else { completion(false) ; return }
        
            print("saved hype successfully")
            self.hypes.insert(savedHype, at: 0)
            completion(true)
        }
            
    }
    
    
    func fetchHypes(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false) ; return }
            print("fetched all hypes")
            
            let fetchedHypes = records.compactMap {Hype(ckRecord: $0) }
            self.hypes = fetchedHypes
            completion(true)
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false) ; return }
        
        let recordToUpdate = CKRecord(hype: hype)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let record = records?.first else { completion(false) ; return }
            print("Updated \(record.recordID.recordName) successfully in CloudKit ")
            return completion(true)
        }
        
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false) ; return }
        
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [hype.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, recordIDs, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let recordIDs = recordIDs else { completion(false) ; return }
                print("\(recordIDs) were removed successfully")
                completion(true)
            }
        
        publicDB.add(operation)
    }
    
    func subscribeForRemoteNotifications(completion: @escaping (Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't stop the hype train"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
    
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
        
}
