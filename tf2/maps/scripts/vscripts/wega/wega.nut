//This script clearly isn't meant to be reused
//This is a shitpost so really I didn't care about cleaning it up
//Script by Alex Turtle

PrecacheModel("models\\wega\\hands.mdl")
PrecacheModel("models\\wega\\wega.mdl")
PrecacheSound("wega/Baseball hit.mp3")
PrecacheSound("npc/stalker/go_alert2a.wav")

    Convars.SetValue("tf_classlimit", 0)
    Convars.SetValue("mp_waitingforplayers_cancel", 1)
    Convars.SetValue("mp_disable_respawn_times", 0)
    Convars.SetValue("tf_dropped_weapon_lifetime", 0)
    Convars.SetValue("mp_scrambleteams_auto_windifference", 0)
    Convars.SetValue("mp_winlimit", 0)
    Convars.SetValue("mp_maxrounds", 0)
    Convars.SetValue("tf_stalematechangeclasstime", casti2f(0x7fa00000)) //NaN.
    Convars.SetValue("mp_respawnwavetime", 999999)
    Convars.SetValue("mp_teams_unbalance_limit", 0)
    Convars.SetValue("tf_scout_air_dash_count", 0)
    Convars.SetValue("tf_weapon_criticals", 0)
    Convars.SetValue("mp_humans_must_join_team", "red")
    Convars.SetValue("mp_autobalance", 0)
    Convars.SetValue("tf_avoidteammates_pushaway", 0)
    Convars.SetValue("sv_Friction", 2)


AllowRespawn <- true
TriggerEnding <- true
TriggerWin <- true
GameText  <- null
CanLose <- true

::WegaArray <- array(0)
::WegaTargetArray <- array(0)

::AggroClosest <- false

TotalTime <- 0.0
PlayersCount <- 1

class Chunk
{
    template_name = null
    template_entity = null
    possible_up = null
    possible_right = null
    possible_down = null
    possible_left = null

    constructor(targetname, possible_up, possible_right, possible_down, possible_left)
	{
        this.template_name = targetname
        this.possible_up = possible_up
        this.possible_right = possible_right
        this.possible_down = possible_down
        this.possible_left = possible_left
        this.template_entity = Entities.FindByName(null, targetname)
    }

}


enum DIRECTION
{
    UP,
    RIGHT,
    DOWN,
    LEFT,
}

