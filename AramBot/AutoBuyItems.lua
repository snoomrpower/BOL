--[[---------------------------------------
Auto Buy Items
BETA

The purpose of this script is that upon playing a game, the script will auto buy the correct items for the character you are playing.
You also get an overlay which tells you what you buy if you would be near the shop.

UPON FIRST START, A CONFIG WILL CREATE ITSELF IN THE SCRIPT FOLDER

Thanks to Levest28 who tested the Script and helped me completing the Lists of Items you will buy.
Thanks to Sergio_G whom Coordinates I use to differentiate between Maps.

ToDo List:
- Add GUI -> Change Items, and Itempresets ingame
- Change the way Itemlists are loaded for later manipulation and easier editing
-----------------------------------------]]
--[[Globals]]
FramesPerSecond = 0
if not SCRIPT_PATH then SCRIPT_PATH = "C:\\Users\\gReY\\Documents\\lolscripts\\AutoBuyItems\\Scripts\\" end
dofile(SCRIPT_PATH .. "Common\\AutoBuyItems_ItemDB.lua")
--Tables and Values for PreCalculation
PreInventory = { 0, 0, 0, 0, 0, 0, }
PreInventoryCount = { 0, 0, 0, 0, 0, 0, }
PreItemList1 = {}
PreGold = 0

--Tables and Values for current State
Inventory = { 0, 0, 0, 0, 0, 0, }
InventoryCount = { 0, 0, 0, 0, 0, 0, }

--Calculated and drawn Tables
ItemsToBuy = {}
ItemsToSell = {}
NextItem = nil
NextItemPrice = nil

--User defined Item Lists -> function getItemList()
ItemList1 = nil --hotfix, dofile cant overwrite globals anymore
ItemList2 = {}
ItemList3 = {}

-----------------------------------------
item = {}
item.Name = function(id)
    if ItemDB[id] then return ItemDB[id][1] end
    return nil
end

item.Recipe = function(id)
    if ItemDB[id] then return ItemDB[id][3] end
    return {}
end

item.ID = function(name)
    if type(name) == "number" then return ItemDB[name] and name or nil end
    for k, v in pairs(ItemDB) do
        if name == v[1] then return k end
    end
    return nil
end

-----------------------------------------
item.IngredientPrice = function(id)
    return ItemDB[id] and ItemDB[id][2] or 0
end

item.PriceFull = function(id)
    local recipe = item.Recipe(id)
    local price = item.IngredientPrice(id)
    if recipe then
        for i, v in ipairs(recipe) do price = price + item.PriceFull(v) end
    end
    return price
end

item.SellPrice = function(id)
    if id == 1055 or id == 1056 or id == 1054 or id == 3093 or id == 3132 or id == 3096 or id == 3098 then
        return math.floor(item.PriceFull(id) * 0.5)
    else
        return math.floor(item.PriceFull(id) * 0.7)
    end
end

-----------------------------------------
item.IsInList = function(list, id)
    if list == PreInventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local count = 0
            for i, v in ipairs(list) do
                if v == id then count = count + PreInventoryCount[i] end
            end
            return count
        end

    elseif list == Inventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local count = 0
            for i, v in ipairs(list) do
                if v == id then count = count + InventoryCount[i] end
            end
            return count
        end
    end

    local count = 0
    for i, v in ipairs(list) do
        if v == id then count = count + 1 end
    end
    return count
end

item.IsInPreInventorySlot = function(id, slot)
    if PreInventory[slot] == id then return PreInventoryCount[slot]
    else return 0
    end
end
-----------------------------------------
item.RemoveFromList = function(list, id, amount)
    local amount = amount or 1
    if list == PreInventory then
        for i, v in ipairs(PreInventory) do
            if v == id then
                if PreInventoryCount[i] > 0 then PreInventoryCount[i] = PreInventoryCount[i] - amount end
                if PreInventoryCount[i] <= 0 then PreInventory[i] = 0 PreInventoryCount[i] = 0 end
                break
            end
        end
    elseif list == Inventory then
        for i, v in ipairs(Inventory) do
            if v == id then
                if InventoryCount[i] > 0 then InventoryCount[i] = InventoryCount[i] - amount end
                if InventoryCount[i] <= 0 then Inventory[i] = 0 InventoryCount[i] = 0 end
                break
            end
        end
    else for i = 1, amount, 1 do
        for i, v in ipairs(list) do
            if v == id then table.remove(list, i) break end
        end
    end
    end
end

item.AddToList = function(list, id, amount)
    local amount = amount or 1
    if list == PreInventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local z
            if id == 2004 or id == 2003 then z = 9
            elseif id == 2043 or id == 2044 then z = 5
            elseif id == 2037 or id == 2039 or id == 2038 then z = 3
            end
            if item.IsInList(PreInventory, id) < z then --ToDo add function isInInventorySlot<n else goto next
                for i, v in ipairs(PreInventory) do
                    if v == id then
                        PreInventoryCount[i] = PreInventoryCount[i] + amount
                        return
                    end
                end
            end
        end
        for i, v in ipairs(PreInventory) do
            if v == 0 then
                PreInventory[i] = id
                PreInventoryCount[i] = (PreInventoryCount[i] or 0) + amount
                return
            end
        end
    elseif list == Inventory then
        if id == 2043 or id == 2044 or id == 2004 or id == 2003 or id == 2037 or id == 2039 or id == 2038 then
            local z
            if id == 2004 or id == 2003 then z = 9
            elseif id == 2043 or id == 2044 then z = 5
            elseif id == 2037 or id == 2039 or id == 2038 then z = 3
            end
            if item.IsInList(Inventory, id) < z then --ToDo add function isInInventorySlot<n else goto next
                for i, v in ipairs(Inventory) do
                    if v == id then
                        InventoryCount[i] = InventoryCount[i] + amount
                        return
                    end
                end
            end
        end
        for i, v in ipairs(Inventory) do
            if v == 0 then
                Inventory[i] = id
                InventoryCount[i] = (InventoryCount[i] or 0) + amount
                return
            end
        end
    else
        for i = 1, amount, 1 do
            table.insert(list, id)
        end
    end
