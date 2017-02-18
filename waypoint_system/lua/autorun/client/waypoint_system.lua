/*
    Waypoint system by Hackcraft STEAM_0:1:50714411

    You may have seen this before and that's because it's in some client side scripts(cheats)
*/

local add_wp_concommand = "waypoint_addpoints"
local remove_wp_concommand = "waypoint_removepoints"
local save_wp_concommand = "waypoint_savepoints"
local all_wp_command = "waypoint_allpoints"
local surface = table.Copy(surface)

--[[ Data saving ]]--
local dataFile = "waypointsystem.txt"
local waypointData = {}
 
--[[        Waypoint stuff      ]]--
local waypoints = {}
local wayp_n = "Name"
local ChosenColor = Color( 255,255,255,255 )
 
--[[ Fast functions ]]--
local function wp_added_msg( name, colour )
    chat.AddText( colour, "Waypoint '" .. name .. "' has been added!" )
    surface.PlaySound( "npc/turret_floor/active.wav" )
end
local function wp_removed_msg( name, colour )
    chat.AddText( colour, "Waypoint '" .. name .. "' has been removed!" )
    surface.PlaySound( "physics/concrete/concrete_block_impact_hard1.wav" )
end
 
--[[ Waypoint font ]]--
surface.CreateFont( "Waypoint_big", {
    font = "DermaLarge",
    size = 600,
    weight = 5000,
    antialias = true,
} )

--[[ Remove waypoints ]]--
local function remove_waypoints( name )
	for k, v in ipairs(waypoints) do
		if v[3] == name then
			table.remove( waypoints, k )
			wp_removed_msg( name, v[2] )
			break
		end
	end
end
 
--[[ Draw waypoints ]]--
local function waypoint_draw()
    for k, v in ipairs( waypoints ) do
        local angles = LocalPlayer():EyeAngles()
        local distance = v[1]:Distance(LocalPlayer():GetPos())
        local distance_m = math.Round(distance / 39.370)
           
        local text = v[3] .. " [" .. distance_m .. "m]" 
        surface.SetFont("Waypoint_big")
        local TextWidth_wp = surface.GetTextSize(text)
        local xy = distance/10 + 100
 
        angles:RotateAroundAxis(angles:Forward(), 90)
        angles:RotateAroundAxis(angles:Right(), 90)
 //       angles:RotateAroundAxis(angles:Up(), 0)
           
        cam.Start3D2D(v[1], angles, 0.1)
            cam.IgnoreZ(true)
            draw.RoundedBox( 0, -xy/2, (-xy/2)*2, xy, xy, v[2] )
            draw.WordBox(2, -TextWidth_wp*0.5, 0, text, "Waypoint_big", Color(0, 0, 0, 150), v[2])
            cam.IgnoreZ(false)
        cam.End3D2D()
    end
end
hook.Add("PostDrawOpaqueRenderables", "waypoint_draw", waypoint_draw) --PostDrawOpaqueRenderables

--[[ Load data ]]--
local function LoadWaypoints()
	if file.Exists(dataFile, "DATA") then
		waypointData = util.JSONToTable(file.Read(dataFile, "DATA"))
	end
end
LoadWaypoints()

--[[ Save data ]]--
local function SaveWaypoints()
	file.Write(dataFile, util.TableToJSON(waypointData))
end

--[[ Get table ]]--
local function GetWaypoints(mapSpecific)
	if mapSpecific then
		local temp = {}
		local map = game.GetMap()
		for k, v in ipairs(waypointData) do
			if v.map == map then
				table.insert(temp, v)
			end
		end
		return temp
	else
		return waypointData
	end
end
 