ChunkList <-
[
    Chunk("entity_maker_0", [0, 2, 3, 5, 6, 7, 8, 11, 12], [], [2, 3, 4, 5, 6, 8], [0, 2, 3, 6, 7, 8])
    Chunk("entity_maker_1", [], [1, 3, 6, 7, 8, 9, 10], [], [1, 3, 6, 7, 9, 10])
    Chunk("entity_maker_2", [3, 6, 8], [4, 6, 7, 8], [0, 3, 4, 6, 7, 8], [3, 6, 8])
    Chunk("entity_maker_3", [0, 3, 6, 7, 8], [0, 1, 2, 4, 6, 7, 8, 9, 10], [0, 3, 4, 6, 7, 8], [0, 1, 2, 4, 6, 7, 8, 9, 10])
    Chunk("entity_maker_4", [0, 2, 3, 5, 6, 7, 8, 10, 11, 12], [2, 4, 6, 7, 8], [], [2, 4, 5, 6])
    Chunk("entity_maker_5", [6, 7], [0, 3, 6, 7, 8], [0, 3, 4, 6, 7, 8], [0, 6, 7, 8])
    Chunk("entity_maker_6", [0, 2, 3, 5, 6, 7, 8], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [0, 2, 3, 4, 5, 6, 7, 8], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    Chunk("entity_maker_7", [0, 2, 3, 6, 7, 8], [1, 3, 6, 7, 8, 9, 10], [0, 3, 4, 5, 6, 7, 8], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    Chunk("entity_maker_8", [0, 2, 3, 6, 7, 8, 11, 12], [3, 5, 6, 7, 8, 9, 10], [0, 3, 4, 5, 6, 7, 8, 11, 12], [2, 3, 4, 5, 6, 7, 8, 9, 10])
    Chunk("entity_maker_9", [], [1, 3, 6, 7, 8], [], [1, 3, 6, 7])
    Chunk("entity_maker_10", [], [1, 3, 6, 7, 8], [], [1, 3, 6, 7])
    Chunk("entity_maker_11", [0], [], [0, 4], [])
    Chunk("entity_maker_12", [0], [], [0, 4], [])
    Chunk("entity_maker_13", [0, 2, 3, 5, 6, 7, 8, 11, 12, 13], [1, 2, 3, 4, 5, 6, 8, 13], [0, 2, 3, 5, 6, 13], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
]

CellWidth <- 960

Size <- 10


//Depth First implementation
function Generate()
{

    CalculateSize()

    //Clear screen for all players
    local player = null
    while (player = Entities.FindByClassname(player, "player") )
    {
        player.SetScriptOverlayMaterial("wega/wega_counter.vmt")
    }

    local direction = null
    local CellArray = array(Size);

    for (local i = 0 ; i < Size ; i++) {
        CellArray[i] = array(Size);
    }

    CellArray[0][0] = 8
    CellArray[0][Size-1] = 8
    CellArray[Size-1][Size-1] = 8
    CellArray[Size-1][0] = 8


    local x = 1
    local y = 0

    //Connect to the other spawn first
    while (x < Size-1 || y < Size-1)
    {
    
    if (x < Size-1 && y < Size-1)
    {

        local rnd = RandomInt(0, 4)
        if (rnd > 1)
        {
            direction = DIRECTION.UP
        }
        else
        {
            direction = DIRECTION.RIGHT
        }
    }
    else
    {
        if (x >= Size-1 && y < Size-1)
        {
            direction = DIRECTION.RIGHT
        }

        if (y >= Size-1 && x < Size-1)
        {
            direction = DIRECTION.UP
        }
    }
    local possibleList = [3, 5, 6, 8, 13]

    switch(direction)
    {
        case DIRECTION.UP:
        if (CellArray[x][y] != null)
        {
            possibleList = ChunkList[CellArray[x][y]].possible_up
      
        }

        x++
        break

        case DIRECTION.RIGHT:
        if (CellArray[x][y] != null)
            possibleList = ChunkList[CellArray[x][y]].possible_right

        y++
        break




    }
    if (y == Size-1 && x == Size-1)
        break

    local possibleList = [3, 5, 6, 8, 13]
    local rnd = RandomInt(0, possibleList.len()-1)

    local selectedChunk = possibleList[rnd]
    CellArray[x][y] = selectedChunk 
    }

    //Phase 2, fill everything
    local possibleList = [0, 2, 3, 5, 6, 7, 8, 11, 12, 13]
    local selectedChunk = null


    x = 0
    while (x < Size-1)
    {
        y = 0

        x++

        if (CellArray[x][y] == null) 
        {

            if (CellArray[x-1][y] == null)
                break

            direction = DIRECTION.RIGHT
            possibleList = ChunkList[CellArray[x-1][y]].possible_right

            if (possibleList.len() > 0)
            {
            local rnd = RandomInt(0, possibleList.len()-1)
            selectedChunk = possibleList[rnd]

            //Prevent impossible layouts
            if (selectedChunk == 0)
                selectedChunk = 8

            CellArray[x][y] = selectedChunk 
            }
        }   



        while (y < Size-1)
        {  
            y++

            if (CellArray[x][y] != null)
                break

            direction = DIRECTION.UP
            if (CellArray[x][y-1] != null)
            {
            possibleList = ChunkList[CellArray[x][y-1]].possible_up

            if (possibleList.len() < 1)
                break

            local rnd = RandomInt(0, possibleList.len()-1)
            selectedChunk = possibleList[rnd]
            CellArray[x][y] = selectedChunk 
    


            }
        }

    }

    //Phase 3, fill the other way

    y = Size-1
    while (y > 0)
    {
        x = Size-1
        y--

        if (CellArray[x][y] == null || y == Size-2) 
        {
            if (CellArray[x][y+1] == null && y != Size-2)
                break

            direction = DIRECTION.DOWN

            if (y == Size-2)
                possibleList = ChunkList[CellArray[x][y+1]].possible_down
            else
                possibleList = [3, 5, 6, 8, 13]

            if (possibleList.len() > 0)
            {
            local rnd = RandomInt(0, possibleList.len()-1)
            selectedChunk = possibleList[rnd]
            CellArray[x][y] = selectedChunk 

            }
        }   



        while (x > 0)
        {  
            x--

            if (CellArray[x][y] != null && x != 0)
                break

            direction = DIRECTION.LEFT
            if (CellArray[x+1][y] != null || x == 0)
            {

            if (x == 0)
                possibleList = [3, 5, 6, 8, 13]
            else
                possibleList = ChunkList[CellArray[x+1][y]].possible_left

            if (possibleList.len() < 1)
                break

            local rnd = RandomInt(0, possibleList.len()-1)
            selectedChunk = possibleList[rnd]
            CellArray[x][y] = selectedChunk 
    


            }
        }


    }


    //Phase 4
    x = Size-1
    y = Size-1

    while(x >= 0)
    {
    local possibleList = [3, 5, 6, 8, 13]
    local rnd = RandomInt(0, possibleList.len()-1)

    local selectedChunk = possibleList[rnd]
    CellArray[x][Size-1] = selectedChunk 
    x--
    }

    while(y >= 0)
    {
    local possibleList = [3, 5, 6, 8, 13]
    local rnd = RandomInt(0, possibleList.len()-1)

    local selectedChunk = possibleList[rnd]
    CellArray[0][y] = selectedChunk 
    y--
    }




    //Phase 5, more random
    local possibleList = [3, 5, 6, 8, 13]
    local selectedChunk = null


    x = 0
    while (x < Size-1)
    {
        y = 0

        x++

        if (CellArray[x][y] == null) 
        {

            if (CellArray[x-1][y] == null)
                break

            direction = DIRECTION.RIGHT
            possibleList = ChunkList[CellArray[x-1][y]].possible_right

            if (possibleList.len() > 0)
            {
            local rnd = RandomInt(0, possibleList.len()-1)
            selectedChunk = possibleList[rnd]
            CellArray[x][y] = selectedChunk 

            }
        }   



        while (y < Size-1)
        {  
            y++

            if (CellArray[x][y] != null)
                break

            direction = DIRECTION.UP
            if (CellArray[x][y-1] != null)
            {
            possibleList = ChunkList[CellArray[x][y-1]].possible_up

            if (possibleList.len() < 1)
                break

            local rnd = RandomInt(0, possibleList.len()-1)
            selectedChunk = possibleList[rnd]
            CellArray[x][y] = selectedChunk 
    


            }
        }

    }
    CellArray[0][0] = 8
    CellArray[0][Size-1] = 8
    CellArray[Size-1][Size-2] = 8

    //Phase 6, spawn templates
    x = 0
    while (x <= Size-1)
    {
        y = 0
        while (y <= Size-1)
        {
            if ((y == 0 && x == 0) || (y == Size-1 && x == Size-1))
            {
                y++
                continue
            }

            if (CellArray[x][y] != null)
                ChunkList[CellArray[x][y]].template_entity.SpawnEntityAtLocation(Vector(x*CellWidth,y*CellWidth,0), Vector(0,0,0))
            /*else
                ChunkList[10].template_entity.SpawnEntityAtLocation(Vector(x*CellWidth,y*CellWidth,0), Vector(0,0,0))*/

            y++
        }
        x++

    }

    PrepareObjective()
}

function CalculateSize()
{
    PlayersCount = GetActivePlayerCount()
    local buffer = ceil(sqrt(PlayersCount + 2))
    buffer += 3
    if (buffer < 4)
        buffer = 4

    //multi is size of 6 min
    if (PlayersCount > 1)
    {
        //buffer++
        if (buffer < 6)
            buffer = 6
    }
    else
    {
        buffer = 4
    }

    if (buffer > 11)
        buffer = 11

    Size = buffer
}

::wegacount <- 0

function PrepareObjective()
{
    local wega = null
    while (wega = Entities.FindByClassname(wega, "prop_dynamic"))
    {
        if (wega.GetModelName() == "models/wega/wega.mdl")
        {
            local rnd = RandomInt(0, 359)
            wega.SetAngles(0, rnd, 0)
            wegacount++
        }
    }


    GameText = SpawnEntityFromTable("game_text",
    {
        spawnflags   = 1 
        message      = ""
        color        = "255 255 255"
        holdtime     = 0.5
        fxtime       = 0.5
        effect       = 0
        fadein       = 0.0
        fadeout      = 0.0
        channel      = 0
        x            = 0.1
        y            = 0.06
    })


}

function ObjectiveTick()
{
    if (GameText == null)
        return -1

    EntFireByHandle(GameText, "AddOutPut", "message " + wegacount, 0.0, null, null)
    EntFireByHandle(GameText, "Display", null, 0.0, null, null)

    if (TriggerEnding && wegacount == 1)
    {
        EntFire("start_final_chase", "Trigger")
        TriggerEnding = false
        TriggerWin = true
        EntFire("wega_brush*", "Kill")
        EntFire("wega_sound*", "Kill")
        EntFire("multiplayer_wega_brush*", "Kill")
        EntFire("multiplayer_wega_sound*", "Kill")

        local destination = Entities.FindByName(null, "final_destination")

        local player = null
        while (player = Entities.FindByClassname(player, "player") )
        {
            if (NetProps.GetPropInt(player, "m_lifeState") != 0 || player.GetTeam() != 2)
                continue

            player.Teleport(true, destination.GetOrigin(), true, QAngle(0, 90, 0), true, Vector(0,0,0))
        }



    }
    //Win
    if (TriggerWin && wegacount == 0)
    {
        GameText = null
        TriggerWin = true

        local player = null
        local matpath = "wega/win_f.vmt"

        //Deduct spawn freeze time
        TotalTime -= 5

        //Multiplayer penalty
        if (PlayersCount > 1)
        {
            TotalTime *= 1.2

        //Size modifiers
        switch (Size)
        {
            case 4:
            TotalTime *= 1.8
            break
            case 5:
            TotalTime *= 1.4
            break
            case 6:
            TotalTime *= 1.2
            break
            case 7:
            TotalTime *= 1.1
            break
            case 8:
            TotalTime *= 1.0
            break
            case 9:
            TotalTime *= 1.0
            break
            case 10:
            TotalTime *= 0.9
            break
            case 11:
            TotalTime *= 0.8
            break
        }
        }


        //ranks (F by default)
        //E
        if (TotalTime < 200)
            matpath = "wega/win_e.vmt"
        //D
        if (TotalTime < 180)
            matpath = "wega/win_d.vmt"
        //C
        if (TotalTime < 160)
            matpath = "wega/win_c.vmt"
        //B
        if (TotalTime < 150)
            matpath = "wega/win_b.vmt"
        //A
        if (TotalTime < 135)
            matpath = "wega/win_a.vmt"
        //S
        if (TotalTime < 125)
            matpath = "wega/win_s.vmt"

        while (player = Entities.FindByClassname(player, "player") )
        {
            player.SetScriptOverlayMaterial(matpath)
        }
        EntFire("relay_win", "Trigger")
        CanLose = false

    }

    TotalTime <- TotalTime + FrameTime()

    return -1
}

function AddWegas()
{
    local maker = Entities.FindByName(null, "wega_maker")
    maker.SpawnEntityAtLocation(Vector(-1*CellWidth,-1*CellWidth,0), Vector(0,0,0))

    local multmaker = Entities.FindByName(null, "multiplayer_wega_maker")

    //How many wegas?
    local playerCount = GetActivePlayerCount()
    local extraWegas = 0

    //Multi only
    if (playerCount > 1)
    {
        extraWegas = floor(sqrt(playerCount*4))

        if (extraWegas + 1 > playerCount)
            extraWegas = playerCount - 1
    }
    //Above 20
    if (playerCount > 20)
    {
        extraWegas = ceil(playerCount / 3.0)
        extraWegas++
    }

    local buffer = Size
    if (buffer > 7)
        buffer = 8

    for (local i = 0; i < extraWegas ; i++)
    {
        local rnd = RandomInt(1, 4)
        switch (rnd)
        {
        case 1:
        multmaker.SpawnEntityAtLocation(Vector((buffer)*CellWidth,-1*CellWidth,0), Vector(0,0,0))
        break
        case 2:
        multmaker.SpawnEntityAtLocation(Vector(-1*CellWidth,-1*CellWidth,0), Vector(0,0,0))
        break
        case 3:
        multmaker.SpawnEntityAtLocation(Vector(-1*CellWidth,(buffer)*CellWidth,0), Vector(0,0,0))
        break
        case 4:
        multmaker.SpawnEntityAtLocation(Vector((buffer)*CellWidth,(buffer)*CellWidth,0), Vector(0,0,0))
        break
        }
    }
}

function GetActivePlayerCount()
{
    local playerCount = 0
    local player = null
    while (player = Entities.FindByClassname(player, "player") )
    {
        if (player.GetTeam() == 2 || player.GetTeam() == 3)
            playerCount++
    }
    return playerCount
}

function DisableRespawns()
{
    AllowRespawn = false
}

ClearGameEventCallbacks()

function OnGameEvent_player_spawn(params)
{
    Convars.SetValue("mp_waitingforplayers_cancel", 1)
    local player = GetPlayerFromUserID(params.userid)
    if (player == null && player.GetTeam() != 2)
		return

    if (!AllowRespawn)
         player.TakeDamage(999999.0, 0, null)

    
    NetProps.SetPropInt(player, "m_Shared.m_iDesiredPlayerClass", 1)
    NetProps.SetPropInt(player, "m_Shared.m_iClass", 1)
    player.SetPlayerClass(1)
    if (player.GetTeam() == 3)
        player.ForceChangeTeam(2, true)

    player.Regenerate(false)

    AddThinkToEnt(player, "Wega_player_tick")

    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_WEAPONSELECTION)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_FLASHLIGHT)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_HEALTH)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_MISCSTATUS)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_CROSSHAIR)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_BONUS_PROGRESS)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_BUILDING_STATUS)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_CLOAK_AND_FEIGN)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_PIPES_AND_CHARGE)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_METAL)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_TARGET_ID)
    player.AddHudHideFlags(Constants.FHideHUD.HIDEHUD_MATCH_STATUS)
    player.SetScriptOverlayMaterial("wega/wega_counter.vmt")

}

