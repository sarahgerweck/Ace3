local AceGUI = LibStub("AceGUI-3.0")

---------------------
-- Common Elements --
---------------------

local FrameBackdrop = {
	bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
	tile = true, tileSize = 32, edgeSize = 32, 
	insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

local PaneBackdrop  = {

	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local ControlBackdrop  = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

local function Control_OnEnter(this)
	this.obj:Fire("OnEnter")
end

local function Control_OnLeave(this)
	this.obj:Fire("OnLeave")
end

-------------
-- Widgets --
-------------
--[[
	Widgets must provide the following functions
		Aquire() - Called when the object is aquired, should set everything to a default hidden state
		Release() - Called when the object is Released, should remove any anchors and hide the Widget
		
	And the following members
		frame - the frame or derivitive object that will be treated as the widget for size and anchoring purposes
		type - the type of the object, same as the name given to :RegisterWidget()
		
	Widgets contain a table called userdata, this is a safe place to store data associated with the wigdet
	It will be cleared automatically when a widget is released
	Placing values directly into a widget object should be avoided
	
	If the Widget can act as a container for other Widgets the following
		content - frame or derivitive that children will be anchored to
		
	The Widget can supply the following Optional Members


]]

----------------
-- Main Frame --
----------------
--[[
	Events :
		OnClose

]]
do
	local function frameOnClose(this)
		local self = this.obj
		self:Fire("OnClose")
	end
	
	local function frameOnSizeChanged(this)
		local self = this.obj
		local status = self.status or self.localstatus
		
		status.width = this:GetWidth()
		status.height = this:GetHeight()
		status.top = this:GetTop()
		status.left = this:GetLeft()
	end
	
	local function closeOnClick(this)
		this.obj:Hide()
	end
	
	local function frameOnMouseDown(this)
		this:GetParent():StartMoving()
	end
	
	local function frameOnMouseUp(this)
		local frame = this:GetParent()
		frame:StopMovingOrSizing()
		local self = frame.obj
		local status = self.status or self.localstatus
		status.width = frame:GetWidth()
		status.height = frame:GetHeight()
		status.top = frame:GetTop()
		status.left = frame:GetLeft()
	end
	
	local function sizerseOnMouseDown(this)
		this:GetParent():StartSizing("BOTTOMRIGHT")
	end
	
	local function sizersOnMouseDown(this)
		this:GetParent():StartSizing("BOTTOM")
	end
	
	local function sizereOnMouseDown(this)
		this:GetParent():StartSizing("RIGHT")
	end
	
	local function sizerOnMouseUp(this)
		this:GetParent():StopMovingOrSizing() 
	end

	local function SetTitle(self,title)
		self.titletext:SetText(title)
	end
	
	local function SetStatusText(self,text)
		self.statustext:SetText(text)
	end
	
	local function Hide(self)
		self.frame:Hide()
	end
	
	local function Show(self)
		self.frame:Show()
	end
	
	local function Aquire(self)
		self.frame:SetParent(UIParent)
		self:ApplyStatus()
	end
	
	local function Release(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end
	
	-- called to set an external table to store status in
	local function SetStatusTable(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end
	
	local function ApplyStatus(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		frame:SetWidth(status.width or 700)
		frame:SetHeight(status.height or 500)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end

	local function Constructor()
		local frame = CreateFrame("Frame",nil,UIParent)
		local self = {}
		self.type = "Frame"
		
		self.Hide = Hide
		self.Show = Show
		self.SetTitle =  SetTitle
		self.Release = Release
		self.Aquire = Aquire
		self.SetStatusText = SetStatusText
		self.SetStatusTable = SetStatusTable
		self.ApplyStatus = ApplyStatus
		
		self.localstatus = {}
		
		self.frame = frame
		frame.obj = self
		frame:SetWidth(700)
		frame:SetHeight(500)
		frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
		frame:EnableMouse()
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetFrameStrata("DIALOG")
		
		frame:SetBackdrop(FrameBackdrop)
		frame:SetBackdropColor(0,0,0,1)
		frame:SetScript("OnHide",frameOnClose)
		frame:SetMinResize(400,200)
		frame:SetScript("OnSizeChanged", frameOnSizeChanged)
		
		local closebutton = CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
		closebutton:SetScript("OnClick", closeOnClick)
		closebutton:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-27,17)
		closebutton:SetHeight(20)
		closebutton:SetWidth(100)
		closebutton:SetText("Close")
		
		self.closebutton = closebutton
		closebutton.obj = self
		
		local statusbg = CreateFrame("Frame",nil,frame)
		statusbg:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",15,15)
		statusbg:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-132,15)
		statusbg:SetHeight(24)
		statusbg:SetBackdrop(PaneBackdrop)
		statusbg:SetBackdropColor(0.1,0.1,0.1)
		statusbg:SetBackdropBorderColor(0.4,0.4,0.4)
		self.statusbg = statusbg
		
		local statustext = statusbg:CreateFontString(nil,"OVERLAY","GameFontNormal")
		self.statustext = statustext
		statustext:SetPoint("TOPLEFT",statusbg,"TOPLEFT",7,-2)
		statustext:SetPoint("BOTTOMRIGHT",statusbg,"BOTTOMRIGHT",-7,2)
		statustext:SetHeight(20)
		statustext:SetJustifyH("LEFT")
		statustext:SetText("")
		
		local title = CreateFrame("Frame",nil,frame)
		self.title = title
		title:EnableMouse()
		title:SetScript("OnMouseDown",frameOnMouseDown)
		title:SetScript("OnMouseUp", frameOnMouseUp)
		
		
		local titlebg = frame:CreateTexture(nil,"OVERLAY")
		titlebg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
		titlebg:SetTexCoord(0.31,0.67,0,0.63)
		titlebg:SetPoint("TOP",frame,"TOP",0,12)
		titlebg:SetWidth(100)
		titlebg:SetHeight(40)

		local titlebg_l = frame:CreateTexture(nil,"OVERLAY")
		titlebg_l:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
		titlebg_l:SetTexCoord(0.21,0.31,0,0.63)
		titlebg_l:SetPoint("RIGHT",titlebg,"LEFT",0,0)
		titlebg_l:SetWidth(30)
		titlebg_l:SetHeight(40)
		
		local titlebg_right = frame:CreateTexture(nil,"OVERLAY")
		titlebg_right:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
		titlebg_right:SetTexCoord(0.67,0.77,0,0.63)
		titlebg_right:SetPoint("LEFT",titlebg,"RIGHT",0,0)
		titlebg_right:SetWidth(30)
		titlebg_right:SetHeight(40)
		
		title:SetAllPoints(titlebg)			
		local titletext = title:CreateFontString(nil,"OVERLAY","GameFontNormal")
		titletext:SetPoint("TOP",titlebg,"TOP",0,-14)
	
		self.titletext = titletext	
		
		local sizer_se = CreateFrame("Frame",nil,frame)
		sizer_se:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,0)
		sizer_se:SetWidth(25)
		sizer_se:SetHeight(25)
		sizer_se:EnableMouse()
		sizer_se:SetScript("OnMouseDown",sizerseOnMouseDown)
		sizer_se:SetScript("OnMouseUp", sizerOnMouseUp)
		self.sizer_se = sizer_se

		local line1 = sizer_se:CreateTexture(nil, "BACKGROUND")
		self.line1 = line1
		line1:SetWidth(14)
		line1:SetHeight(14)
		line1:SetPoint("BOTTOMRIGHT", -8, 8)
		line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		local x = 0.1 * 14/17
		line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

		local line2 = sizer_se:CreateTexture(nil, "BACKGROUND")
		self.line2 = line2
		line2:SetWidth(8)
		line2:SetHeight(8)
		line2:SetPoint("BOTTOMRIGHT", -8, 8)
		line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		local x = 0.1 * 8/17
		line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

		local sizer_s = CreateFrame("Frame",nil,frame)
		sizer_s:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-25,0)
		sizer_s:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",0,0)
		sizer_s:SetHeight(25)
		sizer_s:EnableMouse()
		sizer_s:SetScript("OnMouseDown",sizersOnMouseDown)
		sizer_s:SetScript("OnMouseUp", sizerOnMouseUp)
		self.sizer_s = sizer_s
		
		local sizer_e = CreateFrame("Frame",nil,frame)
		sizer_e:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,25)
		sizer_e:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
		sizer_e:SetWidth(25)
		sizer_e:EnableMouse()
		sizer_e:SetScript("OnMouseDown",sizereOnMouseDown)
		sizer_e:SetScript("OnMouseUp", sizerOnMouseUp)
		self.sizer_e = sizer_e
	
	
		--Container Support
		local content = CreateFrame("Frame",nil,frame)
		self.content = content
		content.obj = self
		content:SetPoint("TOPLEFT",frame,"TOPLEFT",17,-27)
		content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-17,40)
		
		AceGUI:RegisterAsContainer(self)
		return self	
	end
	
	AceGUI:RegisterWidgetType("Frame",Constructor)
end
