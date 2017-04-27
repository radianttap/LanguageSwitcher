//
//  UserDefaults-AppLocale.swift
//  Radiant Tap Essentials
//
//  Copyright © 2016 Aleksandar Vacić, Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation


extension UserDefaults {
	private enum Key : String {
		case languageCode = "AppleLanguages"
		case regionCode = "RegionCode"
	}

	static var languageCode: String? {
		get {
			let defs = UserDefaults.standard
			return defs.string(forKey: Key.languageCode.rawValue)
		}
		set(value) {
			let defs = UserDefaults.standard
			defs.set(value, forKey: Key.languageCode.rawValue)
		}
	}

	static var regionCode: String? {
		get {
			let defs = UserDefaults.standard
			return defs.string(forKey: Key.regionCode.rawValue)
		}
		set(value) {
			let defs = UserDefaults.standard
			defs.set(value, forKey: Key.regionCode.rawValue)
		}
	}
}
