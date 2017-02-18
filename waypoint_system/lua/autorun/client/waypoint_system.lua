/*
    Waypoint system by Hackcraft STEAM_0:1:50714411

    You may have seen this before and that's because it's in some client side scripts(cheats)
*/

// To do
// Waypoint text colour in chat to to be colour of the waypoint.
// Fix visual 3d2d glitch

local add_wp_concommand = "waypoint_addpoints"
local remove_wp_concommand = "waypoint_removepoints"
 
--[[        waypoint stuff      ]]--
local waypoints = {}
local wayp_n = "Name"
local ChosenColor = Color( 255,255,255,255 )
 
--[[ fast functions ]]--
local function wp_added_msg( name )
    chat.AddText( waypoints[name][2], "Waypoint '" .. name .. "' has been added!" )
    surface.PlaySound( "npc/turret_floor/active.wav" )
end
local function wp_removed_msg( name )
    chat.AddText( waypoints[name][2], "Waypoint '" .. name .. "' has been removed!" )
    surface.PlaySound( "physics/concrete/concrete_block_impact_hard1.wav" )
end
 
--[[ Waypoint font ]]--
surface.CreateFont( "Waypoint_big", {
    font = "DermaLarge",
    size = 600,
    weight = 5000,
    antialias = true,
} )

--[[ remove waypoints ]]--
local function remove_waypoints( name )
    waypoints[name] = nil
    wp_removed_msg( name )
end
 
--[[ draw waypoints ]]--
local function waypoint_draw()
    for k, v in pairs( waypoints ) do
        local angles = LocalPlayer():EyeAngles()
        local distance = waypoints[k][1]:Distance(LocalPlayer():GetPos())
        local distance_m = math.Round(distance / 39.370)
           
        local text = k .. " [" .. distance_m .. "m]" 
        local TextWidth_wp = surface.GetTextSize(text)
        local xy = distance/10 + 100
 
        angles:RotateAroundAxis(angles:Forward(), 90)
        angles:RotateAroundAxis(angles:Right(), 90)
        angles:RotateAroundAxis(angles:Up(), 0)
           
        cam.Start3D2D(waypoints[k][1], angles, 0.1)
            cam.IgnoreZ(true)
            draw.RoundedBox( 0, -xy/2, (-xy/2)*2, xy, xy, waypoints[k][2] )
            draw.WordBox(2, -TextWidth_wp*0.5, 0, text, "Waypoint_big", Color(0, 0, 0, 150), waypoints[k][2])
            cam.IgnoreZ(false)
        cam.End3D2D()
    end
end
hook.Add("PostDrawOpaqueRenderables", "waypoint_draw", waypoint_draw) --PostDrawOpaqueRenderables
 
--[[ waypoint menu ]]--
concommand.Add( add_wp_concommand, function( ply, cmd, args, argStr )
 
    local xScreenRes = 1366
    local yScreenRes = 768
    local wMod = ScrW() / xScreenRes    
    local hMod = ScrH() / yScreenRes
 
    local Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Waypoint system" )
    Frame:SetSize( wMod*400, hMod*320 )
    Frame:Center()
    Frame:MakePopup()
    Frame.Paint = function( self, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) ) 
    end
     
    local wayp_Entry = vgui.Create( "DTextEntry", Frame ) 
    wayp_Entry:SetPos( wMod*10, hMod*30 )
    wayp_Entry:SetSize( wMod*380, hMod*30 )
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
    ColorPicker:SetSize( wMod*380, hMod*200 )
    ColorPicker:SetPos( wMod*10, hMod*70 )
    ColorPicker:SetPalette( true )
    ColorPicker:SetAlphaBar( true )
    ColorPicker:SetWangs( true )
    ColorPicker:SetColor( ChosenColor )
     
    local Button = vgui.Create( "DButton", Frame )
    Button:SetText( "Add waypoint" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( wMod*10, hMod*280 )
    Button:SetSize( wMod*380, hMod*30 )
    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) ) -- Draw a blue button
    end
    Button.DoClick = function()
        ChosenColor = ColorPicker:GetColor()

        waypoints[wayp_n] = {}
 
        table.insert( waypoints[wayp_n], Vector(LocalPlayer():GetShootPos() + Vector(0,0,50)) )
        table.insert( waypoints[wayp_n], Color(ChosenColor.r,ChosenColor.g,ChosenColor.b,ChosenColor.a) )
       
        wp_added_msg(wayp_n)
    end
 
end)
 
--[[ remove waypoints ]]--
concommand.Add( remove_wp_concommand, function()
 
    local xScreenRes = 1366
    local yScreenRes = 768
    local wMod = ScrW() / xScreenRes    
    local hMod = ScrH() / yScreenRes
     
    local Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Waypoint remover" )
    Frame:SetSize( wMod*400, hMod*320 )
    Frame:Center()
    Frame:MakePopup()
    Frame.Paint = function( self, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) ) 
    end
     
    local WP_LIST = vgui.Create( "DListView", Frame )
    WP_LIST:SetPos( wMod*10, hMod*30 )
    WP_LIST:SetSize( wMod*380, hMod*240 )
    WP_LIST:SetMultiSelect( true )
    WP_LIST:AddColumn( "Waypoint" )
     
    for k, v in pairs( waypoints ) do
        WP_LIST:AddLine( k )
    end
     
    local Button = vgui.Create( "DButton", Frame )
    Button:SetText( "Remove waypoint(s)" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( wMod*10, hMod*280 )
    Button:SetSize( wMod*380, hMod*30 )
    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) ) -- Draw a blue button
    end
    Button.DoClick = function()
        for k, line in ipairs( WP_LIST:GetSelected()) do
            wp_removed_msg( line:GetValue(1) )
            waypoints[line:GetValue(1)] = nil
            WP_LIST:RemoveLine( line:GetID() )
        end
    end
 
end)

--[[ Chat command ]]--
hook.Add( "OnPlayerChat", "ping_pong", function( ply, strText, bTeam, bDead )
    
    if LocalPlayer() != ply then return end

    local words = string.Explode( " ", string.lower(strText) )

    if words[1] == "!waypoint" then
        
        if words[2] == "add" then
            RunConsoleCommand(add_wp_concommand)
        elseif words[2] == "remove" then 
            RunConsoleCommand(remove_wp_concommand)
        else
            chat.AddText(Color(0,255,63), "[WaypointSystem] ", Color(255,255,255), "Wrong format! Use '!waypoint add' or '!waypoint remove' in chat instead!")
        end

    end
           
end )