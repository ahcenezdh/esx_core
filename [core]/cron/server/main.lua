local Jobs = {}
local LastTime = nil

local function runAt(h, m, cb)
	Jobs[#Jobs+1] = {h = h, m = m, cb = cb}
end

local function getTime()
    local timestamp <const> = os.time()
    local timeTable <const> = os.date('*t', timestamp)
    return {d = timeTable.wday, h = timeTable.hour, m = timeTable.min}
end

local function onTime(d, h, m)
    for _, job in ipairs(Jobs) do
        if job.h == h and job.m == m then
            job.cb(d, h, m)
        end
    end
end

local function tick()
    local time = getTime()

    if time.h ~= LastTime.h or time.m ~= LastTime.m then
        onTime(time.d, time.h, time.m)
        LastTime = time
    end

    SetTimeout(60000, tick)
end

LastTime = getTime()
tick()

exports('runAt', function(h, m, cb)
    runAt(h, m, cb)
end)
