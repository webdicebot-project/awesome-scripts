--
-- Created by IntelliJ IDEA.
-- User: luan
-- Date: 5/31/20
-- Time: 11:41 PM
-- To change this template use File | Settings | File Templates.
--

local allVariable = {
    bet = 0.00000100,
    form = 5,
    to = 95,
    tableChance = {},
    typeBet = {
        hi = true,
        low = false
    },
    countBet = 0,
    bigerBalance = 0,
    maxBet = 0
};

chance = 50
bethigh = true
nextbet = allVariable.bet

function getPayout(chag)
    local py = 100 / tonumber(chag)
    py = py - (py * (1 / 100))
    return py;
end

function createChange()
    for i = allVariable.form, allVariable.to, 1 do
        i = string.format("%.2f", i)
        local py = tonumber(string.format("%.4f", getPayout(i)))
        allVariable.tableChance[tonumber(i)] = {};
        for hiLow, val in pairs(allVariable.typeBet) do
            allVariable.tableChance[tonumber(i)][hiLow] = {};
            allVariable.tableChance[tonumber(i)][hiLow] = {
                lose = 0,
                onlose = 1 / (py - 1) * 100,
                onloseSmall = 1 / (py - 1) * 30,
                onwin = {
                    count = 0,
                    tile = 0
                },
                bet = allVariable.bet,
                py = py,
                bethigh = val,
                chance = tonumber(i),
                tilethang = 0,
                infoData = {
                    profit = 0,
                    maxBet = 0,
                    bigerBalance = 0,
                    balance = balance
                }
            }
            if tonumber(i) <= 15 then
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + ((py * 30) * 20 / 100))
            elseif tonumber(i) > 15 and tonumber(i) <= 30 then
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + 25)
            else
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + ((py * 20) * 20 / 100))
            end
            if val == true then
                allVariable.tableChance[tonumber(i)][hiLow].game = string.format("%.2f", (100 - i - 0.01))
            else
                allVariable.tableChance[tonumber(i)][hiLow].game = string.format("%.2f", i)
            end
        end
    end
end

createChange()

function resetBet()
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            value[hiLow].lose = 0
            value[hiLow].bet = allVariable.bet
            value[hiLow].onwin.count = 0
            value[hiLow].onwin.tile = 0
            value[hiLow].onwin.tilethang = 0
        end
    end
end

function getCurBet(value, hiLow)
    local currentBet = allVariable.bigerBalance / value[hiLow].py
    for i = 1, value[hiLow].risk, 1 do
        currentBet = currentBet / ((value[hiLow].onlose / 100) + 1)
    end
    if currentBet > balance then
        currentBet = allVariable.bet
    else
        if currentBet < allVariable.bet then
            currentBet = allVariable.bet
        end
    end
    return currentBet
end

function getMutiBet(value, hiLow)
    local currentBet = allVariable.bigerBalance / value[hiLow].py
    local risk = value[hiLow].risk - value[hiLow].lose
    for i = 1, risk, 1 do
        currentBet = currentBet / ((value[hiLow].onlose / 100) + 1)
    end
    if currentBet < allVariable.bet then
        currentBet = allVariable.bet
    end
    return currentBet
end

function updateInfo(value, hiLow, winLose)
    local profit
    if winLose then
        profit = value[hiLow].bet * value[hiLow].py - value[hiLow].bet
    else
        profit = -value[hiLow].bet
    end
    if value[hiLow].bet > value[hiLow].infoData.maxBet then
        value[hiLow].infoData.maxBet = value[hiLow].bet
    end
    value[hiLow].infoData.profit = value[hiLow].infoData.profit + profit
    value[hiLow].infoData.balance = value[hiLow].infoData.balance + profit
    if value[hiLow].infoData.balance > value[hiLow].infoData.bigerBalance then
        value[hiLow].infoData.bigerBalance = value[hiLow].infoData.balance
    end
end

function winUpdate (value, hiLow)
    updateInfo(value, hiLow, true)
    local tileT = value[hiLow].lose / value[hiLow].risk * 100
    if tileT ~= 0 then
        value[hiLow].onwin.count = value[hiLow].onwin.count + 1
    end
    value[hiLow].onwin.tile = value[hiLow].onwin.tile + tileT
    value[hiLow].lose = 0
    value[hiLow].bet = getCurBet(value, hiLow)
    value[hiLow].tilethang = 0
end

function loseUpdate(value, hiLow, key)
    updateInfo(value, hiLow, false)
    if value[hiLow].lose > 0 then
        if key == tonumber(lastBet.chance) then
            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
        else
            value[hiLow].bet = getMutiBet(value, hiLow)
        end
--        value[hiLow].bet = getMutiBet(value, hiLow)
--        value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
    end
    value[hiLow].tilethang = value[hiLow].lose / value[hiLow].risk * 100
    value[hiLow].lose = value[hiLow].lose + 1
end

function updateBet()
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            if val then
                if tonumber(lastBet.roll) > tonumber(value[hiLow].game) then
                    winUpdate(value, hiLow)
                else
                    loseUpdate(value, hiLow, key)
                end
            else
                if tonumber(lastBet.roll) < tonumber(value[hiLow].game) then
                    winUpdate(value, hiLow)
                else
                    loseUpdate(value, hiLow, key)
                end
            end
        end
    end
end

function getBet()
    local _bet
    local bigProfit
    local phantram = 0
    local maxBetTatic
    local taticName
    for key, val in pairs(allVariable.tableChance) do
        for hiLow, v in pairs(allVariable.typeBet) do
            if bigProfit == nil then
                bigProfit = profit
            end
            if (val[hiLow].infoData.profit < bigProfit or val[hiLow].infoData.profit > bigProfit) and
                    (val[hiLow].tilethang > phantram) then
                bigProfit = val[hiLow].infoData.profit
                phantram = val[hiLow].tilethang
                _bet = val[hiLow]
            end
        end
    end
    if _bet ~= nil then
        chance = _bet.chance
        bethigh = _bet.bethigh
        nextbet = _bet.bet
    else
        chance = math.random(5, 95)
        bethigh = math.random(0, 100) % 2 == 0
        nextbet = allVariable.bet
    end
end

function dobet()
    if nextbet > allVariable.maxBet then
        allVariable.maxBet = nextbet
    end
    allVariable.countBet = allVariable.countBet + 1
    if balance > allVariable.bigerBalance then
        allVariable.bigerBalance = balance
    end
    updateBet()
    getBet()
end