function OnGameEvent_player_death(params)
{
    EntFire("wega_script", "RunScriptCode", "CheckRoundStats()", 0.5, null)

    local player = GetPlayerFromUserID(params.userid)
    if (player == null && player.GetTeam() != 2)
		return

    if (AllowRespawn == true && PlayersCount != 1)
        EntFireByHandle(player, "RunScriptCode", "self.ForceRegenerateAndRespawn()", 1.1, player, player)
        
}

function OnGameEvent_player_disconnect(params)
{
    EntFire("wega_script", "RunScriptCode", "CheckRoundStats()", 0.5, null)
}

function OnGameEvent_player_changeclass(params)
{
    EntFire("wega_script", "RunScriptCode", "CheckRoundStats()", 0.5, null)
}


function CheckRoundStats()
{
    if ((AllowRespawn && PlayersCount != 1) || CanLose == false || PlayersCount == 0)
        return

    local playersalive = 0
    local player = null
    while (player = Entities.FindByClassname(player, "player") )
    {
        if (NetProps.GetPropInt(player, "m_lifeState") != 0 || player.GetTeam() != 2)
            continue

        playersalive++
    }

    if (playersalive == 0)
    {
        while (player = Entities.FindByClassname(player, "player") )
        {
            player.SetScriptOverlayMaterial("wega/gameover.vmt")
        }
        EntFire("relay_lose", "Trigger")
        GameText = null
    }
}

