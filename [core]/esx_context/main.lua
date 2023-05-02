local activeMenu
local Debug <const> = ESX.GetConfig().EnableDebug

local function post(fn, ...)
    SendNUIMessage({func = fn, args = {...}})
end

local function close()
    SetNuiFocus(false, false)

    local menu <const> = activeMenu
    local cb <const> = menu.onClose

    activeMenu = nil
    LocalPlayer.state:set("context:active", false)

    if cb then cb(menu) end
end

local function open(position, eles, onSelect, onClose, canClose)
    canClose = canClose == nil and true or canClose
    activeMenu = {position = position, eles = eles, canClose = canClose, onSelect = onSelect, onClose = onClose}

    LocalPlayer.state:set("context:active", true)
    post("Open", eles, position)
end

exports("Preview", open)
exports("Open", function(...) open(...); SetNuiFocus(true, true) end)
exports("Close", function() if not activeMenu then return end; post("Closed"); close() end)

exports("Refresh", function(eles, position)
    if not activeMenu then return end

    activeMenu.eles = eles or activeMenu.eles
    activeMenu.position = position or activeMenu.position
    post("Open", activeMenu.eles, activeMenu.position)
end)

local nuiCallbacks = {
    closed = function(data, cb)
        if not activeMenu or (activeMenu and not activeMenu.canClose) then return cb(false) end
        cb(true)
        close()
    end,
    selected = function(data, cb)
        if not activeMenu or not activeMenu.onSelect or not data.index then return end

        local index <const> = tonumber(data.index)
        local ele <const> = activeMenu.eles[index]

        if not ele or ele.input then return end

        activeMenu:onSelect(ele)
        if cb then cb('ok') end
    end,
    changed = function(data, cb)
        if not activeMenu or not data.index or not data.value then return end

        local index <const> = tonumber(data.index)
        local ele = activeMenu.eles[index]

        if not ele or not ele.input then return end

        if ele.inputType == "number" then
            ele.inputValue = tonumber(data.value)
            ele.inputValue = ele.inputMin and math.max(ele.inputMin, ele.inputValue) or ele.inputValue
            ele.inputValue = ele.inputMax and math.min(ele.inputMax, ele.inputValue) or ele.inputValue
        elseif ele.inputType == "text" or ele.inputType == "radio" then
            ele.inputValue = data.value
        end
        if cb then cb('ok') end
    end
}

for name, callback in pairs(nuiCallbacks) do
    RegisterNUICallback(name, callback)
end

local function focusPreview()
    if not activeMenu or not activeMenu.onSelect then return end
    SetNuiFocus(true, true)
end

if PREVIEW_KEYBIND then
    RegisterCommand("previewContext", focusPreview, false)
    RegisterKeyMapping("previewContext", "Preview Active Context", "keyboard", PREVIEW_KEYBIND)
end

exports("focusPreview", focusPreview)

-- Debug/Test
-- Commands:
-- [ ctx:preview | ctx:open | ctx:close | ctx:form ]

if Debug then
	local context <const> = exports["esx_context"]
	local position <const> = "right"

	local eles <const> = {
	 	{
	 		unselectable=true,
	 		icon="fas fa-info-circle",
	 		title="Unselectable Item (Header/Label?)",
	 	},
	 	{
	 		icon="fas fa-check",
	 		title="Item A",
	 		description="Some description here. Add some words to make the text overflow."
	 	},
	 	{
	 		disabled=true,
	 		icon="fas fa-times",
	 		title="Disabled Item",
	 		description="Some description here. Add some words to make the text overflow."
	 	},
	 	{
	 		icon="fas fa-check",
	 		title="Item B",
	 		description="Some description here. Add some words to make the text overflow."
	 	},
	}

	local function onSelect(menu,ele)
		print("Ele selected",ele.title)

		if ele.name == "close" then
			context:Close()
		end

		if ele.name ~= "submit" then
			return
		end

		for _,ele in ipairs(menu.eles) do
			if ele.input then
				print(ele.name,ele.inputType,ele.inputValue)
			end
		end

		context:Close()
	end

	local function onClose(menu)
		print("Menu closed.")
	end

	RegisterCommand("ctx:preview",function()
		context:Preview(position,eles)
	end, false)

	RegisterCommand("ctx:open",function()
		context:Open(position,eles,onSelect,onClose)
	end, false)

	RegisterCommand("ctx:close",function()
		context:Close()
	end, false)

	RegisterCommand("ctx:form",function()
		local eles <const> = {
			{
				unselectable=true,
				icon="fas fa-info-circle",
				title="Unselectable Item (Header/Label?)",
			},
			{
				icon="",
				title="Input Text",
				input=true,
				inputType="text",
				inputPlaceholder="Placeholder...",
				name="firstname",
			},
			{
				icon="",
				title="Input Text",
				input=true,
				inputType="text",
				inputPlaceholder="Placeholder...",
				name="lastname",
			},
			{
				icon="",
				title="Input Number",
				input=true,
				inputType="number",
				inputPlaceholder="Placeholder...",
				inputValue=0,
				inputMin=0,
				inputMax=50,
				name="age",
			},
			{
				icon = "fas fa-check",
				title = "Submit",
				name = "submit"
			}
		}

		context:Open(position, eles, onSelect, onClose)
	end, false)
end