end

-- PRECALCULATION; Mostly based on Recursion

item.Price = function(id)
    local price = 0
    for i, v in ipairs(item.RemainingIngredientsToBuy(id)) do
        price = price + item.IngredientPrice(v)
    end
    return price
end
-----------------------------------------
function item.Ingredients(id)
    local ingredients = {} --zutaten eines items inklusive sich selbst
    table.insert(ingredients, id)
    for i, v in ipairs(item.Recipe(id)) do
        if item.Ingredients(v) then
            for i, v in ipairs(item.Ingredients(v)) do
                table.insert(ingredients, v)
            end
        end
    end
    return ingredients
end

function item.IsIngredient(itemid, ingredientid)
    local recipe = item.Recipe(itemid)
    for k, v in pairs(recipe) do
        if v == ingredientid or item.IsIngredient(v, ingredientid) then return true end
    end
    return false
end

-- zutaten eines items, die nicht verkauft werden sollten(wenn in inventar)

function item.GetReserved()
    local function Reserved(id)
        local reserve = {}
        table.insert(reserve, id)
        if item.IsInList(PreInventory, id) == 0 then
            for i, v in ipairs(item.Recipe(id)) do
                for i, ingredient in ipairs(Reserved(v)) do
                    table.insert(reserve, ingredient)
                end
            end
        end
        return reserve
    end

    local reserve = {}
    for i, v in ipairs(ItemList2) do
        for i, item in ipairs(Reserved(v)) do
            table.insert(reserve, item)
        end
    end
    for i, v in ipairs(ItemList3) do
        if player.level >= v[4] and player.level <= v[5] and item.IsInList(PreInventory, v[1]) <= v[2] then item.AddToList(reserve, v[1]) end
    end
    return reserve
end

function item.IsReserved(id)
    if item.IsInList(item.GetReserved(), id) == 0 or item.IsInList(PreInventory, id) > item.IsInList(item.GetReserved(), id) then return false
    else return true
    end
end

-----------------------------------------
function item.RemainingIngredientsToBuy(id)
    local PreInventoryCopy = table.copy(PreInventory)
    local function RemainingCalculator(id)
        local remaining = {}
        if item.IsInList(PreInventoryCopy, id) > 0 then
            for i, v in ipairs(PreInventoryCopy) do if v == id then PreInventoryCopy[i] = 0 break end end
        else table.insert(remaining, id)
        for i, v in ipairs(item.Recipe(id)) do
            for i, v in ipairs(RemainingCalculator(v)) do
                table.insert(remaining, v)
            end
        end
        end
        return remaining
    end

    local remaining = { id, }
    for i, v in ipairs(item.Recipe(id)) do
        for i, v in ipairs(RemainingCalculator(v)) do
            table.insert(remaining, v)
        end
    end
    return remaining
end

-----------------------------------------
function item.DisappearingItems(id)
    local disappearing = {}
    for i, ingredient in ipairs(item.Recipe(id)) do
        if item.IsInList(PreInventory, ingredient) == 0 then
            if item.DisappearingItems(ingredient) then
                for i, v in ipairs(item.DisappearingItems(ingredient)) do
                    table.insert(disappearing, v)
                end
            end
        else table.insert(disappearing, ingredient)
        end
    end
    return disappearing
end

function table.copy(from)
    if from == nil or type(from) ~= "table" then return end
    local to = {}
    for k, v in pairs(from) do
        to[k] = v
    end
    return to
end

-----------------------------------------
local function deleteDoubleItems()
    if #ItemsToBuy > 0 and #ItemsToSell > 0 then
        local ItemsToSellold = table.copy(ItemsToSell)
        for i, v in ipairs(ItemsToBuy) do
            PreGold = PreGold - item.SellPrice(v) * item.IsInList(ItemsToSell, v)
            item.RemoveFromList(ItemsToSell, v, item.IsInList(ItemsToSell, v))
        end
        for i, v in ipairs(ItemsToSellold) do
            PreGold = PreGold + item.Price(v) * item.IsInList(ItemsToBuy, v)
            item.RemoveFromList(ItemsToBuy, v, item.IsInList(ItemsToBuy, v))
        end
    end
end

function calculateItemsToTrade()
    PrePreGold = nil
    PreGold = math.floor(player.gold)
    PreInventory = table.copy(Inventory)
    PreItemList1 = table.copy(ItemList1)
    PreInventoryCount = table.copy(InventoryCount)
    ItemsToBuy = {}
    ItemsToSell = {}
    unnecessaryItems = {}
    local Buy = whatToBuy()
    local Sell, SellCount = whatToSell()
    while Buy or Sell do
        if Buy then preBuy(Buy) end
        Sell, SellCount = whatToSell()
        if Sell then for i = 1, SellCount, 1 do preSell(Sell) end end
        Buy = whatToBuy()
    end
    deleteDoubleItems() --This can be caused by bad calculation. Hopefully, it will not be needed in future.
    NextItem, NextItemPrice = whatToBuyNext()
