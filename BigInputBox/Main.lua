--[[

	The MIT License (MIT)

	Copyright (c) 2024 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
-- Retrive addon folder name, and our local, private namespace.
local Addon, Private = ...

-- Localization system.
-----------------------------------------------------------
-- Do not modify the function,
-- just the locales in the table below!
local L = (function(tbl,defaultLocale)
	local gameLocale = GetLocale() -- The locale currently used by the game client.
	local L = tbl[gameLocale] or tbl[defaultLocale] -- Get the localization for the current locale, or use your default.
	-- Replace the boolean 'true' with the key,
	-- to simplify locale creation and reduce space needed.
	for i in pairs(L) do
		if (L[i] == true) then
			L[i] = i
		end
	end
	-- If the game client is in another locale than your default,
	-- fill in any missing localization in the client's locale
	-- with entries from your default locale.
	if (gameLocale ~= defaultLocale) then
		for i,msg in pairs(tbl[defaultLocale]) do
			if (not L[i]) then
				-- Replace the boolean 'true' with the key,
				-- to simplify locale creation and reduce space needed.
				L[i] = (msg == true) and i or msg
			end
		end
	end
	return L
end)({
	-- ENTER YOUR LOCALIZATION HERE!
	-----------------------------------------------------------
	-- * Note that you MUST include a full table for your primary/default locale!
	-- * Entries where the value (to the right) is the boolean 'true',
	--   will use the key (to the left) as the value instead!
	["enUS"] = {

	},
	["deDE"] = {},
	["esES"] = {},
	["esMX"] = {},
	["frFR"] = {},
	["itIT"] = {},
	["koKR"] = {},
	["ptPT"] = {},
	["ruRU"] = {},
	["zhCN"] = {},
	["zhTW"] = {}

-- The primary/default locale of your addon.
-- * You should change this code to your default locale.
-- * Note that you MUST include a full table for your primary/default locale!
}, "enUS")


-- Lua API
-----------------------------------------------------------
local pairs = pairs
local select = select
local string_lower = string.lower
local string_match = string.match
local string_gsub = string.gsub
local string_upper = string.upper
local table_insert = table.insert

-- WoW API
-----------------------------------------------------------
local C_BattleNet = C_BattleNet
local ChatTypeInfo = ChatTypeInfo
local ClearOverrideBindings = ClearOverrideBindings
local CreateFrame = CreateFrame
local BNet_GetBNetIDAccount = BNet_GetBNetIDAccount
local GetBindingKey = GetBindingKey
local SetOverrideBindingClick = SetOverrideBindingClick

local ChatLabels = {
	["SAY"] 					= CHAT_MSG_SAY,
	["YELL"] 					= CHAT_MSG_YELL,
	["WHISPER"] 				= CHAT_MSG_WHISPER_INFORM,
	["PARTY"] 					= CHAT_MSG_PARTY,
	["PARTY_LEADER"] 			= CHAT_MSG_PARTY_LEADER,
	["RAID"] 					= CHAT_MSG_RAID,
	["RAID_LEADER"] 			= CHAT_MSG_RAID_LEADER,
	["RAID_WARNING"] 			= CHAT_MSG_RAID_WARNING,
	["INSTANCE_CHAT"] 			= INSTANCE_CHAT or CHAT_MSG_BATTLEGROUND,
	["INSTANCE_CHAT_LEADER"] 	= INSTANCE_CHAT_LEADER or CHAT_MSG_BATTLEGROUND_LEADER,
	["GUILD"] 					= CHAT_MSG_GUILD,
	["OFFICER"] 				= CHAT_MSG_OFFICER,
	["BN_WHISPER"] 				= CHAT_MSG_BN_WHISPER
}

-- Utility Functions
-----------------------------------------------------------
-- Return a value rounded to the nearest integer.
local math_round = function(value, precision)
	if (precision) then
		value = value * 10^precision
		value = (value + .5) - (value + .5)%1
		value = value / 10^precision
		return value
	else
		return (value + .5) - (value + .5)%1
	end
end

-- Convert a coordinate within a frame to a usable position
local parse = function(parentWidth, parentHeight, x, y, bottomOffset, leftOffset, topOffset, rightOffset)
	if (y < parentHeight * 1/3) then
		if (x < parentWidth * 1/3) then
			return "BOTTOMLEFT", leftOffset, bottomOffset
		elseif (x > parentWidth * 2/3) then
			return "BOTTOMRIGHT", rightOffset, bottomOffset
		else
			return "BOTTOM", x - parentWidth/2, bottomOffset
		end
	elseif (y > parentHeight * 2/3) then
		if (x < parentWidth * 1/3) then
			return "TOPLEFT", leftOffset, topOffset
		elseif x > parentWidth * 2/3 then
			return "TOPRIGHT", rightOffset, topOffset
		else
			return "TOP", x - parentWidth/2, topOffset
		end
	else
		if (x < parentWidth * 1/3) then
			return "LEFT", leftOffset, y - parentHeight/2
		elseif (x > parentWidth * 2/3) then
			return "RIGHT", rightOffset, y - parentHeight/2
		else
			return "CENTER", x - parentWidth/2, y - parentHeight/2
		end
	end
end

local capitalize = function(first, rest)
	return string_upper(first)..string_lower(rest)
end

-- Input Box Template
-----------------------------------------------------------
local InputBox = {

	-- Needed for position parsing. Can probably simplify a bit.
	GetParsedPosition = function(self)

		-- Retrieve UI coordinates
		local uiScale = UIParent:GetEffectiveScale()
		local uiWidth, uiHeight = UIParent:GetSize()
		local uiBottom = UIParent:GetBottom()
		local uiLeft = UIParent:GetLeft()
		local uiTop = UIParent:GetTop()
		local uiRight = UIParent:GetRight()

		local worldWidth = math_round(WorldFrame:GetWidth())
		local worldHeight = math_round(WorldFrame:GetHeight()) -- this is 768, always. why not just assume?

		-- Turn UI coordinates into unscaled screen coordinates
		uiWidth = uiWidth*uiScale
		uiHeight = uiHeight*uiScale
		uiBottom = uiBottom*uiScale
		uiLeft = uiLeft*uiScale
		uiTop = uiTop*uiScale - worldHeight -- use values relative to edges, not origin
		uiRight = uiRight*uiScale - worldWidth -- use values relative to edges, not origin

		-- Retrieve frame coordinates
		local frameScale = self:GetEffectiveScale()
		local x, y = self:GetCenter()
		local bottom = self:GetBottom()
		local left = self:GetLeft()
		local top = self:GetTop()
		local right = self:GetRight()

		-- Turn frame coordinates into unscaled screen coordinates
		x = x*frameScale
		y = y*frameScale
		bottom = bottom*frameScale
		left = left*frameScale
		top = top*frameScale - worldHeight -- use values relative to edges, not origin
		right = right*frameScale - worldWidth -- use values relative to edges, not origin

		-- Figure out the frame position relative to the UI master frame
		left = left - uiLeft
		bottom = bottom - uiBottom
		right = right - uiRight
		top = top - uiTop

		-- Figure out the point within the given coordinate space
		local point, offsetX, offsetY = parse(uiWidth, uiHeight, x, y, bottom, left, top, right)

		-- Convert coordinates to the frame's scale.
		return point, offsetX/frameScale, offsetY/frameScale
	end,

	-- Update colors and label.
	UpdateChatType = function(self)
		local chatType = self:GetAttribute("chatType") or "SAY"
		local info = ChatTypeInfo[chatType]
		local r,g,b = info.r, info.g, info.b
		self.Backdrop:SetBackdropColor(r*.1, g*.1, b*.1, .75)
		self.Backdrop:SetBackdropBorderColor(r*.1, g*.1, b*.1, .75)
		self.Border:SetBackdropBorderColor(r, g, b, .85)
		self.Label:SetTextColor(r, g, b, 1)
		self.LanguageButton.Language:SetTextColor(r, g, b, 1)

		local label
		if (chatType == "WHISPER") or (chatType == "BN_WHISPER") then
			local target = self:GetAttribute("tellTarget")
			if (target) then
				-- Real names are protected,
				-- meaning they can only be directly printed,
				-- not parsed or otherwise accessed.
				local id = tonumber(string_match(target, "|Kq(%d+)"))
				if (id) and (C_BattleNet) then
					local bnetID = BNet_GetBNetIDAccount and BNet_GetBNetIDAccount(target)
					if (bnetID) then
						local accountInfo = C_BattleNet.GetAccountInfoByID(bnetID)
						if (accountInfo) then
							target = accountInfo.battleTag
						end
					else
						local accountInfo = C_BattleNet.GetFriendAccountInfo(id)
						if (accountInfo) then
							target = accountInfo.battleTag
						end
					end
					--print(BNet_GetBNetIDAccount(target), chatType, target:gsub("|", "||"), id)
					target = string_gsub(target, "(.+)#(%d+)", "%1|cff666666#|r|cff888888%2|r")
				else
					target = string_gsub(target, "(%a)([%w_']*)", capitalize)
				end
				label = "|cffad2424@|r"..target
			end
		elseif (chatType == "CHANNEL") then
			local channelTarget = self:GetAttribute("channelTarget")
			local localID, channelName, instanceID, isCommunitiesChannel = GetChannelName(channelTarget)
			if (channelName) and (channelName ~= "") then
				label = localID..":"..channelName
			else
				label = tostring(localID)
			end
		end

		self.Label:SetText(label or ChatLabels[chatType])
		self:SetTextColor(r, g, b, 1)
	end,

	-- Fix font and raise the box on show.
	OnPostShow = function(self)
		self:SetFont(self:GetFont(), math_round(BigInputBox.editBox.defaultHeight), "THINOUTLINE")
		self:UpdateChatType()
		self:SetFocus()
		self:Raise()
		self:SetAlpha(1)
	end,

	OnPostTextChanged = function(self)
		local msg = self:GetText()
		local parent = self:GetParent()

		-- The text in the input box will auto-wrap
		-- no matter what settings we give the fontstring,
		-- so we need a copy of it to get correct measurements.
		--
		-- *Update:
		-- The editbox object resizes, wraps and truncates
		-- beyond our control, so this solution doesn't actually work.
		-- We need to relate to the width of what blizzard decides to show us.
		--
		--if (not self.faker) then
		--	self.faker = parent:CreateFontString()
		--	self.faker:SetFontObject(NumberFont_Outline_Large)
		--	self.faker:SetFont(self.faker:GetFont(), self.defaultHeight, "THINOUTLINE")
		--	self.faker:SetWidth(self.defaultWidth)
		--end
		--self.faker:SetText(msg)

		-- I wanted to do this with multiline boxes,
		-- but there are just too many bugs and incompatibilities with them.
		-- A major problem is that multiline boxes don't support history.
		--
		--local fullWidth = self.faker:GetUnboundedStringWidth()
		local fullWidth = self.fontString:GetStringWidth()
		if (fullWidth > self.minWidth) then
			if (fullWidth < self.maxWidth) then
				local width = self.defaultWidth + fullWidth - self.minWidth
				self:SetSize(width, self.defaultHeight)
				parent:SetSize(parent.defaultWidth + (width - self.defaultWidth), parent.defaultHeight)
			else
				local width = self.defaultWidth + self.maxWidth - self.minWidth
				self:SetSize(width, self.defaultHeight)
				parent:SetSize(parent.defaultWidth + (width - self.defaultWidth), parent.defaultHeight)
			end
		else
			self:SetSize(self.defaultWidth, self.defaultHeight)
			parent:SetSize(parent.defaultWidth, parent.defaultHeight)
		end
	end

}

-- Callbacks
-----------------------------------------------------------
Private.AssignBindActions = function(self, overrideButton, ...)
	ClearOverrideBindings(overrideButton)
	for i = 1,select("#", ...) do
		local bindAction = select(i,...)
		for keyNumber = 1, select("#", GetBindingKey(bindAction)) do
			local key = select(keyNumber, GetBindingKey(bindAction))
			if (key and (key ~= "")) then
				SetOverrideBindingClick(overrideButton, true, key, overrideButton:GetName())
			end
		end
	end
end

-- Addon Core
-----------------------------------------------------------
-- Your event handler.
-- Any events you add should be handled here.
-- @input event <string> The name of the event that fired.
-- @input ... <misc> Any payloads passed by the event handlers.
Private.OnEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then

		-- Only ever call this once.
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		-- Embed a few extra metods in our inputbox.
		for method,func in pairs(InputBox) do
			BigInputBox.editBox[method] = func
		end

		-- Need to hook this, not replace, or we will break spell casts.
		-- The execution path leading to spellcasts needs to be unchanged.
		BigInputBox.editBox:HookScript("OnShow", InputBox.OnPostShow)
		--BigInputBox.editBox:HookScript("OnTextChanged", InputBox.OnPostTextChanged)
		BigInputBox.editBox:HookScript("OnCursorChanged", InputBox.OnPostTextChanged) -- more reliable

		-- Piggyback on the blizzard chat header updates
		-- to figure out what label and colors to use.
		hooksecurefunc("ChatEdit_UpdateHeader", function(editBox)
			if (editBox == BigInputBox.editBox) then
				BigInputBox.editBox:UpdateChatType()
			end
		end)

		-- Borrow all the chat input opening keybinds.
		--	"OPENCHAT"			-- The regular button to open chat.
		--	"REPLY"			 	-- Reply to whomever whispered you last.
		--	"REPLY2"			-- Re-whisper the same person you whispered last.
		--	"OPENCHATSLASH"		-- We can't do this from an addon without taint, so skipping it for now.
		self:AssignBindActions(BigInputBoxToggleButton, "OPENCHAT")
		self:AssignBindActions(BigInputBoxReplyButton, "REPLY")
		self:AssignBindActions(BigInputBoxRewhisperButton, "REPLY2")

	elseif (event == "UPDATE_BINDINGS") then
		-- This happens when players change bindings,
		-- or if the saved ones for some reason is loaded late.
		self:AssignBindActions(BigInputBoxToggleButton, "OPENCHAT")
		self:AssignBindActions(BigInputBoxReplyButton, "REPLY")
		self:AssignBindActions(BigInputBoxRewhisperButton, "REPLY2")
	end
end

-- Initialization.
-- This fires when the addon and its settings are loaded.
Private.OnInit = function(self)
end

-- Enabling.
-- This fires when most of the user interface has been loaded
-- and most data is available to the user.
Private.OnEnable = function(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_BINDINGS")
end


-- Setup the environment
-----------------------------------------------------------
(function(self)
	-- Private Default API
	-- This mostly contains methods we always want available
	-----------------------------------------------------------

	-- Addon version
	-- *Keyword substitution requires the packager,
	-- and does not affect direct GitHub repo pulls.
	local version = "@project-version@"
	if (version:find("project%-version")) then
		version = "Development"
	end

	-- WoW Client versions
	local patch, build, date, tocversion = GetBuildInfo()
	local major, minor, micro = string.split(".", patch)

	-- WoW 11.0.x
	local GetAddOnEnableState = GetAddOnEnableState or function(character, name) return C_AddOns.GetAddOnEnableState(name, character) end
	local GetAddOnInfo = GetAddOnInfo or C_AddOns.GetAddOnInfo
	local GetNumAddOns = GetNumAddOns or C_AddOns.GetNumAddOns

	-- Simple flags for client version checks
	Private.IsRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
	Private.IsClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
	Private.IsTBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
	Private.IsWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
	--Private.IsCata = WOW_PROJECT_ID == (WOW_PROJECT_CATA_CLASSIC or 99) -- NYI in first build
	Private.IsCata = (tocversion >= 40400) and (tocversion < 50000)
	Private.WoW10 = tocversion >= 100000

	Private.ClientVersion = tocversion
	Private.ClientDate = date
	Private.ClientPatch = patch
	Private.ClientMajor = tonumber(major)
	Private.ClientMinor = tonumber(minor)
	Private.ClientMicro = tonumber(micro)
	Private.ClientBuild = tonumber(build)

	-- Set a relative subpath to look for media files in.
	local Path
	Private.SetMediaPath = function(self, path)
		Path = path
	end

	-- Simple API calls to retrieve a media file.
	-- Will honor the relativ subpath set above, if defined,
	-- and will default to the addon folder itself if not.
	-- Note that we cannot check for file or folder existence
	-- from within the WoW API, so you must make sure this is correct.
	Private.GetMedia = function(self, name, type)
		if (Path) then
			return ([[Interface\AddOns\%s\%s\%s.%s]]):format(Addon, Path, name, type or "tga")
		else
			return ([[Interface\AddOns\%s\%s.%s]]):format(Addon, name, type or "tga")
		end
	end

	-- Parse chat input arguments
	local parse = function(msg)
		msg = string.gsub(msg, "^%s+", "") -- Remove spaces at the start.
		msg = string.gsub(msg, "%s+$", "") -- Remove spaces at the end.
		msg = string.gsub(msg, "%s+", " ") -- Replace all space characters with single spaces.
		if (string.find(msg, "%s")) then
			return string.split(" ", msg) -- If multiple arguments exist, split them into separate return values.
		else
			return msg
		end
	end

	-- This methods lets you register a chat command, and a callback function or private method name.
	-- Your callback will be called as callback(Private, editBox, commandName, ...) where (...) are all the input parameters.
	Private.RegisterChatCommand = function(_, command, callback)
		command = string.gsub(command, "^\\", "") -- Remove any backslash at the start.
		command = string.lower(command) -- Make it lowercase, keep it case-insensitive.
		local name = string.upper(Addon.."_CHATCOMMAND_"..command) -- Create a unique uppercase name for the command.
		_G["SLASH_"..name.."1"] = "/"..command -- Register the chat command, keeping it lowercase.
		SlashCmdList[name] = function(msg, editBox)
			local func = Private[callback] or Private.OnChatCommand or callback
			if (func) then
				func(Private, editBox, command, parse(string.lower(msg)))
			end
		end
	end

	Private.GetAddOnInfo = function(self, index)
		local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(index)
		local enabled = not(GetAddOnEnableState(UnitName("player"), index) == 0)
		return name, title, notes, enabled, loadable, reason, security
	end

	-- Check if an addon exists in the addon listing and loadable on demand
	Private.IsAddOnLoadable = function(self, target, ignoreLoD)
		local target = string.lower(target)
		for i = 1,GetNumAddOns() do
			local name, title, notes, enabled, loadable, reason, security = self:GetAddOnInfo(i)
			if string.lower(name) == target then
				if loadable or ignoreLoD then
					return true
				end
			end
		end
	end

	-- This method lets you check if an addon WILL be loaded regardless of whether or not it currently is.
	-- This is useful if you want to check if an addon interacting with yours is enabled.
	-- My philosophy is that it's best to avoid addon dependencies in the toc file,
	-- unless your addon is a plugin to another addon, that is.
	Private.IsAddOnEnabled = function(self, target)
		local target = string.lower(target)
		for i = 1,GetNumAddOns() do
			local name, title, notes, enabled, loadable, reason, security = self:GetAddOnInfo(i)
			if string.lower(name) == target then
				if enabled and loadable then
					return true
				end
			end
		end
	end

	-- Event API
	-----------------------------------------------------------
	-- Proxy event registering to the addon namespace.
	-- The 'self' within these should refer to our proxy frame,
	-- which has been passed to this environment method as the 'self'.
	Private.RegisterEvent = function(_, ...) self:RegisterEvent(...) end
	Private.RegisterUnitEvent = function(_, ...) self:RegisterUnitEvent(...) end
	Private.UnregisterEvent = function(_, ...) self:UnregisterEvent(...) end
	Private.UnregisterAllEvents = function(_, ...) self:UnregisterAllEvents(...) end
	Private.IsEventRegistered = function(_, ...) self:IsEventRegistered(...) end

	-- Event Dispatcher and Initialization Handler
	-----------------------------------------------------------
	-- Assign our event script handler,
	-- which runs our initialization methods,
	-- and dispatches event to the addon namespace.
	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			-- Nothing happens before this has fired for your addon.
			-- When it fires, we remove the event listener
			-- and call our initialization method.
			if ((...) == Addon) then
				-- Delete our initial registration of this event.
				-- Note that you are free to re-register it in any of the
				-- addon namespace methods.
				self:UnregisterEvent("ADDON_LOADED")
				-- Call the initialization method.
				if (Private.OnInit) then
					Private:OnInit()
				end
				-- If this was a load-on-demand addon,
				-- then we might be logged in already.
				-- If that is the case, directly run
				-- the enabling method.
				if (IsLoggedIn()) then
					if (Private.OnEnable) then
						Private:OnEnable()
					end
				else
					-- If this is a regular always-load addon,
					-- we're not yet logged in, and must listen for this.
					self:RegisterEvent("PLAYER_LOGIN")
				end
				-- Return. We do not wish to forward the loading event
				-- for our own addon to the namespace event handler.
				-- That is what the initialization method exists for.
				return
			end
		elseif (event == "PLAYER_LOGIN") then
			-- This event only ever fires once on a reload,
			-- and anything you wish done at this event,
			-- should be put in the namespace enable method.
			self:UnregisterEvent("PLAYER_LOGIN")
			-- Call the enabling method.
			if (Private.OnEnable) then
				Private:OnEnable()
			end
			-- Return. We do not wish to forward this
			-- to the namespace event handler.
			return
		end
		-- Forward other events than our two initialization events
		-- to the addon namespace's event handler.
		-- Note that you can always register more ADDON_LOADED
		-- if you wish to listen for other addons loading.
		if (Private.OnEvent) then
			Private:OnEvent(event, ...)
		end
	end)
end)((function() return CreateFrame("Frame", nil, WorldFrame) end)())
