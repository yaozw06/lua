
local w32= require "w32"

local whiteboard = {}
local restaurant = {}
local open

local table_id= 10
function customer_arrive()
	table_id=table_id- 1
	if table_id== 0 then table_id=10 end
	print("arrive at tab ".. table_id)
	return table_id
end

local dishes={"coffee", "noodle", "pisa", "beef" }
local dish_id= 0
function customer_order()
	dish_id=dish_id+ 1
	if dish_id> 4 then dish_id=1 end
	print("order ".. dish_id)
	return dish_id
end

function restaurant.queue(order, callback)
	print("queue ")
    local nextCmd = function(d)
		print("nextCmd ")
        callback(d)
    end
    table.insert(whiteboard, order)
    table.insert(whiteboard, nextCmd)
end


function restaurant.kitchen()
	function makedish(order)
		print("makedish " .. dishes[order])
		return dishes[order]
	end
    while open do
		print("kitchen ")
        local order = table.remove(whiteboard, 1)
        local act = table.remove(whiteboard, 1)
		for k,v in pairs(order)  do
			local tray= {}
			tray[k]= makedish(v)
            act(tray)
        end
    end
	print("kitchen quit")
end


function receive()
	print("receive")
	local tid= customer_arrive()
	local did= customer_order()
	local order={}
	order[tid]= did
    local co = coroutine.running()
    local toserve = (function(line)
		print("resume to serve ")
        coroutine.resume(co, line)
		print("after yield ")
    end)
    restaurant.queue(order, toserve)
	print("yield to")
    local t = coroutine.yield()
	print("after resume ")
    return t
end

function serve(t)
	print("serve")
	for tid, dish in pairs(t)  do
		print("take "..dish .. " to tab "..tid)
	end
end


function run(code)
	print("run")
    local co = coroutine.wrap(function()
        code()
    end)
    co()
    restaurant.kitchen()
end

run(function()
	local times= 0
	open= true
	while times< 30 do
		print("hall")
        	local tray = receive()
		serve(tray)
		times= times+ 1
		w32.Sleep(5)
	end
	open= false
end)