end

function canBuyBetterItemAfterSell(id)
    if id == 1001 or id == 3117 or id == 3009 or id == 3158 or id == 3006 or id == 3111 then if #ItemList1 > 1 then return 0 end end --Boots
    local saveGold = PreGold
    local savePreInventory = table.copy(PreInventory)
    local savePreInventoryCount = table.copy(PreInventoryCount)

    local function closeSandbox()
        PreGold = saveGold
        PreInventory = table.copy(savePreInventory)
        PreInventoryCount = table.copy(savePreInventoryCount)
    end

    local sellingItemPrice = item.PriceFull(id) or 0 --is not the right value if you have stacked items, but works best.
    local itemWithoutSell = whatToBuy()
    local itemWithoutSellPrice = item.PriceFull(itemWithoutSell) or 0   --ItemwithoutSell + Der eigenwert!
    -----------------------------
    local itemWithSell, itemWithSellPrice
    if id == 2043 or id == 2044 or id == 2004 or id == 2003 then
        local counter = 0
        local max = item.IsInList(PreInventory, id)
        for i = 1, max, 1 do
            PreGold = PreGold + item.SellPrice(id)
            item.RemoveFromList(PreInventory, id)
            itemWithSell = whatToBuy()
            itemWithSellPrice = item.PriceFull(itemWithSell) or 0
            counter = counter + 1
            if itemWithSellPrice > sellingItemPrice + itemWithoutSellPrice then --ToDo: Think about this Line, the results are Ok, but I Only can decide if another item is better by comparing there prices.
                closeSandbox()
                return counter
            end
        end

        closeSandbox()
        return 0
    end
    PreGold = PreGold + item.SellPrice(id)
    item.RemoveFromList(PreInventory, id)
    itemWithSell = whatToBuy()
    itemWithSellPrice = item.PriceFull(itemWithSell) or 0

    closeSandbox()
    if itemWithSellPrice > sellingItemPrice + itemWithoutSellPrice then return 1 end
    return 0
end



function whatToBuy()
    local function deleteUnnecessaryItems() --- untested
        unnecessaryItems = unnecessaryItems or {}
        if #PreItemList1 > 1 then
            for i = 2, #PreItemList1, 1 do
                local currentremain = item.RemainingIngredientsToBuy(PreItemList1[i])
                item.RemoveFromList(currentremain, PreItemList1[i])
                for j, v in ipairs(currentremain) do
                    if v ~= 1001 and v == PreItemList1[1] and item.CanBuy(PreItemList1[i]) then
                        table.remove(PreItemList1, 1)
                        table.insert(unnecessaryItems, v)
                        deleteUnnecessaryItems()
                        return
                    end
                end
            end
        end
    end

    local itemToBuy
    for i, v in ipairs(ItemList3) do
        if player.level >= v[4] and player.level <= v[5] and item.CanBuy(v[1]) and item.IsInList(PreInventory, v[1]) < v[2] and v[3] >= v[2] then
            if v[1] ~= 2038 and v[1] ~= 2039 and v[1] ~= 2037 and v[1] ~= 2042 and v[1] ~= 2047 then return v[1]
            elseif item.IsInList(ItemsToBuy, v[1]) == 0 then return v[1]
            end
        end
    end
    local itemFromList3 = false
    for i, v in ipairs(ItemList3) do
        if player.level >= v[4] and player.level <= v[5] and item.CanBuy(v[1]) and item.IsInList(PreInventory, v[1]) < v[3] and v[3] >= v[2] then
            if v[1] ~= 2038 and v[1] ~= 2039 and v[1] ~= 2037 and v[1] ~= 2042 and v[1] ~= 2047 then itemToBuy = v[1] itemFromList3 = true break
            elseif item.IsInList(ItemsToBuy, v[1]) == 0 then itemToBuy = v[1] itemFromList3 = true break
            end
        end
    end
    --deleteUnnecessaryItems()
    local highestPrice = 0
    for i, v in ipairs(item.RemainingIngredientsToBuy(PreItemList1[1])) do
        if item.CanBuy(v) and item.PriceFull(v) > highestPrice then
            itemToBuy = v
            highestPrice = item.PriceFull(v)
        end
    end
    if itemFromList3 == true and PrePreGold == nil then PrePreGold = Pregold end
    return itemToBuy
end

