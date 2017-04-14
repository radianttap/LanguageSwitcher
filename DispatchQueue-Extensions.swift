//
//  DispatchQueue-Extensions.swift
//  Radiant Tap Essentials
//
//  Copyright © 2016 Aleksandar Vacić, Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

public extension DispatchQueue {
	private static var onceTracker = [String]()

	///	Execute the given `block` only once during app's lifecycle
	public class func once(token: String, block: (Void) -> Void) {
		objc_sync_enter(self);
		defer {
			objc_sync_exit(self)
		}

		if onceTracker.contains(token) { return }
		onceTracker.append(token)
		block()
	}
}
