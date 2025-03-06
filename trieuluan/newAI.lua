--
-- Created by IntelliJ IDEA.
-- User: luan
-- Date: 4/29/20
-- Time: 6:29 PM
-- To change this template use File | Settings | File Templates.
--

resetstats()
stb = balance
chance = math.random(5, 20)
base = 0.00004000
nextbet = base
lose = 0
chancePayout = {min = 0.01, max = 10}
chanceGo = {min = 10, max = 50}
firstTimePlay = 0
listChancePayout = {}
listChanceGo = {}
type = {"hi", "low"}
bethigh = math.random(0, 100) % 2 == 0
balancelose = 0
flagChange = false
flagGo = false
flagNormal = true
target = stb * 10
targetResetSeeds = 10000
resetProfit = balance / 100;
wg = 0
hl = 0
lk = 0
ct = 0
wc = 0
hb = 0
runOnMinimun = 0.01

function getPayout(chag)
    local py = 100 / tonumber(chag)
    py = py - (py * (1 / 100))
    return py;
end

function createChange()
    for i = chancePayout.min, chancePayout.max, runOnMinimun do
        local py = getPayout(i)
        table.insert(listChancePayout, {
            hi = {
                game = string.format("%.2f", (100 - i - 0.01)),
                risk = py * 10 + 15,
                change = i,
                lose = 0,
                defaultHi = true,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 110,
                bet = 0
            },
            low = {
                game = string.format("%.2f", i),
                risk = py * 10 + 15,
                change = i,
                lose = 0,
                defaultHi = false,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 110,
                bet = 0
            }
        })
    end
    for i = chanceGo.min, chanceGo.max, runOnMinimun do
        local py = getPayout(i)
        table.insert(listChanceGo, {
            hi = {
                game = string.format("%.2f", (100 - i - 0.01)),
                risk = py * 10 + 15,
                change = i,
                lose = 0,
                defaultHi = true,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 110
            },
            low = {
                game = string.format("%.2f", i),
                risk = py * 10 + 15,
                change = i,
                lose = 0,
                defaultHi = false,
                tilethang = 0,
                onlose = 1 / (1 * py - 1) * 110
            }
        })
    end
end
function updateTiLeThang()
    for key, value in pairs(listChancePayout) do
        if lastBet.roll < tonumber(value["hi"].game) then
            value["hi"].lose = value["hi"].lose + 1
        else
            value["hi"].lose = 0
        end
        if lastBet.roll > tonumber(value["low"].game) then
            value["low"].lose = value["low"].lose + 1
        else
            value["low"].lose = 0
        end
        for i, v in ipairs(type) do
            value[v].tilethang = value[v].lose / value[v].risk * 100
        end
    end
    for key, value in pairs(listChanceGo) do
        if lastBet.roll < tonumber(value["hi"].game) then
            value["hi"].lose = value["hi"].lose + 1
        else
            value["hi"].lose = 0
        end
        if lastBet.roll > tonumber(value["low"].game) then
            value["low"].lose = value["low"].lose + 1
        else
            value["low"].lose = 0
        end
        for i, v in ipairs(type) do
            value[v].tilethang = value[v].lose / value[v].risk * 100
        end
    end
end
function resetTileThang()
    for key, value in pairs(listChancePayout) do
        for i, v in ipairs(type) do value[v].tilethang = 0 end
    end
    for key, value in pairs(listChanceGo) do
        for i, v in ipairs(type) do value[v].tilethang = 0 end
    end
end
function getGoChange()
    local phantram = 0
    local infobet = {};
    for key, value in pairs(listChanceGo) do
        for i, v in ipairs(type) do
            if value[v].tilethang >= 70 then
                phantram = value[v].tilethang
                infobet.change = value[v].change
                infobet.defaultHi = value[v].defaultHi
                infobet.onlose = value[v].onlose
                infobet.tilethang = value[v].tilethang
            elseif value[v].tilethang >= 65 and value[v].tilethang <= 70 then
                phantram = value[v].tilethang
                infobet.change = value[v].change
                infobet.defaultHi = value[v].defaultHi
                infobet.onlose = value[v].onlose
                infobet.tilethang = value[v].tilethang
            elseif value[v].tilethang >= 45 and value[v].tilethang <= 55 then
                phantram = value[v].tilethang
                infobet.change = value[v].change
                infobet.defaultHi = value[v].defaultHi
                infobet.onlose = value[v].onlose
                infobet.tilethang = value[v].tilethang
            elseif value[v].tilethang >= 25 and value[v].tilethang <= 35 then
                phantram = value[v].tilethang
                infobet.change = value[v].change
                infobet.defaultHi = value[v].defaultHi
                infobet.onlose = value[v].onlose
                infobet.tilethang = value[v].tilethang
            elseif value[v].tilethang >= 5 and value[v].tilethang <= 10 then
                phantram = value[v].tilethang
                infobet.change = value[v].change
                infobet.defaultHi = value[v].defaultHi
                infobet.onlose = value[v].onlose
                infobet.tilethang = value[v].tilethang
            elseif value[v].tilethang > phantram then
                phantram = value[v].tilethang
                infobet.change = value[v].change
                infobet.defaultHi = value[v].defaultHi
                infobet.onlose = value[v].onlose
                infobet.tilethang = value[v].tilethang
            end
        end
    end
    return infobet
