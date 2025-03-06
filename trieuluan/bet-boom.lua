--
-- Created by IntelliJ IDEA.
-- User: luan
-- Date: 5/20/20
-- Time: 12:31 AM
-- To change this template use File | Settings | File Templates.
--
bet = 1
form = 0.01
to = 0.9
gameRoll = 1
runOnMinimun = 0.01
tableChance = {}
chance = 50
nextbet = bet

function getPayout(chag)
    local py = 100 / tonumber(chag)
    py = py - (py * (2 / 100))
    return py;
end

function createChange()
    tableChance = {}
    for i = 1, 100, 1 do
        local num = math.random(98, 97000000) / 1000000
        num = tonumber(string.format("%.6f", num))
        local py = tonumber(string.format("%.2f", getPayout(num)))
        tableChance[num] = {
            game = py,
            risk = math.ceil(py * 10 + ((py * 15) * 20 / 100)),
            lose = 0,
            onlose = 1 / (py - 1) * 100,
            bet = bet,
            onWin = 0,
            py = py
        }
    end
end

createChange()

function getCurBet(value)
    local currentBet = balance / value.py
    for i = 1, value.risk, 1 do
        currentBet = currentBet / ((value.onlose / 100) + 1)
    end
    if currentBet > balance then
        currentBet = bet
    else
        if currentBet < bet then
            currentBet = bet
        end
    end
    return currentBet
end

function getMutiBet(value)
    local currentBet = balance / value.py
    local risk = value.risk - value.lose
    for i = 1, risk, 1 do
        currentBet = currentBet / ((value.onlose / 100) + 1)
    end
    if currentBet < bet then
        currentBet = bet
    end
    return currentBet
end

function updateBet()
    for key, value in pairs(tableChance) do
        if tonumber(lastBet.roll) > tonumber(value.game) then
            value.lose = 0
            value.bet = getCurBet(value)
        else
            if value.lose > 0 then
                if key == chance then
                    value.bet = value.bet + (value.bet * value.onlose / 100)
                else
                    value.bet = getMutiBet(value)
                end
            end
            value.lose = value.lose + 1
        end
    end
end

function getNextBet()
    local phantram = 100
    local smartChance = 0
    for key, value in pairs(tableChance) do
        local cbet = value.risk - value.lose
        local pt = cbet / value.risk * 100
        if pt < phantram and (pt >= 70 or pt <= 40) then
            phantram = pt
            smartChance = key
        end
    end
    if (smartChance > 0) then
        local myBetNext = tableChance[smartChance]
        chance = smartChance
        nextbet = myBetNext.bet
    else
        chance = 50
        nextbet = bet
    end
end

function dobet()
    if profit > balance / 100 then
        createChange()
        resetstats()
    end
    updateBet()
    getNextBet()
end

