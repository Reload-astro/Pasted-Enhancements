local ModuleManager = {} do
    ModuleManager.Folder = 'Linora/Modules'
    ModuleManager.API = nil
    ModuleManager.LoadedModules = {}

    function ModuleManager:BuildFolderTree()
        local parts = self.Folder:split('/')
        local paths = {}

        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, '/', 1, idx)
        end

        for _, path in ipairs(paths) do
            if not isfolder(path) then
                makefolder(path)
            end
        end
    end

    function ModuleManager:CreateModuleManager(groupbox)
        groupbox:AddInput('ModuleManager_CustomThemeName', { Text = 'script name' })
        groupbox:AddDropdown('ModuleManager_CustomThemeList', {
            Text = 'Scripts',
            Values = self:GetModules(),
            AllowNull = true,
            Default = 1
        })
        groupbox:AddDivider()

        groupbox:AddButton('load', function()
            local selected = Options.ModuleManager_CustomThemeList.Value
            if not selected then
                self.Library:Notify('[API] No script selected to load', 3)
                return
            end

            if self:LoadModule(selected, self.API) then
                self.Library:Notify('[API] Loaded module: ' .. selected)
            else
                self.Library:Notify('[API] Failed to load module: ' .. selected, 3)
            end
        end)
        :AddButton('unload', function()
            local selected = Options.ModuleManager_CustomThemeList.Value
            if not selected then
                self.Library:Notify('No script selected to unload', 3)
                return
            end

            if self:UnloadModule(selected, self.API) then
                self.Library:Notify('[API] Unloaded module: ' .. selected)
            else
                self.Library:Notify('[API] Failed to unload module: ' .. selected, 3)
            end
        end)

        groupbox:AddButton('Refresh', function()
            local newList = self:GetModules()
            Options.ModuleManager_CustomThemeList:SetValues(newList)
            Options.ModuleManager_CustomThemeList:SetValue(nil)
            self.Library:Notify('[API] Refreshed script list')
        end)
    end

    function ModuleManager:LoadModule(moduleName, api)
        local path = self.Folder .. '/' .. moduleName .. '.lua'
        if not isfile(path) then
            warn('[API] Module not found:', path)
            return false
        end

        if self.LoadedModules[moduleName] then
            warn('[API] Module already loaded:', moduleName)
            return true
        end

        local source = readfile(path)
        local chunk, err = loadstring(source)
        if not chunk then
            error('[API] Error loading module "' .. moduleName .. '": ' .. err, 2)
            return false
        end

        local success, result = pcall(chunk, api)
        if not success then
            error('[API] Runtime error in module "' .. moduleName .. '": ' .. result, 2)
            return false
        end

        print('[API] Loaded module:', moduleName)
        self.LoadedModules[moduleName] = true
        return true
    end

    function ModuleManager:UnloadModule(moduleName, api)
        if not self.LoadedModules[moduleName] then
            warn('[API] Module not loaded:', moduleName)
            return false
        end

        if typeof(api.Unload) == "function" then
            local success, err = pcall(api.Unload)
            if not success then
                warn('[API] Error during unload of module "' .. moduleName .. '":', err)
            end
        end

        self.LoadedModules[moduleName] = nil
        print('[API] Unloaded module:', moduleName)
        return true
    end

    function ModuleManager:ReloadModule(moduleName, api)
        self:UnloadModule(moduleName, api)
        return self:LoadModule(moduleName, api)
    end

    function ModuleManager:UnloadAllModules()
        for name, data in pairs(self.LoadedModules) do
            if data and type(data.api.Unload) == "function" then
                local success, err = pcall(data.api.Unload)
                if not success then
                    warn("[API] Error unloading module:", name, err)
                else
                    warn("[API] Unloaded module:", name)
                end
            else
                warn("[API] Module has no unload function or is nil:", name)
            end
        end

        table.clear(self.LoadedModules)
    end

    function ModuleManager:GetModules()
        local modules = {}
        if not isfolder(self.Folder) then
            warn('[API] Module folder not found:', self.Folder)
            return modules
        end

        for _, file in ipairs(listfiles(self.Folder)) do
            if file:sub(-4) == '.lua' then
                local name = file:match("([^\\/]+)%.lua$")
                if name then
                    table.insert(modules, name)
                end
            end
        end

        return modules
    end

	function ModuleManager:SetLibrary(lib)
		self.Library = lib
	end

	function ModuleManager:SetAPI(api)
		self.API = api
	end

    function ModuleManager:GetLoadedModules()
        return self.LoadedModules
    end

    function ModuleManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    ModuleManager:BuildFolderTree()
end

return ModuleManager
