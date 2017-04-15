//
//  Locale-App.swift
//  Radiant Tap Essentials
//
//  Copyright © 2016 Aleksandar Vacić, Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

final class AppLocale {
	private(set) var original: Locale
	private init() {
		original = Locale.autoupdatingCurrent
	}
	static var shared = AppLocale()


	///	Builds as specific LocaleIdentifier as your app needs
	private var localeIdentifier: String {
		//	start with whatever is used by iOS
		var comps = NSLocale.components(fromLocaleIdentifier: original.identifier)

		//	Note: if customer has not yet chosen anything custom,
		//	then it may make sense to default to primary language on his device

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
		}

		//	WARNING:
		//	user language must be one of the ones available in the app
		//	so make sure that whatever ends up as result, it actually has its own .lproj file
		//	this is good moment to make sanity checks

		//	finally return all of those settings combined
		let identifier = NSLocale.localeIdentifier(fromComponents: comps)
		return identifier
	}

	class var identifier: String { return shared.localeIdentifier }
}

extension NSLocale {

	///	This is used to override `current`. It uses `AppLocale.identifier`
	class var app: Locale {
		return Locale(identifier: AppLocale.identifier)
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
	///	This should be set to the language you used as Base localization
	fileprivate static var fallbackLanguageCode: String { return "en" }


	///
	fileprivate static func enforceLanguage(code: String) {
		//	save this so it's automatically loaded on next cold start of the app
		UserDefaults.languageCode = code

		//	load translated bundle for the chosen language
		Bundle.enforceLanguage(code)
	}


	///	Call this from wherever in the app's UI you are allowing the customer to change the language.
	///	The supplied value of `code` must be proper code acceptable by NSLocale.languageCode
	static func updateLanguage(code: String) {
		enforceLanguage(code: code)

		//	update all cached stuff in the app
		DateFormatter.resetupCashed()
		NumberFormatter.resetupCashed()

		//	post notification so the app views can update themselves
		NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: NSLocale.app)
	}


	///	Call this as early as possible in application lifecycle, say in application(_:willFinishLaunchingWithOptions:)
	static func setupInitialLanguage() {
		let _ = AppLocale.shared

		if let languageCode = UserDefaults.languageCode {
			enforceLanguage(code: languageCode)

			//	override NSLocale.current
			NSLocale.swizzle(selector: #selector(getter: NSLocale.current))
			return;
		}

		let code = NSLocale.app.languageCode ?? fallbackLanguageCode

		//	enforce throughout the app
		Locale.enforceLanguage(code: code)

		//	override NSLocale.current
		NSLocale.swizzle(selector: #selector(getter: NSLocale.current))

		//	post notification so the app views can update themselves
		NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: NSLocale.app)
	}
}