function whatToBuyNext()
    local itemToBuy
    local lowestPrice = math.huge
    for i, v in ipairs(item.RemainingIngredientsToBuy(PreItemList1[1])) do
        if item.PriceFull(v) < lowestPrice and item.FitInInventory(v) then
            itemToBuy = v
            lowestPrice = item.PriceFull(v)
        end
    end
    for i, v in ipairs(ItemList3) do
        if player.level >= v[4] and player.level <= v[5] and item.PriceFull(v[1]) < lowestPrice and item.IsInList(PreInventory, v[1]) < v[2] and v[3] >= v[2] then
            if v[1] ~= 2038 and v[1] ~= 2039 and v[1] ~= 2037 and v[1] ~= 2042 and v[1] ~= 2047 then itemToBuy = v[1] lowestPrice = item.PriceFull(v[1])
            elseif item.IsInList(ItemsToBuy, v[1]) == 0 then itemToBuy = v[1] lowestPrice = item.PriceFull(v[1])
            end
        end
    end

    local function getMaxSellableItemprice() --so much problems here
        local highestPrice = 0
        if PreInventory[1] ~= 0 and PreInventory[2] ~= 0 and PreInventory[3] ~= 0 and PreInventory[4] ~= 0 and PreInventory[5] ~= 0 and PreInventory[6] ~= 0 then
            for i, v in ipairs(PreInventory) do
                local price = item.SellPrice(v)
                if v ~= 0 and item.IsInList(item.GetReserved(), v) == 0 and price > highestPrice and v ~= 2043 and v ~= 2044 and v ~= 2004 and v ~= 2003 then
                    highestPrice = (PreInventoryCount[i] * price)
                end
            end
        end
        for i, v in ipairs(ItemList3) do
            if player.level >= v[4] and player.level <= v[5] then
                local amount = item.IsInList(PreInventory, v[1]) - v[2]
                if amount > 0 then
                    if v ~= 2043 and v ~= 2044 and v ~= 2004 and v ~= 2003 then highestPrice = highestPrice + item.SellPrice(v[1]) * amount end
                end
            end
        end
        return highestPrice
    end

    local NextItemPrice
    local PreGold = PrePreGold or PreGold
    if itemToBuy then NextItemPrice = (item.Price(itemToBuy) - PreGold) - getMaxSellableItemprice() else NextItemPrice = 0 end
    if NextItemPrice < 0 then NextItemPrice = item.Price(itemToBuy) - PreGold end
    return itemToBuy, NextItemPrice
end

function whatToSell()
    local itemToSell, itemToSellCount
    if PreInventory[1] ~= 0 and PreInventory[2] ~= 0 and PreInventory[3] ~= 0 and PreInventory[4] ~= 0 and PreInventory[5] ~= 0 and PreInventory[6] ~= 0 then
        local LowestPrice = math.huge
        for i, v in ipairs(PreInventory) do
            if not item.IsIngredient(PreItemList1[1],v) then
                local price
                if v == 2043 or v == 2044 or v == 2004 or v == 2003 then price = item.PriceFull(v) * item.IsInList(PreInventory, v) else price = item.PriceFull(v) end
                local amount = canBuyBetterItemAfterSell(v)
                if amount > 0 and v ~= 0 and v ~= 3200 and not item.IsReserved(v) and
                        price < LowestPrice then
                    itemToSell = v
                    itemToSellCount = amount
                    LowestPrice = price
                end
            end
        end
        return itemToSell, itemToSellCount
    end
    return nil
end

function item.CanBuy(id)
    if PreGold >= item.Price(id) and item.FitInInventory(id) then
        return true
    end
    return false
end

function item.ElexirOver(id)
    if player.buffCount == nil then return false end --debug
    local function isBuffActive(name)
        for i = 1, player.buffCount, 1 do
            if player:getBuff(i).name == name and player:getBuff(i).valid then return true end
        end
        return false
    end

    if id == 2038 and not isBuffActive("PotionOfElusiveness") then return true
    elseif id == 2039 and not isBuffActive("PotionOfBrilliance") then return true
    elseif id == 2037 and not isBuffActive("PotionOfGiantStrength") then return true
        --elseif id == 2047 and not isBuffActive("...") then return true --ToDo: Add Oracles Extract
    elseif id == 2042 and not isBuffActive("OracleElixirSight") then return true
    end
    return false
end

function item.FitInInventory(id)
    if id == 2003 or id == 2004 then
        if item.IsInList(PreInventory, id) > 0 and item.IsInList(PreInventory, id) < 9 then return true
        end
    end
    if id == 2044 or id == 2043 then
        if item.IsInList(PreInventory, id) > 0 and item.IsInList(PreInventory, id) < 5 then return true
        end
    end
    if id == 2037 or id == 2038 or id == 2039 or id == 2042 or id == 2047 then
        return item.ElexirOver(id)
    end
    if PreInventory[1] == 0 or PreInventory[2] == 0 or PreInventory[3] == 0 or PreInventory[4] == 0 or PreInventory[5] == 0 or PreInventory[6] == 0 or #item.DisappearingItems(id) > 0 then return true
    end
    return false
end

-----------------------------------------
function preBuy(id)
    PreGold = PreGold - item.Price(id) --ziehe von pregold ab
    if id ~= 2037 and id ~= 2038 and id ~= 2039 and id ~= 2042 and id ~= 2047 then
        for i, v in ipairs(item.DisappearingItems(id)) do --entferne disappearingItems
            item.RemoveFromList(PreInventory, v)
        end
        item.AddToList(PreInventory, id)
    end
    item.RemoveFromList(PreItemList1, id) --Loesche von PurchaseOrder
    item.AddToList(ItemsToBuy, id)
end

function preSell(id)
    PreGold = PreGold + item.SellPrice(id)
    item.RemoveFromList(PreInventory, id)
    item.AddToList(ItemsToSell, id)
end

-- FINAL TRADING
function UseElexir()
    local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
    for i = 1, 6, 1 do local item = player:getInventorySlot(ItemSlot[i])
    if item == 2038 or item == 2039 or item == 2037 or item == 2042 or item == 2047 then
        CastSpell(ItemSlot[i])
    end
    end
end

function sell(id)
    local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
    for i = 1, 6, 1 do
        if player:getInventorySlot(ItemSlot[i]) == id then return SellItem(ItemSlot[i])
        end
    end
    item.RemoveFromList(Inventory, id)
    return false
