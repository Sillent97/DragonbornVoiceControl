#pragma once

#include <atomic>
#include <cstdint>
#include <mutex>
#include <sstream>
#include <string>
#include <unordered_set>

namespace RE
{
    using FormID = std::uint32_t;
    class PlayerCharacter;
    class TESShout;
}

namespace DragonbornVoiceControl::detail
{
    extern std::mutex g_shoutCacheMutex;
    extern std::unordered_set<RE::FormID> g_knownShouts;
    extern std::unordered_set<RE::FormID> g_favoriteShouts;
    extern std::unordered_set<RE::FormID> g_knownPowers;
    extern std::unordered_set<RE::FormID> g_favoritePowers;
    extern std::atomic<double> g_voiceCooldownEndSec;

    extern std::atomic_bool g_gameLoaded;
    extern std::atomic_bool g_shoutScanInFlight;
    extern std::atomic_bool g_powerScanInFlight;
    extern std::uint64_t g_lastShoutStateHash;
    extern std::uint64_t g_lastPowerStateHash;

    extern std::atomic_bool g_muteShoutVoiceWindow;
    extern std::atomic<std::uint64_t> g_muteShoutVoiceWindowGen;

    inline std::string FormIDToHex(RE::FormID id)
    {
        std::stringstream ss;
        ss << std::hex << std::uppercase << id;
        return ss.str();
    }

    inline std::string BaseIDToHex(RE::FormID id)
    {
        std::stringstream ss;
        ss << std::hex << std::uppercase << (id & 0x00FFFFFF);
        return ss.str();
    }
}
