#include "PCH.h"

#include "Paths.h"

#include <Shlwapi.h>

namespace
{
    std::wstring GetThisModulePath()
    {
        wchar_t path[MAX_PATH]{};
        HMODULE hm = nullptr;
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           (LPCWSTR)&GetThisModulePath, &hm);
        GetModuleFileNameW(hm, path, MAX_PATH);
        return path;
    }
}

namespace DragonbornVoiceControl
{
    std::wstring GetDataDirFromPlugin()
    {
        auto dllPath = GetThisModulePath();

        wchar_t tmp[MAX_PATH];
        wcsncpy_s(tmp, dllPath.c_str(), _TRUNCATE);
        PathRemoveFileSpecW(tmp);
        PathRemoveFileSpecW(tmp);
        PathRemoveFileSpecW(tmp);
        return tmp;
    }

    std::wstring GetIniPathFromPlugin()
    {
        auto dataDir = GetDataDirFromPlugin();
        std::wstring ini = dataDir;
        ini += L"\\SKSE\\Plugins\\DVCRuntime.ini";
        return ini;
    }
}
