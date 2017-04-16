//
//  Bundle-AppLocale.swift
//  Radiant Tap Essentials
//
//  Copyright © 2016 Aleksandar Vacić, Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/*
	Credits:
	https://www.factorialcomplexity.com/blog/2015/01/28/how-to-change-localization-internally-in-your-ios-application.html
*/


///	Custom subclass to enable on-the-fly Bundle.main language change
public final class LocalizedBundle: Bundle {
	///	Overrides system method and enforces usage of particular .lproj translation bundle
	override public func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
		if let bundle = Bundle.main.localizedBundle {
			return bundle.localizedString(forKey: key, value: value, table: tableName)
		}
		return super.localizedString(forKey: key, value: value, table: tableName)
	}
}


public extension Bundle {
	private struct AssociatedKeys {
		static var b = "LocalizedMainBundle"
	}

	fileprivate var localizedBundle: Bundle? {
		get {
			//	warning: Make sure this object you are fetching really exists
			return objc_getAssociatedObject(self, &AssociatedKeys.b) as? Bundle
		}
	}

	///
	public static func enforceLanguage(_ code: String) {
		guard let path = Bundle.main.path(forResource: code, ofType: "lproj") else { return }
		guard let bundle = Bundle(path: path) else { return }

		//	prepare translated bundle for chosen language and
		//	save it as property of the Bundle.main
		objc_setAssociatedObject(Bundle.main, &AssociatedKeys.b, bundle, .OBJC_ASSOCIATION_RETAIN)

		//	now override class of the main bundle (only once during the app lifetime)
		//	this way, `localizedString(forKey:value:table)` method in our subclass above will actually be called
		DispatchQueue.once(token: AssociatedKeys.b)  {
			object_setClass(Bundle.main, LocalizedBundle.self)
		}
	}
}
