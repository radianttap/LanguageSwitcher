//
//  ViewController.swift
//  LanguageSwitcher2
//
//  Created by Aleksandar Vacić on 27.4.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

	@IBOutlet fileprivate weak var gbBtn: UIButton!
	@IBOutlet fileprivate weak var frBtn: UIButton!
	@IBOutlet fileprivate weak var deBtn: UIButton!
	@IBOutlet fileprivate weak var rsBtn: UIButton!
	@IBOutlet fileprivate weak var ilBtn: UIButton!

	fileprivate weak var currentBtn: UIButton?

	@IBOutlet fileprivate weak var dateLabel: UILabel!
	@IBOutlet fileprivate weak var textField: UITextField!
	@IBOutlet fileprivate weak var convertedLabel: UILabel!
	@IBOutlet fileprivate weak var arrowLabel: UILabel!

	@IBOutlet fileprivate var doneButton: UIButton!
	fileprivate var doneButtonBottomConstraint: NSLayoutConstraint?

	@IBOutlet fileprivate var resetButton: UIBarButtonItem!


	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var introLabel: UILabel!
	@IBOutlet weak var footnoteLabel: UILabel!
	@IBOutlet weak var captionLabel: UILabel!

	fileprivate var amount: Decimal?


	override func viewDidLoad() {
		super.viewDidLoad()

		setupUI()
		setupNotifications()

		localize()
		setupDynamicUI()
	}

	fileprivate func setupUI() {
		doneButton.alpha = 0
		doneButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(doneButton)
		self.doneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

		convertedLabel.text = nil

		guard let languageCode = Locale.current.languageCode else { return }

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
			guard let regionCode = Locale.current.regionCode?.lowercased() else { return }

			switch regionCode {
			case "gb":
				currentBtn = gbBtn
			case "fr":
				currentBtn = frBtn
			case "de":
				currentBtn = deBtn
			case "rs":	//	Serbia
				currentBtn = rsBtn
			case "il":	//	Israel
				currentBtn = ilBtn

			default:
				print("Unsupported language and/or country, sorry!")
				return
			}
		}

		currentBtn?.backgroundColor = .white
	}
}

fileprivate extension ViewController {
	func setupNotifications() {
		let nc = NotificationCenter.default

		//	when keyboard appears, make sure to
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


		nc.addObserver(forName: NSLocale.currentLocaleDidChangeNotification, object: nil, queue: OperationQueue.main) {
			[weak self] notification in
			guard let `self` = self else { return }

			//	layout pass..?
			self.view.layoutIfNeeded()
			self.currentBtn?.backgroundColor = .clear

			//	translate stuff
			self.localize()
			self.setupUI()
			self.setupDynamicUI()
		}
	}

	func localize() {
		titleLabel.text = NSLocalizedString("titleLabel", comment: "")
		introLabel.text = NSLocalizedString("introLabel", comment: "")
		footnoteLabel.text = NSLocalizedString("footnote", comment: "")
		doneButton.setTitle(NSLocalizedString("doneButton", comment: ""), for: .normal)
		arrowLabel.text = NSLocalizedString("arrowLabel", comment: "")
		captionLabel.text = NSLocalizedString("textFieldCaption", comment: "")
	}

	fileprivate func setupDynamicUI() {
		//	DYNAMIC stuff
		//	(anything that produces a result which should be localized)

		textField.placeholder = NumberFormatter.moneyFormatter.string(for: 0)
		let now = Date()
		dateLabel.text = DateFormatter.dobFormatter.string(from: now)

		resetButton.isEnabled = UserDefaults.languageCode != nil

		if let num = amount {
			textField.text = NumberFormatter.moneyFormatter.string(for: num)
		}
		textFieldDidChangeValue(textField)
	}
}


extension ViewController: UITextFieldDelegate {

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

	@IBAction func reset(_ sender: UIBarButtonItem) {
		Locale.clearInAppOverrides()
	}
}


fileprivate extension ViewController {
	//	MARK: Actions
	@IBAction func dismissKeyboard(_ sender: Any) {
		textField.resignFirstResponder()
	}

	@IBAction func changeLanguage(_ sender: UIButton) {
		if sender == currentBtn { return }

		currentBtn?.backgroundColor = nil

		switch sender {
		case gbBtn:
			Locale.updateLanguage(code: "en")
		case frBtn:
			Locale.updateLanguage(code: "fr")
		case deBtn:
			Locale.updateLanguage(code: "de")
		case rsBtn:
			Locale.updateLanguage(code: "sr")
		case ilBtn:
			Locale.updateLanguage(code: "he", regionCode: "il")
		default:
			break
		}

		currentBtn = sender
		currentBtn?.backgroundColor = .white
	}

	func convert(_ str: String) {
		guard let num = NumberFormatter.moneyFormatter.number(from: str)?.decimalValue else {
			amount = nil
			convertedLabel.text = nil
			return
		}
		amount = num
		convertedLabel.text = NumberFormatter.moneyFormatter.string(for: num)
	}
}
