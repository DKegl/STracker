//
//  ShowStoreManager.swift
//
// mmmmmmmmmmm
// Dani du Sahne?
//  Created by Andre Frank on 27.11.18.
//

import Foundation
import RealmSwift

enum ShowStoreFilter {
    case EpisodesBy(airdate: String)
    case EpisodesByShow(Id:Int)
}

// Public interface of ShowStore

protocol ShowStoreManagerQueries {
    func showFilterWith(id: Int) -> Results<RealmBookmarkShow>
    func isShowBookmark(id: Int) -> Bool
    func showAvailable(id: Int) -> Bool
    func filter(type: ShowStoreFilter) -> Results<RealmEpisodenInformation>?
}

protocol ShowStoreManagerBase {
    func saveAsBookmarkShow(show: ShowMainInformation, episodes: [ShowEpisodenInformation]?) -> Bool
    func deleteBookmarkShow(realmShow: RealmBookmarkShow) -> Bool
    func deleteBookmarkShow(id: Int) -> Bool
    var bookmarkShows: Results<RealmBookmarkShow> { get }
}

private protocol InternalShowStore {
    func filter<T: Object, K: Equatable>(objectType: T.Type, query: String, value: K) -> Results<T>?
}

class ShowStoreManager: NSObject {
    static let shared = ShowStoreManager()
    
    private override init() {
        super.init()
    }
    
    private lazy var realm: Realm! = {
        do {
            let realm = try Realm()
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            return realm
        } catch let error {
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            fatalError(error.localizedDescription)
        }
    }()
}

extension ShowStoreManager: InternalShowStore {
    fileprivate func filter<T, K>(objectType: T.Type, query: String, value: K) -> Results<T>? where T: Object, K: Equatable {
        let queriedElement = realm.objects(objectType).filter("\(query) == %@", value)
        return queriedElement
    }
}

extension ShowStoreManager: ShowStoreManagerQueries {
    func filter(type: ShowStoreFilter) -> Results<RealmEpisodenInformation>? {
        switch type {
        case .EpisodesBy(airdate: let airDate):
            return filter(objectType: RealmEpisodenInformation.self, query: "airdate", value: airDate)
        case .EpisodesByShow(let Id):
            break
        }
        return nil
    }
    
    internal func showAvailable(id: Int) -> Bool {
        return realm.objects(RealmBookmarkShow.self).filter("showId==\(id)").count > 0
    }
    
    internal func showFilterWith(id: Int) -> Results<RealmBookmarkShow> {
        return realm.objects(RealmBookmarkShow.self).filter("showId==\(id)")
    }
    
    internal func isShowBookmark(id: Int) -> Bool {
        let obj = realm.objects(RealmBookmarkShow.self).filter("showId==\(id)").first
        if obj == nil {
            return false
        } else {
            return true
        }
    }
}

extension ShowStoreManager: ShowStoreManagerBase {
    var bookmarkShows: Results<RealmBookmarkShow> {
        return realm.objects(RealmBookmarkShow.self)
    }
    
    internal func deleteBookmarkShow(id: Int) -> Bool {
        if showAvailable(id: id) {
            let show = showFilterWith(id: id)
            return deleteBookmarkShow(realmShow: show.first!)
        } else { return false }
    }
    
    internal func saveAsBookmarkShow(show: ShowMainInformation, episodes: [ShowEpisodenInformation]?) -> Bool {
        do {
            try realm.write {
                let realmShow = RealmBookmarkShow()
                realmShow.isBookmark = true
                realmShow.showId = show.showId
                realmShow.showName = show.showName
                realmShow.showStatus = show.showStatus
                realmShow.showPremiered = show.showPremiered
                realmShow.showSummary = show.showSummary
                
                let image = RealmShowImage()
                image.medium = show.image?.medium
                image.original = show.image?.original
                image.showId = show.showId
                realmShow.setValue(image, forKey: "image")
                
                var realmEpisoden = [RealmEpisodenInformation]()
                if let episodes = episodes {
                    realmEpisoden = episodes.map({ (episode) -> RealmEpisodenInformation in
                        let realmEp = RealmEpisodenInformation()
                        realmEp.name = episode.name
                        realmEp.show = realmShow
                        realmEp.id = episode.id
                        realmEp.url = episode.url
                        realmEp.season = episode.season ?? 0
                        realmEp.number = episode.number ?? 0
                        realmEp.airdate = episode.airdate
                        realmEp.summary = episode.summary
                        realmEp.isSeen = false
                        
                        let image = RealmEpImage()
                        image.medium = episode.image?.medium
                        image.original = episode.image?.original
                        image.episodeId = realmEp.id
                        image.showId = show.showId
                        realmEp.setValue(image, forKey: "image")
                        return realmEp
                    })
                    realmShow.realmEpisoden.append(objectsIn: realmEpisoden)
                }
                
                self.realm.add(realmShow, update: true)
            }
        } catch let error {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    internal func deleteBookmarkShow(realmShow: RealmBookmarkShow) -> Bool {
        let showImageObject = realm.object(ofType: RealmShowImage.self, forPrimaryKey: realmShow.showId)
        do {
            try realm.write {
                self.realm.delete(showImageObject!)
                let episodeShowImages = self.realm.objects(RealmEpImage.self).filter("showId==\(realmShow.showId)")
                if episodeShowImages.count > 0 {
                    self.realm.delete(episodeShowImages)
                }
                
                self.realm.delete(realmShow.realmEpisoden)
                self.realm.delete(realmShow)
                
        } } catch let error {
            print(error.localizedDescription)
            return false
        }
        return true
    }
}