function OnGameEvent_post_inventory_application(params)
{

    EntFire("tf_wearable_vm", "Kill")
	if ("userid" in params)
	{
		local player = GetPlayerFromUserID(params.userid)	//grab player ID...

        for (local i = 0; i < 7; i++)
        {
            local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i);
            if (weapon == null || i == 2)
                continue;
            weapon.Kill()
        }

        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
        {
            if (wearable.GetModelName().find("mvm_loot") || wearable.GetModelName().find("xmas") )
                EntFireByHandle(wearable, "Kill", "", 0.0, null, null)
        }

  
    local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 2);

    if (weapon == null)
        weapon = GiveDefaultBat(player)

    NetProps.SetPropBool(weapon, "m_bBeingRepurposedForTaunt", true)
    weapon.SetModelSimple("")
    weapon.SetCustomViewModel("models\\wega\\hands.mdl")

    weapon.AddAttribute("no_attack", 1.0, -1)
    weapon.AddAttribute("increased jump height", 0.0, -1)

    weapon.AddAttribute("move speed bonus", 1.07, -1)

    NetProps.SetPropInt(weapon, "m_nRenderMode", 4)
    NetProps.SetPropInt(weapon, "m_clrRender", 0)
    NetProps.SetPropInt(weapon, "m_nRenderFX", 0)
    player.Weapon_Switch(weapon)
    }
	
}