end
function getPayoutChange()
    local phantram = 0
    local infobet = {};
    for key, value in pairs(listChancePayout) do
        for i, v in ipairs(type) do
            if value[v].tilethang > phantram then
                phantram = value[v].tilethang
                infobet.change = value[v].change
                infobet.defaultHi = value[v].defaultHi
                infobet.onlose = value[v].onlose
                infobet.tilethang = value[v].tilethang
            end
        end
    end
    return infobet
end

function workingChange()
    updateTiLeThang()
    local smartChange = getPayoutChange()
    local gochange = getGoChange()
    if smartChange.tilethang >= 30 and smartChange.tilethang <= 60 then
        log('here smart');
        flagChange = true
        flagNormal = false
        flagGo = false
        firstTimePlay = firstTimePlay + 1
        chance = tonumber(smartChange.change)
        local py = getPayout(smartChange.change)
        if firstTimePlay == 1 then nextbet = base end
        if lose >= py / 2 then
            nextbet = previousbet + previousbet * smartChange.onlose / 100
        end
        bethigh = smartChange.defaultHi
    elseif gochange.tilethang >= 5 and gochange.tilethang <= 70 and math.abs(balancelose) > (balance / 1000) then
        flagChange = false;
        flagNormal = false;
        flagGo = true
        chance = tonumber(gochange.change)
        local py = getPayout(chance)
        bethigh = gochange.defaultHi
        if math.abs(balancelose) < base then
            log('here go / normal');
            nextbet = math.abs(balancelose) / (py - 1)
        elseif (math.abs(balancelose) < resetProfit) then
            log('here go')
            nextbet = math.abs(balancelose) / (py - 1)
        elseif gochange.tilethang >= 65 and gochange.tilethang <= 70 then
            log('here go / 5');
            nextbet = (math.abs(balancelose) / 6) / (py - 1)
        elseif gochange.tilethang >= 45 and gochange.tilethang <= 50 then
            log('here go / 4');
            nextbet = (math.abs(balancelose) / 5) / (py - 1)
        elseif gochange.tilethang >= 25 and gochange.tilethang <= 30 then
            log('here go / 3');
            nextbet = (math.abs(balancelose) / 4) / (py - 1)
        elseif gochange.tilethang >= 5 and gochange.tilethang <= 10 then
            log('here go / 2');
            nextbet = (math.abs(balancelose) / 3) / (py - 1)
        else
            log('here random')
            chance = math.random(10, 30)
            bethigh = math.random(0, 100) % 2 == 0
            nextbet = base
        end
        firstTimePlay = 0
    else
        log('here normal');
        flagChange = false
        flagNormal = true
        flagGo = false
        firstTimePlay = 0
        chance = math.random(10, 30)
        local py = getPayout(chance)
        local onlose = 1 / (1 * py - 1) * 110;
        bethigh = math.random(0, 100) % 2 == 0
        if lose >= py / 2 then
            nextbet = previousbet + previousbet * onlose / 100
        end
    end
    if nextbet > balance then nextbet = balance / 2 end
    if nextbet < 0.00000001 then nextbet = base end
    if nextbet < base then nextbet = base end
end
createChange()

function dobet()
    ct = ct + 1
    lk = wc * 200 / ct
    wg = wg + previousbet
    if nextbet >= hb then hb = nextbet end
    if lose >= hl then hl = lose end
    if win then
        wc = wc + 1
        nextbet = base
        if balancelose <= 0 and (flagGo == true) then
            balancelose = balancelose + currentprofit
        end
        firstTimePlay = 0
        if balancelose > 0 then balancelose = 0 end
        if flagChange == true or flagNormal == true or balancelose == 0 or
                flagGo == false then lose = 0 end
        if targetResetSeeds == bets then
            resetseed()
            resetTileThang()
        end
    else
        if flagGo == true then
            lose = 0
        else
            lose = lose + 1
        end
        balancelose = balancelose + currentprofit
    end
    if profit == target then stop() end
    workingChange()
end

function s() stop() end
function seed() resetseed() end
function stats() resetstats() end