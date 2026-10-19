#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "[CS] Starsim Arsenal - UI";
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"arsenal_main", "cba_main", "cba_settings", "ace_common", "ace_arsenal", "A3_Ui_F", "A3_3DEN"};
        author = "Celxste";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "ui\RscControls.hpp"
#include "ui\DisplayPatch.hpp"
