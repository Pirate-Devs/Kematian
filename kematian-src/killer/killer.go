package killer

import (
	"fmt"
	"os"
	"syscall"
	"unsafe"
)

const (
	FILE_READ_ATTRIBUTES               = 0x80
	FILE_SHARE_READ                    = 1
	OPEN_EXISTING                      = 3
	FILE_FLAG_BACKUP_SEMANTICS         = 0x02000000
	FileProcessIdsUsingFileInformation = 47
	INVALID_HANDLE_VALUE               = ^syscall.Handle(0)
)

type IO_STATUS_BLOCK struct {
	Status      uintptr
	Information uintptr
}

type FILE_PROCESS_IDS_USING_FILE_INFORMATION struct {
	NumberOfProcessIdsInList int64
	ProcessIdList            [64]int64
}

func SeekAndDestroy(path string) {
	_, err := os.Stat(path)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	ntdll := syscall.NewLazyDLL("ntdll.dll")

	CreateFileW := kernel32.NewProc("CreateFileW")
	NtQueryInformationFile := ntdll.NewProc("NtQueryInformationFile")

	pointer_thing, err := syscall.UTF16PtrFromString(path)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	hFile, _, err := CreateFileW.Call(
		uintptr(unsafe.Pointer(pointer_thing)),
		FILE_READ_ATTRIBUTES,
		FILE_SHARE_READ,
		0,
		OPEN_EXISTING,
		FILE_FLAG_BACKUP_SEMANTICS,
		0,
	)
	if hFile == uintptr(INVALID_HANDLE_VALUE) {
		fmt.Printf("Error: %v\n", err)
		return
	}
	defer syscall.CloseHandle(syscall.Handle(hFile))

	iosb := IO_STATUS_BLOCK{}
	info := FILE_PROCESS_IDS_USING_FILE_INFORMATION{}

	status, _, _ := NtQueryInformationFile.Call(
		hFile,
		uintptr(unsafe.Pointer(&iosb)),
		uintptr(unsafe.Pointer(&info)),
		uintptr(unsafe.Sizeof(info)),
		FileProcessIdsUsingFileInformation,
	)
	if status != 0 {
		fmt.Printf("NtQueryInformationFile failed with status: %x\n", status)
		return
	}

	pidList := info.ProcessIdList[:info.NumberOfProcessIdsInList]

	current_process_id := os.Getpid()

	for _, pid := range pidList {
		process, err := os.FindProcess(int(pid))
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			continue
		}

		if pid == int64(current_process_id) {
			continue
		}

		err = process.Kill()
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			continue
		}
	}
}
