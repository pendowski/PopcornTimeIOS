//
//  Settings.swift
//  PopcornTime
//
//  Created by Jarosław Pendowski on 24/10/16.
//  Copyright © 2016 Popcorn Time. All rights reserved.
//

import Foundation


enum Settings: String {
    case AuthorizedTrakt
    case AuthorizedOpenSubs
    case PreferredSubtitleLanguage
    case PreferredQuality
    case StreamOnCellular
    case RemoveCacheOnPlayerExit
}

extension Settings {
    
    var bool: Bool {
        get {
            return self.getBool()
        }
        set (newValue) {
            self.setBool(newValue)
        }
    }
    
    var string: String? {
        get {
            return self.getString()
        }
        set (newValue) {
            self.setString(newValue)
        }
    }
    
    func getString(inDefaults defaults: UserDefaultsProvider = NSUserDefaults.standardUserDefaults(), defaultValue: String? = nil) -> String? {
        return defaults.stringForKey(self.rawValue) ?? defaultValue
    }
    
    func getBool(inDefaults defaults: UserDefaultsProvider = NSUserDefaults.standardUserDefaults()) -> Bool {
        return defaults.boolForKey(self.rawValue)
    }

    func setString(value: String?, inDefaults defaults: UserDefaultsProvider = NSUserDefaults.standardUserDefaults()) {
        defaults.setObject(value, forKey: self.rawValue)
    }
    
    func setBool(value: Bool, inDefaults defaults: UserDefaultsProvider = NSUserDefaults.standardUserDefaults()) {
        defaults.setBool(value, forKey: self.rawValue)
    }
}


protocol UserDefaultsProvider {
    func stringForKey(key: String) -> String?
    func boolForKey(key: String) -> Bool
    
    func setObject(value: AnyObject?, forKey defaultName: String)
    func setBool(value: Bool, forKey defaultName: String)
}

extension NSUserDefaults: UserDefaultsProvider {
    
}