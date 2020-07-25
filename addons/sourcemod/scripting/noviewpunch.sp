
#define DEBUG

#define PLUGIN_NAME           "NoViewPunch"
#define PLUGIN_AUTHOR         "carnifex"
#define PLUGIN_DESCRIPTION    "Removes viewpunch for bhop"
#define PLUGIN_VERSION        "1.0"
#define PLUGIN_URL            ""

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <dhooks>

#pragma semicolon 1

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
	
	LoadDHooks();
	
	ConVar viewPunch = FindConVar("view_punch_decay");
	viewPunch.FloatValue = 0.0;
	ConVar viewRecoil = FindConVar("view_recoil_tracking");
	viewRecoil.FloatValue =  0.0;
	ConVar recoilSpread = FindConVar("weapon_recoil_view_punch_extra");
	recoilSpread.FloatValue = 0.0;
}

void LoadDHooks()
{
	Handle gamedataConf = LoadGameConfigFile("noviewpunch.games");
	
	if(gamedataConf == null)
	{
		SetFailState("Failed to load NoViewPunch gamedata");
	}
	
	StartPrepSDKCall(SDKCall_Static);
	if(!PrepSDKCall_SetFromConf(gamedataConf, SDKConf_Signature, "CreateInterface"))
	{
		SetFailState("Failed to get CreateInterface");
	}
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	Handle CreateInterface = EndPrepSDKCall();
	
	if(CreateInterface == null)
	{
		SetFailState("Unable to prepare SDKCall for CreateInterface");
	}
	
	char interfaceName[64];
	if(!GameConfGetKeyValue(gamedataConf, "IGameMovement", interfaceName, sizeof(interfaceName)))
	{
		SetFailState("Failed to get IGameMovement interface name");
	}
	
	Address IGameMovement = SDKCall(CreateInterface, interfaceName, 0);
	if(!IGameMovement)
	{
		SetFailState("Failed to get IGameMovement pointer");
	}
	
	int iOffset = GameConfGetOffset(gamedataConf, "PlayerRoughLandingEffects");
	if(iOffset == -1)
	{
		LogError("Can't find CGameMovement::PlayerRoughLandingEffects offset in gamedata.");
		return;
	}
	
	Handle g_PlayerRoughLandingEffectsHook = DHookCreate(iOffset, HookType_Raw, ReturnType_Void, ThisPointer_Ignore, DHooks_PlayerRoughLandingEffects);
	if(g_PlayerRoughLandingEffectsHook == null)
	{
		LogError("Failed to create CGameMovement::PlayerRoughLandingEffects hook.");
		return;
	}
	
	DHookAddParam(g_PlayerRoughLandingEffectsHook, HookParamType_Float);
	DHookRaw(g_PlayerRoughLandingEffectsHook, false, IGameMovement);
	
	delete CreateInterface;
	delete gamedataConf;
}

public MRESReturn DHooks_PlayerRoughLandingEffects(Handle hParams)
{
	return MRES_Supercede;
}

// https://github.com/perilouswithadollarsign/cstrike15_src/blob/29e4c1fda9698d5cebcdaf1a0de4b829fa149bf8/game/shared/gamemovement.cpp#L4397
// We can't cancel out viewpunch, so when view_punch_decay is set to 0, the viewpunch will stay at 0.75. Lets keep setting it to 0.75 in case other forces try to affect the players view (long falls, wall collision etc)
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	float punch[3] = {0.75, 0.0, 0.0};
	SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", punch);	
}