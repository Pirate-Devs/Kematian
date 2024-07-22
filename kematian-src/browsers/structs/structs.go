package structs

type Browser struct {
	IsChromium  bool       `json:"ischromium"`
	Path        string     `json:"path"`
	LocalState  string     `json:"localstate"`
	ProfilePath string     `json:"profilepath"`
	Profiles    []Profiles `json:"profiles"`
}

type Profiles struct {
	NameAndPath string `json:"nameandpath"`
	WebData     string `json:"webdata,omitempty"`
	Cookies     string `json:"cookies"`
	History     string `json:"history"`
	LoginData   string `json:"logindata"`
	Bookmarks   string `json:"bookmarks"`
}

type CookiesOutput struct {
	BrowserName string
	Cookies     string
}
