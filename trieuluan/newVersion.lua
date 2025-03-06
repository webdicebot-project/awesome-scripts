--
-- Coder: luan
-- Date: 5/16/20
-- Time: 6:12 PM
-- Please set bet = min of coin with site you play
-- Code will do any thing
-- Set chance you want to play. For example (form = 5, to = 85 or form = 1, to = 98)
-- With duckdice set gameRoll = 100
-- set target you want on variable target
-- Buy me a coffee with Doge: DTQUKPAtskAnri5dKKVT4n5VaWz3DDovqw
--
bet = 0.00000001
form = 5
to = 95
gameRoll = 1
runOnMinimun = 1
tableChance = {}
typeBet = {
    hi = true,
    low = false
}
chance = 50
nextbet = bet
bethigh = true
target = balance * 5
onriskbalance = 0
flag = false

function getPayout(chag)
    local py = 100 / tonumber(chag)
    py = py - (py * (1 / 100))
    return py;
end

function createChange()
    for i = form, to, runOnMinimun do
        i = string.format("%.2f", i)
        local py = tonumber(string.format("%.4f", getPayout(i)))
        tableChance[tonumber(i)] = {
            hi = {
                game = string.format("%.2f", (100 - i - 0.01)) * gameRoll,
                risk = math.ceil(py * 10 + ((py * 10) * 20 / 100)),
                lose = 0,
                onlose = 1 / (py - 1) * 100,
                bet = bet,
                py = py
            },
            low = {
                game = string.format("%.2f", i) * gameRoll,
                risk = math.ceil(py * 10 + ((py * 10) * 20 / 100)),
                lose = 0,
                onlose = 1 / (py - 1) * 100,
                bet = bet,
                py = py
            }
        }
    end
end

createChange()

function getCurBet(value, hiLow)
    local currentBet = (balance / 10) / value[hiLow].py
    for i = 1, value[hiLow].risk, 1 do
        currentBet = currentBet / ((value[hiLow].onlose / 100) + 1)
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

function getMutiBet(value, hiLow)
    local currentBet = (balance / 10) / value[hiLow].py
    if onriskbalance > 0 then
        currentBet = onriskbalance / value[hiLow].py
    end
    local risk = value[hiLow].risk - value[hiLow].lose
    for i = 1, risk, 1 do
        currentBet = currentBet / ((value[hiLow].onlose / 100) + 1)
    end
    if currentBet < bet then
        currentBet = bet
    end
    return currentBet
end

function updateBet()
    for key, value in pairs(tableChance) do
        for hiLow, val in pairs(typeBet) do
            value[hiLow].defaultHigh = val
            if val then
                if tonumber(lastBet.roll) > tonumber(value[hiLow].game) then
                    value[hiLow].lose = 0
                    value[hiLow].bet = getCurBet(value, hiLow)
                else
                    if value[hiLow].lose > 0 then
                        if key == chance then
                            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
                        else
                            value[hiLow].bet = getMutiBet(value, hiLow)
                        end
                    end
                    value[hiLow].lose = value[hiLow].lose + 1
                end
            else
                if tonumber(lastBet.roll) < tonumber(value[hiLow].game) then
                    value[hiLow].lose = 0
                    value[hiLow].bet = getCurBet(value, hiLow)
                else
                    if value[hiLow].lose > 0 then
                        if key == chance then
                            value[hiLow].bet = value[hiLow].bet + (value[hiLow].bet * value[hiLow].onlose / 100)
                        else
                            value[hiLow].bet = getMutiBet(value, hiLow)
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
            if pt < phantram and (pt >= 70 or pt <= 40) then
                phantram = pt
                smartChance = key
                curHL = hiLow
            end
        end
    end
    if phantram <= 40 then
        if onriskbalance == 0 then
            onriskbalance = (balance / 10)
        end
        log(phantram)
    else
        if (balance / 10) >= onriskbalance then
            onriskbalance = 0
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
    if balance >= target then
        stop()
    end
end