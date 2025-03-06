
--[[  

	Basic D'Albert
	
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

delay   		= 0                       	-- sleep time (secs) for rate limiting
minbet 		= 1e-8                  	-- minimum bet accepted for this coin 
div     		= 1e7                		-- divider of you balance for basebet
chance  	= 49.5              		-- your basic chance
bethigh 	= true						-- most of the time useless
goal    		= balance * 1.25   	-- your target for this session (1.25 = 25% gain)
slf     		= 0.5                  		-- % of trail stop (0.5  = 50% stop loss)
sl      		= balance * slf     		-- your initial stop loss 
maxbet 	= balance * 0.05       -- limit bets not to go too wild

-- your basebet 

basebet 	= math.max(balance / div, minbet)

nextbet 	= basebet
sbal    		= balance
ath     		= balance
atl     		= balance
atlp    		= 0


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
		--   uncomment if you want to increase your basebet while you gain
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
        if sl > sbal then
            log("\t Safe gain\t »»»  " .. string.format("%.8f ", (sl - sbal)) ..currency  .. " [ " .. string.format("%.2f", (((sl - sbal) / sbal) * 100)) .. " % ]")          
        else
            log("\t Stop Loss\t »»» " ..string.format("%.8f ",sl) ..currency .." [-" ..string.format("%.2f",100 - ( sl/((sbal)/100))) .." %]" )
        end 
        log("\n\n")
    end

end   -- end check_conditions()


function dobet()

	check_conditions()


	if win then 
		nextbet = previousbet * 0.25    -- original D'albert calls for half previous bet (0.5). I think it is too risky
	else
		nextbet = math.min( maxbet, previousbet * 2 )  -- you might want to multiply for 2.1 for "quicker" gain
	end

	   nextbet = math.max(minbet,nextbet)
	   
	 
	-- check if we reached (or going to reach) the stop loss

		if balance - nextbet < sl  then   
				log(" Stop Loss reached ")
				log("\n \t Final Gain\t »»» " ..string.format("%.8f", balance - sbal) .." [" ..string.format("%.2f", (balance - sbal)/(sbal/100)) .." %]" )
				stop()
		end 
    
end   -- end dobet