--[[ Waypoint menu ]]--
local function AddWP(pos)
 
    local yScreenRes = 768  
    local hMod = ScrH() / yScreenRes
    pos = isvector(pos) and pos or false
 
    local Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Waypoint system" )
    Frame:SetSize( hMod*400, hMod*320 )
    if pos then
    	Frame:SetPos(pos.x, pos.y)
    else
    	Frame:Center()
    end
    Frame:MakePopup()
    Frame.Paint = function( self, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) ) 
    end
     
    local wayp_Entry = vgui.Create( "DTextEntry", Frame ) 
    wayp_Entry:SetPos( hMod*10, hMod*30 )
    wayp_Entry:SetSize( hMod*380, hMod*30 )
    wayp_Entry:SetText( wayp_n )
    wayp_Entry.OnTextChanged = function(self)
        -- 115 Character Cap
        wayp_n = self:GetValue()
        if string.len(wayp_n) > 50 then
            self:SetText(self.OldText)
            self:SetValue(self.OldText)
            self:SetCaretPos(50)
            surface.PlaySound ("common/wpn_denyselect.wav")
        else
            self.OldText = wayp_n
        end
    end
  
    local ColorPicker = vgui.Create( "DColorMixer", Frame )
    ColorPicker:SetSize( hMod*380, hMod*200 )
    ColorPicker:SetPos( hMod*10, hMod*70 )
    ColorPicker:SetPalette( true )
    ColorPicker:SetAlphaBar( true )
    ColorPicker:SetWangs( true )
    ColorPicker:SetColor( ChosenColor )
     
    local Button = vgui.Create( "DButton", Frame )
    Button:SetText( "Add waypoint" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( hMod*10, hMod*280 )
    Button:SetSize( hMod*380, hMod*30 )
    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
    end
    Button.DoClick = function()
        ChosenColor = ColorPicker:GetColor()

        table.insert( waypoints, {
        	Vector(LocalPlayer():GetShootPos() + Vector(0,0,50)),
        	ChosenColor,
        	wayp_n
        } )
       
        wp_added_msg(wayp_n, ChosenColor)
    end
 
end
concommand.Add( add_wp_concommand, AddWP )
 
--[[ Remove waypoints ]]--
local function RemoveWP(pos)
 
    local yScreenRes = 768  
    local hMod = ScrH() / yScreenRes
    pos = isvector(pos) and pos or false
     
    local Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Waypoint remover" )
    Frame:SetSize( hMod*400, hMod*320 )
    if pos then
    	Frame:SetPos(pos.x, pos.y)
    else
    	Frame:Center()
    end
    Frame:MakePopup()
    Frame.Paint = function( self, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) ) 
    end
     
    local WP_LIST = vgui.Create( "DListView", Frame )
    WP_LIST:SetPos( hMod*10, hMod*30 )
    WP_LIST:SetSize( hMod*380, hMod*240 )
    WP_LIST:SetMultiSelect( true )
    WP_LIST:AddColumn( "Waypoint" )
     
    for k, v in ipairs( waypoints ) do
        WP_LIST:AddLine( v[3] )
    end
     
    local Button = vgui.Create( "DButton", Frame )
    Button:SetText( "Remove waypoint(s)" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( hMod*10, hMod*280 )
    Button:SetSize( hMod*380, hMod*30 )
    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) ) 
    end
    Button.DoClick = function()

        for k, line in ipairs( WP_LIST:GetSelected()) do
            remove_waypoints( line:GetValue(1) )
            WP_LIST:RemoveLine( line:GetID() )
        end

    end
 
end
concommand.Add( remove_wp_concommand, RemoveWP )

