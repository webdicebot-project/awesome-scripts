--
-- Created by IntelliJ IDEA.
-- User: luan
-- Date: 5/17/20
-- Time: 4:48 PM
-- To change this template use File | Settings | File Templates.
--

bet = 0.37037037
allChance = {min = 1, max = 98}
runOnMinimun = 1
tableChance = {}
typeBet = {
    hi = true,
    low = false
}
chance = 50
nextbet = bet
bethigh = true

function getPayout(chag)
    local py = 100 / tonumber(chag)
    py = py - (py * (1 / 100))
    return py;
end

function createChange()
    for i = allChance.min, allChance.max, runOnMinimun do
        i = string.format("%.2f", i)
        local py = tonumber(string.format("%.4f", getPayout(i)))
        tableChance[tonumber(i)] = {
            hi = {
                game = string.format("%.2f", (100 - i - 0.01)) * 100,
                risk = py * 10,
                lose = 0,
                onlose = 1 / (py - 1) * 100,
                onSetBet = 1 / (py - 1) / 100,
                onloseSmall = 1 / (py - 1) * 20,
                bet = bet,
                onWin = 0
            },
            low = {
                game = string.format("%.2f", i) * 100,
                risk = py * 10,
                lose = 0,
                onlose = 1 / (py - 1) * 100,
                onSetBet = 1 / (py - 1) / 100,
                onloseSmall = 1 / (py - 1) * 20,
                bet = bet,
                onWin = 0
            }
        }
    end
end

createChange()

function updateBet()
    for key, value in pairs(tableChance) do
        for hiLow, val in pairs(typeBet) do
            value[hiLow].defaultHigh = val
            local currentBet = balance / value[hiLow].risk * value[hiLow].onSetBet
            currentBet = currentBet / ((value[hiLow].onlose / 100) + 1)
            if val then
                if tonumber(lastBet.roll) > tonumber(value[hiLow].game) then
                    value[hiLow].onWin = value[hiLow].lose
                    value[hiLow].lose = 0
                    if currentBet > balance then
                        value[hiLow].bet = bet
                    else
                        if currentBet < bet then
                            value[hiLow].bet = bet
                        else
                            value[hiLow].bet = currentBet
                        end
                    end
                else
                    if value[hiLow].lose > 0 then
                        if key == chance then
                            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
                        end
                    end
                    value[hiLow].lose = value[hiLow].lose + 1
                end
            else
                if tonumber(lastBet.roll) < tonumber(value[hiLow].game) then
                    value[hiLow].onWin = value[hiLow].lose
                    value[hiLow].lose = 0
                    if currentBet > balance then
                        value[hiLow].bet = bet
                    else
                        if currentBet < bet then
                            value[hiLow].bet = bet
                        else
                            value[hiLow].bet = currentBet
                        end
                    end
                else
                    if value[hiLow].lose > 0 then
                        if key == chance then
                            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
                        end
                    end
                    value[hiLow].lose = value[hiLow].lose + 1
                end
            end
        end
    end
end

function getNextBet()
    local phantram = 100
    local smartChance = 0
    local curHL
    for key, value in pairs(tableChance) do
        for hiLow, val in pairs(typeBet) do
            local cbet = value[hiLow].risk - value[hiLow].lose
            local pt = cbet / value[hiLow].risk * 100
            if pt < phantram then
                phantram = pt
                smartChance = key
                curHL = hiLow
            end
        end
    end
    if (smartChance > 0 and curHL ~= inl) then
        local myBetNext = tableChance[smartChance][curHL]
        chance = smartChance
        bethigh = myBetNext.defaultHigh
        nextbet = myBetNext.bet
    else
        chance = 50
        nextbet = bet
    end
end

function dobet()
    updateBet()
    getNextBet()
end