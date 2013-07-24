--[[
	comboClass.lua, a la FruityBatmanSlippers

	A class-esque object designed for making combo scripts easily.
	IDK why lua doesn't have a legitimate class system, metatables is dumb. >:(
	
	
		ComboBase:new( tsMode, tsRange, tsType, oKeyList[, iTickRate=100, bDrawRange=true, iDrawColor=0x19A712])
			- Returns a new ComboBase object for your lazy coder butt. Arguments tsMode, tsRange, and tsType are the
				arguments you would normally pass to TargetSelector:new(). oKeyList is an object/table containing
				keycodes and their callbacks. bDrawRange determines whether or not a circle will be drawn around
				your champion, with the color following.
				
			- local MyUberCombo = ComboBase:new( "Akali", TARGET_LOW_HP, 800, DAMAGE_MAGIC, { {hotkey=32,callback=SomeFunction}, {hotkey=90,callback=OtherFunction} } )
			
		ComboBase:UseActives()
			- This one bakes you a pizza.
			
			- MyUberCombo:UseActives()
			  getPizza(true)
			  
	== 8/17/2012:
		I encased all the callbacks with pcall's, this way instead of crashing the game-- a LUA error will be properly displayed. Phew.
		I also added MSG_HANDLER and PROCESS_SPELL_HANDLER for convenience and uniformity
]]--

local function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)
end


	altDoFile("common/target_selector.lua")


if player == nil then
	player = GetMyHero()
end

if ComboBase == nil then
	-- Some constants for ease of use
	TICK_HANDLER 		  = 0xFF
	DRAW_HANDLER 		  = 0xFE -- If you have a clear key on your keyboard (does that even exist?) you'd have to change this.
	MSG_HANDLER  		  = 0xFD
	PROCESS_SPELL_HANDLER = 0xFC
	
	ComboBase = {}
	
	function ComboBase:new( tsMode, tsRange, tsType, oKeyList, iTickRate, bDrawRange, iDrawColor )
		ts = TargetSelector:new(tsMode, tsRange, tsType)
		iTickRate = iTickRate or 100
		bDrawRange = bDrawRange or true
		iDrawColor = iDrawColor or 0x19A712
		
		local tComboBase = 
		{
			_drawRange = tsRange,
			_bDrawRange = bDrawRange,
			_iDrawColor = iDrawColor,
			_keyCallbackList = oKeyList,
			_keysActive = {},
			Selector = ts,
			
			enum_InventorySlots =
			{
				ITEM_1,
				ITEM_2,
				ITEM_3,
				ITEM_4,
				ITEM_5,
				ITEM_6
			},
			
			OnUseItems =
			{
				{name = "Deathfire Grasp", id = 3128, onHeal = 0, percHpReq = 0.60},
				{name = "Hextech Gunblade", id = 3146, onHeal = 0, percHpReq = 0.00},
				{name = "Bilgewater Cutlass", id = 3144, onHeal = 0, percHpReq = 0.00},
				{name = "Morello's Evil Tome", id = 3165, onHeal = 1, percHpReq = 0.00},
				{name = "Executioner's Calling", id = 3123, onHeal = 1, percHpReq = 0.00},
				
				count = 5
			},
			
			HealingChampions = -- Champions to use Morello's Evil Tome on to negate healing
			[[
				Swain
				Fiddlesticks
				DrMundo
				Nunu
				Irelia
				Kayle
				MasterYi
				Olaf
				Renekton
				Ryze
				Sion
				Warwick
			]]
		}
		
		do -- tComboBase methods
			function OnWndMsg(msg, wParam)
				if msg == KEY_DOWN or KEY_UP then
					tComboBase._keysActive[wParam] = msg
				end
				
				for i=1,# tComboBase._keyCallbackList do
					if tComboBase._keyCallbackList[i].hotkey == MSG_HANDLER then
						local bDebug, err = pcall(tComboBase._keyCallbackList[i].callback, tComboBase, msg, wParam)
						if not bDebug then PrintChat(err) end
					end
				end
			end
			
			function OnTick()
				tComboBase.Selector:tick()
				
				for i=1,# tComboBase._keyCallbackList do
					if tComboBase._keysActive[tComboBase._keyCallbackList[i].hotkey] == KEY_DOWN or tComboBase._keyCallbackList[i].hotkey == TICK_HANDLER then
						local bDebug, err = pcall(tComboBase._keyCallbackList[i].callback, tComboBase)
						if not bDebug then PrintChat(err) end
					end
				end
			end
			
			function OnDraw()
				if not player.dead and tComboBase._bDrawRange then
					DrawCircle(player.x, player.y, player.z, tComboBase._drawRange, tComboBase._iDrawColor)
				end
				
				for i=1,# tComboBase._keyCallbackList do
					if tComboBase._keyCallbackList[i].hotkey == DRAW_HANDLER then
						local bDebug, err = pcall(tComboBase._keyCallbackList[i].callback, tComboBase)
						if not bDebug then PrintChat(err) end
					end
				end
			end
			
			function OnProcessSpell( from, name )
				for i=1,# tComboBase._keyCallbackList do
					if tComboBase._keysActive[tComboBase._keyCallbackList[i].hotkey] == KEY_DOWN or tComboBase._keyCallbackList[i].hotkey == TICK_HANDLER then
						local bDebug, err = pcall(tComboBase._keyCallbackList[i].callback, tComboBase, from, name, level, start, _end)
						if not bDebug then PrintChat(err) end
					end
				end
			end
			
			tComboBase.GetTarget = function()
				return tComboBase.Selector.target
			end
			
			tComboBase.UseActives = function()
				for i=1,6,1 do
					for c=1,tComboBase.OnUseItems.count,1 do
						-- I hate this block of code solely because there's a billion if statements, it rooks so ugreh
						if player:getInventorySlot(tComboBase.enum_InventorySlots[i]) == tComboBase.OnUseItems[c].id then
							if tComboBase.Selector.target ~= nil and player:CanUseSpell(tComboBase.enum_InventorySlots[i]) then
								if (tComboBase.Selector.target.health / tComboBase.Selector.target.maxHealth) >= tComboBase.OnUseItems[c].percHpReq then
									if tComboBase.OnUseItems[c].onHeal == 0 or tComboBase.HealingChampions:find(tComboBase.Selector.target.charName) then
										CastSpell(tComboBase.enum_InventorySlots[i], tComboBase.Selector.target)
									end
								end
							end
						end
					end
				end
			end
			
			tComboBase.IsKeyDown = function(key)
				return (tComboBase._keysActive[key] == KEY_DOWN)
			end
		end
		
		--BoL:addMsgHandler(tComboBase._msgHandler)
		--BoL:addTickHandler(tComboBase._tickHandler,iTickRate)
		--BoL:addDrawHandler(tComboBase._drawHandler)
		--BoL:addProcessSpellHandler(tComboBase._spellHandler)
		
		return tComboBase
	end
end