__CollectGameEventCallbacks(this)

function GiveDefaultBat(player)
{
    local weapon = Entities.CreateByClassname("tf_weapon_bat")
    NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 0)
    NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
    NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
    weapon.SetTeam(player.GetTeam())
    weapon.DispatchSpawn()

    player.Weapon_Equip(weapon)
    player.Weapon_Switch(weapon)

    return weapon
}

::Wega_player_tick <- function()
{

if (NetProps.GetPropInt(self, "m_lifeState") != 0 || self.GetTeam() != 2)
    return 10

local origin = self.GetOrigin()
origin.z += 54.0
local wega = null

wega = Entities.FindByClassnameNearest("prop_dynamic", origin, 80.0)

if (wega != null)
{
    EntFireByHandle(wega, "FireUser1", null, 0.0, self, self)
}

return 0.05

}

function WegaCollected()
{
    caller.Kill()
    wegacount--

    if (wegacount > 1)
        EmitSoundEx({
	sound_name = "wega/Baseball hit.mp3",
	entity = activator,
	filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_SINGLE_PLAYER
    })
}

function JumpscareUrio()
{
    EmitSoundEx({
	sound_name = "npc/stalker/go_alert2a.wav",
	entity = activator,
	filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_SINGLE_PLAYER
    })
    activator.SetScriptOverlayMaterial("wega/uario_jumpscare.vtf")

    EntFireByHandle(activator, "RunScriptCode", "self.TakeDamage(1000, Constants.FDmgType.DMG_SLASH, null)", 1.5, null, null);
    EntFireByHandle(activator, "RunScriptCode", "self.SetScriptOverlayMaterial(``)", 1.5, null, null);
}

::ToggleAggroClosest <- function()
{
    if (AggroClosest)
        AggroClosest = false
    else
        AggroClosest = true
}

::IncreaseWegaSpeedByOne <- function()
{
    for (local i = 0; i < WegaArray.len(); i++)
    {
        WegaArray[i].speed++
    }
}