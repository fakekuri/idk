local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Enemies = workspace:FindFirstChild("Enemies")
local request_fn =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

local API = {
    url = "https://api-trieu.onrender.com",
    id = "63646de03538",
    key = "3a32914b240b06beada51f81055aac3069e999ca12fbfca51c3e6d7b81d0d61f"
}

local active = {}
local sentFruit = {}

local function getFruit()
    for _,v in next, workspace:GetChildren() do
        if (v:IsA("Model") or v:IsA("Tool"))
        and v.Name:find("Fruit")
        and v.Parent
        and v:FindFirstChild("Handle") then
            return v
        end
    end
end

local function getSea()
    local id = game.PlaceId

    if id == 2753915549 or id == 85211729168715 then return 1 end
    if id == 4442272183 or id == 79091703265657 then return 2 end
    if id == 7449423635 or id == 100117331123089 then return 3 end

    return 0
end

local function send(name)
    pcall(function()
        request_fn({
            Url = API.url .. "/push",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                id = API.id,
                apiKey = API.key,
                job = game.JobId,
                players = #Players:GetPlayers(),
                sea = getSea(),
                boss = string.lower(name)
            })
        })
    end)
end

local function check(name,cond)
    local ok = false
    pcall(function() ok = cond() end)

    if ok then
        if not active[name] then
            active[name] = true
            send(name)
        end
    else
        active[name] = nil
    end
end

local function enemy(name)
    return function()
        return RS:FindFirstChild(name)
            or (Enemies and Enemies:FindFirstChild(name))
    end
end

task.spawn(function()
    while task.wait(5) do

        local sea = getSea()

        if sea == 2 then
            check("dark", enemy("Darkbeard"))
            check("captain", enemy("Cursed Captain"))

            check("sword", function()
                local f = RS.Remotes.CommF_
                for i = 1,3 do
                    local ok,res = pcall(f.InvokeServer, f, "LegendarySwordDealer", tostring(i))
                    if ok and res then return true end
                end
            end)
        end

        if sea == 3 then

            check("rip", enemy("Rip Indra"))
            check("doughv2", enemy("Dough King"))
            check("doughv1", enemy("Cake Prince"))
            check("tyrant", enemy("Tyrant of the Skies"))
            check("reaper", enemy("Soul Reaper"))
            check("elite", function()

                local elite =
                    RS:FindFirstChild("Diablo")
                    or RS:FindFirstChild("Deandre")
                    or RS:FindFirstChild("Urban")
                    or (Enemies and Enemies:FindFirstChild("Diablo"))
                    or (Enemies and Enemies:FindFirstChild("Deandre"))
                    or (Enemies and Enemies:FindFirstChild("Urban"))

                if elite then
                    send(elite.Name)
                    return true
                end

                return false
            end)

            local loc = workspace:FindFirstChild("_WorldOrigin")
            loc = loc and loc:FindFirstChild("Locations")

            if loc then
                check("daobian", function()
                    return loc:FindFirstChild("Mirage Island")
                end)

                check("kitsune", function()
                    return loc:FindFirstChild("Kitsune Island")
                end)

                check("prehistoric", function()
                    return loc:FindFirstChild("Prehistoric Island")
                end)
            end

            local sky = Lighting:FindFirstChild("Sky")
            if sky then
                local moon = sky.MoonTextureId

                check("fullmoon", function()
                    return moon == "http://www.roblox.com/asset/?id=9709149431"
                end)

                check("nearmoon", function()
                    return moon == "http://www.roblox.com/asset/?id=9709149052"
                end)
            end
        end
        local f = getFruit()
        if f and not sentFruit[f] then
            sentFruit[f] = true
            send(f.Name)
        end
    end
end)
