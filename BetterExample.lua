repeat task.wait() until game:IsLoaded()

if getgenv().PE_LOADED then 
    getgenv().PE_LOADED:Unload()
end 

local framework = {
    services = {
        userinputservice = game:GetService('UserInputService'),
        players = game:GetService('Players'),
        runservice = game:GetService('RunService'),
        replicatedstorage = game:GetService('ReplicatedStorage'),
        workspace = game:GetService('Workspace'),
        lighting = game:GetService('Lighting'),
        tweenservice = game:GetService('TweenService'),
        soundservice = game:GetService('SoundService'),
        chat = game:GetService('Chat'),
        virtualuser = game:GetService('VirtualUser'),
        coregui = game:GetService('CoreGui')
    },
    data = {
        watermark = {
            frametimer = tick(),
            framecounter = 0,
            fps = 60
        },
    },
    library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Reload-astro/Pasted-Enhancements/refs/heads/main/Library.lua'))(),
    themes = loadstring(game:HttpGet('https://raw.githubusercontent.com/Reload-astro/Pasted-Enhancements/refs/heads/main/addons/ThemeManager.lua'))(),
    saves = loadstring(game:HttpGet('https://raw.githubusercontent.com/Reload-astro/Pasted-Enhancements/refs/heads/main/addons/SaveManager.lua'))(),
    modules = loadstring(game:HttpGet('https://raw.githubusercontent.com/Reload-astro/Pasted-Enhancements/refs/heads/main/addons/ModuleManager.lua'))(),
    connections = {},
    instances = {},
    drawings = {},
    flags = nil,
    window = nil,
    tabs = {},
    sections = {},
    menu = {},
    utility = {},
}

do -- // Utility \\
    framework['utility'].new_connection = function(type, callback)
        local connection = type:Connect(callback);
        table.insert(framework['connections'], connection);
        return connection;
    end

    framework['utility'].new_instance = function(instance, options)
        local ins = Instance.new(instance) 
        for prop, value in next, options do 
            ins[prop] = value
        end
        table.insert(framework['instances'], ins)
        return ins 
    end

    framework['utility'].new_drawing = function(drawing, options)
        local ins = Drawing.new(drawing) 
        for prop, value in next, options do 
            ins[prop] = value
        end
        table.insert(framework['drawings'], ins)
        return ins 
    end

    framework['utility'].validate = function(Player)
        return Player and Player.Character and Player.Character:FindFirstChild('HumanoidRootPart') and Player.Character:FindFirstChild('Head') and Player.Character:FindFirstChild('Humanoid') and true or false 
    end
end

do -- // Menu \\
    framework['window'] = framework['library']:CreateWindow({
        Title = 'Pasted Enhancements | Base',
        Center = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    framework['tabs'] = {
        --// base tabs, clean look so i keep. \\
        main = framework['window']:AddTab('main'),
        visuals = framework['window']:AddTab('visuals'),
        character = framework['window']:AddTab('character'),
        misc = framework['window']:AddTab('misc'),
        settings = framework['window']:AddTab('settings'),
    }

    framework['sections'] = {
        -- // example group \\
        example = framework['tabs'].main:AddLeftGroupbox('example'),
    }

    framework['menu'] = {
        -- // example menu \\
        framework['sections'].example:AddToggle('example_toggle', {
            Text = 'example toggle',
            Default = false,
            Tooltip = 'This is a example toggle, it changes the speed of your char when toggled.'
        })
    }
end

do -- // Main Functions \\
    framework['utility'].new_connection(framework['services'].runservice.RenderStepped,function()
        framework['data'].watermark.framecounter += 1;

        if (tick() - framework['data'].watermark.frametimer) >= 1 then
            framework['data'].watermark.fps = framework['data'].watermark.framecounter
            framework['data'].watermark.frametimer = tick()
            framework['data'].watermark.framecounter = 0
        end

        framework['library']:SetWatermark(('Pasted Enhancements | %s fps | %s ms'):format(
            math.floor(framework['data'].watermark.fps),
            math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
        ))
    end)
end

do -- // Initialization \\

end

do -- // Library Stuff \\
    framework['library']:OnUnload(function()
        for _, connection in ipairs(framework['connections']) do
            connection:Disconnect()
        end
        for _, instance in ipairs(framework['instances']) do
            instance:Destroy()
        end
        for _, drawing in ipairs(framework['drawings']) do
            drawing:Destroy()
        end
        framework['modules']:UnloadAllModules()
        table.clear(framework)
    end)

    --// prepear lua api to be loaded \\
    local api = {
        Tabs = framework['tabs'],
        Utility = framework['utility'],
        Unload = nil -- no touchy
    }

    framework['sections'].menu:AddLabel('Menu bind'):AddKeyPicker('Menu_Keybind', { Default = 'Rig', NoUI = true, Text = 'Menu keybind' })
    framework['sections'].menu:AddButton('Unload', function() framework['library']:Unload() end)
    framework['sections'].menu:AddToggle('Keybind_List', { Default = false, Text = 'Keybind List', Callback = function(Value) framework['library'].KeybindFrame.Visible = Value end})
    framework['sections'].menu:AddToggle('Watermark', { Default = false, Text = 'Watermark', Callback = function(Value) framework['library']:SetWatermarkVisibility(Value) end})
    framework['library'].ToggleKeybind = Options.MenuKeybind

    framework['themes']:SetLibrary(framework['library'])
    framework['themes']:SetFolder('Pasted Enhancements/Base')
    framework['themes']:ApplyToTab(framework['tabs'].settings)

    framework['saves']:SetLibrary(framework['library'])
    framework['saves']:IgnoreThemeSettings()
    framework['saves']:SetIgnoreIndexes({ 'MenuKeybind' })
    framework['saves']:SetFolder('Pasted Enhancements/Base')
    framework['saves']:BuildConfigSection(framework['tabs'].settings)
    framework['saves']:LoadAutoloadConfig()

    framework['modules']:SetAPI(api)
    framework['modules']:SetLibrary(framework['library'])
    framework['modules']:SetFolder('Pasted Enhancements/Base')
    framework['modules']:ApplyToTab(framework['tabs'].settings)

    getgenv().PE_LOADED = framework['library']
end