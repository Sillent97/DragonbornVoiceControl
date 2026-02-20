#include "PCH.h"

#include "GameLanguage.h"

#include <algorithm>
#include <cctype>
#include <filesystem>
#include <fstream>
#include <string>

#include <ShlObj.h>

namespace
{
    std::string TrimLower(const std::string& raw)
    {
        auto is_space = [](unsigned char ch) { return std::isspace(ch) != 0; };
        std::string s = raw;
        s.erase(s.begin(), std::find_if(s.begin(), s.end(), [&](unsigned char ch) { return !is_space(ch); }));
        s.erase(std::find_if(s.rbegin(), s.rend(), [&](unsigned char ch) { return !is_space(ch); }).base(), s.end());
        std::transform(s.begin(), s.end(), s.begin(), [](unsigned char ch) {
            return static_cast<char>(std::tolower(ch));
        });
        return s;
    }

    std::string NormalizeKey(const std::string& raw)
    {
        std::string s = TrimLower(raw);
        std::string out;
        out.reserve(s.size());
        for (unsigned char ch : s) {
            if (std::isalnum(ch)) {
                out.push_back(static_cast<char>(ch));
            }
        }
        return out;
    }

    std::filesystem::path GetMyGamesDir()
    {
        wchar_t docs[MAX_PATH] = {};
        if (FAILED(SHGetFolderPathW(NULL, CSIDL_PERSONAL, NULL, 0, docs))) {
            return {};
        }
        return std::filesystem::path(docs) / L"My Games";
    }

    std::wstring GetEditionFolderName()
    {
        if (REL::Module::IsVR()) {
            return L"Skyrim VR";
        }
        if (REL::Module::IsAE()) {
            return L"Skyrim Special Edition";
        }
        return L"Skyrim Special Edition";
    }

    std::string ReadLanguageFromIni(const std::filesystem::path& path)
    {
        std::ifstream f(path);
        if (!f.is_open()) {
            return {};
        }

        std::string line;
        std::string section;
        while (std::getline(f, line)) {
            std::string s = TrimLower(line);
            if (s.empty()) {
                continue;
            }
            if (s.rfind(";", 0) == 0 || s.rfind("#", 0) == 0) {
                continue;
            }
            if (s.front() == '[' && s.back() == ']') {
                section = s.substr(1, s.size() - 2);
                continue;
            }
            if (section != "general") {
                continue;
            }
            auto eq = s.find('=');
            if (eq == std::string::npos) {
                continue;
            }
            std::string key = s.substr(0, eq);
            std::string value = s.substr(eq + 1);
            key = TrimLower(key);
            value = TrimLower(value);
            if (key == "slanguage") {
                return value;
            }
        }

        return {};
    }

    std::string ReadLanguageFromIniFiles()
    {
        auto myGames = GetMyGamesDir();
        if (myGames.empty()) {
            return {};
        }

        auto base = myGames / GetEditionFolderName();
        if (base.empty()) {
            return {};
        }

        auto custom = base / L"SkyrimCustom.ini";
        auto ini = base / L"Skyrim.ini";

        std::string value = ReadLanguageFromIni(custom);
        if (!value.empty()) {
            return value;
        }
        return ReadLanguageFromIni(ini);
    }
}

namespace DragonbornVoiceControl
{
    GameLanguageInfo DetectGameLanguage()
    {
        GameLanguageInfo info;

        std::string raw;
        auto ini = RE::INISettingCollection::GetSingleton();
        if (ini) {
            if (auto setting = ini->GetSetting("sLanguage:General")) {
                const char* s = setting->GetString();
                if (s && *s) {
                    raw = s;
                }
            }
        }

        std::string iniRaw = ReadLanguageFromIniFiles();
        if (!iniRaw.empty()) {
            raw = iniRaw;
        }

        if (raw.empty()) {
            return info;
        }

        info.raw = raw;
        const std::string key = NormalizeKey(info.raw);

        if (key == "en" || key == "english") {
            info.code = "en";
            info.label = "english";
        } else if (key == "ru" || key == "russian") {
            info.code = "ru";
            info.label = "russian";
        } else if (key == "fr" || key == "french") {
            info.code = "fr";
            info.label = "french";
        } else if (key == "it" || key == "italian") {
            info.code = "it";
            info.label = "italian";
        } else if (key == "de" || key == "german" || key == "deutsch") {
            info.code = "de";
            info.label = "german";
        } else if (key == "es" || key == "spanish" || key == "espanol") {
            info.code = "es";
            info.label = "spanish";
        } else if (key == "pl" || key == "polish" || key == "polski") {
            info.code = "pl";
            info.label = "polish";
        } else if (key == "ja" || key == "japanese") {
            info.code = "ja";
            info.label = "japanese";
        } else if (key == "cn" || key == "zh" || key == "zhcn" || key == "zhhant" ||
                   key == "chinese" || key == "chinesetraditional" || key == "traditionalchinese") {
            info.code = "cn";
            info.label = "traditional_chinese";
        }

        return info;
    }
}
