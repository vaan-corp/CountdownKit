//
//  FavoriteEvent.swift
//  CountdownKit
//
//  Created by Imthath M on 09/07/20.
//  Copyright © 2020 Imthath. All rights reserved.
//

import MIFileManager
import CoreData
import EventKit
import SwiftUI

public class FavoriteModel: ObservableObject {
  let event: EKEvent
  
  @Published public var image: Image
  
  public init(event: EKEvent) {
    self.event = event
    
    if CDStore.isFavorite(event) {
      image = Image(systemName: "heart.fill")
    } else {
      image = Image(systemName: "heart")
    }
  }
  
  public func toggle() {
    if isFavEvent {
      CDStore.deleteEvent(withID: self.event.eventIdentifier)
      self.image = Image(systemName: "heart")
    } else {
      CDStore.favorite(self.event)
      self.image = Image(systemName: "heart.fill")
    }
  }
  
  public var isFavEvent: Bool { CDStore.isFavorite(event) }
}

public class CDStore {
  
  static var entityName: String { FavEvent.entityName }
  static var appGroup: String = ""
  
  public static func prepare(forAppGroup groupName: String) {
    CDStore.appGroup = groupName
    MICoreData.initialize(with: container)
  }
  
  public static func isFavorite(_ event: EKEvent) -> Bool {
    let fetchRequest = fetchRequestForEvent(withID: event.eventIdentifier)
    
    guard let objects = try? MICoreData.viewContext?.fetch(fetchRequest) else {
      return false
    }
    
    return !objects.isEmpty
  }
  
  public static var allFavIdentifiers: [String] {
    guard let objects = try? MICoreData.viewContext?.fetch(FavEvent.fetchRequest) as? [NSManagedObject] else {
      return []
    }
    
    return objects.compactMap({ $0.value(forKey: FavEvent.id) as? String })
  }
  
  //    public static var allFavorites: [FavoriteEvent] {
  //        guard let objects = try? MICoreData.viewContext?.fetch(FavEvent.fetchRequest) as? [NSManagedObject] else {
  //                return []
  //        }
  //
  //        return objects.compactMap({ $0.value(forKey: FavEvent.id) as? String })
  //    }
  
  public static func favorite(_ event: EKEvent) {
    guard let context = MICoreData.viewContext else {
      "unable to save favorite into context".log()
      return
    }
    
    let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    
    //        if let favEvent = object as? FavoriteEvent {
    //            favEvent.eventID = event.eventIdentifier
    //            favEvent.occurenceDate = event.occurrenceDate
    //        } else {
    object.setValue(event.eventIdentifier, forKey: FavEvent.id)
    object.setValue(event.occurrenceDate, forKey: FavEvent.date)
    //        }
    
    "event saved with id - \(event.eventIdentifier ?? "")".log()
    
    MICoreData.update()
  }
  
  public static func deleteEvent(withID string: String) {
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestForEvent(withID: string))
    
    do {
      try MICoreData.viewContext?.execute(batchDeleteRequest)
      "deleted event with id - \(string)".log()
    } catch {
      "Unable to delete entity with name \(entityName)".log()
    }
    
    // Core data save not required after performing delete batch request
    // as it acts directly on the underlying SQLite store
    //        MICoreData.update()
  }
  
  static func fetchRequestForEvent(withID string: String) -> NSFetchRequest<NSFetchRequestResult>{
    let fetchRequest = FavEvent.fetchRequest
    fetchRequest.predicate = NSPredicate(format: "\(FavEvent.id) = %@", string)
    return fetchRequest
  }
  
  static var container: NSPersistentContainer {
    SharedContainer(name: "CountdownStore", managedObjectModel: objectModel)
  }
  
  static var objectModel: NSManagedObjectModel {
    let model: NSManagedObjectModel = NSManagedObjectModel()
    model.entities = [favoriteEntity]
    return model
  }
  
  static var favoriteEntity: NSEntityDescription {
    let entity = NSEntityDescription()
    entity.name = entityName
    entity.addAttribute(name: FavEvent.id, type: .stringAttributeType, isUnique: true)
    entity.addAttribute(name: FavEvent.date, type: .dateAttributeType)
    return entity
  }
}

class SharedContainer: NSPersistentCloudKitContainer {
  override open class func defaultDirectoryURL() -> URL {
    let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CDStore.appGroup)
    return storeURL ?? super.defaultDirectoryURL()
  }
}

struct FavEvent {
  static var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
    NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
  }
  
  static var entityName: String { "FavoriteEvent" }
  static var id: String { "eventID" }
  static var date: String { "occurenceDate" }
}

//@objc(FavoriteEvent) public class FavoriteEvent: NSManagedObject {
////    @nonobjc public class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
////        return NSFetchRequest<NSFetchRequestResult>(entityName: CDStore.entityName)
////    }
//
//    @NSManaged public var eventID: String
//    @NSManaged public var occurenceDate: Date
//}
