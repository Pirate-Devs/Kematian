// Credits to https://github.com/tedburke/CommandCam
#include <dshow.h>
#include <iostream>
#include <ctime>
#include <string.h>
#import "qedit.dll" raw_interfaces_only named_guids

EXTERN_C const CLSID CLSID_NullRenderer;
EXTERN_C const CLSID CLSID_SampleGrabber;
HRESULT hr;
ICreateDevEnum* pDevEnum = NULL;
IEnumMoniker* pEnum = NULL;
IMoniker* pMoniker = NULL;
IPropertyBag* pPropBag = NULL;
IGraphBuilder* pGraph = NULL;
ICaptureGraphBuilder2* pBuilder = NULL;
IBaseFilter* pCap = NULL;
IBaseFilter* pSampleGrabberFilter = NULL;
DexterLib::ISampleGrabber* pSampleGrabber = NULL;
IBaseFilter* pNullRenderer = NULL;
IMediaControl* pMediaControl = NULL;
char* pBuffer = NULL;


void exit_message(const char* error_message, int error)
{
	fprintf(stderr, error_message);
	fprintf(stderr, "\n");
	if (pBuffer != NULL) delete[] pBuffer;
	if (pMediaControl != NULL) pMediaControl->Release();
	if (pNullRenderer != NULL) pNullRenderer->Release();
	if (pSampleGrabber != NULL) pSampleGrabber->Release();
	if (pSampleGrabberFilter != NULL)
	pSampleGrabberFilter->Release();
	if (pCap != NULL) pCap->Release();
	if (pBuilder != NULL) pBuilder->Release();
	if (pGraph != NULL) pGraph->Release();
	if (pPropBag != NULL) pPropBag->Release();
	if (pMoniker != NULL) pMoniker->Release();
	if (pEnum != NULL) pEnum->Release();
	if (pDevEnum != NULL) pDevEnum->Release();
	CoUninitialize();
	exit(error);
}
int main(int argc, char** argv)
{
	int snapshot_delay = 0;
	int show_preview_window = 0;
	int list_devices = 0;
	int device_number = 1;
	char device_name[100];
	char filename[100];
	char char_buffer[100];
	strcpy(device_name, "");
	strcpy(filename, "image.bmp");
	fprintf(stderr, "\n");
	fprintf(stderr, "[!] Starting Webcam Grabber\n");
	fprintf(stderr, "[!] Loading custom version by Somali-Devs\n");
	int n = 1;
	
	while (n < argc)
	{
		if (strcmp(argv[n], "/preview") == 0)
		{
		 show_preview_window = 1;
		}
		else if (strcmp(argv[n], "/devlist") == 0)
		{
		 list_devices = 1;
		}
		else if (strcmp(argv[n], "/filename") == 0)
		{
			if (++n < argc)
			{

				strcpy(char_buffer, argv[n]);
				if (char_buffer[0] == '"')
				{
				 strncat(filename, char_buffer, strlen(char_buffer) - 2);
				}
				else
				{
					strcpy(filename, char_buffer);
					char* ts = strstr(filename, "{TS}");
					if (ts != 0) {
						char temp[100];
						time_t rawtime;
						struct tm* timeinfo;
						size_t  dateLen;
						time(&rawtime);
						timeinfo = localtime(&rawtime);
						strcpy(temp, ts + strlen("{TS}"));
						dateLen = strftime(ts, 80, "%Y-%m-%d_%H-%M-%S", timeinfo);
						strcpy(ts + dateLen, temp);
						int i = 4;
					}
				}
			}
			else exit_message("Error: no filename specified", 1);
		}
		else if (strcmp(argv[n], "/delay") == 0)
		{
			if (++n < argc) snapshot_delay = atoi(argv[n]);
			else exit_message("Error: invalid delay specified", 1);
			if (snapshot_delay <= 0)
			exit_message("Error: invalid delay specified", 1);
		}
		else if (strcmp(argv[n], "/devnum") == 0)
		{
			if (++n < argc) device_number = atoi(argv[n]);
			else exit_message("Error: invalid device number", 1);
			if (device_number <= 0)
			exit_message("Error: invalid device number", 1);
		}
		else if (strcmp(argv[n], "/devname") == 0)
		{
			if (++n < argc)
			{
				strcpy(char_buffer, argv[n]);
				if (char_buffer[0] == '"')
				{
				 strncat(device_name, char_buffer, strlen(char_buffer) - 2);
				}
				else
				{
				 strcpy(device_name, char_buffer);
				}
				device_number = 0;
			}
			else exit_message("Error: invalid device name", 1);
		}
		else
		{
		 fprintf(stderr, "Unrecognised option: %s\n", argv[n]);
		 exit_message("", 1);
		}
		n++;
	}
	hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
	if (hr != S_OK)
	exit_message("Could not initialise COM", 1);
	hr = CoCreateInstance(CLSID_FilterGraph, NULL,
	CLSCTX_INPROC_SERVER, IID_IGraphBuilder,
	(void**)&pGraph);
	if (hr != S_OK)
	exit_message("Could not create filter graph", 1);
	hr = CoCreateInstance(CLSID_CaptureGraphBuilder2, NULL,
	CLSCTX_INPROC_SERVER, IID_ICaptureGraphBuilder2,
	(void**)&pBuilder);
	if (hr != S_OK)
	exit_message("Could not create capture graph builder", 1);
	hr = pBuilder->SetFiltergraph(pGraph);
	if (hr != S_OK)
	exit_message("Could not attach capture graph builder to graph", 1);
	hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL,
	CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&pDevEnum));
	if (hr != S_OK)
	exit_message("Could not crerate system device enumerator", 1);
	hr = pDevEnum->CreateClassEnumerator(
	CLSID_VideoInputDeviceCategory, &pEnum, 0);
	if (hr != S_OK)
	exit_message("No video devices found", 1);
	if (list_devices != 0)
	{
		fprintf(stderr, "Available capture devices:\n");
		n = 0;
		while (1)
		{
			hr = pEnum->Next(1, &pMoniker, NULL);
			if (hr == S_OK)
			{
			 n++;
			 hr = pMoniker->BindToStorage(0, 0, IID_PPV_ARGS(&pPropBag));
			 VARIANT var;
			 VariantInit(&var);
			 hr = pPropBag->Read(L"FriendlyName", &var, 0);
			 fprintf(stderr, "  %d. %ls\n", n, var.bstrVal);
			 VariantClear(&var);
			}
			else
			{
			 if (n == 0) exit_message("[!] No devices found", 0);
			 else exit_message("", 0);
			}
		}
	}

	VARIANT var;
	n = 0;
	while (1)
	{
		hr = pEnum->Next(1, &pMoniker, NULL);
		if (hr == S_OK)
		{
		  n++;
		}
		else
		{
			if (device_number == 0)
			{
			  fprintf(stderr, "[!] Video capture device %s not found\n", device_name);
			}
			else
			{
			  fprintf(stderr,"[!] Video capture device %d not found\n", device_number);
			}
			exit_message("", 1);
		}

		if (device_number == 0)
		{
			hr = pMoniker->BindToStorage(0, 0, IID_PPV_ARGS(&pPropBag));
			if (hr == S_OK)
			{
			 VariantInit(&var);
			 hr = pPropBag->Read(L"FriendlyName", &var, 0);
			 sprintf(char_buffer, "%ls", var.bstrVal);
			 VariantClear(&var);
			 pPropBag->Release();
			 pPropBag = NULL;
			 if (strcmp(device_name, char_buffer) == 0) break;
			}
			else
			{
			 exit_message("[!] Error getting device names", 1);
			}
		}
		else if (n >= device_number) break;
	}

	hr = pMoniker->BindToStorage(0, 0, IID_PPV_ARGS(&pPropBag));
	VariantInit(&var);
	hr = pPropBag->Read(L"FriendlyName", &var, 0);
	fprintf(stderr, "[!] Capture device: %ls\n", var.bstrVal);
	VariantClear(&var);
	hr = pMoniker->BindToObject(0, 0,
	IID_IBaseFilter, (void**)&pCap);
	if (hr != S_OK) exit_message("Could not create capture filter", 1);
	hr = pGraph->AddFilter(pCap, L"Capture Filter");
	if (hr != S_OK) exit_message("Could not add capture filter to graph", 1);
	hr = CoCreateInstance(CLSID_SampleGrabber, NULL,
	CLSCTX_INPROC_SERVER, IID_IBaseFilter,
	(void**)&pSampleGrabberFilter);
	if (hr != S_OK)
	exit_message("Could not create Sample Grabber filter", 1);
	hr = pSampleGrabberFilter->QueryInterface(
	DexterLib::IID_ISampleGrabber, (void**)&pSampleGrabber);
	if (hr != S_OK)
	exit_message("Could not get ISampleGrabber interface to sample grabber filter", 1);
	hr = pSampleGrabber->SetBufferSamples(TRUE);
	if (hr != S_OK)
	exit_message("Could not enable sample buffering in the sample grabber", 1);
	AM_MEDIA_TYPE mt;
	ZeroMemory(&mt, sizeof(AM_MEDIA_TYPE));
	mt.majortype = MEDIATYPE_Video;
	mt.subtype = MEDIASUBTYPE_RGB24;
	hr = pSampleGrabber->SetMediaType((DexterLib::_AMMediaType*)&mt);
	if (hr != S_OK)
	exit_message("Could not set media type in sample grabber", 1);
	hr = pGraph->AddFilter(pSampleGrabberFilter, L"SampleGrab");
	if (hr != S_OK)
	exit_message("Could not add Sample Grabber to filter graph", 1);
	hr = CoCreateInstance(CLSID_NullRenderer, NULL,
	CLSCTX_INPROC_SERVER, IID_IBaseFilter,
	(void**)&pNullRenderer);
	if (hr != S_OK)
	exit_message("Could not create Null Renderer filter", 1);
	hr = pGraph->AddFilter(pNullRenderer, L"NullRender");
	if (hr != S_OK)
	exit_message("Could not add Null Renderer to filter graph", 1);
	hr = pBuilder->RenderStream(
	&PIN_CATEGORY_CAPTURE, &MEDIATYPE_Video,
	pCap, pSampleGrabberFilter, pNullRenderer);
	if (hr != S_OK)
	exit_message("Could not render capture video stream", 1);

	if (show_preview_window > 0)
	{
	 hr = pBuilder->RenderStream(
	 &PIN_CATEGORY_PREVIEW, &MEDIATYPE_Video,
	 pCap, NULL, NULL);
	 if (hr != S_OK && hr != VFW_S_NOPREVIEWPIN)
	 exit_message("Could not render preview video stream", 1);
	}
	hr = pGraph->QueryInterface(IID_IMediaControl,
	(void**)&pMediaControl);
	if (hr != S_OK) exit_message("Could not get media control interface", 1);

	while (1)
	{
		hr = pMediaControl->Run();
		if (hr == S_OK) break;
		if (hr == S_FALSE) continue;
		fprintf(stderr, "Error: %u\n", hr);
		exit_message("Could not run filter graph", 1);
	}
	 Sleep(snapshot_delay);
	 long buffer_size = 0;
	 while (1)
	{
	hr = pSampleGrabber->GetCurrentBuffer(&buffer_size, NULL);
	 if (hr == S_OK && buffer_size != 0) break;
	 if (hr != S_OK && hr != VFW_E_WRONG_STATE)
	 exit_message("Could not get buffer size", 1);
	}
	pMediaControl->Stop();
	pBuffer = new char[buffer_size];
	if (!pBuffer)
	exit_message("Could not allocate data buffer for image", 1);
	hr = pSampleGrabber->GetCurrentBuffer(
	&buffer_size, (long*)pBuffer);
	if (hr != S_OK)
	exit_message("Could not get buffer data from sample grabber", 1);
	hr = pSampleGrabber->GetConnectedMediaType(
	(DexterLib::_AMMediaType*)&mt);
	if (hr != S_OK) exit_message("Could not get media type", 1);
	VIDEOINFOHEADER* pVih = NULL;
	if ((mt.formattype == FORMAT_VideoInfo) &&
	(mt.cbFormat >= sizeof(VIDEOINFOHEADER)) &&
	(mt.pbFormat != NULL))
	{
		pVih = (VIDEOINFOHEADER*)mt.pbFormat;
		fprintf(stderr, "[!] Capture resolution: %dx%d\n",
		pVih->bmiHeader.biWidth,
		pVih->bmiHeader.biHeight);
		long cbBitmapInfoSize = mt.cbFormat - SIZE_PREHEADER;
		BITMAPFILEHEADER bfh;
		ZeroMemory(&bfh, sizeof(bfh));
		bfh.bfType = 'MB';
		bfh.bfSize = sizeof(bfh) + buffer_size + cbBitmapInfoSize;
		bfh.bfOffBits = sizeof(BITMAPFILEHEADER) + cbBitmapInfoSize;
		HANDLE hf = CreateFile(filename, GENERIC_WRITE,
		FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, 0, NULL);
		if (hf == INVALID_HANDLE_VALUE)
		exit_message("Error opening output file", 1);
		DWORD dwWritten = 0;
		WriteFile(hf, &bfh, sizeof(bfh), &dwWritten, NULL);
		WriteFile(hf, HEADER(pVih),
		cbBitmapInfoSize, &dwWritten, NULL);
		WriteFile(hf, pBuffer, buffer_size, &dwWritten, NULL);
		CloseHandle(hf);
	}
	else
	{
	 exit_message("Wrong media type", 1);
	}

	if (mt.cbFormat != 0)
	{
	 CoTaskMemFree((PVOID)mt.pbFormat);
	 mt.cbFormat = 0;
	 mt.pbFormat = NULL;
	}
	if (mt.pUnk != NULL)
	{
	 mt.pUnk->Release();
	 mt.pUnk = NULL;
	}
	fprintf(stderr, "[!] Captured image to %s", filename);
	exit_message("", 0);
}
