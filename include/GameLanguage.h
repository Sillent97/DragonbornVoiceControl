#pragma once

#include <string>

namespace DragonbornVoiceControl
{
    struct GameLanguageInfo
    {
        std::string code;
        std::string label;
        std::string raw;
    };

    GameLanguageInfo DetectGameLanguage();
}
