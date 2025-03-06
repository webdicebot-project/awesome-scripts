--
-- Created by IntelliJ IDEA.
-- User: luan
-- Date: 6/17/20
-- Time: 10:01 PM
-- To change this template use File | Settings | File Templates.
--

local allVariable = {
    bet = 0.01000000,
    form = 5,
    to = 95,
    tableChance = {},
    typeBet = {
        hi = true,
        low = false
    },
    bigerBalance = 0,
    target = balance * 2,
    maxBet = 0,
    profitWinDown = 0,
    profitWinUp = 0,
    stb = balance,
    resetBet = 100000
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
                bet = allVariable.bet,
                py = py,
                bethigh = val,
                chance = tonumber(i),
                tilethang = 0,
                maxTileThang = 0,
                maxWin = 0,
                profit = 0,
                maxBet = 0,
                bigerBalance = 0,
                balance = balance,
                play = true,
                stop = false
            }
            if tonumber(i) <= 15 then
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + ((py * 30) * 20 / 100))
            elseif tonumber(i) > 15 and tonumber(i) <= 30 then
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + ((py * 25) * 20 / 100))
            else
                allVariable.tableChance[tonumber(i)][hiLow].risk = math.ceil((py * 10) + ((py * 20) * 20 / 100))
            end
            if val then
                allVariable.tableChance[tonumber(i)][hiLow].game = string.format("%.2f", (100 - i - 0.01))
            else
                allVariable.tableChance[tonumber(i)][hiLow].game = string.format("%.2f", i)
            end
        end
    end
end

createChange()

function resetBet()
    allVariable.tableChance = {}
    createChange()
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

function getBalanceTarget(bet)
    local risk = bet.maxTileThang * bet.risk / 100;
    local totalBalance = allVariable.bet;
    local startBet = allVariable.bet;
    for i = 1, risk, 1 do
        startBet = startBet + (startBet * bet.onlose / 100);
        totalBalance = totalBalance + startBet;
    end
    return totalBalance;
end

function winUpdate (value, hiLow)
    local profit = value[hiLow].bet * value[hiLow].py - value[hiLow].bet;
    value[hiLow].profit = value[hiLow].profit + profit;
    value[hiLow].balance = value[hiLow].balance + profit;
    if value[hiLow].balance > value[hiLow].bigerBalance then
        value[hiLow].bigerBalance = value[hiLow].balance
    end
    value[hiLow].maxWin = value[hiLow].maxWin + 1;
    value[hiLow].lose = 0;
    value[hiLow].bet = getCurBet(value, hiLow)
    value[hiLow].tilethang = 0
    return value[hiLow]
end

function loseUpdate(value, hiLow)
    value[hiLow].lose = value[hiLow].lose + 1
    local profit = -value[hiLow].bet;
    value[hiLow].profit = value[hiLow].profit + profit;
    value[hiLow].balance = value[hiLow].profit + profit;
    value[hiLow].tilethang = value[hiLow].lose / value[hiLow].risk * 100
    if value[hiLow].tilethang > value[hiLow].maxTileThang then
        value[hiLow].maxTileThang = value[hiLow].tilethang;
    end
    if value[hiLow].bet > value[hiLow].maxBet then
        value[hiLow].maxBet = value[hiLow].bet
    end
    if value[hiLow].lose > 0 then
        value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
        --            value[hiLow].bet = getMutiBet(value, hiLow)
        --            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
    end
    local balanceCheck
    if value[hiLow].balance < balance then
        balanceCheck = value[hiLow].balance
    else
        balanceCheck = balance
    end
    value[hiLow].play = getBalanceTarget(value[hiLow]) < balanceCheck
    if value[hiLow].bet > balanceCheck then
        value[hiLow].play = false
    end
    if value[hiLow].balance < 0 then
        value[hiLow].stop = true
    end
    return value[hiLow]
end

function updateBet()
    for key, value in pairs(allVariable.tableChance) do
        for hiLow, val in pairs(allVariable.typeBet) do
            if value[hiLow].stop ~= true then
                if val then
                    if tonumber(lastBet.roll) > tonumber(value[hiLow].game) then
                        allVariable.tableChance[key][hiLow] = winUpdate(value, hiLow)
                    else
                        allVariable.tableChance[key][hiLow] = loseUpdate(value, hiLow)
                    end
                else
                    if tonumber(lastBet.roll) < tonumber(value[hiLow].game) then
                        allVariable.tableChance[key][hiLow] = winUpdate(value, hiLow)
                    else
                        allVariable.tableChance[key][hiLow] = loseUpdate(value, hiLow)
                    end
                end
            end
        end
    end
end

function getBet()
    local _bet
    local phantram = 0
    local maxBetTatic
    local profitBiger
    local taticName
    local gameTarget
    for key, val in pairs(allVariable.tableChance) do
        for hiLow, v in pairs(allVariable.typeBet) do
            if val[hiLow].tilethang > phantram and
                    val[hiLow].tilethang < val[hiLow].maxTileThang and
                    val[hiLow].play == true and
                    val[hiLow].stop ~= true and
                    (not profitBiger or val[hiLow].profit < profitBiger) and
                    (not maxBetTatic or val[hiLow].maxBet > maxBetTatic) then
                profitBiger = val[hiLow].profit
                maxBetTatic = val[hiLow].maxBet
                phantram = val[hiLow].tilethang
                _bet = val[hiLow]
            end
        end
    end
    if _bet ~= nil then
        chance = _bet.chance
        bethigh = _bet.bethigh
        nextbet = _bet.bet
        --[[if _bet.tilethang < 100 - (_bet.onwin.tile / _bet.onwin.count + 50) then
            nextbet = _bet.bet
        else
            nextbet = _bet.betTwo
        end]]
    else
        chance = math.random(5, 95)
        bethigh = math.random(0, 100) % 2 == 0
        nextbet = allVariable.bet
    end
end

function dobet()
    if balance > allVariable.bigerBalance then
        allVariable.bigerBalance = balance
    end
    if nextbet > allVariable.maxBet then
        allVariable.maxBet = nextbet
    end
    if balance > allVariable.target then
        resetseed()
        resetstats()
        resetBet()
        allVariable.target = balance * 2
        allVariable.bigerBalance = 0
        allVariable.resetBet = allVariable.resetBet + 100000
    end
    if bets > allVariable.resetBet and balance < allVariable.target then
        resetseed()
        resetstats()
        resetBet()
        allVariable.target = balance * 2
        allVariable.bigerBalance = 0
        allVariable.resetBet = allVariable.resetBet + 100000
    end
    updateBet()
    getBet()
end