--
-- Created by IntelliJ IDEA.
-- User: luan
-- Date: 5/27/20
-- Time: 6:32 PM
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
    target = balance * 10,
    countBet = 0,
    bigerBalance = 0,
    balancelose = 0,
    flagGo = false
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
                onwin = {
                    count = 0,
                    tile = 0
                },
                bet = allVariable.bet,
                py = py,
                bethigh = val,
                chance = tonumber(i),
                tilethang = 0
            }
            if tonumber(i) <= 15 then
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + ((py * 30) * 20 / 100))
            elseif tonumber(i) > 15 and tonumber(i) < 30 then
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + 20)
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

function updateBet()
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            if val then
                if tonumber(lastBet.roll) > tonumber(value[hiLow].game) then
                    value[hiLow].onwin.count = value[hiLow].onwin.count + 1
                    value[hiLow].onwin.tile = value[hiLow].onwin.tile + (value[hiLow].lose / value[hiLow].risk * 100)
                    value[hiLow].lose = 0
                    value[hiLow].bet = getCurBet(value, hiLow)
                    value[hiLow].tilethang = 0
                else
                    if value[hiLow].lose > 0 then
                        if key == lastBet.chance then
                            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
                        else
                            value[hiLow].bet = getMutiBet(value, hiLow)
                        end
--                        value[hiLow].bet = getMutiBet(value, hiLow)
                    end
                    value[hiLow].tilethang = value[hiLow].lose / value[hiLow].risk * 100
                    value[hiLow].lose = value[hiLow].lose + 1
                end
            else
                if tonumber(lastBet.roll) < tonumber(value[hiLow].game) then
                    value[hiLow].onwin.count = value[hiLow].onwin.count + 1
                    value[hiLow].onwin.tile = value[hiLow].onwin.tile + (value[hiLow].lose / value[hiLow].risk * 100)
                    value[hiLow].lose = 0
                    value[hiLow].bet = getCurBet(value, hiLow)
                    value[hiLow].tilethang = 0
                else
                    if value[hiLow].lose > 0 then
                        if key == lastBet.chance then
                            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
                        else
                            value[hiLow].bet = getMutiBet(value, hiLow)
                        end
--                        value[hiLow].bet = getMutiBet(value, hiLow)
                    end
                    value[hiLow].tilethang = value[hiLow].lose / value[hiLow].risk * 100
                    value[hiLow].lose = value[hiLow].lose + 1
                end
            end
        end
    end
end

function tacticOne()
    local phantram = 100
    local up
    local down
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            up = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) + 10
            down = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) - 10
            local cbet = value[hiLow].risk - value[hiLow].lose
            local pt = cbet / value[hiLow].risk * 100
            if pt < phantram and (pt >= up or pt <= down) then
                phantram = pt
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function tacticTwo()
    local phantram = 100
    local up
    local down
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            up = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) + 30
            down = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) - 30
            local cbet = value[hiLow].risk - value[hiLow].lose
            local pt = cbet / value[hiLow].risk * 100
            if pt < phantram and (pt <= up and pt >= down) then
                phantram = pt
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function tacticThree()
    local phantram = 100
    local up
    local down
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            up = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) + 20
            down = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) - 20
            local cbet = value[hiLow].risk - value[hiLow].lose
            local pt = cbet / value[hiLow].risk * 100
            if pt < phantram and (pt >= up or pt <= down) then
                phantram = pt
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function tacticFour()
    local phantram = 100
    local up
    local down
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            up = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) + 30
            down = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) - 30
            local cbet = value[hiLow].risk - value[hiLow].lose
            local pt = cbet / value[hiLow].risk * 100
            if pt < phantram and (pt <= up and pt >= down) then
                phantram = pt
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function tacticFive()
    local phamtram = 0
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            if value[hiLow].tilethang > phamtram and value[hiLow].tilethang < 50 then
                phamtram = value[hiLow].tilethang
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function tacticSix()
    local phamtram = 0
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            if value[hiLow].tilethang > phamtram and value[hiLow].tilethang < 70 and value[hiLow].tilethang > 10 then
                phamtram = value[hiLow].tilethang
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function tacticSeven()
    local phantram = 0
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            if value[hiLow].tilethang < 90 and value[hiLow].tilethang > phantram then
                phantram = value[hiLow].tilethang
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function taticGo()
    local phantram = 0
    local up
    local down
    local _bet
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            up = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) + 20
            down = 100 - (value[hiLow].onwin.tile / value[hiLow].onwin.count) - 20
            if value[hiLow].tilethang > phantram and (value[hiLow].tilethang > up or value[hiLow].tilethang < down) then
                phantram = value[hiLow].tilethang
                _bet = value[hiLow]
            end
        end
    end
    return _bet
end

function getBet()
    local _bet
    local profitPersen = profit / allVariable.bigerBalance * 100
    if allVariable.countBet >= 10000 and profitPersen > 20 then
        log('reset count')
        allVariable.countBet = 0
    elseif allVariable.countBet >= 10000 and profitPersen < 20 then
        log('reset seed')
        allVariable.countBet = 0
        resetseed()
        resetBet()
    elseif allVariable.countBet >= 9000 and profitPersen < 90 then
        log('p7')
        _bet = tacticSeven()
    elseif allVariable.countBet >= 7000 and profitPersen < 80 then
        log('p6')
        _bet = tacticSix()
    elseif allVariable.countBet >= 6000 and profitPersen < 60 then
        log('p5')
        _bet = tacticFive()
    elseif allVariable.countBet >= 4000 and profitPersen < 40 then
        log('p4')
        _bet = tacticFour()
    elseif allVariable.countBet >= 2000 and profitPersen < 20 then
        log('p3')
        _bet = tacticThree()
    elseif profitPersen > 5 and profitPersen < 10 then
        log('p2')
        _bet = tacticTwo()
    else
        log('p1')
        _bet = tacticOne()
    end
    if _bet ~= nil then
        allVariable.flagGo = false
        chance = _bet.chance
        bethigh = _bet.bethigh
        nextbet = _bet.bet
    else
        if allVariable.balancelose < 0 then
            allVariable.flagGo = true
            _bet = taticGo()
            if _bet ~= nil then
                local placeBet = math.abs(allVariable.balancelose) / (_bet.py - 1)
                if placeBet < allVariable.bet then
                    placeBet = allVariable.bet
                end
                if placeBet > balance then
                    placeBet = allVariable.bet
                end
                chance = _bet.chance
                bethigh = _bet.bethigh
                nextbet = placeBet
            else
                chance = math.random(5, 95)
                bethigh = math.random(0, 100) % 2 == 0
                nextbet = allVariable.bet
            end
        else
            chance = math.random(5, 95)
            bethigh = math.random(0, 100) % 2 == 0
            nextbet = allVariable.bet
        end
    end
end

function dobet()
    if balance >= allVariable.target then
        stop()
    end
    if win then
        if allVariable.flagGo == true then
            allVariable.balancelose = allVariable.balancelose + currentprofit
        end
    else
        allVariable.balancelose = allVariable.balancelose + currentprofit
    end
--    allVariable.balancelose = allVariable.balancelose + currentprofit
    allVariable.countBet = allVariable.countBet + 1
    if balance > allVariable.bigerBalance then
        allVariable.bigerBalance = balance
    end
    updateBet()
    getBet()
end