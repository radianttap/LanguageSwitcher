//
//  Locale-App.swift
//  Radiant Tap Essentials
//
//  Copyright © 2016 Aleksandar Vacić, Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

extension NSLocale {

	///	Builds as specific LocaleIdentifier as your app needs
	class var appIdentifier: String {
		//	start with whatever is used by iOS
		let cur = NSLocale.autoupdatingCurrent
		var comps = NSLocale.components(fromLocaleIdentifier: cur.identifier)

		//	then load your app-level overrides
//		for (key, value) in AppConfig.localeOverrides {
//			comps[key] = value
//		}

		//	then potentially load customer-account-level overrides (from say back-end API)
//		for (key, value) in Customer.localeOverrides {
//			comps[key] = value
//		}

		//	then override the language with current in-app choice
		if let languageCode = UserDefaults.languageCode {
			comps[NSLocale.Key.languageCode.rawValue] = languageCode
		} else {
			//	if customer has not yet chosen anything custom, 
			//	then default to primary language on his device
			//	WARNING:
			//	user language must be one of the ones available in the app
			//	so make sure that whatever ends up as result, it actually has its own .lproj file
			if let userPreferredLanguage = cur.languageCode {
				comps[NSLocale.Key.languageCode.rawValue] = userPreferredLanguage
			}
		}

		//	finally return all of those settings combined
		let identifier = localeIdentifier(fromComponents: comps)
		return identifier
	}


	///	This is used to to override `current` and `autoupdatingCurrent`
	///	using `appIdentifier`
	class var app: Locale {
		return Locale(identifier: appIdentifier)
	}


	fileprivate static func swizzle(selector: Selector) {
		let originalSelector = selector
		let swizzledSelector = #selector(getter: NSLocale.app)
		let originalMethod = class_getClassMethod(self, originalSelector)
		let swizzledMethod = class_getClassMethod(self, swizzledSelector)
		method_exchangeImplementations(originalMethod, swizzledMethod)
	}
}

extension Locale {
	fileprivate static var fallbackLanguageCode: String { return "en" }


	///
	fileprivate static func enforceLanguage(code: String) {
		//	save this so it's automatically loaded on next cold start of the app
		UserDefaults.languageCode = code

		//	load translated bundle for the chosen language
		Bundle.enforceLanguage(code)

		//	override NSLocale.current
		NSLocale.swizzle(selector: #selector(getter: NSLocale.current))
		//	override NSLocale.autoupdatingCurrent
		NSLocale.swizzle(selector: #selector(getter: NSLocale.autoupdatingCurrent))
	}


	///	Call this from wherever in the app's UI you are allowing the customer to change the language.
	///	The supplied value of `code` must be proper code acceptable by NSLocale.languageCode
	static func updateLanguage(code: String) {
		enforceLanguage(code: code)

		//	post notification so the app views can update themselves
		NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: NSLocale.app)
	}


	///	Call this as early as possible in application lifecycle, say in application(_:willFinishLaunchingWithOptions:)
	static func setupInitialLanguage() {
		if let languageCode = UserDefaults.languageCode {
			enforceLanguage(code: languageCode)
			return;
		}

		let code = NSLocale.app.languageCode ?? fallbackLanguageCode

		//	enforce throughout the app
		Locale.enforceLanguage(code: code)

		//	post notification so the app views can update themselves
		NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: NSLocale.app)
	}
}
