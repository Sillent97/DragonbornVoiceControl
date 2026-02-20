Scriptname DragonbornVoiceControlShout

; Simulate a shout key press/hold/release via Papyrus Input functions.
; Called from the C++ plugin (METHOD_G) via DispatchStaticCall.
;
; Input.HoldKey / ReleaseKey directly manipulate the engine's internal
; key-pressed state — equivalent to a physical key press.  The engine
; handles cooldown, menu checks, power tier from charge time, etc.
;
; @param power  1 = tap, 2 = short hold, 3 = long hold

Function SimulateShoutKey(int power) Global
    int shoutKey = Input.GetMappedKey("Shout", 0)
    if shoutKey <= 0
        Debug.Trace("[DVC][SHOUT][METHOD_G] No keyboard mapping for Shout (key=" + shoutKey + ")")
        return
    endif

    float holdTime = 0.06
    if power == 2
        holdTime = 0.6
    elseif power >= 3
        holdTime = 1.2
    endif

    Debug.Trace("[DVC][SHOUT][METHOD_G] Pressing key=" + shoutKey + " holdTime=" + holdTime + "s power=" + power)

    Input.HoldKey(shoutKey)
    Utility.Wait(holdTime)
    Input.ReleaseKey(shoutKey)

    Debug.Trace("[DVC][SHOUT][METHOD_G] Key released after " + holdTime + "s")
EndFunction
