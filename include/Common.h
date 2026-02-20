#pragma once

#include <chrono>

namespace DragonbornVoiceControl
{
    inline double GetNowSec()
    {
        using namespace std::chrono;
        return duration_cast<duration<double>>(steady_clock::now().time_since_epoch()).count();
    }
}
