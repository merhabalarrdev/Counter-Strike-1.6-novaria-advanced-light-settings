#include <amxmodx>
#include <reapi>
#include <nvault>

#define CHAT_TAG "^4[Novaria]"
#define MENU_TAG "\r[Novaria]"

const c_MaxLight = 23;
new const szLightBrightness[][] = {
    "a", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "v", "y", "z"
}

new iUserLight[33], iVault;
new bool:g_bUsingSystem[33];

public plugin_init() {
    register_plugin("Gelismis Isik Eklentisi", "1.0", "Merhabalar");
    register_dictionary("gelismis_isikayari.txt");

    register_clcmd("say /isik", "@cmd_Isik");
    register_clcmd("say .isik", "@cmd_Isik");

    RegisterHookChain(RG_CBasePlayer_Spawn, "@OnPlayerSpawn", true);
    RegisterHookChain(RG_CBasePlayer_Killed, "@OnPlayerKilled", true);
}

public plugin_cfg() {
    iVault = nvault_open("gelismis_isikayari");
}

public plugin_end() {
    nvault_close(iVault);
}

@cmd_Isik(const iPlayer) {
    @g_LightMenu(iPlayer);
    return PLUGIN_HANDLED;
}

@g_LightMenu(const iPlayer) {
    if(!is_user_connected(iPlayer)) return;

    if(iUserLight[iPlayer] < 1 || iUserLight[iPlayer] > c_MaxLight) {
        iUserLight[iPlayer] = 12;
    }

    g_bUsingSystem[iPlayer] = true;

    new iCurrentLevel = iUserLight[iPlayer];
    if(iCurrentLevel < 1) iCurrentLevel = 1;
    if(iCurrentLevel > c_MaxLight) iCurrentLevel = c_MaxLight;

    new szMenuTitle[160];
    format(szMenuTitle, charsmax(szMenuTitle), "%L", iPlayer, "MENU_TITLE", MENU_TAG, iCurrentLevel);

    new iMenu = menu_create(szMenuTitle, "@g_LightMenu_");

    new szItem[96];

    format(szItem, charsmax(szItem), "%L", iPlayer, "ITEM_RESET");
    menu_additem(iMenu, szItem, "1");

    format(szItem, charsmax(szItem), "%L", iPlayer, "ITEM_INCREASE", iCurrentLevel >= c_MaxLight ? "\d" : "\w");
    menu_additem(iMenu, szItem, "2");

    format(szItem, charsmax(szItem), "%L", iPlayer, "ITEM_DECREASE", iCurrentLevel <= 1 ? "\d" : "\w");
    menu_additem(iMenu, szItem, "3");

    format(szItem, charsmax(szItem), "%L", iPlayer, "ITEM_MAX");
    menu_additem(iMenu, szItem, "4");

    format(szItem, charsmax(szItem), "%L", iPlayer, "ITEM_MIN");
    menu_additem(iMenu, szItem, "5");

    format(szItem, charsmax(szItem), "%L", iPlayer, "ITEM_SAVE");
    menu_additem(iMenu, szItem, "6");

    new szClose[32];
    format(szClose, charsmax(szClose), "%L", iPlayer, "MENU_CLOSE");
    menu_setprop(iMenu, MPROP_EXITNAME, szClose);
    menu_display(iPlayer, iMenu);
}

