//
//  ViewController.swift
//  LanguageSwitcher
//
//  Created by Aleksandar Vacić on 14.4.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

	@IBOutlet fileprivate weak var gbBtn: UIButton!
	@IBOutlet fileprivate weak var usBtn: UIButton!
	@IBOutlet fileprivate weak var frBtn: UIButton!
	@IBOutlet fileprivate weak var deBtn: UIButton!
	@IBOutlet fileprivate weak var rsBtn: UIButton!
	@IBOutlet fileprivate weak var ilBtn: UIButton!

	fileprivate weak var currentBtn: UIButton!

	@IBOutlet fileprivate weak var dateLabel: UILabel!
	@IBOutlet fileprivate weak var textField: UITextField!
	@IBOutlet fileprivate weak var convertedLabel: UILabel!

	@IBOutlet fileprivate var doneButton: UIButton!
	fileprivate var doneButtonBottomConstraint: NSLayoutConstraint?

	override func viewDidLoad() {
		super.viewDidLoad()

		setupUI()
		setupNotifications()
	}

	@IBAction func dismissKeyboard(_ sender: Any) {
		textField.resignFirstResponder()
	}

	@IBAction func changeLanguage(_ sender: UIButton) {
		if sender == currentBtn { return }

		currentBtn.backgroundColor = nil

		switch sender {
		case gbBtn, usBtn:
			Locale.updateLanguage(code: "en")
		case frBtn:
			Locale.updateLanguage(code: "fr")
		case deBtn:
			Locale.updateLanguage(code: "de")
		case rsBtn:
			Locale.updateLanguage(code: "sr")
		case ilBtn:
			Locale.updateLanguage(code: "he")
		default:
			break
		}

		currentBtn = sender
		currentBtn.backgroundColor = .white
	}
}

fileprivate extension ViewController {
	func setupNotifications() {
		let nc = NotificationCenter.default
		nc.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) {
			[weak self] notification in
			guard let `self` = self else { return }

			guard
				let userInfo = notification.userInfo,
				let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
			else {
				return
			}

			let frame = frameValue.cgRectValue
			if let lc = self.doneButtonBottomConstraint {
				lc.constant = -frame.size.height
			} else {
				self.doneButtonBottomConstraint = self.doneButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -frame.size.height)
				self.doneButtonBottomConstraint?.isActive = true
			}
			self.doneButton.alpha = 1
		}
	}

	func setupUI() {
		doneButton.alpha = 0
		doneButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(doneButton)
		self.doneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

		convertedLabel.text = nil
		textField.placeholder = NumberFormatter.moneyFormatter.string(for: 0)
		let now = Date()
		dateLabel.text = DateFormatter.dobFormatter.string(from: now)

		guard
			let languageCode = Locale.current.languageCode,
			let countryCode = Locale.current.regionCode?.lowercased()
		else { return }

		switch countryCode {
		case "gb":
			currentBtn = gbBtn
		case "us":
			currentBtn = usBtn
		case "fr":
			currentBtn = frBtn
		case "de":
			currentBtn = deBtn
		case "rs":	//	Serbia
			currentBtn = rsBtn
		case "il":	//	Israel
			currentBtn = ilBtn

		default:
			switch languageCode {
			case "en":
				currentBtn = gbBtn
			case "fr":
				currentBtn = frBtn
			case "de":
				currentBtn = deBtn
			case "sr":	//	Serbian
				currentBtn = rsBtn
			case "he":	//	Hebrew
				currentBtn = ilBtn

			default:
				print("Unsupported language and/or country, sorry!")
				return
			}
		}

		currentBtn.backgroundColor = .white
	}

	func convert(_ str: String) {
		guard let num = NumberFormatter.moneyFormatter.number(from: str)?.decimalValue else {
			convertedLabel.text = nil
			return
		}
		convertedLabel.text = NumberFormatter.moneyFormatter.string(for: num)
	}
}


extension ViewController: UITextFieldDelegate {

	func textFieldDidBeginEditing(_ textField: UITextField) {

	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		self.doneButton.alpha = 0
	}

	@IBAction func textFieldDidChangeValue(_ textField: UITextField) {
		guard let str = textField.text else {
			convertedLabel.text = nil
			return
		}
		convert(str)
	}
}
