----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ChatOptionsWindow = {}

ChatOptionsWindow.TID = { Accept=1013076,CustomColor=1111675,Red=1018351,Green=1079391,Blue=1111676,
                          TextColorHelp=1111677,TextColors=1111678,}

ChatOptionsWindow.channelListData = {}
ChatOptionsWindow.channelListOrder = {}

ChatOptionsWindow.SelectedMessageTypeIndex = 0
ChatOptionsWindow.SelectedMessageTypeWindowIndex = 0

ChatOptionsWindow.channelListCurrentStatus = {}
local wndIndex = 0
local channelChanging = false
local function InitChatOptionListData()
    ChatOptionsWindow.channelListData = {}
    local channelIndex = 0
    for channel, channelData in pairs(ChatSettings.Channels) do
        if (channelData ~= nil and channelData.name ~= nil) then
            channelIndex = channelIndex + 1
            ChatOptionsWindow.channelListData[channelIndex] = {
                    channelName = channelData.name,
                    color = ChatSettings.ChannelColors[channel],
                    logName = channelData.logName,
                    channelID = channelData.id,
                }
            
            ChatOptionsWindow.channelListCurrentStatus[channelIndex] = {
                hasChanged = false,
            }
            
        end
    end
    
    local hueR,hueG,hueB = HueRGBAValue(SystemData.Settings.Interface.SpeechHue)
    ChatOptionsWindow.channelListData[ChatOptionsWindow.SpeechHueIndex] = {
                    channelName = L"Your Speech",
                    color = {r=hueR,g=hueG,b=hueB},
                    logName = nil,
                    channelID = nil,
    }
    ChatOptionsWindow.channelListCurrentStatus[ChatOptionsWindow.SpeechHueIndex] = {
        hasChanged = false,
    }                
end

local function CompareColors( colorTable1, colorTable2 )
    if (colorTable1 == nil or colorTable2 == nil)
    then
        return
    end
    if (colorTable1.r == colorTable2.r and colorTable1.g == colorTable2.g and colorTable1.b == colorTable2.b)
    then
        return true
    else
        return false
    end
end

local function FilterChannelList()

    ChatOptionsWindow.channelListOrder = {}
    wndIndex = ChatWindow.activeWindow
    local r,g,b
    for idx, info in ipairs (ChatSettings.Ordering) do
        for dataIndex, data in ipairs( ChatOptionsWindow.channelListData ) do
            if (info == data.channelID)
            then
                table.insert(ChatOptionsWindow.channelListOrder, dataIndex)
                r,g,b = LogDisplayGetFilterColor( ChatWindow.Windows[wndIndex].Tabs[1].tabWindow, data.logName, data.channelID)
                ChatOptionsWindow.channelListData[dataIndex].color.r = r
                ChatOptionsWindow.channelListData[dataIndex].color.g = g
                ChatOptionsWindow.channelListData[dataIndex].color.b = b
                if (idx < ChatFiltersWindowList.numVisibleRows)
                then
                    -- Only fill the table with the number of labels actually visible
                    labelName = "ChatOptionsWindowListRow"..idx.."ChannelName"
                    LabelSetTextColor(labelName, 
                              r, 
                              g,
                              b)
                end
                
                break
            end
        end
    end
    
    -- do the special case for your speech
    table.insert(ChatOptionsWindow.channelListOrder, ChatOptionsWindow.SpeechHueIndex)
    labelName = "ChatOptionsWindowListRow"..ChatOptionsWindow.SpeechHueIndex.."ChannelName"
    local hueR,hueG,hueB = HueRGBAValue(SystemData.Settings.Interface.SpeechHue)
    LabelSetTextColor(labelName, 
              hueR, 
              hueG,
              hueB)    
end

local function ResetChannelList()
    -- Filter, Sort, and Update
    InitChatOptionListData()
    FilterChannelList()
    ListBoxSetDisplayOrder( "ChatOptionsWindowList", ChatOptionsWindow.channelListOrder )
    
    -- Reset variables
    ChatOptionsWindow.SelectedMessageTypeIndex = 0
    ChatOptionsWindow.SelectedMessageTypeWindowIndex = 0
end