@g_LightMenu_(const iPlayer, const iMenu, const iItem) {
    if(iItem == MENU_EXIT) {
        menu_destroy(iMenu);
        return PLUGIN_HANDLED;
    }

    new iData[6], iKey, szSteamID[35], szMsg[128];
    menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
    iKey = str_to_num(iData);
    get_user_authid(iPlayer, szSteamID, charsmax(szSteamID));

    switch(iKey) {
        case 1: {
            iUserLight[iPlayer] = 12;
            @UTIL_Set_Player_Light(iPlayer);
            format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_RESET");
            client_print_color(iPlayer, print_team_default, "%s %s", CHAT_TAG, szMsg);
        }
        case 2: {
            if(iUserLight[iPlayer] < c_MaxLight) {
                iUserLight[iPlayer]++;
                @UTIL_Set_Player_Light(iPlayer);
                format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_INCREASED");
            } else {
                format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_MAX_ALREADY");
            }
            client_print_color(iPlayer, print_team_default, "%s %s", CHAT_TAG, szMsg);
        }
        case 3: {
            if(iUserLight[iPlayer] > 1) {
                iUserLight[iPlayer]--;
                @UTIL_Set_Player_Light(iPlayer);
                format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_DECREASED");
            } else {
                format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_MIN_ALREADY");
            }
            client_print_color(iPlayer, print_team_default, "%s %s", CHAT_TAG, szMsg);
        }
        case 4: {
            iUserLight[iPlayer] = c_MaxLight;
            @UTIL_Set_Player_Light(iPlayer);
            format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_MAX_ON");
            client_print_color(iPlayer, print_team_default, "%s %s", CHAT_TAG, szMsg);
        }
        case 5: {
            iUserLight[iPlayer] = 1;
            @UTIL_Set_Player_Light(iPlayer);
            format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_MIN_ON");
            client_print_color(iPlayer, print_team_default, "%s %s", CHAT_TAG, szMsg);
        }
        case 6: {
            new szVal[3];
            num_to_str(iUserLight[iPlayer], szVal, charsmax(szVal));
            nvault_set(iVault, szSteamID, szVal);
            format(szMsg, charsmax(szMsg), "%L", iPlayer, "MSG_SAVED");
            client_print_color(iPlayer, print_team_default, "%s %s", CHAT_TAG, szMsg);
        }
    }

    menu_destroy(iMenu);
    @g_LightMenu(iPlayer);
    return PLUGIN_HANDLED;
}

public client_putinserver(iPlayer) {
    iUserLight[iPlayer] = 12;
    g_bUsingSystem[iPlayer] = true;

    new szSteamID[35], szData[4];
    get_user_authid(iPlayer, szSteamID, charsmax(szSteamID));

    if(nvault_get(iVault, szSteamID, szData, charsmax(szData))) {
        iUserLight[iPlayer] = str_to_num(szData);
        if(iUserLight[iPlayer] < 1 || iUserLight[iPlayer] > c_MaxLight) {
            iUserLight[iPlayer] = 12;
        }
    }
}

public client_disconnected(iPlayer, bool:drop, message[], maxlen) {
    g_bUsingSystem[iPlayer] = false;
}

// Oyuncu dogdugunda isik ayari aninda (gecikmesiz) uygulanir
@OnPlayerSpawn(const iPlayer) {
    if(g_bUsingSystem[iPlayer] && is_user_alive(iPlayer)) {
        @UTIL_Set_Player_Light(iPlayer);
        // Bazi haritalarda spawn anindaki motor sifirlamasina karsi 1 frame sonra da uygulanir
        set_task(0.0, "@ApplyLight", iPlayer);
    }
}

// Oyuncu oldugunde de isik ayari korunsun / aninda uygulansin
@OnPlayerKilled(const iVictim, const iKiller, const iShared) {
    @UTIL_Set_Player_Light(iVictim);
}

@ApplyLight(const iPlayer) {
    if(is_user_connected(iPlayer) && g_bUsingSystem[iPlayer]) {
        @UTIL_Set_Player_Light(iPlayer);
    }
}

@UTIL_Set_Player_Light(const iPlayer) {
    if(!is_user_connected(iPlayer)) return;

    if(!g_bUsingSystem[iPlayer]) {
        message_begin(MSG_ONE, SVC_LIGHTSTYLE, .player = iPlayer);
        write_byte(0);
        write_string("m");
        message_end();
        return;
    }

    new iLevel = iUserLight[iPlayer];
    if(iLevel < 1) iLevel = 1;
    if(iLevel > c_MaxLight) iLevel = c_MaxLight;

    message_begin(MSG_ONE, SVC_LIGHTSTYLE, .player = iPlayer);
    write_byte(0);
    write_string(szLightBrightness[iLevel]);
    message_end();
}