end

function buy(id)
    if id and id ~= 0 then
        local res = BuyItem(id)
        if res == nil or res then
            item.RemoveFromList(ItemList1, id)
            if unnecessaryItems then
                for i, v in ipairs(unnecessaryItems) do
                    item.RemoveFromList(ItemList1, v)
                end
                unnecessaryItems = nil
            end
            return true
        end
    end
    return false
end

-----------------------------------------
function inShop() --distance player to shop < range
    local function getShopCoordinates()
        for i = 1, objManager.maxObjects, 1 do
            local object = objManager:getObject(i)
            if object and object.type == "obj_Shop" and object.team == player.team then return object.x, object.y, object.z, 1250 end
        end
    end

    if ShopX == nil or ShopY == nil or ShopZ == nil or ShopRange == nil then
        if getShopCoordinates() then ShopX, ShopY, ShopZ, ShopRange = getShopCoordinates() else PrintChat("Could not get Shop Coordinates, unloading...") OnWndMsg, OnTick, OnDraw = function() end, function() end, function() end return end
    end

    if math.sqrt((ShopX - player.x) ^ 2 + (ShopZ - player.z) ^ 2) < ShopRange then return true, ShopX, ShopY, ShopZ, ShopRange
    end
    return false, ShopX, ShopY, ShopZ, ShopRange
end

function isJungling()
    if player.buffCount == nil then return false end --debug
    if player:GetSpellData(SUMMONER_1).name == "SummonerSmite" or player:GetSpellData(SUMMONER_1).name == "SummonerSmite" then return true
    else return false
    end
end

function getMapName()
    if player.buffCount == nil then return false end --debug
    for i = 1, objManager.maxObjects, 1 do
        object = objManager:getObject(i)
        if object and object.name == "Turret_OrderTurretShrine" then
            local x = object.x
            if x > -237 and x < -235 then return "Summoners Rift" end --x:-236 y:187 z:-53
            if x > 0 and x < 300 then return "Dominion" end
            if x > 341 and x < 343 then return "Twisted Treeline" end -- x:342 y:292 z:7291
            if x > 604 and x < 606 then return "Proving Grounds" end -- x:605 y:140 z:810
            if x > 811 and x < 813 then return "Crystal Scar" end -- x:812 y:20 z:3015
        end
    end
    return "UNKNOWN"
end

function getItemList()
    local itemsToBuy = {}
    local itemsNotToSell = {}
    local tools = {}
    local map = getMapName()
    dofile(SCRIPT_PATH .. "Common\\AutoBuyItems_ItemLists.lua")
    if not Champions[player.charName] then return false end
    if Champions[player.charName].Default then
        itemsToBuy = Champions[player.charName].Default.ItemList1 or {}
        itemsNotToSell = Champions[player.charName].Default.ItemList2 or {}
        tools = Champions[player.charName].Default.ItemList3 or {}
    end
    if map == "Summoners Rift" and isJungling() and Champions[player.charName].Jungler then
        if Champions[player.charName].Jungler.ItemList1 then itemsToBuy = Champions[player.charName].Jungler.ItemList1 end
        if Champions[player.charName].Jungler.ItemList2 then itemsToBuy = Champions[player.charName].Jungler.ItemList2 end
        if Champions[player.charName].Jungler.ItemList3 then itemsToBuy = Champions[player.charName].Jungler.ItemList3 end
    elseif  Champions[player.charName][map] then
        if Champions[player.charName][map].ItemList1 then itemsToBuy = Champions[player.charName].Jungler.ItemList1 end
        if Champions[player.charName][map].ItemList2 then itemsToBuy = Champions[player.charName].Jungler.ItemList2 end
        if Champions[player.charName][map].ItemList3 then itemsToBuy = Champions[player.charName].Jungler.ItemList3 end
    end
    if itemsToBuy and itemsNotToSell and tools then
        for i, v in ipairs(itemsToBuy) do
            if item.ID(v) then table.insert(ItemList1, item.ID(v))
            elseif player.buffCount then PrintChat("Error: " .. v .. "is not a valid item")
            else print("Error: " .. v .. " is not a valid item")
            end
        end
        for i, v in ipairs(itemsNotToSell) do
            if item.ID(v) then table.insert(ItemList2, item.ID(v))
            elseif player.buffCount then PrintChat("Error: " .. v .. " is not a valid item")
            else print("Error: " .. v .. " is not a valid item")
            end
        end
        for i, v in ipairs(tools) do
            ItemList3[i] = v
            if item.ID(v[1]) then ItemList3[i][1] = item.ID(v[1])
            elseif player.buffCount then PrintChat("Error: " .. v[1] .. " is not a valid item") return false
            else print("Error: " .. v[1] .. " is not a valid item") return false
            end
        end
        if ItemList2 and #ItemList2>0 then
            if item.IsInList(ItemList2,3004)>0 or item.IsInList(ItemList2,3008)>0 then --Manamume/Muramana
                table.insert(ItemList2,3042)
            end
            if item.IsInList(ItemList2,3003)>0 or item.IsInList(ItemList2,3007)>0 then --Archangels Staff/Seraph's Embrace
                table.insert(ItemList2,3040)
            end
            if item.IsInList(ItemList2,3166)>0 then --Bonetooth Necklace
                table.insert(ItemList2,3167)
                table.insert(ItemList2,3168)
                table.insert(ItemList2,3169)
                table.insert(ItemList2,3171)
                table.insert(ItemList2,3175)
            end
        end
        if #ItemList1 > 0 and ItemList2 and ItemList3 then LastChamp = player.charName return true
        end
    end
    return false
