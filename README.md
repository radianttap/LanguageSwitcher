# LanguageSwitcher
Example how to switch iOS app's language on-the-fly, instantly

![](language-switcher-50pct.gif)

iOS – and Apple OSs in general – have excellent I18N support. You more or less don't have to worry about date and number formatting as long as you are following the rules. The essential rules are:

* all translations are prepared beforehand and compiled into the app
* language choice is done outside your app, in system' Settings

Fairly often, I have requests from clients to implement in-app language change, which should (at least) instantly translate the app. There is no API support in iOS frameworks for this.

It's not impossible though.

## Force-load correct set of translations

First issue is that all the translations are kept inside _LANGUAGE_CODE.lproj_ folders, like `en.lproj`, `fr.lproj` etc. 

When your app starts, iOS looks into `UserDefaults.standard.value(forKey: "AppleLanguages")` value and loads the corresponding translations from the `.lproj` folder. It processes all the `.xib` and `.storyboard` files plus makes an internal dictionary (or something similar) that `NSLocalizedString()` is using to load appropriate string.

This is done at the app start and there is no way I know of to force-change the language without restarting the app itself. 

*So we need to cheat and since iOS runtime is dynamism heaven enabled by Objective-C, we can actually do that.*

Maxim Bilan found [neat solution](https://www.factorialcomplexity.com/blog/2015/01/28/how-to-change-localization-internally-in-your-ios-application.html) which I have [converted into Swift 3](https://github.com/radianttap/LanguageSwitcher/blob/master/Bundle-AppLocale.swift):

* subclass Bundle and override its `localizedString(forKey…)` method to check for `Bundle.main.localizedBundle`
* force-change the Class of the Bundle.main to be that subclass so our method is called instead of default one _(thanks Objective-C!)_
* when app's language change is initiated somewhere in the app, load the Main bundle again but with appropriate .lproj 
* saved that loaded bundle as Bundle.main.localizedBundle

Things now work on their own. This will be enough to instantly translate the app *if* your app is using `LocalizedString()` only. If your strings are in IB files though, then you need to force-reload those files.

In the demo app, I am pushing the notification that informs everyone about Locale change and AppDelegate is responding to that by reloading the `window.rootController`:

```swift
let nc = NotificationCenter.default
nc.addObserver(forName: NSLocale.currentLocaleDidChangeNotification, 
               object: nil, 
               queue: OperationQueue.main) {
	[weak self] notification in
	guard let `self` = self else { return }

	let sb = UIStoryboard(name: "Main", bundle: nil)
	let vc = sb.instantiateInitialViewController()
	self.window?.rootViewController = vc
}
```

## Overriding Locale.current

Reloading string translations is not enough, though. Large number of system-wide methods on various types is consulting `Locale.current` (or rather `Locale.autoupdatingCurrent`..?) to perform its function. 

Example: say you have a `UITextField` for number input. You set its keyboard to DecimalPad which display decimal separator as lower left button. The caption and the actual character that's a result of the tap is the value of `decimalSeparator` property on the currently active Locale.

Further, if you try to convert `textField.text` to a `Double` or `Decimal`, conversion will accept only that one value as valid decimal separator. So if you've entered "5,15" and your `localeIdentifier` is "en_US", that will be converted to `0`, not `5.15`. Bummer. While this is solvable issue by re-setting cached Formatters, the keyboard issue mentioned above is not. 

Thus you need to create your own custom keyboard (yuck!) or…[you can swizzle](https://github.com/apple/swift-evolution/blob/master/proposals/0064-property-selectors.md) `NSLocale.current` property. _(Thanks again, Objective-C!)_

```swift
extension NSLocale {
fileprivate static func swizzle(selector: Selector) {
	let originalSelector = selector
	let swizzledSelector = #selector(getter: NSLocale.app)
	let originalMethod = class_getClassMethod(self, originalSelector)
	let swizzledMethod = class_getClassMethod(self, swizzledSelector)
	method_exchangeImplementations(originalMethod, swizzledMethod)
}
}
…

NSLocale.swizzle(selector: #selector(getter: NSLocale.current))
```

`NSLocale.app` is my [own custom Locale](https://github.com/radianttap/LanguageSwitcher/blob/master/Locale-App.swift) I build in any way I need. I start with system's original value for `autoupdatingCurrent` and then add and/or replace components using whatever app-level or user-level settings I have.

Swizzling needs to be done only once, as early as possible in app's lifecycle. 

## Demo

Look into the `localize()` method in [demo's ViewController](https://github.com/radianttap/LanguageSwitcher/blob/master/LanguageSwitcher/ViewController.swift). This is actually my preferred method to handle instant translations as there's no loss of user context. It's more work but it leads to better customer experience. 

If you cache your DateFormatter and NumberFormatter instances - as you certainly should - then on language change you need to [make sure to re-set up](https://github.com/radianttap/LanguageSwitcher/blob/master/LanguageSwitcher/Formatters.swift) Locale and dateFormat values.

* LanguageSwitcher project uses `Main.storyboard` and shows how you can "restart" the app and thus render the changes.
* LanguageSwitcher2 project builds the UI stack in `AppDelegate` and shows how you can keep the user context and use notifications to inform all the views to re-populate their content using `NSLocalizedString()`


### Issues

There's a non-critical issue with the keyboard: when the keyboard is shown, iOS will cache that generated view. Thus if you do this sequence:

- open the app
- make sure English is shown
- tap the text field so the keyboard appears (you can see the `.` shown as decimal separator)
- dismiss it
- switch to Serbian (which uses `,` as decimal separator
- tap the text field again

You can see that keyboard view still shows the `.` but if you tap it, it will correctly enter `,`. Hence it's annoyance at best. 

I'm not aware of any way to force-clear the keyboard cache in iOS. If you do, [please let me know](https://twitter.com/radiantav).
