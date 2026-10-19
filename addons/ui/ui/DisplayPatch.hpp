// Every way of opening the ACE arsenal (boxes, Zeus, Eden, scripts) creates this display.
// The handlers below send it to the Starsim Arsenal UI when it's enabled and to ACE's own UI otherwise.
// If this addon's functions are missing for any reason, ACE's handlers run unchanged.
class ace_arsenal_display {
    onLoad = "if (isNil 'arsenal_ui_fnc_onLoad') then {['onLoad',_this,'ace_arsenal_display'] call ace_arsenal_fnc_onArsenalOpen} else {_this call arsenal_ui_fnc_onLoad}";
    onUnload = "if (isNil 'arsenal_ui_fnc_onUnload') then {['onUnload',_this,'ace_arsenal_display'] call ace_arsenal_fnc_onArsenalClose} else {_this call arsenal_ui_fnc_onUnload}";
    onKeyDown = "if (isNil 'arsenal_ui_fnc_onKeyDown') then {['onKeyDown',_this,'ace_arsenal_display'] call ace_arsenal_fnc_onKeyDown} else {_this call arsenal_ui_fnc_onKeyDown}";
};
