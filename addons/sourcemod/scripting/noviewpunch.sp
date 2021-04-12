
#define DEBUG

#define PLUGIN_NAME           "NoViewPunch"
#define PLUGIN_AUTHOR         "carnifex"
#define PLUGIN_DESCRIPTION    "Removes viewpunch for bhop"
#define PLUGIN_VERSION        "1.1"
#define PLUGIN_URL            ""

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#pragma semicolon 1

ConVar gCV_UseCustomModels;
ConVar gCV_forcePredict;
bool g_bToggled[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSGO)
	SetFailState("This plugin is only for CS:GO!");
	
	gCV_UseCustomModels = CreateConVar("nvp_custommodels", "1", "Use custom models to remove landing animation?", _, true, 0.0, true, 1.0);
	
	HookEvent("player_spawn", Hook_Spawn);
	RegConsoleCmd("sm_toggleprediction", Command_TogglePrediction, "Lets a user toggle client side prediction. Only use with low ping..", 0);
}

public void OnConfigsExecuted()
{
	ConVar viewPunch = FindConVar("view_punch_decay");
	viewPunch.Flags &= ~FCVAR_CHEAT;
	viewPunch.FloatValue = 0.0;
	ConVar viewRecoil = FindConVar("view_recoil_tracking");
	viewRecoil.FloatValue =  0.0;
	viewRecoil.Flags &= ~FCVAR_CHEAT;
	ConVar recoilSpread = FindConVar("weapon_recoil_view_punch_extra");
	recoilSpread.FloatValue = 0.0;
	recoilSpread.Flags &= ~FCVAR_CHEAT;
	
	gCV_forcePredict = FindConVar("sv_client_predict");
}

public void Hook_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(gCV_UseCustomModels.BoolValue)
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			SetEntityModel(client, "models/player/tm_leet_varianta.mdl");
		}
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			SetEntityModel(client, "models/player/ctm_idf_variantc.mdl");
		}
	}	

	SDKHook(client, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
}

void Hook_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	float punch[3] = {0.75, 0.0, 0.0};
	SetEntPropVector(victim, Prop_Send, "m_viewPunchAngle", punch);
}

public void OnClientPutInServer(int client)
{
	g_bToggled[client] = false;
}

public Action Command_TogglePrediction(int client, int args)
{
	if(g_bToggled[client])
	{
		g_bToggled[client] = false;
		PrintToChat(client, "You have now enabled client-side prediction.");
		gCV_forcePredict.ReplicateToClient(client, "1.0");
	} 
	else
	{
		g_bToggled[client] = true;
		PrintToChat(client, "You have now disabled client-side prediction.");
		gCV_forcePredict.ReplicateToClient(client, "0.0");
	}
	return Plugin_Continue;
}

//these are just some models that I know don't have animations because of use in previous plugins. You can change them or disable them completly by commenting out the "HookEvent" line in OnPluginStart.
public void OnMapStart()
{
	PrecacheModel("models/player/tm_leet_varianta.mdl", true);
	AddFileToDownloadsTable("models/player/tm_leet_varianta.mdl");
	PrecacheModel("models/player/ctm_idf_variantc.mdl", true);
	AddFileToDownloadsTable("models/player/ctm_idf_variantc.mdl");
}

// https://github.com/perilouswithadollarsign/cstrike15_src/blob/29e4c1fda9698d5cebcdaf1a0de4b829fa149bf8/game/shared/gamemovement.cpp#L4397
// We can't cancel out viewpunch, so when view_punch_decay is set to 0, the viewpunch will stay at 0.75. Lets keep setting it to 0.75 in case other forces try to affect the players view (long falls, wall collision etc)
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	float punch[3] = {0.75, 0.0, 0.0};
	SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", punch);	
}
