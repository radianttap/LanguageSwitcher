//
//  Formatters.swift
//  LanguageSwitcher
//
//  Created by Aleksandar Vacić on 14.4.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation


extension NumberFormatter {

	static let moneyFormatter: NumberFormatter = {
		let nf = NumberFormatter()
		nf.generatesDecimalNumbers = true
		nf.maximumFractionDigits = 2
		nf.minimumFractionDigits = 2
		nf.numberStyle = .decimal
		return nf
	}()

	static func resetupCashed() {
		moneyFormatter.locale = Locale.current
	}
}


extension DateFormatter {

	static let dobFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .full
		return df
	}()

	static func resetupCashed() {
		dobFormatter.locale = Locale.current
	}
}