-- OnInitialize Handler
function ChatOptionsWindow.Initialize()
    Debug.Print("init chat options")
    LabelSetText( "ChatOptionsWindowCustomColorText", GetStringFromTid(ChatOptionsWindow.TID.CustomColor) )
    LabelSetText( "ChatOptionsWindowCustomColorRedText", GetStringFromTid(ChatOptionsWindow.TID.Red) )
    LabelSetText( "ChatOptionsWindowCustomColorGreenText", GetStringFromTid(ChatOptionsWindow.TID.Green) )
    LabelSetText( "ChatOptionsWindowCustomColorBlueText", GetStringFromTid(ChatOptionsWindow.TID.Blue) )
    LabelSetText( "ChatOptionsWindowHelpHeaderText", GetStringFromTid(ChatOptionsWindow.TID.TextColorHelp) )
    ButtonSetText( "ChatOptionsWindowAcceptButton", GetStringFromTid(ChatOptionsWindow.TID.Accept) ) 
    WindowSetShowing("ChatOptionsWindowColorSelectionRing", false)
    WindowSetShowing("ChatOptionsWindowChannelSelection", false)
    ColorPickerCreateWithColorTable("ChatOptionsWindowColorPicker", ChatSettings.Colors, 4, 10, 10)
    ChatOptionsWindow.SelectedMessageTypeIndex = 0
    ChatOptionsWindow.SelectedMessageTypeWindowIndex = 0
    
    ChatOptionsWindow.SpeechHueIndex = #ChatSettings.Channels + 1
    
    WindowUtils.SetWindowTitle("ChatOptionsWindow", GetStringFromTid(ChatOptionsWindow.TID.TextColors) )
    
    WindowSetShowing( "ChatOptionsWindow", false )
end

function ChatOptionsWindow.Shutdown()
	WindowSetShowing( "ChatOptionsWindow", false )
end

function ChatOptionsWindow.Hide()
    WindowSetShowing("ChatOptionsWindowColorSelectionRing", false)
    WindowSetShowing("ChatOptionsWindowChannelSelection", false)
    WindowSetShowing( "ChatOptionsWindow", false )
end
function ChatOptionsWindow.ClearSelectionImage()
    WindowSetShowing("ChatOptionsWindowChannelSelection", false)
end
function ChatOptionsWindow.OnShown()
    ResetChannelList()
    ChatOptionsWindow.UpdateChatOptionRow()
end

function ChatOptionsWindow.OnHidden()
end

-- Callback from the <List> that updates a single row.
function ChatOptionsWindow.UpdateChatOptionRow()
    if (ChatOptionsWindowList.PopulatorIndices ~= nil) then
        local active = false
        local labelName
        local tab = ChatWindow.GetMenuTab()
        for rowIndex, dataIndex in ipairs(ChatOptionsWindowList.PopulatorIndices) do
			local r,g,b
			labelName = "ChatOptionsWindowListRow"..rowIndex.."ChannelName"
			if( rowIndex == ChatOptionsWindow.SpeechHueIndex ) then
				r,g,b = HueRGBAValue(SystemData.Settings.Interface.SpeechHue)
			else
				r,g,b = LogDisplayGetFilterColor( ChatWindow.Windows[wndIndex].Tabs[1].tabWindow, 
									ChatOptionsWindow.channelListData[dataIndex].logName, 
									ChatOptionsWindow.channelListData[dataIndex].channelID)
			end
			
			LabelSetTextColor(labelName, 
				  r, 
				  g,
				  b)
        end
    end
end