end

function getInventory()
    local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
    for i = 1, 6, 1 do
        local id = player:getInventorySlot(ItemSlot[i])
        if id and id > 0 then
            Inventory[i], InventoryCount[i] = id, player:getItem(ItemSlot[i]).stacks or 0
            if (not InventoryCount[i] or InventoryCount[i] == 0) and Inventory[i] and Inventory[i] > 0 then InventoryCount[i] = 1 end --temporary fix for BoL
        else Inventory[i], InventoryCount[i] = 0, 0
        end
    end
end

function OnDraw()
    timeold = time or os.clock()
    time = os.clock()
    FramesPerSecond = 1 / (time - timeold)
    if DebugMode then
        local width = 10
        local ItemSlot = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, }
        for i = 1, 6, 1 do
            local id = player:getInventorySlot(ItemSlot[i])
            if id and id > 0 then
                local object, count = id, player:getItem(ItemSlot[i]).stacks
                local t = item.Name(object) .. "(" .. (count or "nil") .. ")"
                DrawText(t, 12, width, 100, 0xFFFFFF00)
                width = width + #t * 6
            end
        end
        width = 10
        for i, v in ipairs(Inventory) do
            if item.Name(v) and InventoryCount[i] then
                local t = item.Name(v) .. "(" .. InventoryCount[i] .. ")"
                DrawText(t, 12, width, 111, 0xFFFFFF00)
                width = width + #t * 6
            end
        end
    end
    local function DrawItemWindow(X1, Y1)
        local X1 = X1 + 2 or 10
        local maxHeight = Y1 or 140
        local maxWidth = 0
        local Y1 = maxHeight

        if Draw then
            local list = {}
            ---
            fade = fade or -1
            if FramesPerSecond < MinFPS then
                if fade < 1 then fade = fade + 0.05 end
            else
                if fade > -1 then fade = fade - 0.01 end
            end
            if fade > 0 then table.insert(list, { "Low FPS, overlay does not refresh!", maxHeight - 15, 0xD61123 + (fade * 255 * 0x1000000) }) end
            ---
            if NextItem then
                local text = string.format("Next: %s Gold: %s", item.Name(NextItem), NextItemPrice)
                if #text > maxWidth then maxWidth = #text end
                table.insert(list, { text, maxHeight, 0xFF0095B6 })
                maxHeight = maxHeight + 15
            end
            if ItemsToBuy and #ItemsToBuy > 0 then
                local text = "Items To Buy:"
                if #text > maxWidth then maxWidth = #text end
                table.insert(list, { text, maxHeight, 0xFFF3FD00 })
                maxHeight = maxHeight + 10
                local BuyDrawList = table.copy(ItemsToBuy)
                for i, buy in ipairs(BuyDrawList) do
                    if buy then
                        local n = item.IsInList(BuyDrawList, buy)
                        if n > 1 then
                            text = string.format("%sx%s", n, item.Name(buy))
                            if #text > maxWidth then maxWidth = #text end
                            table.insert(list, { text, maxHeight, 0xFF9EDB24 })
                            for j, v in ipairs(BuyDrawList) do if buy == v then BuyDrawList[j] = nil end end
                        else
                            text = string.format("%s", item.Name(buy))
                            if #text > maxWidth then maxWidth = #text end
                            table.insert(list, { text, maxHeight, 0xFF9EDB24 })
                        end
                        maxHeight = maxHeight + 10
                    end
                end
                maxHeight = maxHeight + 5
            end
            if ItemsToSell and #ItemsToSell > 0 then
                local text = "Items To Sell:"
                if #text > maxWidth then maxWidth = #text end
                table.insert(list, { text, maxHeight, 0xFF799753 })
                maxHeight = maxHeight + 10
                local SellDrawList = table.copy(ItemsToSell)
                for i, sell in ipairs(SellDrawList) do
                    if sell then
                        local n = item.IsInList(SellDrawList, sell)
                        if n > 1 then
                            text = string.format("%sx%s", n, item.Name(sell))
                            if #text > maxWidth then maxWidth = #text end
                            table.insert(list, { text, maxHeight, 0xFF9EDB24 })
                            for j, v in ipairs(SellDrawList) do if sell == v then SellDrawList[j] = nil end end
                        else
                            text = string.format("%s", item.Name(sell))
                            if #text > maxWidth then maxWidth = #text end
                            table.insert(list, { text, maxHeight, 0xFF9EDB24 })
                        end
                        maxHeight = maxHeight + 10
                    end
                end
                maxHeight = maxHeight + 5
            end
            DrawLine(PositionX1, (PositionY1 + maxHeight) / 2, math.ceil(X1 + maxWidth * 5.5), (PositionY1 + maxHeight) / 2, math.abs(maxHeight - PositionY1), 0x66000000)
            for i, v in ipairs(list) do
                DrawText(v[1], 12, X1, v[2], v[3])
            end
        end
        return math.ceil(X1 + maxWidth * 5.5), maxHeight
    end

    if Draw and inShop() then DrawCircle(ShopX, ShopY, ShopZ, ShopRange, 0xFFFFFF) end


    if rPosX and rPosY then
        local X, Y = GetCursorPos().x, GetCursorPos().y
        PositionX1 = X - rPosX
        PositionY1 = Y - rPosY
        PositionX2, PositionY2 = DrawItemWindow(PositionX1, PositionY1)
        DrawLine(PositionX1, PositionY1, PositionX2, PositionY1, 1, 0xFFFFFF66)
        DrawLine(PositionX1, PositionY2, PositionX2, PositionY2, 1, 0xFFFFFF66)
        DrawLine(PositionX1, PositionY1, PositionX1, PositionY2, 1, 0xFFFFFF66)
        DrawLine(PositionX2, PositionY1, PositionX2, PositionY2, 1, 0xFFFFFF66)
    else
        PositionX2, PositionY2 = DrawItemWindow(PositionX1, PositionY1)

        --
    end
