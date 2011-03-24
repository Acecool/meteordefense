--Function To Check Partial Class names
--ex. IsClass( ent, "npc_" ) would return all ents with classes starting with npc_
-- if you want all the antlions IsClass(ent, "npc_a")
function IsClass( ent, class )

	if ent == nil then return false end
	if ent == NULL then return false end
	if !ent:IsValid() then return false end
	
	local result = string.find(ent:GetClass(), class)
	--print("Is " .. ent:GetClass() .. " a " .. class .. " : " .. tostring(!(result == nil)))
	if (result == nil) then 
		return false 
	else 
		return true 
	end
	
end				


function GetRandomKeyValue( tbl )

	maxIndex = table.Count(tbl)
	key = math.random(1, maxIndex)
	value = tbl[key]
	
	return key, value

end

function GetRandomKey( tbl )

	maxIndex = table.Count(tbl)
	key = math.random(1, maxIndex)
		
	return key

end

function GetRandomValue( tbl )

	maxIndex = table.Count(tbl)
	if maxIndex == 0 then return nil end
	key = math.random(1, maxIndex)
	value = tbl[key]
	
	return value

end

function FindInTable( tbl, what)

	for k, v in pairs(tbl) do
		if v == what then
			return k
		end
	end
	
	return nil

end

function IndexByValue( tbl, value, field )

	if tbl == nil then return nil end
	
	for i, v in pairs(tbl) do
		if field == nil then
			if v == value then
				return i
			end
		else
			if v[field] == value then
				return i
			end
		end
	end
	
	return nil
	
end



function StringToColor( str ) 

	elements = string.Explode(".",str)
	
	return Color(elements[1], elements[2], elements[3], elements[4])
	
end

function ColorToString( clr ) 

	return tostring(clr.r .."." .. clr.g .."." .. clr.b .."." .. clr.a)
	
end


-- Add Comma to numbers function from CowThing on Facepunch.com in WAYWO v4 thread
function AddComma(n)
    sn = tostring(n)
    sn = string.ToTable(sn)
     
    tab = {}
    for i=0,#sn-1 do
         
        if i%3 == #sn%3 and !(i==0) then
            table.insert(tab, ",")
        end
        table.insert(tab, sn[i+1])
     
    end
     
    return string.Implode("",tab)
end

function inc( n )
	
	return n + 1

end

function dec( n )
	return n - 1
end

function GM:EntityRemoved(ent)
   --print("Removed Entity: " .. tostring(ent) .. " @ " .. tostring(os.time()))
end
--hook.Add("EntityRemoved", "entRemoved", entityRemoved)