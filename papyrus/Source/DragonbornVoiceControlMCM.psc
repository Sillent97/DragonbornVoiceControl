Scriptname DragonbornVoiceControlMCM extends SKI_ConfigBase

int _optDialogueSelect
int _optOpen
int _optClose
int _optShouts
int _optPowers
int _optMute
int _optWeapons
int _optSpells
int _optPotions
int _optDebug
int _optSaveWav
int _optRestart

Bool Function GetEnableVoiceOpen() Global Native
Bool Function GetEnableVoiceClose() Global Native
Bool Function GetEnableDialogueSelect() Global Native
Bool Function GetEnableVoiceShouts() Global Native
Bool Function GetMuteShoutVoiceLine() Global Native
Bool Function GetEnablePowers() Global Native
Bool Function GetEnableWeapons() Global Native
Bool Function GetEnableSpells() Global Native
Bool Function GetEnablePotions() Global Native
Bool Function GetDebug() Global Native
Bool Function GetSaveWavCaptures() Global Native

Function SetEnableVoiceOpen(Bool value) Global Native
Function SetEnableVoiceClose(Bool value) Global Native
Function SetEnableDialogueSelect(Bool value) Global Native
Function SetEnableVoiceShouts(Bool value) Global Native
Function SetMuteShoutVoiceLine(Bool value) Global Native
Function SetEnablePowers(Bool value) Global Native
Function SetEnableWeapons(Bool value) Global Native
Function SetEnableSpells(Bool value) Global Native
Function SetEnablePotions(Bool value) Global Native
Function SetDebug(Bool value) Global Native
Function SetSaveWavCaptures(Bool value) Global Native

Function RestartServer() Global Native

Event OnConfigInit()
    ModName = "Dragonborn Voice Control"
    Pages = new string[1]
    Pages[0] = "Settings"
EndEvent

Event OnPageReset(string page)
    SetCursorFillMode(LEFT_TO_RIGHT)

    ; --- Left column: Voice Features ---
    AddHeaderOption("Voice Features")
    ; --- Right column: Other ---
    AddHeaderOption("Other")

    _optDialogueSelect = AddToggleOption("Dialogue Select", GetEnableDialogueSelect())
    _optDebug   = AddToggleOption("Debug Notifications", GetDebug())

    _optOpen  = AddToggleOption("Dialogue Open", GetEnableVoiceOpen())
    _optSaveWav = AddToggleOption("Save WAV Captures", GetSaveWavCaptures())

    _optClose = AddToggleOption("Dialogue Close", GetEnableVoiceClose())
    _optRestart = AddTextOption("Restart Server", "Restart")

    _optShouts  = AddToggleOption("Shouts", GetEnableVoiceShouts())
    AddEmptyOption()

    _optMute    = AddToggleOption("Mute Shout Voice Line", GetMuteShoutVoiceLine())
    AddEmptyOption()
    
    _optPowers = AddToggleOption("Powers", GetEnablePowers())
    AddEmptyOption()

    _optWeapons = AddToggleOption("Weapons", GetEnableWeapons())
    AddEmptyOption()

    _optSpells  = AddToggleOption("Spells", GetEnableSpells())
    AddEmptyOption()

    _optPotions = AddToggleOption("Potions", GetEnablePotions())
    AddEmptyOption()
EndEvent

Event OnOptionSelect(int option)
    if option == _optDialogueSelect
        bool v = !GetEnableDialogueSelect()
        SetEnableDialogueSelect(v)
        SetToggleOptionValue(option, v)

    elseif option == _optOpen
        bool v = !GetEnableVoiceOpen()
        SetEnableVoiceOpen(v)
        SetToggleOptionValue(option, v)

    elseif option == _optClose
        bool v = !GetEnableVoiceClose()
        SetEnableVoiceClose(v)
        SetToggleOptionValue(option, v)

    elseif option == _optShouts
        bool v = !GetEnableVoiceShouts()
        SetEnableVoiceShouts(v)
        SetToggleOptionValue(option, v)

    elseif option == _optMute
        bool v = !GetMuteShoutVoiceLine()
        SetMuteShoutVoiceLine(v)
        SetToggleOptionValue(option, v)

    elseif option == _optPowers
        bool v = !GetEnablePowers()
        SetEnablePowers(v)
        SetToggleOptionValue(option, v)

    elseif option == _optWeapons
        bool v = !GetEnableWeapons()
        SetEnableWeapons(v)
        SetToggleOptionValue(option, v)

    elseif option == _optSpells
        bool v = !GetEnableSpells()
        SetEnableSpells(v)
        SetToggleOptionValue(option, v)

    elseif option == _optPotions
        bool v = !GetEnablePotions()
        SetEnablePotions(v)
        SetToggleOptionValue(option, v)

    elseif option == _optDebug
        bool v = !GetDebug()
        SetDebug(v)
        SetToggleOptionValue(option, v)

    elseif option == _optSaveWav
        bool v = !GetSaveWavCaptures()
        SetSaveWavCaptures(v)
        SetToggleOptionValue(option, v)

    elseif option == _optRestart
        bool ok = ShowMessage("Restart the voice server now?", true, "Restart", "Cancel")
        if ok
            RestartServer()
        endif
    endif
EndEvent

Event OnOptionHighlight(int option)
    if option == _optDialogueSelect
        SetInfoText("Enable voice selection of dialogue options.")

    elseif option == _optOpen
        SetInfoText("Enable voice open phrases to open dialogue when looking at an NPC.")

    elseif option == _optClose
        SetInfoText("Enable voice close phrases to close dialogue.")

    elseif option == _optShouts
        SetInfoText("Use favorite shouts by speaking shout words.")

    elseif option == _optMute
        SetInfoText("Suppress the Dovahkiin voice line when a shout is triggered via voice.")

    elseif option == _optPowers
        SetInfoText("Use favorite powers by speaking their name.")

    elseif option == _optWeapons
        SetInfoText("Equip favorite weapons by speaking their name.")

    elseif option == _optSpells
        SetInfoText("Equip favorite spells by speaking their name.")

    elseif option == _optPotions
        SetInfoText("Use favorite potions by speaking their name.")

    elseif option == _optDebug
        SetInfoText("Show in-game recognition notifications.")

    elseif option == _optSaveWav
        SetInfoText("Save captured voice audio to DVCRuntime/caches/vad_caps/*.wav for debugging.")

    elseif option == _optRestart
        SetInfoText("Restart the voice recognition server.")
    endif
EndEvent
