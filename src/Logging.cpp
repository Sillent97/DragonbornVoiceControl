#include "PCH.h"

#include "Logging.h"

#include <filesystem>
#include <optional>
#include <string>

#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>
#include <spdlog/spdlog.h>

#include <ShlObj.h>
#include <Shlwapi.h>

namespace
{
    const char* GetRuntimeName()
    {
        if (REL::Module::IsVR()) {
            return "Skyrim VR";
        }
        if (REL::Module::IsAE()) {
            return "Skyrim AE";
        }
        return "Skyrim SE";
    }

    std::string FormatSKSEVersion(std::uint32_t rawVersion)
    {
        const auto major = static_cast<std::uint8_t>((rawVersion >> 24) & 0xFF);
        const auto minor = static_cast<std::uint8_t>((rawVersion >> 16) & 0xFF);
        const auto patch = static_cast<std::uint8_t>((rawVersion >> 8) & 0xFF);
        const auto build = static_cast<std::uint8_t>(rawVersion & 0xFF);

        return std::to_string(major) + "." + std::to_string(minor) + "." +
               std::to_string(patch) + "." + std::to_string(build);
    }
}

namespace DragonbornVoiceControl
{
    void SetupLogging(const SKSE::LoadInterface* skse)
    {
        auto buildDocsSksePath = [&]() -> std::optional<std::filesystem::path> {
            wchar_t exePath[MAX_PATH] = {};
            if (!GetModuleFileNameW(NULL, exePath, MAX_PATH)) {
                return std::nullopt;
            }

            const wchar_t* exeName = PathFindFileNameW(exePath);
            std::wstring edition = L"Skyrim";

            if (exeName) {
                if (_wcsicmp(exeName, L"SkyrimVR.exe") == 0) {
                    edition = L"Skyrim VR";
                } else if (_wcsicmp(exeName, L"SkyrimSE.exe") == 0 || _wcsicmp(exeName, L"SkyrimSELauncher.exe") == 0) {
                    edition = L"Skyrim Special Edition";
                } else if (_wcsicmp(exeName, L"TESV.exe") == 0 || _wcsicmp(exeName, L"Skyrim.exe") == 0) {
                    edition = L"Skyrim";
                }
            }

            wchar_t docs[MAX_PATH] = {};
            if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_PERSONAL, NULL, 0, docs))) {
                std::filesystem::path p = docs;
                p /= "My Games";
                p /= edition;
                p /= "SKSE";

                std::error_code ec;
                if (std::filesystem::create_directories(p, ec) || std::filesystem::exists(p)) {
                    return p;
                }
            }

            return std::nullopt;
        };

        std::shared_ptr<spdlog::logger> log;
        std::optional<std::filesystem::path> logPath;

        if (auto docsPath = buildDocsSksePath()) {
            logPath = *docsPath / "DragonbornVoiceControl.log";
            auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(logPath->string(), true);
            log = std::make_shared<spdlog::logger>("global log", std::move(sink));
        } else if (auto logDir = SKSE::log::log_directory()) {
            logPath = *logDir / "DragonbornVoiceControl.log";
            auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(logPath->string(), true);
            log = std::make_shared<spdlog::logger>("global log", std::move(sink));
        } else {
            auto sink = std::make_shared<spdlog::sinks::msvc_sink_mt>();
            log = std::make_shared<spdlog::logger>("global log", std::move(sink));
        }

        spdlog::set_default_logger(std::move(log));
        spdlog::set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%l] %v");
        spdlog::set_level(spdlog::level::info);
        spdlog::flush_on(spdlog::level::info);

        spdlog::info("=== Dragonborn Voice Control ===");
        if (skse) {
            spdlog::info("{} {}", GetRuntimeName(), std::to_string(skse->RuntimeVersion()));
            spdlog::info("SKSE {}", FormatSKSEVersion(skse->SKSEVersion()));
        }
    }

    void LogLine(const std::string& s)
    {
        spdlog::info("{}", s);
    }
}
