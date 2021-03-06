----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

WarShield = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------


----------------------------------------------------------------
-- Functions
----------------------------------------------------------------

function WarShield.OnInitialize()
	WindowUtils.RestoreWindowPosition("WarShield")
	WindowSetShowing("WarShieldHandle", false)
end

function WarShield.Shutdown()
	WindowUtils.SaveWindowPosition("WarShield")
end

WarShield.ShieldHandle = false
function WarShield.ShieldOver()
	
	if not WarShield.ShieldHandle then
		WindowSetShowing("WarShieldHandle", true)
		WarShield.ShieldHandle = true
	end
end

function WarShield.ShieldOnLButtonDown()
	SnapUtils.StartWindowSnap(WindowUtils.GetActiveDialog())
end

function WarShield.ShieldOverend()
	WindowSetShowing("WarShieldHandle", false)
	WarShield.ShieldHandle = false
end
