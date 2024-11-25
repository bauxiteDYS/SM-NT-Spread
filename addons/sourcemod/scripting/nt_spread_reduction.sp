#include <sourcemod>
#include <dhooks>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required

// do not enable debug for a public server
#define DEBUG false;

int cwep;
int clnt;
int bltc[NEO_MAXPLAYERS+1];
float lsblt[NEO_MAXPLAYERS+1];
float crblt[NEO_MAXPLAYERS+1];
float sprd;

public Plugin myinfo =
{
	name = "NT Spread reduction",
	description = "Reduces the spread, first 5 shots are more accurate, shotguns excluded",
	author = "bauxite, based on Agiels spread plugin",
	version = "0.1.7",
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
	
	cwep = hParams.Get(4);
	
	if(cwep == 2 || cwep == 25)
	{
		return MRES_Ignored;
	}
	
	clnt = hParams.Get(1);
	sprd = hParams.Get(7);
	crblt[clnt] = GetGameTime();
	
	#if DEBUG
	PrintToServer("[Spread] Bullet time: %f", crblt[clnt]);
	#endif
	
	if((crblt[clnt] - lsblt[clnt]) > 0.5)
	{
		bltc[clnt] = 1;
	}
	else
	{
		++bltc[clnt];
	}
	
	#if DEBUG
	PrintToServer("[Spread] bullet count: %d", bltc[clnt]);
	#endif
	
	lsblt[clnt] = crblt[clnt];
	
	switch(bltc[clnt])
	{
		case 1:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.79);
			#endif
			
			hParams.Set(7, sprd*0.79);
			return MRES_ChangedHandled;
		}
		case 2:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.66);
			#endif
			
			hParams.Set(7, sprd*0.66);
			return MRES_ChangedHandled;
		}
		case 3:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.60);
			#endif
			
			hParams.Set(7, sprd*0.60);
			return MRES_ChangedHandled;
		}
		case 4:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.66);
			#endif
			
			hParams.Set(7, sprd*0.66);
			return MRES_ChangedHandled;
		}
		case 5:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.79);
			#endif
			
			hParams.Set(7, sprd*0.79);
			return MRES_ChangedHandled;
		}
		default:
		{
			if(sprd > 0.016)
			{	
				#if DEBUG
				PrintToServer("[Spread] %f", sprd);
				PrintToServer("[Spread] %f new", sprd - 0.0023);
				#endif
			
				hParams.Set(7, sprd - 0.0023);
				return MRES_ChangedHandled;
			}
			
			return MRES_Ignored;
		}	
	}
}
