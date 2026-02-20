#pragma once

#include <string>

namespace DragonbornVoiceControl
{
    void SetupLogging(const SKSE::LoadInterface* skse);
    void LogLine(const std::string& s);
}
