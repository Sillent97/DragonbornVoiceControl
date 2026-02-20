#pragma once
#include <string>

class ServerLauncher
{
public:
    static ServerLauncher& Get();

    bool StartFromIni(const std::wstring& dataDir, const std::wstring& iniPath);
    void Stop();

private:
    ServerLauncher() = default;

    bool StartProcess(const std::wstring& pythonExe,
                      const std::wstring& scriptPath,
                      const std::wstring& args,
                      const std::wstring& workingDir,
                      bool newConsole);

    void* _procHandle = nullptr; // HANDLE
    void* _jobHandle  = nullptr; // HANDLE
    unsigned long _procId = 0;
};
