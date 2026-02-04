Config = {}

------------------------------------------
-- [ Ddiretorios ]
------------------------------------------

Config.ImagensInventario = "http://localhost/itens"
Config.ImagensGaragem = "http://212.18.114.229/cancun/vehicles"
Config.ImagensSkins = "http://localhost/skins/"

------------------------------------------
-- [ Permissoes ]
------------------------------------------

Config.Perms = {
    OpenPainel = {"Admin",3},
    AddTeleport = {"Admin",3},
    AddAdv = {"Admin",3},
    AddKick = {"Admin",3},
    AddBan = {"Admin",3},

    AddItens = {"Admin",3},
    CatchVehicles = {"Admin",3},
    AddSkins = {"Admin",3},

    ManageChests = {"Admin",3},
    ManageGroups = {"Admin",3},
    ManageInventory = {"Admin",3},
    ManageVehicles = {"Admin",3},
    ManageMoney = {"Admin",3},
    ChangeNumber = {"Admin",3},
    ChangeName = {"Admin",3},

    Policia = "Police",
    Staff = "Admin",
    Bandits = {"Laranjas","Verdes"}
}

------------------------------------------
-- [ Logs ]
------------------------------------------

Config.Webhooks = {
    ScreenShots = "https://discord.com/api/webhooks/1412502746581565481/WBnfVicupV-aOUSyZodPv_RO1VlEyBZXllyXS1QtuxCicq4lQxqD0Br8o6d2ECTj2riA",
    FastActions = "https://discord.com/api/webhooks/1412502975154491493/Fn8apG2VtyOB96B_3s9R9-QFPJq5m0u8ea0lsJCNQt59ScC8bzEBdVT080a-Caf3XMGC"
}

------------------------------------------
-- [ Skins ]
------------------------------------------

Config.Skins = { -- 1100 x 900
    [1] = { Nome = "Default M", Spawn = "mp_m_freemode_01", Sex = "Default" },
    [2] = { Nome = "Liana", Spawn = "Liana_GamerGirlfriend" , Sex = "Default" },
    [3] = { Nome = "Cesar", Spawn = "pw_cesar" , Sex = "Default" },
}

return Config