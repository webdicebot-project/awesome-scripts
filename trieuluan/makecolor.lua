--
-- Created by IntelliJ IDEA.
-- User: ad
-- Date: 2020-05-25
-- Time: 09:29
-- To change this template use File | Settings | File Templates.
--
bet = 0.0100000
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
realBalance = balance
profitHigh = 0
countBet = 0

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
                risk = math.ceil(py * 10),
                lose = 0,
                onlose = 1 / (py - 1) * 100,
                onwin = {
                    count = 0,
                    tile = 0
                },
                bet = bet,
                py = py
            },
            low = {
                game = string.format("%.2f", i) * gameRoll,
                risk = math.ceil(py * 10),
                lose = 0,
                onlose = 1 / (py - 1) * 100,
                onwin = {
                    count = 0,
                    tile = 0
                },
                bet = bet,
                py = py
            }
        }
    end
end

createChange()

function getCurBet(value, hiLow)
    local currentBet = realBalance / value[hiLow].py
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
    local currentBet = realBalance / value[hiLow].py
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
                    value[hiLow].onwin['count'] = value[hiLow].onwin['count'] + 1
                    value[hiLow].onwin['tile'] = value[hiLow].onwin['tile'] + (value[hiLow].lose / value[hiLow].risk * 100)
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
                    value[hiLow].onwin['count'] = value[hiLow].onwin['count'] + 1
                    value[hiLow].onwin['tile'] = value[hiLow].onwin['tile'] + (value[hiLow].lose / value[hiLow].risk * 100)
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
    local phantram = 0
    local flagFirst = true
    local smartChance = 0
    local curHL
    local up = 60
    local down = 40
    for key, value in pairs(tableChance) do
        for hiLow, val in pairs(typeBet) do
            if value[hiLow].onwin['tile'] > 0 then
                up = 100 - (value[hiLow].onwin['tile'] / value[hiLow].onwin['count']) + 20
                down = 100 - (value[hiLow].onwin['tile'] / value[hiLow].onwin['count']) - 20
            end
            local cbet = value[hiLow].risk - value[hiLow].lose
            local pt = cbet / value[hiLow].risk * 100
            if flagFirst == true then
                phantram = pt
                flagFirst = false
            end
            if countBet >= 1000 and profit < profitHigh then
                if (pt >= up or (pt <= down)) then
                    phantram = pt
                    smartChance = key
                    curHL = hiLow
                end
                if countBet >= 1500 then
                    countBet = 0
                end
            else
                if pt < phantram and (pt <= up and (pt >= down)) then
                    phantram = pt
                    smartChance = key
                    curHL = hiLow
                end
            end
        end
    end
    if phantram <= down then
        if onriskbalance == 0 then
            onriskbalance = realBalance
        end
        log(phantram)
    else
        onriskbalance = 0
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
    realBalance = balance
    countBet = countBet + 1
    if profit > profitHigh then
        profitHigh = profit
        countBet = 0
    end
    updateBet()
    getNextBet()
    if balance >= target then
        stop()
    end
end