
--[[  

	Basic Labouchere
	
    Code by pflip   https://t.me/pflip97 


 if you like it or make profit using this script, I will not mind a tip :)

		TRON     	  	: TAWTFzoL1ewgwJhqyVdjeMCiUe53USSQvx
        DOGE        	: D8omXGquak9z6nFGtB5N5n6d2m1wNiGcRZ
        LTC         		: 0xadf4817288f20562c07ad9f9632a1def02e99513  (bep20)
        Stake nick 	: pflip
		Primedice		: pflip3
        wolf nick   	: pflip3
        shuffle     		: pflip
		
--]]

resetpartialprofit()

-----  User settings  -----

delay 		= 0                       	-- sleep time (secs) for rate limiting
minbet 		= 1e-8                  	-- minimum bet accepted for this coin 
div     		= 1e6                 		-- divider of you balance for basebet
chance  	= 49.5              		-- your basic chance
bethigh 	= true						-- most of the time useless
goal    		= balance * 1.05   	-- your target for this session in %
slf     		= 0.95                  	-- % of trail stop
sl      		= balance * slf     		-- your stop loss 

-- your basebet 

basebet 	= math.max(balance / div, minbet)

-- your Labouchere sequence
-- you can make any sequence you want at any lenght
-- document yourself on what is popular

a = { 1, 2, 3, 4, 5, 6, 7}


------ end user settings  ------

--  let create the sequence and populate with the bets

seq ={}
for i, value in ipairs(a) do  
    table.insert(seq, basebet * value)  
end


nextbet 		= seq[1] + seq[#seq]
sbal    			= balance
ath     			= balance
atl     			= balance
atlp    			= 0
num_seq      = 0

function check_conditions()
    
    sleep(delay)
    
-- check if we made our target

    if balance > goal  then   
        log ("\n\t  ☺☻☺☻ Target Reached ☻☺☻☺ ")
        log("\n \t Final Gain\t »»» " ..string.format("%.8f ", balance - sbal) ..currency .." [" ..string.format("%.2f", (balance - sbal)/(sbal/100)) .." %]" )
        log("\t Max drawdown\t »»» " ..string.format("%.8f ", atl) ..currency .." [-" ..string.format("%.2f", atlp*100 ) .." %]" )
        
        stop()
    end
    
-- this will update your basebet as your balance increases

    if balance > ath then   
        ath = balance

		--   *********************
		--   uncomment if you want to increase your basebet with balance gain
		--   *********************
		
        -- basebet = math.max(balance / div, minbet)
		
        sl = balance * slf			-- trail stop update
		
    end

--  this will update max drawdown of the script (max loss %)

    if (ath - balance)/ath > atlp then
        atl = ath - balance
        atlp = (ath - balance)/ath
    end
     
-- this prints current gain every XX bets (default XX = 2)

    if bets % 2 == 0 then  
        log("\n \t Current Gain\t »»» " ..string.format("%.8f ", balance - sbal) ..currency .." [" ..string.format("%.2f", (balance - sbal)/(sbal/100)) .." %]" )
        log("\t Max drawdown\t »»» " ..string.format("%.8f ", atl) ..currency .." [-" ..string.format("%.2f", atlp*100 ) .." %]" )
        log("\t Sequences #\t »»»  "  ..num_seq)
        if sl > sbal then
            log("\t Safe gain\t »»»  " .. string.format("%.8f ", (sl - sbal)) ..currency  .. " [ " .. string.format("%.2f", (((sl - sbal) / sbal) * 100)) .. " % ]")          
        else
            log("\t Stop Loss\t »»» " ..string.format("%.8f ",sl) ..currency .." [-" ..string.format("%.2f",100 - ( sl/((sbal)/100))) .." %]" )
        end 
        log("\n\n")
    end

end


function dobet()

	check_conditions()


	if win then 
			table.remove(seq,#seq)
			table.remove(seq, 1)
		if #seq == 0 then  --  sequence complete. let's re-initialize 
			num_seq += 1
			for i, value in ipairs(a) do  
				table.insert(seq, basebet * value)  
			end
		end
	else
		table.insert(seq,  previousbet)
	end

	   nextbet = seq[1] + seq[#seq]
	   
 
-- check if we reached (or going to reach) the stop loss

    if balance - nextbet < sl  then   
            log(" Stop Loss reached ")
            log("\n \t Final Gain\t »»» " ..string.format("%.8f", balance - sbal) .." [" ..string.format("%.2f", (balance - sbal)/(sbal/100)) .." %]" )
            stop()
    end 
    
end   -- end dobet
