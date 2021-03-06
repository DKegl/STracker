//
//  ShowStoreManager.swift
//
// mmmmmmmmmmm
// Dani du Sahne?
//  Created by Andre Frank on 27.11.18.
//

import Foundation
import RealmSwift


//MARK: - Grouped filter types associated with th data model
enum ShowStoreFilter {
    case EpisodesBy(airdate: String)
}

// MARK:- Filter protocol of ShowStoreManager
protocol ShowStoreManagerQueries {
    //Modified 04.12. to get only one show object
    func showWith(id: Int) -> RealmBookmarkShow?
    func isShowBookmark(id: Int) -> Bool
    func showAvailable(id: Int) -> Bool
    func filter(type: ShowStoreFilter) -> Results<RealmEpisodenInformation>?
    func episodesBy(bookmarkShow:RealmBookmarkShow)->[ShowEpisodenInformation]?
}

// MARK: - Base public ShowStoreManager protocol
protocol ShowStoreManagerBase {
    func saveAsBookmarkShow(show: ShowMainInformation, episodes: [ShowEpisodenInformation]?) -> Bool
    func deleteBookmarkShow(realmShow: RealmBookmarkShow) -> Bool
    func deleteBookmarkShow(id: Int) -> Bool
    var bookmarkShows: Results<RealmBookmarkShow> { get }
    func updateEpisode(_ episode:ShowEpisodenInformation,id:Int)
}

// MARK: - Generic filter protocol
private protocol InternalShowStore {
    func filter<T: Object, K: Equatable>(objectType: T.Type, query: String, value: K) -> Results<T>?
}

// MARK: - The ShowStore Singleton which mages the Realm accesses
final class ShowStoreManager: NSObject {
    static let shared = ShowStoreManager()
    
    private let serialQueue=DispatchQueue(label: "serialQueue")
    
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
    func episodesBy(bookmarkShow show: RealmBookmarkShow) -> [ShowEpisodenInformation]? {
        let realmEpisodes=show.realmEpisoden
        //Transform Realm objects into original form
        let episodes:[ShowEpisodenInformation]=Array(realmEpisodes).map { realmEpisode in
            var image:ShowEpisodenInformation.epImage?
            //Create image object
            if let realmImage=realmEpisode.image{
                image=ShowEpisodenInformation.epImage(medium: realmImage.medium, original: realmImage.original)
            }
            
            let ep=ShowEpisodenInformation(id: realmEpisode.id, url: realmEpisode.url, name: realmEpisode.name, airdate: realmEpisode.airdate, season: realmEpisode.season, number: realmEpisode.number, image:image, seen: realmEpisode.isSeen, summary: realmEpisode.summary)
            return ep
        }
        return episodes
    }
    
    
    
    func filter(type: ShowStoreFilter) -> Results<RealmEpisodenInformation>? {
        switch type {
        case .EpisodesBy(airdate: let airDate):
            return filter(objectType: RealmEpisodenInformation.self, query: "airdate", value: airDate)
        }
    }
    
    internal func showAvailable(id: Int) -> Bool {
        return realm.objects(RealmBookmarkShow.self).filter("showId==\(id)").count > 0
    }
    
    internal func showWith(id: Int) -> RealmBookmarkShow? {
        return realm.objects(RealmBookmarkShow.self).filter("showId==\(id)").first
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
    func updateEpisode(_ episode:ShowEpisodenInformation,id: Int) {
        let realmEp=RealmEpisodenInformation()
        realmEp.id=episode.id
        realmEp.airdate=episode.airdate
        realmEp.name=episode.name
        realmEp.number=episode.number ?? 0
        realmEp.season=episode.season ?? 0
        realmEp.show=showWith(id: id)
        realmEp.summary=episode.summary
        realmEp.isSeen=episode.seen ?? false
        realmEp.url=episode.url
        
        let image = RealmEpImage()
        image.original=episode.image?.original
        image.medium=episode.image?.medium
        image.showId=id
        image.episodeId=episode.id
        realmEp.setValue(image, forKey: "image")
        
        do{
            try realm.write {
                realm.add(realmEp, update: true)
            }
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    var bookmarkShows: Results<RealmBookmarkShow> {
        return realm.objects(RealmBookmarkShow.self)
    }
    
    internal func deleteBookmarkShow(id: Int) -> Bool {
        if showAvailable(id: id) {
            let show = showWith(id: id)
            return deleteBookmarkShow(realmShow: show!)
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
                        realmEp.isSeen = episode.seen ?? false
                        
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
