#include <sourcemod>
#include <dhooks>
#include <neotokyo>

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
		return MRES_Ignored;
	}

	hParams.Set(7, 0.0);
	return MRES_ChangedHandled;
}