function ChatOptionsWindow.OnLButtonUpChannelLabel()

    local windowIndex = WindowGetId (SystemData.ActiveWindow.name)
    local windowParent = WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex = ListBoxGetDataIndex (WindowGetParent (windowParent), windowIndex)

    local targetRowWindow = "ChatOptionsWindowListRow"..windowIndex
    
    if (ChatOptionsWindow.SelectedMessageTypeWindowIndex ~= windowIndex) then
        ChatOptionsWindow.SelectedMessageTypeWindowIndex = windowIndex
        ChatOptionsWindow.SelectedMessageTypeIndex = dataIndex
        WindowSetShowing("ChatOptionsWindowChannelSelection", true)
        WindowClearAnchors("ChatOptionsWindowChannelSelection")
        WindowAddAnchor( "ChatOptionsWindowChannelSelection", "topleft", "ChatOptionsWindowListRow"..windowIndex, "topleft", -5, 2 )
        WindowAddAnchor( "ChatOptionsWindowChannelSelection", "bottomright", "ChatOptionsWindowListRow"..windowIndex, "bottomright", -20, 0 )
    end
    
    local x, y = ColorPickerGetCoordinatesForColor("ChatOptionsWindowColorPicker", ChatOptionsWindow.channelListData[dataIndex].color.r,
                                                                                   ChatOptionsWindow.channelListData[dataIndex].color.g,
                                                                                   ChatOptionsWindow.channelListData[dataIndex].color.b)
    
    if (x ~= nil and y ~= nil)
    then
        WindowSetShowing("ChatOptionsWindowColorSelectionRing", true)
        WindowClearAnchors("ChatOptionsWindowColorSelectionRing")
        WindowAddAnchor( "ChatOptionsWindowColorSelectionRing", "topleft", "ChatOptionsWindowColorPicker", "topleft", x-5, y-5 ) 
    else
        WindowSetShowing("ChatOptionsWindowColorSelectionRing", false)
    end
    
    -- Set the sliders
    local color = ChatOptionsWindow.channelListData[dataIndex].color
    channelChanging = true
    local colorRatio = color.r / 255
    SliderBarSetCurrentPosition("ChatOptionsWindowCustomColorRedSlider", colorRatio )
    colorRatio = color.g / 255
    SliderBarSetCurrentPosition("ChatOptionsWindowCustomColorGreenSlider", colorRatio )
    colorRatio = color.b / 255
    SliderBarSetCurrentPosition("ChatOptionsWindowCustomColorBlueSlider", colorRatio )
    -- We've completed the slider updates, it is now safe for the user to make their custom color.
    channelChanging = false
    
    WindowSetTintColor("ChatOptionsWindowCustomColorSwatch", ChatOptionsWindow.channelListData[dataIndex].color.r,
                                                       ChatOptionsWindow.channelListData[dataIndex].color.g,
                                                       ChatOptionsWindow.channelListData[dataIndex].color.b)
    
    
    
end

function ChatOptionsWindow.OnLButtonUpColorPicker( flags, x, y )
    if (ChatOptionsWindow.SelectedMessageTypeIndex == nil or ChatOptionsWindow.SelectedMessageTypeIndex == 0)
    then
        -- No chosen filter, please exit
        return true
    end
    local color = ColorPickerGetColorAtPoint( "ChatOptionsWindowColorPicker", x, y )
    local dataIndex = ChatOptionsWindow.SelectedMessageTypeIndex
    local currentColor = ChatOptionsWindow.channelListData[dataIndex].color
    local colorRatio = 0
    -- We have a valid color
    if (color ~= nil)
    then
        LabelSetTextColor("ChatOptionsWindowListRow"..ChatOptionsWindow.SelectedMessageTypeWindowIndex.."ChannelName", 
                          color.r, 
                          color.g,
                          color.b)
        -- Set the sliders
        colorRatio = color.r / 255
        SliderBarSetCurrentPosition("ChatOptionsWindowCustomColorRedSlider", colorRatio )
        colorRatio = color.g / 255
        SliderBarSetCurrentPosition("ChatOptionsWindowCustomColorGreenSlider", colorRatio )
        colorRatio = color.b / 255
        SliderBarSetCurrentPosition("ChatOptionsWindowCustomColorBlueSlider", colorRatio )
        
        WindowSetTintColor("ChatOptionsWindowCustomColorSwatch", color.r,
                                                   color.g,
                                                   color.b)
        -- Update the position of the color ring
        WindowSetShowing("ChatOptionsWindowColorSelectionRing", true)
        WindowClearAnchors("ChatOptionsWindowColorSelectionRing")
        WindowAddAnchor( "ChatOptionsWindowColorSelectionRing", "topleft", "ChatOptionsWindowColorPicker", "topleft", color.x-5, color.y-5 )
        
        -- Update the color, and the save flag
        ChatOptionsWindow.channelListData[ChatOptionsWindow.SelectedMessageTypeIndex].color.r = color.r
        ChatOptionsWindow.channelListData[ChatOptionsWindow.SelectedMessageTypeIndex].color.g = color.g
        ChatOptionsWindow.channelListData[ChatOptionsWindow.SelectedMessageTypeIndex].color.b = color.b
        ChatOptionsWindow.channelListCurrentStatus[ChatOptionsWindow.SelectedMessageTypeIndex].hasChanged = true
    end
