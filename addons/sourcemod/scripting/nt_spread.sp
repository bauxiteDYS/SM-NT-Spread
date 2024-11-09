#include <sourcemod>
#include <dhooks>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required


#define PRINT_SPREAD false

int cwep;
int lwep[NEO_MAXPLAYERS+1];
int clnt;
int bltc[NEO_MAXPLAYERS+1];
float lsblt[NEO_MAXPLAYERS+1];
float crblt[NEO_MAXPLAYERS+1];
float sprd;
//float snew;

public Plugin myinfo =
{
	name = "NT Spread reduction",
	description = "Reduces the spread value",
	author = "bauxite, Agiel",
	version = "0.1.0",
	url = ""
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
		return MRES_Ignored;
	}
	
	clnt = hParams.Get(1);
	cwep = hParams.Get(4);
	sprd = hParams.Get(7);
	
	if(sprd < 0.005 || cwep == 2 || cwep == 25 || cwep == 5 || cwep == 10 || cwep == 24)
	{
		lwep[clnt] = cwep;
		return MRES_Ignored;
	}
	
	crblt[clnt] = GetGameTime();
	
	if(cwep != lwep[clnt] || (crblt[clnt] - lsblt[clnt]) > 0.7)
	{
		bltc[clnt] = 1;
	}
	else
	{
		++bltc[clnt];
	}
	
	lwep[clnt] = cwep;
	lsblt[clnt] = crblt[clnt];
	
	if(bltc[clnt] > 6)
	{
		return MRES_Ignored;
	}
	
	//snew = sprd*(0.1*bltc[clnt] + 0.3);
	hParams.Set(7, sprd*(0.1*bltc[clnt] + 0.3));
	
	#if PRINT_SPREAD
	PrintToServer("[Spread] %f", sprd);
	PrintToServer("[Spread] %f new", sprd*(0.1*bltc[clnt] + 0.3));
	#endif
	
	return MRES_ChangedHandled;
}
