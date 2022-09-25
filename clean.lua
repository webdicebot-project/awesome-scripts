--
-- Created by IntelliJ IDEA.
-- User: luan
-- Date: 5/1/20
-- Time: 5:48 PM
-- To change this template use File | Settings | File Templates.
--
bet = 0.00001000
nextbet = bet
chance = 50
bethigh = true
chanceLow = {min = 0.01, max = 10}
chanceGo = {min = 15, max = 40}
listChanceLow = {}
listChanceGo = {}
runOnMinimun = 0.01
type = {"hi", "low"}
flagGo = false
target = 1
stb = balance

function getPayout(chag)
    local py = 100 / tonumber(chag)
    py = py - (py * (1 / 100))
    return py;
end

function createChange()
    for i = chanceLow.min, chanceLow.max, runOnMinimun do
        local py = getPayout(i)
        listChanceLow[tonumber(i)] = {
            hi = {
                game = string.format("%.2f", (100 - i - 0.01)),
                risk = py * 10 + ((py * 10) * 20 / 100),
                change = i,
                lose = 0,
                defaultHi = true,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 120,
                bet = bet
            },
            low = {
                game = string.format("%.2f", i),
                risk = py * 10 + ((py * 10) * 20 / 100),
                change = i,
                lose = 0,
                defaultHi = false,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 120,
                bet = bet
            }
        }
    end
    for i = chanceGo.min, chanceGo.max, runOnMinimun do
        local py = getPayout(i)
        listChanceGo[tonumber(i)] = {
            hi = {
                game = string.format("%.2f", (100 - i - 0.01)),
                risk = py * 10 + 15,
                change = i,
                lose = 0,
                defaultHi = true,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 120,
                bet = bet
            },
            low = {
                game = string.format("%.2f", i),
                risk = py * 10 + 15,
                change = i,
                lose = 0,
                defaultHi = false,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 120,
                bet = bet
            }
        }
    end
end

function updateTiLeThang()
    for key, value in pairs(listChanceLow) do
        if lastBet.roll < tonumber(value["hi"].game) then
            value["hi"].lose = value["hi"].lose + 1
            if key == chance then
                value["hi"].bet = value["hi"].bet + value["hi"].bet * value["hi"].onlose / 100
            end
        else
            value["hi"].lose = 0
            value["hi"].bet = bet
        end
        if lastBet.roll > tonumber(value["low"].game) then
            value["low"].lose = value["low"].lose + 1
            if key == chance then
                value["low"].bet = value["low"].bet + value["low"].bet * value["low"].onlose / 100
            end
        else
            value["low"].lose = 0
            value["low"].bet = bet
        end
        for i, v in ipairs(type) do
            if value[v].lose == 0 then
                value[v].tilethang = 0
            else
                value[v].tilethang = value[v].lose / value[v].risk * 100
                if value[v].tilethang < 10 then
                    value[v].bet = bet
                end
            end
        end
    end
    for key, value in pairs(listChanceGo) do
        if lastBet.roll < tonumber(value["hi"].game) then
            value["hi"].lose = value["hi"].lose + 1
            value["hi"].bet = value["hi"].bet + value["hi"].bet * value["hi"].onlose / 100
        else
            value["hi"].lose = 0
            value["hi"].bet = bet
        end
        if lastBet.roll > tonumber(value["low"].game) then
            value["low"].lose = value["low"].lose + 1
            value["low"].bet = value["low"].bet + value["low"].bet * value["low"].onlose / 100
        else
            value["low"].lose = 0
            value["low"].bet = bet
        end
        for i, v in ipairs(type) do
            if value[v].lose == 0 then
                value[v].tilethang = 0
            else
                value[v].tilethang = value[v].lose / value[v].risk * 100
            end
        end
    end
end

function getPayoutGo()
    local phantram = 0
    local smartChance = 0
    local curHL
    for key, value in pairs(listChanceGo) do
        for i, v in ipairs(type) do
            if (value[v].tilethang > phantram) then
                phantram = value[v].tilethang
                smartChance = key
                curHL = v
            end
        end
    end
    local myBetNext = listChanceGo[smartChance][curHL]
    return myBetNext
end

function getPayoutCur()
    local phantram = 0
    local smartChance = 0
    local curHL
    for key, value in pairs(listChanceLow) do
        for i, v in ipairs(type) do
            if value[v].tilethang >= 120 and value[v].tilethang > phantram then
                phantram = value[v].tilethang
                smartChance = key
                curHL = v
            elseif (value[v].tilethang >= 80 and value[v].tilethang <= 100) and value[v].tilethang > phantram then
                phantram = value[v].tilethang
                smartChance = key
                curHL = v
            elseif (value[v].tilethang >= 40 and value[v].tilethang <= 60) and value[v].tilethang > phantram then
                phantram = value[v].tilethang
                smartChance = key
                curHL = v
            elseif (value[v].tilethang >= 10 and value[v].tilethang <= 30) and value[v].tilethang > phantram then
                phantram = value[v].tilethang
                smartChance = key
                curHL = v
            elseif value[v].tilethang > phantram then
                phantram = value[v].tilethang
                smartChance = key
                curHL = v
            end
        end
    end
    local myBetNext = listChanceLow[smartChance][curHL]
    return myBetNext
end

createChange()

function workingBet()
    local normal = getPayoutCur()
    if ((normal.tilethang >= 10 and normal.tilethang <= 30) or
            (normal.tilethang >= 40 and normal.tilethang <= 60) or
            (normal.tilethang >= 80 and normal.tilethang <= 100) or
            (normal.tilethang >= 120)) then
        log('smart')
        chance = normal.change
        bethigh = normal.defaultHi
        nextbet = normal.bet
    else
        local go = getPayoutGo()
        log('go')
        chance = go.change
        bethigh = go.defaultHi
        nextbet = go.bet
    end
    if nextbet > balance then nextbet = balance / 2 end
    if nextbet < bet then nextbet = bet end
end

function dobet()
    updateTiLeThang()
    workingBet()
    if balance >= target then stop() end
end
