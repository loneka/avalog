local Avalog = script.Parent.Parent.Parent
local AvatarManager = require(Avalog.SourceCode.Client.Avatar.AvatarManager)

export type AvatarManager = AvatarManager.AvatarManager

--[=[
    Provides some service. Must call `Setup` to setup services before getting any.
    This is how the plugin swaps its implementations.
]=]
local ServiceProvider = {
    _AvatarManager = nil :: AvatarManager.AvatarManager?,
}

export type SetupOptions = {
    AvatarManager: AvatarManager.AvatarManager,
}
function ServiceProvider:Setup(Options: SetupOptions)
    self._AvatarManager = Options.AvatarManager
end

function ServiceProvider:GetAvatarManager()
    assert(self._AvatarManager, "Missing AvatarManager. Forgot to call Setup?")
    return self._AvatarManager
end

return ServiceProvider