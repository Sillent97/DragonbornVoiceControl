#pragma once

namespace DragonbornVoiceControl
{
    void RegisterDialogueWatcher();
    void LogOptionsIfChanged(const char* tag);
    void RequestSelectIndex_MainThread(int index0);
    bool IsDialogueOpen();
}