end

function ChatOptionsWindow.OnSetCustomColor()
    
    if (ChatOptionsWindow.SelectedMessageTypeIndex == nil or ChatOptionsWindow.SelectedMessageTypeIndex == 0)
    then
        -- No channel picked
        return
    end
    local colorRatio = 0
    local color = {
        r = 0,
        b = 0,
        g = 0,
    }
    colorRatio = SliderBarGetCurrentPosition("ChatOptionsWindowCustomColorRedSlider")
    color.r = colorRatio * 255
    colorRatio = SliderBarGetCurrentPosition("ChatOptionsWindowCustomColorGreenSlider")
    color.g = colorRatio * 255
    colorRatio = SliderBarGetCurrentPosition("ChatOptionsWindowCustomColorBlueSlider")
    color.b = colorRatio * 255
    
    -- Update the color swatch
    WindowSetTintColor("ChatOptionsWindowCustomColorSwatch", color.r,
                                                       color.g,
                                                       color.b)
                                                       
    if (channelChanging == false)
    then
        LabelSetTextColor("ChatOptionsWindowListRow"..ChatOptionsWindow.SelectedMessageTypeWindowIndex.."ChannelName", 
                                  color.r, 
                                  color.g,
                                  color.b)
        -- Update the color, and the save flag
        ChatOptionsWindow.channelListData[ChatOptionsWindow.SelectedMessageTypeIndex].color.r = color.r
        ChatOptionsWindow.channelListData[ChatOptionsWindow.SelectedMessageTypeIndex].color.g = color.g
        ChatOptionsWindow.channelListData[ChatOptionsWindow.SelectedMessageTypeIndex].color.b = color.b
        ChatOptionsWindow.channelListCurrentStatus[ChatOptionsWindow.SelectedMessageTypeIndex].hasChanged = true
    end
end

function ChatOptionsWindow.SetAllColorChanges()
    for idx=1, #ChatOptionsWindow.channelListCurrentStatus do
        if (ChatOptionsWindow.channelListCurrentStatus[idx].hasChanged == true)
        then
            -- Set the new color, and Reset the flag
            ChatOptionsWindow.SetChannelColor(idx)
            ChatOptionsWindow.channelListCurrentStatus[idx].hasChanged = false
        end
    end
    -- Update the channel Selection window with the new colors
    ChatWindow.UpdateAllChannelColors()
    -- Hide all components
    WindowSetShowing("ChatOptionsWindowColorSelectionRing", false)
    WindowSetShowing("ChatOptionsWindowChannelSelection", false)
    WindowSetShowing("ChatOptionsWindow", false)
end

function ChatOptionsWindow.SetChannelColor( channelIndex )
    local newColor = ChatOptionsWindow.channelListData[ channelIndex ].color
	if( channelIndex == ChatOptionsWindow.SpeechHueIndex ) then
		SystemData.Settings.Interface.SpeechHue = GetHueFromRGB(newColor.r, newColor.g, newColor.b)
		-- push the new values to c++
		UserSettingsChanged()
	else
		local channelId = ChatOptionsWindow.channelListData[ channelIndex ].channelID
		ChatSettings.ChannelColors[ channelId ] = newColor
		-- Loop through all the tabs and change the chat channel color for it.
		for idxW, wnd in pairs(ChatWindow.Windows) do
			for idxT, tab in pairs(wnd.Tabs) do
				LogDisplaySetFilterColor(tab.tabWindow,
										 ChatOptionsWindow.channelListData[channelIndex].logName,
										 channelId, 
										 newColor.r, newColor.g, newColor.b ) 
			end
		end
	end
end
