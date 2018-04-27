Lunar = {}

--SystemData.ChatLogFilters.SKILL_CHANGE = 10001
--SystemData.ChatLogFilters.STAT_CHANGE  = 10002

--PrintWStringToChatWindow(L"text1",SystemData.ChatLogFilters.SKILL_CHANGE)

-- RegisterEventHandler(SystemData.Events.PLAYER_SKILLS_UPDATED, "Lunar.HandleSkillUpdate")
-- RegisterEventHandler(WindowData.SkillDynamicData.Event, "Lunar.UpdateSkill")

-- WindowRegisterEventHandler( "Lunar", WindowData.SkillDynamicData.Event, "Lunar.HandleSkillUpdate")

-- -- ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.SKILL_CHANGE]   = SwitchText( L"/asdf ", L"[SKILL_CHANGE]:" )
-- -- ChatSettings.ChannelSwitches[ SystemData.ChatLogFilters.STAT_CHANGE]   = SwitchText( L"/asd2 ", L"[STAT_CHANGE]:" )

-- ChatSettings.Channels[ SystemData.ChatLogFilters.SKILL_CHANGE]   = ChatChannel(L"SkChange",        SystemData.ChatLogFilters.SKILL_CHANGE,       "Chat",     true,           true,                false,       ChannelColor(75, 120, 230),      SystemData.ChatLogFilters.SKILL_CHANGE,  nil )
-- ChatSettings.Channels[ SystemData.ChatLogFilters.STAT_CHANGE]    = ChatChannel(L"StChange",        SystemData.ChatLogFilters.STAT_CHANGE,        "Chat",     true,           true,                false,       ChannelColor(75, 120, 230),      SystemData.ChatLogFilters.STAT_CHANGE,  nil )

Debug.Print("--- Lunar.lua loaded!")
--Debug.Print(ChatSettings.Channels)
--PrintWStringToChatWindow(L"text2",SystemData.ChatLogFilters.SKILL_CHANGE)
Debug.Print("-------------------------------------------")

function Lunar.TestOverhead(text)
    WindowUtils.SendOverheadText(text, 1152, false)
end

function Lunar.HandleSkillUpdate()
    local skillId = WindowData.UpdateInstanceId
    Debug.Print("skill update; skill id: " .. tostring(skillId))
end

function Lunar.UpdateSkill()
    -- local skillId = WindowData.UpdateInstanceId
    Debug.Print("UpdateSkill() event; skill id: ")
end

function Lunar.TestChat()
   Debug.Print(ChatSettings.Channels)
end

function Lunar.Init()
    if (ChatSettings == nil) then
        ChatSettings = {}
        ChatSettings.Channels = {}
        ChatSettings.ChannelColors = {}
    end

    --ChatSettings.Channels[ SystemData.ChatLogFilters.SKILL_CHANGE]   = ChatChannel(L"SkChange",        SystemData.ChatLogFilters.SKILL_CHANGE,       "Chat",     true,           true,                false,       ChannelColor(75, 120, 0),      SystemData.ChatLogFilters.SKILL_CHANGE,  nil )
    --ChatSettings.Channels[ SystemData.ChatLogFilters.STAT_CHANGE]    = ChatChannel(L"StChange",        SystemData.ChatLogFilters.STAT_CHANGE,        "Chat",     true,           true,                false,       ChannelColor(75, 120, 0),      SystemData.ChatLogFilters.STAT_CHANGE,  nil )
    --ChatSettings.ChannelColors[SystemData.ChatLogFilters.SKILL_CHANGE] = { r = 12, g = 128, b = 12}
    --ChatSettings.ChannelColors[SystemData.ChatLogFilters.STAT_CHANGE] = { r = 12, g = 128, b = 12}

    --WindowRegisterEventHandler("Lunar", WindowData.SkillDynamicData.Event, "Lunar.HandleSkillUpdate")
    --RegisterEventHandler(SystemData.Events.PLAYER_SKILLS_UPDATED, "Lunar.UpdateSkill")
    
    UO_GenericGump.DEBUG_ON = true
end

function Lunar.Initialize()
    -- WindowUtils.LoadSettings( "Lunar" )
    Lunar.Init()
end

function Lunar.Shutdown()
    -- WindowUtils.SaveSettings( "Lunar" )
end

function Lunar.HideWindow()
    WindowSetShowing("Lunar", false )
end

-- debug tools
local seen={}

function Lunar.Dump(t, i)
    seen[t]=true
    local s={}
    local n=0
    for k in pairs(t) do
        n=n+1 s[n]=k
    end
    table.sort(s)
    for k,v in ipairs(s) do
        Debug.Print(v)
        v=t[v]
        if type(v)=="table" and not seen[v] then
            Lunar.Dump(v, i .. "\t")
        end
    end
end