-- amazon delivery window finder
-- inspired by work by ahertel!
to clickClassName(theClassName, elementnum, mytab)
	-- log element to js console
	js("console.log(document.getElementsByClassName('" & theClassName & "')[" & elementnum & "].querySelector('a,input,button'))", mytab)
	-- click inner a,input,button,etc of given element
	return js("document.getElementsByClassName('" & theClassName & "')[" & elementnum & "].querySelector('a,input,button').click()", mytab)
end clickClassName

to clickContinue(mytab)
	-- first continue on page
	return js("document.getElementsByClassName('a-button a-button-primary')[0].querySelector('a,input,button').click()	", mytab)
end clickContinue

to js(code, mytab)
	tell application "Safari"
		return do JavaScript "" & code in mytab
	end tell
	
end js


set autoCheckout to false
-- variable definitions
set found to false
set reload to true
set cartUrl to "https://www.amazon.com/gp/cart/view.html"
set navigate to false
set autoCheckout to false

display dialog "Auto checkout?" buttons {"Yes", "No"} default button "Yes"
if result = {button returned:"Yes"} then
	set autoCheckout to true -- redundant, but included for clarity
end if

log autoCheckout
-- save tab
tell application "Safari"
	set mywin to (front window)
	tell mywin
		set mytab to (current tab)
	end tell
end tell

repeat while found is false
	
	if navigate then
		tell application "Safari" to set the URL of mytab to cartUrl
		delay 10
		-- assume its the first continue button on the cart page
		-- this may not work as expected if multiple carts are present, e.g fresh is always first for me
		clickContinue(mytab)
		delay 10
		-- before you checkout
		clickContinue(mytab)
		delay 10
		-- optional sub page
		clickContinue(mytab)
		delay 20
		-- landed on delivery window page
		set navigate to false
	end if
	
	
	tell application "Safari"
		tell mywin
			-- reload the delivery slot page
			if reload then
				tell mytab to do JavaScript "location.reload();"
			end if
			set reload to true
			-- wait for the page to load
			delay 7
			-- log text on the page
			set siteText to (text of mytab) as string
		end tell
		
	end tell
	
	-- Amazon Fresh
	if siteText contains "Reserve your time" then
		
		-- cycle through tabs and delivery window buttons
		-- click/select delivery window button and click continue in each iteration
		-- try to alert based on disabled class name in delivery button span
		-- Removed: tabs and window buttons are completely separate, click tabs anyway in case that influences activation, this is probably not needed
		
		repeat with j from 0 to 20
			-- check if radio button is disabled
			set radioDisabled to js("document.getElementsByClassName('a-box spanOutsideSlotButton')[" & j & "].querySelector('input').disabled", mytab)
			try
				if not radioDisabled then
					-- not disabled, means we got one baby
					-- click the radio, the continue
					js("document.getElementsByClassName('a-box spanOutsideSlotButton')[" & j & "].querySelector('input').click()", mytab)
					set found to true
					exit repeat
				end if
			on error errMsg
				-- if no radio buttons are found, no slots are available, bail out
				exit repeat
			end try
			delay 0.1
		end repeat
		-- Whole Foods
	else if siteText contains "Schedule your order" then
		-- TODO more testing
		if siteText does not contain "No delivery windows available" then
			-- click first slot
			clickClassName("ufss-slot-toggle-button", 0, mytab)
			-- continue
			set found to true
			exit repeat
		end if
	else if siteText contains "We're sorry we are unable to fulfill your entire order" then
		log siteText
		display notification "Out of stock page, continuing" with title "Amazon"
		clickContinue(mytab)
	else if siteText contains "Review items and shipping" then
		log siteText
		say "Error!"
		display notification "Wrong page: Regular Amazon checkout page. Check Grocery cart!" with title "Amazon"
		return
	else
		log siteText
		display notification "Wrong page: renavigating" with title "Amazon"
		set navigate to true
	end if
	
	-- rate limit for subsequent attempts
	if not found then
		delay 10
	end if
	
end repeat

if found then
	
	display notification "Found delivery slot!" with title "Amazon" sound name "Sosumi"
	say "Success: Delivery slot found"
	-- Click Continue several times to attempt to complete checkout
	-- this part is highly fragile/fickle depending on payment methods etc, may need user intervention
	-- payment method can be changed later, for example it always picks amazon store card on my acct
	-- TODO
	-- Ive noticed a bug where amazon fails to check me out and directs me back to delivery slot page
	-- do not panic, just initiate check out again, your delivery slot should still be reserved for Fresh at least, Whole Foods seems to drop it, this may be due to contention 
	repeat 3 times
		if autoCheckout then
			clickContinue(mytab)
		end if
		delay 10
		say "Success: Delivery slot found"
	end repeat
	
	repeat 20 times
		say "Success: Delivery slot found"
	end repeat
else
	display notification "Error: finished" with title "Amazon" sound name "Sosumi"
	say "Error: finished"
end if
