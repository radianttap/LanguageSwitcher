//
//  AppDelegate.swift
//  LanguageSwitcher
//
//  Created by Aleksandar Vacić on 14.4.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

		Locale.setupInitialLanguage()
		setupNotifications()

		return true
	}

	fileprivate func setupNotifications() {
		let nc = NotificationCenter.default
		nc.addObserver(forName: NSLocale.currentLocaleDidChangeNotification, object: nil, queue: OperationQueue.main) {
			[weak self] notification in
			guard let `self` = self else { return }

			//	this is the only way I know of to force-reload storyboard-based stuff
			//	limitations like this is one of the main reason why I avoid basing entire app on them
			//	since doing this essentialy resets the app and all user-generated context and data

			let sb = UIStoryboard(name: "Main", bundle: nil)
			let vc = sb.instantiateInitialViewController()
			self.window?.rootViewController = vc
		}
	}
}

