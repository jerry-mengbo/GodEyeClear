//
//  RecordBaseModel.swift
//  TK_IGS_iPad_Swift
//
//  Created by 51Talk_zhaoguanghui on 2017/5/24.
//  Copyright © 2017年 AC. All rights reserved.
//

import UIKit
import RealmSwift
private var kShowAll = "\(#file)+\(#line)"
private var kAddCount = "\(#file)+\(#line)"


protocol RecordORMProtocol : class {
  //static func configure(tableBuilder:AnyObject)
    
    static var type:RecordType { get }
    func attributeString() -> NSAttributedString
}


extension RecordORMProtocol {
    static func delete(complete:@escaping (_ success:Bool)->())  {
        
    }
    
    internal static var addCount: Int {
        get {
            return objc_getAssociatedObject(self, &kAddCount) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &kAddCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var showAll: Bool {
        get {
            return objc_getAssociatedObject(self, &kShowAll) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &kShowAll, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var realClass:AnyClass! {
        switch self.type {
        case .anr:
            return ANRRecordModel.self
        case .command:
            return CommandRecordModel.self
        case .crash:
            return CrashRecordModel.self
        case .leak:
            return LeakRecordModel.self
        case .log:
            return LogRecordModel.self
        case .network:
            return NetworkRecordModel.self
        }
    }
    
    static func getRealm() -> Realm
    {
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                             FileManager.SearchPathDomainMask.userDomainMask, true)
        let dirPath = documentPaths[0] + "/RealmDB"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dirPath){
            try! fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: false, attributes: nil)
        }
        
        let dbPath = dirPath + "/Realm.sqlite"
        return try! Realm(fileURL: URL(fileURLWithPath: dbPath))
    }
    
    static func select(at index:Int,_ success:@escaping ([Any]?)->()) {
        DispatchQueue.main.async {
            let realm:Realm = self.getRealm()
            let arr = Array<Object>(realm.objects(self.realClass as! Object.Type))
            DispatchQueue.main.async {
                success(arr)
            }
        }
    }
    
    static func create() {
        
    }

//    fileprivate static var queue: DispatchQueue {
//        get {
//            var key = "\(#file)+\(#line)"
//            guard let result = objc_getAssociatedObject(self, &key) as? DispatchQueue else {
//                let result = DispatchQueue(label: "RecordDB")
//                objc_setAssociatedObject(self, &key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                return result
//            }
//            return result
//        }
//    }
//    
    func insert(complete:@escaping (_ success:Bool)->()) {
        DispatchQueue.main.async {
            let realm:Realm = Self.getRealm()
            try! realm.write {
                realm.add(self as! Object)
            }
            DispatchQueue.main.async {
                complete(true)
            }
        }
    }
    
    
    func attributes() -> Dictionary<String, Any>{
        return
        [NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName:UIFont.courier(with: 12)]
    }
    
    func contentString(with prefex:String?,content:String?,newline:Bool = false,color:UIColor = UIColor(hex: 0x3D82C7)) -> NSAttributedString {
        let pre = prefex != nil ? "[\(prefex!)]:" : ""
        let line = newline == true ? "\n" : (pre == "" ? "" : " ")
        let str = "\(pre)\(line)\(content ?? "nil")\n"
        let result = NSMutableAttributedString(string: str, attributes: self.attributes())
        let range = str.NS.range(of: pre)
        if range.location != NSNotFound {
            result.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        }
        return result
    }
    
    func headerString(with prefex:String,content:String? = nil,color:UIColor) -> NSAttributedString {
        let header = "> \(prefex): \(content ?? "")\n"
        let result = NSMutableAttributedString(string: header, attributes: self.attributes())
        
        let range = header.NS.range(of: prefex)
        if range.location + range.length <= header.NS.length {
            result.addAttributes([NSForegroundColorAttributeName: color], range: range)
        }
        return result
    }

}
