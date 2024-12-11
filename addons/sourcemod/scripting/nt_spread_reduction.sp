#include <sourcemod>
#include <dhooks>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required

// do not enable debug for a public server
#define DEBUG false;

// for overtuned reduction
#define TUNED false;

int cwep;
int clnt;
int bltc[NEO_MAXPLAYERS+1];
float lsblt[NEO_MAXPLAYERS+1];
float crblt[NEO_MAXPLAYERS+1];
float sprd;

public Plugin myinfo = {
	#if !DEBUG
	name = "NT Spread reduction",
	#else
	name = "NT Spread reduction Debug",
	#endif
	description = "Reduces the spread, shotguns excluded",
	author = "bauxite, based on Agiels spread plugin",
	#if !TUNED
	version = "0.3.1",
	#else
	version = "0.3.1.overtuned",
	#endif
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

#if !TUNED
MRESReturn FireBullet(DHookParam hParams)
{
	if (!hParams)
	{
		return MRES_Ignored;
	}

	cwep = hParams.Get(4);
	
	if(cwep == 2 || cwep == 25) //supa, aa
	{
		return MRES_Ignored;
	}
	
	sprd = hParams.Get(7);
	
	if(cwep == 5 || cwep == 10 || cwep == 24) //tachi, milso, kyla
	{
		#if DEBUG
		PrintToServer("[Spread] %f", sprd);
		#endif
		
		if(sprd > 0.016)
		{
			#if DEBUG
			PrintToServer("[Spread] %f new", sprd - 0.0023);
			#endif
			
			hParams.Set(7, sprd - 0.0023);
		}
		
		return MRES_ChangedHandled;
	}
	
	clnt = hParams.Get(1);
	
	crblt[clnt] = GetGameTime();
	
	#if DEBUG
	PrintToServer("[Spread] Bullet time: %f", crblt[clnt]);
	#endif
	
	if((crblt[clnt] - lsblt[clnt]) > 0.41)
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
		case 1: // when aimed the rifles have 0 spread so this does nothing for them, smgs 1st shot will be somewhat accurate
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
			PrintToServer("[Spread] %f new", sprd*0.70);
			#endif
			
			hParams.Set(7, sprd*0.70);
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
#else
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
	
	sprd = hParams.Get(7);
	
	if(cwep == 5 || cwep == 10 || cwep == 24)
	{
		#if DEBUG
		PrintToServer("[Spread] %f", sprd);
		#endif
		
		if(sprd > 0.016)
		{
			#if DEBUG
			PrintToServer("[Spread] %f new", sprd - 0.0035);
			#endif
			
			hParams.Set(7, sprd - 0.0035);
		}
		
		return MRES_ChangedHandled;
	}
	
	
	clnt = hParams.Get(1);
	
	crblt[clnt] = GetGameTime();
	
	#if DEBUG
	PrintToServer("[Spread] Bullet time: %f", crblt[clnt]);
	#endif
	
	if((crblt[clnt] - lsblt[clnt]) > 0.41)
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
		case 1: // when aimed the rifles have 0 spread so this does nothing for them, smgs/pistols 1st shot will be somewhat accurate
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.70);
			#endif
			
			hParams.Set(7, sprd*0.70);
			return MRES_ChangedHandled;
		}
		case 2:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.60);
			#endif
			
			hParams.Set(7, sprd*0.60);
			return MRES_ChangedHandled;
		}
		case 3:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.53);
			#endif
			
			hParams.Set(7, sprd*0.53);
			return MRES_ChangedHandled;
		}
		case 4:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.60);
			#endif
			
			hParams.Set(7, sprd*0.60);
			return MRES_ChangedHandled;
		}
		case 5:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.66);
			#endif
			
			hParams.Set(7, sprd*0.66);
			return MRES_ChangedHandled;
		}
		case 6:
		{
			#if DEBUG
			PrintToServer("[Spread] %f", sprd);
			PrintToServer("[Spread] %f new", sprd*0.72);
			#endif

			hParams.Set(7, sprd*0.72);
			return MRES_ChangedHandled;
		}
		default:
		{
			if(sprd > 0.016)
			{
				#if DEBUG
				PrintToServer("[Spread] %f", sprd);
				PrintToServer("[Spread] %f new", sprd - 0.0035);
				#endif
				
				hParams.Set(7, sprd - 0.0035);
				return MRES_ChangedHandled;
			}
			
			return MRES_Ignored;
		}
	}
}
#endif 
