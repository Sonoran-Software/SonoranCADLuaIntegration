--[[
    Sonoran Plugins

    frameworksupport Plugin Configuration

    Put all needed configuration in this file.

]] local config = {
    enabled = true,
    configVersion = "1.2",
    pluginName = "frameworksupport", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {}, -- required plugins for this plugin to work, separated by commas

    -- Newer ESX versions use license instead of steam for identity, specify the other below if different
    identityType = "license",
    -- Some ESX versions don't use the prefix (such as license:abcdef), set to false to disable the prefix
    usePrefix = true,
    -- If you are using QBCore set this to true
    usingQBCore = true,
    -- If using qb-management for LEO set this to true
    usingQBManagement = false,
    -- Setup the qb-management account names dependent on department issuing fine
    qbManagementAccountNames = {
        ['LSPD'] = 'police',
        ['SAHP'] = 'sahp'
        -- ['DEPARTMENT ABBREVIATION IN CAD   ADMIN>CUSTOMIZATION>DEPARTMENTS'] = 'qb-management_account_name'
    },
    qbNotifyFinedPlayer = true,
    -- Placeholders $AMOUNT and $OFFICER_NAME where $AMOUNT is the fine total and $OFFICER_NAME is the Unit Name of the officer issuing the fine
    qbFineMessage = "You have been fined $$AMOUNT by $OFFICER_NAME",

    -- Fine payment system
    issueFines = true, -- Use the fine system
    fineNotify = false, -- Send a message in chat when someone is fined.
    fineableForms = {"Arrest Report", "General Citation"}, -- List of form names that should issue fines (Don't Include Warrants or Bolos)

    -- ESX Legacy Support (Created for and tested using ESX v1.1.0 esx_identity v1.0.2)
    legacyESX = false -- Set to true if default settings do not get character name properly (older esx_identity/ESX legacy versions)
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end
