#include <sourcemod>
#include <dhooks>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required

#define PRINT_SPREAD false

#define PLUGIN_VERSION "0.1.0"

ConVar g_cvarSpread = null;
static bool g_pluginDisabled;
	
public Plugin myinfo =
{
	name		= "NT Spread reduction",
	description 	= "Reduces the spread value for each shot",
	author		= "Agiel, bauxite",
	version		= PLUGIN_VERSION,
	url		= "https://github.com/Agiel/nt-spread"
};

public void OnPluginStart()
{
	CreateDetour();
	g_cvarSpread = CreateConVar("sm_spread_reduction", "0", "0 off, 1 reduce spread to 0.9x", _, true, 0.0, true, 1.0);
	g_cvarSpread.AddChangeHook(CvarChanged_Spread);
}

public void OnConfigsExecuted()
{
	g_pluginDisabled = !g_cvarSpread.BoolValue;
}

public void CvarChanged_Spread(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_pluginDisabled = !convar.BoolValue;
	PrintToChatAll("[Spread] Spread reduction is now %s", g_pluginDisabled ? "disabled":"enabled");
}

void CreateDetour()
{
	Handle gd = LoadGameConfigFile("neotokyo/spread");
	if (gd == INVALID_HANDLE)
	{
		SetFailState("Failed to load GameData");
	}
	DynamicDetour dd = DynamicDetour.FromConf(gd, "Fn_FireBullet");
	if (!dd)
	{
		SetFailState("Failed to create dynamic detour");
	}
	if (!dd.Enable(Hook_Pre, FireBullet))
	{
		SetFailState("Failed to detour");
	}
	delete dd;
	CloseHandle(gd);
}

MRESReturn FireBullet(DHookParam hParams)
{
	if (g_pluginDisabled || !hParams)
	{
		return MRES_Ignored;
	}
	
	#if PRINT_SPREAD
	PrintToChat(hParams.Get(1), "[Spread] %f", hParams.Get(7));
	#endif
	
	float spread = hParams.Get(7);
	hParams.Set(7, (spread * 0.9)); // set all shots to 0.9x
	return MRES_ChangedHandled;
}