end

--Three Rings for the Elven kings under the sky,
--Seven for the Dwarf-lords in their halls of stone,
--Nine for Mortal Men, doomed to die,
--One for the Dark Lord on his Dark Throne,
--In the land of Mordor where the shadows lie,
--One Ring to rule them all,
--One Ring to find them,
--One ring to bring them all,
--And in the darkness bind them,
--In the Land of Mordor where the shadows lie.

local function writeWindowPositionToFile()
    local file, error = assert(io.open(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua"))
    if error then return error end
    local t = file:read("*all")
    file:close()
    t = string.gsub(t, "PositionX1 = [-]?%d+", "PositionX1 = " .. PositionX1, 1)
    t = string.gsub(t, "PositionY1 = [-]?%d+", "PositionY1 = " .. PositionY1, 1)
    local file, error = assert(io.open(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua", "w"))
    if error then return error end
    file:write(t)
    file:close()
end

local function saveItemsToFile()
    --save LastTime save ItemList1 LastChamp
    local file, error = assert(io.open(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua"))
    if error then return error end
    local t = file:read("*all")
    file:close()
    t = string.gsub(t, "LastLevel = %d+", "LastLevel = " .. math.floor(LastLevel), 1)
    t = string.gsub(t, [[LastChamp = "%a+"]], [[LastChamp = "]] .. LastChamp .. [["]], 1)
    local ItemList1toString = "ItemList1 = {"
    for i, v in ipairs(ItemList1) do
        ItemList1toString = ItemList1toString .. v .. ","
    end
    ItemList1toString = ItemList1toString .. "}"
    t = string.gsub(t, "\nItemList1 = {([%d+%,]*)}", "\n" .. ItemList1toString, 1)
    local file, error = assert(io.open(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua", "w"))
    if error then return error end
    file:write(t)
    file:close()
end

local function saveDebugFile()
    local t = ""
    for i, v in ipairs(item.GetReserved()) do
        if item.Name(v) then
            t = t .. item.Name(v) .. "\n"
        else t = t .. v .. "/n"
        end
    end
    t = t .. "\n"
    for i, v in ipairs(ItemList2) do
        if item.Name(v) then
            t = t .. item.Name(v) .. "\n"
        else t = t .. v .. "/n"
        end
    end
    local file, error = assert(io.open(SCRIPT_PATH .. "ABI.log", "w+"))
    if error then return error end
    file:write(t)
    file:close()
end


function OnTick()
    if not lastUpdated or os.clock() - lastUpdated > 0.250 then
        lastUpdated = os.clock()
        UseElexir()
        if FramesPerSecond > MinFPS or inShop() then
            getInventory()
            calculateItemsToTrade()
            if inShop() or player.dead then
                if StartBuyTime < GetInGameTimer() and GetInGameTimer() - LastTime > math.random(MinDelay * 10, MaxDelay * 10) / 10 then
                    LastTime = GetInGameTimer()
                    LastLevel = player.level
                    for i = 1, #ItemsToSell, 1 do
                        if not sell(ItemsToSell[i]) then return end
                        if MaxDelay > 0 then saveItemsToFile() return end
                    end
                    for i = 1, #ItemsToBuy, 1 do
                        if IsItemPurchasable(ItemsToBuy[i]) then
                            if not buy(ItemsToBuy[i]) then return end
                            if MaxDelay > 0 then saveItemsToFile() return end
                        end
                    end
                    saveItemsToFile()
                end
            end
        end
    end
end

function OnWndMsg(msg, key)
    if key == DisableHotkey and msg == KEY_DOWN then
        if SHIFT then
            writeWindowPositionToFile()
            OnWndMsg, OnTick, OnDraw = function() end, function() end, function() end
            return
        else
            if Draw then Draw = false
            else Draw = true
            end
        end
    elseif key == 16 then
        if msg == KEY_DOWN then SHIFT = true
        else SHIFT = false
        end
    elseif msg == WM_LBUTTONDOWN then
        local X, Y = GetCursorPos().x, GetCursorPos().y
        if X > PositionX1 and X < PositionX2 and Y > PositionY1 and Y < PositionY2 then
            rPosX = X - PositionX1
            rPosY = Y - PositionY1
        end
    elseif msg == WM_LBUTTONUP then
        if rPosX or rPosY then
            rPosX = nil rPosY = nil
            writeWindowPositionToFile()
        end
    end
end

function recoverLastState()
    local function fileExist(name)
        local f = io.open(name, "r")
        if f then io.close(f) return true else return false end
    end

    local function createConfig()
        local t = [[
--Config

--Delay to prevent detection through SpectatorMode
StartBuyTime = 4 --in seconds (set to 0 to disable)
MinDelay = 0.6 --in seconds
MaxDelay = 1.2 --in seconds

--Hotkey
Draw = true
DisableHotkey = 122 --"F11" To disable Overlay; Shift-F11 to Unload the script

--Minimal Frames per Second. If below, it will not update or buy. To Disable set MinFPS -1
MinFPS = 25

--WindowCoordinates
PositionX1 = 10
PositionY1 = 140

DebugMode = false

ItemList1 = {}

LastLevel = 18
LastChamp = "none"
        ]]
        local file, error = assert(io.open(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua", "w"))
        if error then return error end
        file:write(t)
        file:close()
    end

    if not fileExist(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua") then createConfig() end
    dofile(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua")
    if not LastLevel then createConfig() dofile(SCRIPT_PATH .. "Common\\AutoBuyItems_Config.lua") end --only for now, can be removed later on
    if LastChamp ~= player.charName or GetInGameTimer() < 1 or LastLevel > player.level then
        ItemList1 = {}
        LastLevel = player.level
        LastTime = GetInGameTimer()
        return getItemList() --begin new calculations
    else
        local lastItemList1 = table.copy(ItemList1)
        ItemList1 = {}
        LastLevel = player.level
        LastTime = GetInGameTimer()
        if getItemList() then ItemList1 = lastItemList1 return true else return false end
    end
end

function OnLoad()
    if not GetInGameTimer then PrintChat(" >> Auto Buy Items script unloaded! You are using an outdated BoL.dll") OnWndMsg, OnTick, OnDraw = function() end, function() end, function() end end

    player = GetMyHero()
    if recoverLastState() then
        PrintChat(" >> Auto Buy Items script loaded in " .. getMapName() .. "!")
    else PrintChat(" >> Auto Buy Items script unloaded! Check your Itemlist for" .. player.charName .. ".")
    OnWndMsg, OnTick, OnDraw = function() end, function() end, function() end
    return
    end
end

function BuyOrderDebug(charName, interval, skip)
    local skip = skip or 1
    player = {}
    player.charName = charName or "Lux"
    player.gold = 475
    player.level = 1
    local n = interval or 500
    PreInventory = { 0, 0, 0, 0, 0, 0, }
    PreInventoryCount = { 0, 0, 0, 0, 0, 0, }
    PreItemList1 = {}
    PreGold = 0
    Inventory = { 0, 0, 0, 0, 0, 0, }
    InventoryCount = { 0, 0, 0, 0, 0, 0, }
    ItemsToBuy = {}
    ItemsToSell = {}
    NextItem = nil
    NextItemPrice = nil
    ItemList1 = {}
    ItemList2 = {}
    ItemList3 = {}
    FramesPerSecond = math.huge
    if getItemList() then
        local function unpack(array)
            local txt = ""
            for i, v in pairs(array) do
                txt = txt .. item.Name(v) .. ", "
            end
            return txt
        end
        print("ItemList1: " .. unpack(ItemList1))
        print("ItemList2: " .. unpack(ItemList2))
        PreGold = 475
        Gold = 475
        local counter = 0
        local t
        local aold, bold, cold, dold, eold, fold
        repeat
            counter = counter + 1
            PreGold = PreGold + n
            player.gold = PreGold
            Gold = Gold + n
            if player.level < 18 then player.level = math.ceil((Gold / 1000) * (20 / 15))
            end
            t0 = os.clock()
            calculateItemsToTrade()
            t = os.clock() - t0
            Inventory = table.copy(PreInventory)
            InventoryCount = table.copy(PreInventoryCount)
            ItemList1 = table.copy(PreItemList1)
            if #ItemsToBuy > 0 then print("Buy: " .. unpack(ItemsToBuy)) end
            if #ItemsToSell > 0 then print("Sell: " .. unpack(ItemsToSell)) end
            local a, b, c, d, e, f = "empty", "empty", "empty", "empty", "empty", "empty"
            if PreInventory[1] ~= 0 then a = PreInventoryCount[1] .. "x" .. item.Name(PreInventory[1]) or "empty" end
            if PreInventory[2] ~= 0 then b = PreInventoryCount[2] .. "x" .. item.Name(PreInventory[2]) or "empty" end
            if PreInventory[3] ~= 0 then c = PreInventoryCount[3] .. "x" .. item.Name(PreInventory[3]) or "empty" end
            if PreInventory[4] ~= 0 then d = PreInventoryCount[4] .. "x" .. item.Name(PreInventory[4]) or "empty" end
            if PreInventory[5] ~= 0 then e = PreInventoryCount[5] .. "x" .. item.Name(PreInventory[5]) or "empty" end
            if PreInventory[6] ~= 0 then f = PreInventoryCount[6] .. "x" .. item.Name(PreInventory[6]) or "empty" end
            if skip == 1 then
                if aold ~= a or bold ~= b or cold ~= c or dold ~= d or eold ~= e or fold ~= f then
                    print(string.format("%s | %s | %s | %s | %s | %s | %s | %s | %s | %s", a, b, c, d, e, f, PreGold, Gold, NextItemPrice, player.level))
                end
            else print(string.format("%s | %s | %s |%s | %s | %s | %s | %s | %s | %s", a, b, c, d, e, f, PreGold, Gold, NextItemPrice, player.level))
            end
            aold, bold, cold, dold, eold, fold = a, b, c, d, e, f
            until Gold >= 25000
        print(string.format("Time per Calculation: %s ms", (t / counter) * 1000))
    end
end
