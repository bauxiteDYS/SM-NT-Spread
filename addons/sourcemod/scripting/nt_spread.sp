#include <sourcemod>
#include <dhooks>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required


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
	description = "Reduces the spread value",
	author = "bauxite, Agiel",
	version = "0.1.3",
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
	
	if(cwep == 2 || cwep == 25)
	{
		#if DEBUG
		PrintToServer("spread %f", sprd);
		PrintToServer("spread %f new", sprd - 0.0029);
		#endif
		
		hParams.Set(7, sprd - 0.0029);
		return MRES_ChangedHandled;
	}
	
	crblt[clnt] = GetGameTime();
	
	#if DEBUG
	PrintToServer("time %f", crblt[clnt]);
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
	PrintToServer("bullet %d", bltc[clnt]);
	#endif
	
	lsblt[clnt] = crblt[clnt];
	
	switch(bltc[clnt])
	{
		case 1:
		{
			#if DEBUG
			PrintToServer("spread %f", sprd);
			PrintToServer("spread %f new", sprd*0.75);
			#endif
			
			hParams.Set(7, sprd*0.75);
			return MRES_ChangedHandled;
		}
		case 2:
		{
			#if DEBUG
			PrintToServer("spread %f", sprd);
			PrintToServer("spread %f new", sprd*0.60);
			#endif
			
			hParams.Set(7, sprd*0.60);
			return MRES_ChangedHandled;
		}
		case 3:
		{
			#if DEBUG
			PrintToServer("spread %f", sprd);
			PrintToServer("spread %f new", sprd*0.50);
			#endif
			
			hParams.Set(7, sprd*0.50);
			return MRES_ChangedHandled;
		}
		case 4:
		{
			#if DEBUG
			PrintToServer("spread %f", sprd);
			PrintToServer("spread %f new", sprd*0.66);
			#endif
			
			hParams.Set(7, sprd*0.66);
			return MRES_ChangedHandled;
		}
		case 5:
		{
			#if DEBUG
			PrintToServer("spread %f", sprd);
			PrintToServer("spread %f new", sprd*0.75);
			#endif
			
			hParams.Set(7, sprd*0.75);
			return MRES_ChangedHandled;
		}
		default:
		{
			if(sprd > 0.016)
			{	
				#if DEBUG
				PrintToServer("spread %f", sprd);
				PrintToServer("spread %f new", sprd - 0.0029);
				#endif
			
				hParams.Set(7, sprd - 0.0029);
				return MRES_ChangedHandled;
			}
			
			return MRES_Ignored;
		}	
	}
}
