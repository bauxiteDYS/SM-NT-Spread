#include <sourcemod>
#include <dhooks>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.0.1"

public Plugin myinfo =
{
	name		= "NT Spread",
	description = "Prints the spread value for each shot",
	author		= "Agiel",
	version		= PLUGIN_VERSION,
	url			= "https://github.com/Agiel/nt-spread"
};

public void OnPluginStart()
{
	CreateDetour();
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
	if (!hParams)
	{
		PrintToChatAll("No params");
		return MRES_Ignored;
	}
	PrintToChatAll("%f", hParams.Get(7));
	PrintToConsoleAll("%f", hParams.Get(7));
	return MRES_Handled;
}