--[[ Save/Load command ]]
local function SaveWP(pos)

    local yScreenRes = 768 
    local hMod = ScrH() / yScreenRes
    pos = isvector(pos) and pos or false
     
    local Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Waypoint save/load" )
    Frame:SetSize( hMod*400, hMod*360 )
    if pos then
    	Frame:SetPos(pos.x, pos.y)
    else
    	Frame:Center()
    end
    Frame:MakePopup()
    Frame.Paint = function( self, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) ) 
    end

    local AppList = vgui.Create( "DListView", Frame )
	AppList:SetMultiSelect( true )
	AppList:SetPos( hMod*10, hMod*110 )
    AppList:SetSize( hMod*380, hMod*160 )
	AppList:AddColumn( "Name" )
	AppList:AddColumn( "Map" )

	for k, v in ipairs(GetWaypoints(true)) do
		AppList:AddLine( v.name, v.map )
	end

	local Button = vgui.Create( "DButton", Frame )
    Button:SetText( "Load" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( hMod*10, hMod*70 )
    Button:SetSize( hMod*380, hMod*30 )
    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) ) 
    end
    Button.DoClick = function()

    	for k, line in ipairs( AppList:GetSelected() ) do

            local name = line:GetValue(1)
            for k, v in ipairs(waypointData) do
            	if v.name == name then

            		// To fix empty table bug
            		local data = #v.data >= 1 and v.data or util.JSONToTable(file.Read(dataFile, "DATA"))[k].data

            		for k, v in ipairs(data) do
            			table.insert( waypoints, v )
            		end
            		chat.AddText( Color(0,255,63), "[WaypointSystem] ", Color(255,255,255), "Loaded: " .. name )
            		surface.PlaySound( "npc/turret_floor/active.wav" )

            		break
            	end
            end

        end

    end

	local Button = vgui.Create( "DButton", Frame )
    Button:SetText( "Save" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( hMod*10, hMod*280 )
    Button:SetSize( hMod*380, hMod*30 )
    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) ) 
    end
    Button.DoClick = function()

    	Derma_StringRequest(
			"Save current waypoints",
			"Name for the save",
			"",
			function( text )

				table.insert( waypointData, { map = game.GetMap(), name = text , data = waypoints } )
				SaveWaypoints()
				AppList:AddLine( text, game.GetMap() )
				chat.AddText( Color(0,255,63), "[WaypointSystem] ", Color(255,255,255), "Saved: " .. text )
				surface.PlaySound( "npc/turret_floor/active.wav" )

			end,
			function( text ) print( "Cancelled input" ) end
		 )

    end

    local Button = vgui.Create( "DButton", Frame )
    Button:SetText( "Delete" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( hMod*10, hMod*320 )
    Button:SetSize( hMod*380, hMod*30 )
    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) ) 
    end
    Button.DoClick = function()

    	for k, line in ipairs( AppList:GetSelected() ) do

            local name = line:GetValue(1)
            for k, v in ipairs(waypointData) do

            	if v.name == name then

            		table.remove(waypointData, k)
            		AppList:RemoveLine( line:GetID() )

            		chat.AddText( Color(0,255,63), "[WaypointSystem] ", Color(255,255,255), "Removed: " .. name )
   					surface.PlaySound( "physics/concrete/concrete_block_impact_hard1.wav" )
   					
            		break

            	end

            end

        end
        SaveWaypoints()

    end

    // DCombo
    local DComboBox = vgui.Create( "DComboBox", Frame )
	DComboBox:SetPos( hMod*10, hMod*30 )
    DComboBox:SetSize( hMod*380, hMod*30 )
	DComboBox:SetValue( "Waypoints for the current map" )
	DComboBox:AddChoice( "Waypoints for the current map" )
	DComboBox:AddChoice( "All waypoints" )
	DComboBox.OnSelect = function( panel, index, value )

		AppList:Clear()
		local bool = DComboBox:GetValue() == "Waypoints for the current map"

		for k, v in ipairs(GetWaypoints(bool)) do
			AppList:AddLine( v.name, v.map )
		end

	end

end
concommand.Add( save_wp_concommand, SaveWP )

--[[ All derma menus ]]--
local function AllWP()

	local ScrW = ScrW()
	local ScrH = ScrH()

	local half = ScrH / 2 - ( ScrH / 768 ) * 160
	local minus = ( ScrH / 768 ) * 200
	local middle = ScrH / 2 - ( minus / 2 )

	AddWP( Vector( middle - minus, half ) )
	RemoveWP( Vector( middle + minus, half) ) 
	SaveWP( Vector( middle + minus * 3, half ) )

end
concommand.Add( all_wp_command, AllWP )


--[[ Chat command ]]--
local waypointChatFuncs = {}
waypointChatFuncs["add"] = AddWP
waypointChatFuncs["remove"] = RemoveWP
waypointChatFuncs["save"] = SaveWP
waypointChatFuncs["load"] = SaveWP
waypointChatFuncs["all"] = AllWP

// Error message
local ErrorWP = 'chat.AddText(Color(0,255,63), "[WaypointSystem] ", Color(255,255,255), "Wrong format! Use: ", '
for k, v in pairs(waypointChatFuncs) do
	ErrorWP = ErrorWP .. 'Color(0,161,255), "!waypoint ' .. k .. ' ", Color(255,255,255), "or ", '
end
ErrorWP = string.TrimRight(ErrorWP, '"or ", ')
ErrorWP = ErrorWP .. '"in chat instead!")'

local Errorfunc = CompileString( ErrorWP, "WaypointHelp" )

// Chat command hook
hook.Add( "OnPlayerChat", "WaypointSystem", function( ply, strText, bTeam, bDead )
    
    local words = string.Explode( " ", string.lower(strText) )

    if words[1] == "!waypoint" then

    	if LocalPlayer() != ply then 
    		return ""
        elseif waypointChatFuncs[words[2]] then
        	waypointChatFuncs[words[2]]()
        	return ""
        else
            Errorfunc()
            surface.PlaySound("buttons/button8.wav")
            return
        end

    end
           
end )
