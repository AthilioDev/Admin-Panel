local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")

athdev = {}
Tunnel.bindInterface("athdev_staffpainel",athdev)
vCLIENT = Tunnel.getInterface("athdev_staffpainel")

vRP.Prepare("athdevLiterally/jesterInstagram", "SELECT * FROM smartphone_instagram WHERE user_id = @user_id")
vRP.Prepare("literallyme/infosTeleports", "SELECT * FROM athdev_teleportes WHERE user_id = @user_id") 
vRP.Prepare("literallyme/insertTeleports", "INSERT INTO athdev_teleportes(user_id,id,nome,coords) VALUES(@user_id,@id,@nome,@coords)") 
vRP.Prepare("literallyme/deleteTeleport","DELETE FROM athdev_teleportes WHERE id = @id")

vRP.Prepare("literallyme/infosPunicoes", "SELECT * FROM athdev_punicoes")
vRP.Prepare("literallyme/selectPunicao", "SELECT * FROM athdev_punicoes WHERE user_id = @user_id")
vRP.Prepare("literallyme/insertPunicao", "INSERT INTO athdev_punicoes(user_id,staffid,motivo,status,contagem,data) VALUES(@user_id,@staffid,@motivo,@status,@contagem,@data)")
vRP.Prepare("literallyme/deletePunicao","DELETE FROM athdev_punicoes WHERE user_id = @user_id AND status = @status AND contagem = @contagem")

Citizen.CreateThread(function()
    vRP.Prepare("literallyme/athdev_teleportes", [[
        CREATE TABLE IF NOT EXISTS athdev_teleportes(
            user_id INTEGER,
            id longtext,
            nome longtext,
            coords longtext
        )
    ]])
    
    vRP.Prepare("literallyme/athdev_punicoes", [[
        CREATE TABLE IF NOT EXISTS athdev_punicoes(
            user_id INTEGER,
            staffid longtext,
            motivo longtext,
            status longtext,
            contagem longtext,
            data longtext
        )
    ]])

    vRP.Query("literallyme/athdev_teleportes")
    vRP.Query("literallyme/athdev_punicoes")
end)

local PainelLogs = {}
local FreezePlayer = {}

-- Parte de permissão e return dos dados principais
-- Parte de permissão e return dos dados principais
-- Parte de permissão e return dos dados principais
function athdev.CheckPermission()
    local Source = source
    local Passport = vRP.Passport(Source)

    return vRP.HasPermission(Passport, Config["Perms"]["OpenPainel"][1],Config["Perms"]["OpenPainel"][2])
end

function athdev.ReturnNames()
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    if Passport then
        local Infos = vRP.Query("athdevLiterally/jesterInstagram", {user_id = Passport})
        if Infos[1] then
            return Identity["name"],Identity["name2"],Infos[1]["avatarURL"]
        else
            return Identity["name"],Identity["name2"],"./images/profile.png"
        end
    end
end

function athdev.ReturnServices()
    local Source = source
    local Passport = vRP.Passport(Source)

    local Players = 0
    local Police = 0
    local Ilegal = 0
    local Staff = 0

    Players = GetNumPlayerIndices()
    _,Police = vRP.NumPermission(Config["Perms"]["Policia"])
    _,Staff = vRP.NumPermission(Config["Perms"]["Staff"])

    for index,PermissionName in pairs(Config["Perms"]["Bandits"]) do
        local IService, Iamount = vRP.NumPermission(PermissionName)
        Ilegal = Ilegal + Iamount
    end

    return Players,Police,Ilegal,Staff
end




-- Parte dos teleportes
-- Parte dos teleportes
-- Parte dos teleportes
function athdev.ConsultCoordsList()
    local Source = source
    local Passport = vRP.Passport(Source)
    teleportTables = {}

    if Passport then
        local SelectQuery = vRP.Query("literallyme/infosTeleports", {user_id = Passport})
        if SelectQuery[1] then
            for k,v in pairs(SelectQuery) do
                table.insert(teleportTables,{id = v["id"],nome = v["nome"], coord = json.decode(v["coords"]) })
            end
        end
    end

    return teleportTables
end

function athdev.AddTeleport(ReturnName)
    local Source = source
    local Passport = vRP.Passport(Source)
    if Passport then
        if vRP.HasPermission(Passport,Config["Perms"]["AddTeleport"][1],Config["Perms"]["AddTeleport"][2]) then
            if ReturnName ~= "" then 
                local PlayerPed = GetPlayerPed(Source)
                local CoordsPlayer = GetEntityCoords(PlayerPed)
                local RandomIdentification = math.random(1,99999)

                local Identity = vRP.Identity(Passport)
                if Identity then
                    table.insert(PainelLogs,{ user_id = Passport, cor = "azul",nome = Identity["name"].." "..Identity["name2"],motivo = "Adicionou um novo teleport, nome do teleport: "..ReturnName.."." })
                end

                vRP.Query("literallyme/insertTeleports", { user_id = Passport, id = RandomIdentification, nome = ReturnName, coords = json.encode(CoordsPlayer)})
                return true
            else
                TriggerClientEvent("Notify",Source,"vermelho","Voce precisa inserir um Nome.",10000)
            end
        else
            TriggerClientEvent("Notify",Source,"vermelho","Voce nao tem Permissão.",10000)
        end
    end
end

function athdev.DeleteTeleport(ReturnIdentification,ReturnName)
    local Source = source
    local Passport = vRP.Passport(Source)

    if Passport and vRP.HasPermission(Passport,Config["Perms"]["AddTeleport"][1],Config["Perms"]["AddTeleport"][2]) then
        local Identity = vRP.Identity(Passport)
        if Identity then
            table.insert(PainelLogs,{ user_id = Passport, cor = "vermelho",nome = Identity["name"].." "..Identity["name2"],motivo = "Deletou um teleport, nome do teleport: "..ReturnName.."." })
        end

        vRP.Query("literallyme/deleteTeleport", { id = ReturnIdentification })
        return true
    end

    return false
end




-- Parte dos logs
-- Parte dos logs
-- Parte dos logs
function athdev.ReturnLogsList()
    local Source = source
    local Passport = vRP.Passport(Source)
    local ReturnLogsList = {}

    if Passport then
        for k,v in ipairs(PainelLogs) do
            local ColorLog = "#ff0000"
            if v["cor"] == "vermelho" then
                ColorLog = "#ff0000"
            elseif v["cor"] == "azul" then
                ColorLog = "#00a2ff"
            elseif v["cor"] == "amarelo" then
                ColorLog = "#ffc400"
            end

            table.insert(ReturnLogsList,{ cor = ColorLog,img = "./images/warning.png",nome = v["nome"],user_id = v["user_id"],motivo = v["motivo"] })
        end
    end

    return ReturnLogsList
end




-- Parte das consultas do player
-- Parte das consultas do player
-- Parte das consultas do player
function athdev.ReturnPlayerList()
    local Source = source
    local Passport= vRP.Passport(Source)
    local ControleTables = {}

    local Players = vRP.Players()
    if Passport then
        for SelectedPassport,Ignore in pairs(Players) do
            local Identity = vRP.Identity(SelectedPassport)
            local Infos = vRP.Query("athdevLiterally/jesterInstagram", {user_id = SelectedPassport})
            if Infos[1] then
                table.insert(ControleTables,{user_id = SelectedPassport, nome = Identity["name"].." ".. Identity["name2"], foto = Infos[1]["avatarURL"] })
            else
                table.insert(ControleTables,{user_id = SelectedPassport, nome = Identity["name"].." ".. Identity["name2"], foto = "./images/profile.png" })
            end
        end
    end

    return ControleTables
end

function athdev.SeeInformationsProfile(SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    local SelectedPassport = parseInt(SelectedPassport)
    local SourcePed = vRP.Source(SelectedPassport)

    if SourcePed then
        local BankMoney = vRP.GetBank(SourcePed)
        local WalletMoney = vRP.ItemAmount(SelectedPassport, "dollars")
        local Identity = vRP.Identity(SelectedPassport)
        local License = vRP.Identities(SourcePed)
        local SelectedWork = vRP.GetUserType(SelectedPassport, "Work")
        local VipStatus = vRP.LicensePremium(License)
        local VipCoins = vRP.UserGemstone(License)
        local BannerImage = "https://i.pinimg.com/originals/1a/9a/20/1a9a20cc06e7084d35a34f89ce756ad6.gif"

        local Infos = vRP.Query("athdevLiterally/jesterInstagram", {user_id = SelectedPassport})
        if Infos[1] then
            return parseFormat(WalletMoney),parseFormat(BankMoney),Identity["name"],Identity["name2"],Identity["steam"],Identity["phone"],Sanguine(Identity["blood"]),SelectedWork,VipStatus,parseFormat(VipCoins),Infos[1]["avatarURL"],BannerImage
        else
            return parseFormat(WalletMoney),parseFormat(BankMoney),Identity["name"],Identity["name2"],Identity["steam"],Identity["phone"],Sanguine(Identity["blood"]),SelectedWork,VipStatus,parseFormat(VipCoins),"./images/profile.png",BannerImage
        end
    end
end




-- Parte das punições
-- Parte das punições
-- Parte das punições
function athdev.SeeInformationsWarnings()
	local Source = source
	local Passport = vRP.Passport(Source)
    local PunicoesList = {}

	if Passport then
        local SelectAll = vRP.Query("literallyme/infosPunicoes", {})
        if SelectAll then
            for k,v in pairs(SelectAll) do
                local SelectedPassport = parseInt(v["user_id"])
                local StaffPassport = parseInt(v["staffid"])
                local Identity = vRP.Identity(SelectedPassport)
                local Identity2 = vRP.Identity(StaffPassport)
                local Identity3 = vRP.Identity(Passport)
                local Infos = vRP.Query("athdevLiterally/jesterInstagram", {user_id = SelectedPassport})
                local ImageUrl = "./images/profile.png"
                if Infos[1] then ImageUrl = Infos[1]["avatarURL"] end

                local SelectedColor = "#fff"
                local SelectedBackground = "#fff"
                if string["find"](v["status"],"ADVERTÊNCIA") then SelectedBackground = "rgb(255, 102, 0)" SelectedColor = "#fff" end
                if string["find"](v["status"],"BANIDO") then SelectedBackground = "rgb(255, 0, 0)" SelectedColor = "#fff" end

                if Identity and Identity2 then
                    table.insert(PunicoesList,{
                        user_id = SelectedPassport,
                        myname = Identity3["name"].." "..Identity3["name2"],
                        nome = Identity["name"].." "..Identity["name2"],
                        status = v["status"],
                        contagem = v["contagem"],

                        color = SelectedColor,
                        background = SelectedBackground,

                        motivo = v["motivo"],
                        staff = Identity2["name"].." "..Identity2["name2"].." ["..StaffPassport.."]",
                        foto = ImageUrl, 
                        data = v["data"]
                    })
                end
            end
        end
	end

    return PunicoesList
end

function athdev.DeleteAdv(SelectedPassport, SelectedStatus, SelectedContagem)
    local Source = source
    local Passport = vRP.Passport(Source)

    if Passport then
        if vRP.HasPermission(Passport,Config["Perms"]["AddAdv"][1],Config["Perms"]["AddAdv"][2]) then
            vRP.Query("literallyme/deletePunicao", {user_id = SelectedPassport, status = SelectedStatus, contagem = SelectedContagem})

            local Identity = vRP.Identity(SelectedPassport)
            local Punicoes = vRP.Query("literallyme/selectPunicao", {user_id = SelectedPassport})
            if #Punicoes <= 0 and Identity then
                vRP.Query("banneds/RemoveBanned",{ license = Identity["license"] })
            end
            if SelectedStatus == "BANIDO" then
                vRP.Query("banneds/RemoveBanned",{ license = Identity["license"] })
            end

            local IdentityLog = vRP.Identity(Passport)
            if IdentityLog then
                table.insert(PainelLogs, { user_id = Passport, cor = "vermelho", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Deletou uma advertência, no id ["..SelectedPassport.."] com status ["..SelectedStatus.." "..SelectedContagem.."]." })
            end

            return true
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Voce não tem Permissao.", 10000)
        end
    end

    return false
end

function athdev.AddKick(SelectedMotivo, SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    if Passport then
        if vRP.HasPermission(Passport,Config["Perms"]["AddKick"][1],Config["Perms"]["AddKick"][2]) then
            local SelectedSource = vRP.Source(SelectedPassport)
            if SelectedSource then
                local IdentityLog = vRP.Identity(Passport)
                local IdentityAffected = vRP.Identity(SelectedPassport)
                if IdentityLog and IdentityAffected then
                    table.insert(PainelLogs, { user_id = Passport, cor = "amarelo", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Aplicou um kick no id ["..SelectedPassport.."]." })

                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Aplicou um kick**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 No passporte:", 
                                        value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                vRP.Kick(SelectedSource,SelectedMotivo)
                return true
            end
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Voce não tem Permissao.", 10000)
        end
    end

    return false
end

function athdev.AddBan(SelectedMotivo, SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)

    if Passport then
        if vRP.HasPermission(Passport,Config["Perms"]["AddBan"][1],Config["Perms"]["AddBan"][2]) then
            local Identity = vRP.Identity(SelectedPassport)
            if Identity then
                vRP.Query("banneds/InsertBanned",{ license = Identity["license"], time = 99999999 })
                vRP.Query("literallyme/insertPunicao", {user_id = SelectedPassport, staffid = Passport, motivo = SelectedMotivo, status = "BANIDO", contagem = "PERMANENTE", data = os.date("%d/%m/%Y")})
                TriggerClientEvent("Notify",Source,"verde","Você baniu o player com sucesso!",10000)

                local SelectedSource = vRP.Source(SelectedPassport)
                if SelectedSource then
                    vRP.Kick(SelectedSource,"Você foi banido! Motivo: "..SelectedMotivo)
                end

                local IdentityLog = vRP.Identity(Passport)
                local IdentityAffected = vRP.Identity(SelectedPassport)
                if IdentityLog and IdentityAffected then
                    table.insert(PainelLogs, { user_id = Passport, cor = "vermelho", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Aplicou um ban no id ["..SelectedPassport.."] motivo ["..SelectedMotivo.."]" })

                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Aplicou um ban, motivo: "..SelectedMotivo.."**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 No passporte:", 
                                        value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                return true
            end
        else
            TriggerClientEvent("Notify",Source,"vermelho","Voce não tem Permissao.",10000)
        end
    end

    return false
end

function athdev.AddWarning(SelectedMotivo, SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    if Passport then
        if vRP.HasPermission(Passport,Config["Perms"]["AddAdv"][1],Config["Perms"]["AddAdv"][2]) then
            local Identity = vRP.Identity(SelectedPassport)
            if Identity then
                local Punicoes = vRP.Query("literallyme/selectPunicao", {user_id = SelectedPassport})
                if #Punicoes <= 2 then
                    local StatusADV = "ADVERTÊNCIA"
                    local ContagemADV = 1

                    if #Punicoes == 2 then
                        StatusADV = "BANIDO"
                        ContagemADV = "PERMANENTE"
                    else
                        StatusADV = "ADVERTÊNCIA"
                        if #Punicoes > 0 then ContagemADV = #Punicoes + 1 end
                    end

                    if StatusADV == "BANIDO" then
                        vRP.Query("literallyme/insertPunicao", {user_id = SelectedPassport,staffid = Passport,motivo = SelectedMotivo,status = "ADVERTÊNCIA",contagem = "3",data = os.date("%d/%m/%Y")})
                        vRP.Query("literallyme/insertPunicao", {user_id = SelectedPassport,staffid = Passport,motivo = SelectedMotivo,status = StatusADV,contagem = ContagemADV,data = os.date("%d/%m/%Y")})
                        vRP.Query("banneds/InsertBanned",{ license = Identity["license"], time = 99999999 })
                        TriggerClientEvent("Notify",Source,"verde","Você baniu o player com sucesso!",10000)

                        local SelectedSource = vRP.Source(SelectedPassport)
                        if SelectedSource then
                            vRP.Kick(SelectedSource,"Você foi banido! Motivo: "..SelectedMotivo)
                        end
                    else
                        vRP.Query("literallyme/insertPunicao", {user_id = SelectedPassport,staffid = Passport,motivo = SelectedMotivo,status = StatusADV,contagem = ContagemADV,data = os.date("%d/%m/%Y")})
                        TriggerClientEvent("Notify",Source,"verde","Você adverteu o player com sucesso!",10000)
                    end

                    local IdentityLog = vRP.Identity(Passport)
                    local IdentityAffected = vRP.Identity(SelectedPassport)
                    if IdentityLog and IdentityAffected then
                        table.insert(PainelLogs, { user_id = Passport, cor = "amarelo", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Aplicou uma advertência no id ["..SelectedPassport.."] motivo ["..SelectedMotivo.."]." })

                        PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                            embeds = {
                                {     
                                    title = "**Aplicou uma advertência, Status: "..SelectedMotivo.."**",
                                    fields = {
                                        { 
                                            name = "📝 Author:", 
                                            value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                        },
                                        { 
                                            name = "📝 No passporte:", 
                                            value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                        },
                                    }, 
                                    footer = { 
                                        text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                        icon_url = "./images/profile.png"
                                    },
                                    thumbnail = { 
                                        url = "./images/profile.png"
                                    },
                                    color = 3092790
                                }
                            }
                        }), { ["Content-Type"] = "application/json" })
                    end
                end

                return true
            end
        else
            TriggerClientEvent("Notify",Source,"vermelho","Voce não tem Permissao.",10000)
        end
    end

    return false
end




-- Parte dos get dos itens
-- Parte dos get dos itens
-- Parte dos get dos itens
function athdev.SeeInformationsItemList()
	local Source = source
	local Passport = vRP.Passport(Source)
    local ItemList = {}

	if Passport then
        for Item,ItemTable in pairs(itemlist()) do
            table.insert(ItemList,{
                item = Item,
                name = ItemTable["Name"],
                index = itemIndex(Item),
                linkinventario = Config["ImagensInventario"]
            })
        end
	end

    return ItemList
end

function athdev.CatchItem(ItemCatch,ItemAmount)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)

    if Passport then
        if vRP.HasPermission(Passport, Config["Perms"]["AddItens"][1],Config["Perms"]["AddItens"][2]) then
            vRP.GenerateItem(Passport, ItemCatch, ItemAmount, true)

            TriggerClientEvent("Notify", Source, "verde", "Você Pegou "..ItemAmount.."x "..itemName(ItemCatch)..".", 10000)

            local IdentityLog = vRP.Identity(Passport)
            if IdentityLog then
                table.insert(PainelLogs, { user_id = Passport, cor = "azul", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Pegou um item ["..ItemCatch.."] "..ItemAmount.."x." })

                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Spawn de Item**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📦 Item:", 
                                    value = "" ..ItemAmount.."x "..itemName(ItemCatch).." ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            end

            return true
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem Permissao", 10000)
        end
    end
end




-- Parte dos veículos
-- Parte dos veículos
-- Parte dos veículos
function athdev.SeeInformationsAllVeiculos()
	local Source = source
	local Passport = vRP.Passport(Source)
    local GaragemList = {}

	if Passport then
        for NameVehicle,Ignorar in pairs(VehicleGlobal()) do
            table.insert(GaragemList,{ 	
                carro = NameVehicle,
                name = VehicleName(NameVehicle), 
                linkgaragem = Config["ImagensGaragem"]
            })
        end
	end

    return GaragemList
end

function athdev.GiveVehicle(NameVehicle,SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)

    if SelectedPassport then
        local Identity2 = vRP.Identity(SelectedPassport)

        if vRP.HasPermission(Passport, Config["Perms"]["CatchVehicles"][1],Config["Perms"]["CatchVehicles"][2]) then
            vRP.Query("vehicles/addVehicles",{ Passport = SelectedPassport, vehicle = NameVehicle, plate = vRP.GeneratePlate(), work = "false" })

            TriggerClientEvent("Notify", Source, "verde", "Voce setou o "..VehicleName(NameVehicle).." no passaporte: "..Identity2["name"].." "..Identity2["name2"].." ["..SelectedPassport.."].", 10000)

            local IdentityLog = vRP.Identity(Passport)
            local IdentityAffected = vRP.Identity(SelectedPassport)
            if IdentityLog and IdentityAffected then
                table.insert(PainelLogs, { user_id = Passport, cor = "azul", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Gerou um veiculo no id ["..SelectedPassport.."] veiculo ["..NameVehicle.."]." })

                local x, y, z = vCLIENT.GetPosition(Source)
                PerformHttpRequest(Config.Webhooks.seeGaragem, function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Setou Carro**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Player:", 
                                    value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                },
    
                                { 
                                    name = "🚗 Carro:", 
                                    value = "" ..VehicleName(NameVehicle).." ",
                                },
    
                                { 
                                    name = "🌐 Coordenada do Staff:", 
                                        value = ""..x..","..y..","..z.." \n \n " 
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            end

            return true
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem permissão!", 10000)
        end
    else
        TriggerClientEvent("Notify", Source, "vermelho", "Você precisa colocar um Passaporte!", 10000)
    end
end



-- Parte das opções rápidas
-- Parte das opções rápidas
-- Parte das opções rápidas
local Spectate = {}

function athdev.FastActionsToogle(SelectedPassport,tipo)
    local Source = source
    local Passport = vRP.Passport(Source)
    local SelectedPassport = parseInt(SelectedPassport)
    local SelectedSourcePed = vRP.Source(SelectedPassport)

    if Passport then
        if SelectedSourcePed then
            local Identity2 = vRP.Identity(SelectedPassport)
            local x, y, z = vCLIENT.GetPosition(Source)
            if tipo == "reviver" then
				vRP.Revive(SelectedSourcePed,200)
				vRP.UpgradeThirst(SelectedPassport,100)
				vRP.UpgradeHunger(SelectedPassport,100)
				vRP.DowngradeStress(SelectedPassport,100)
                TriggerClientEvent("Notify", Source, "verde", "Voce reviveu o "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    local IdentityTarget = vRP.Identity(SelectedPassport)
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "azul",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Reviveu o jogador ["..SelectedPassport.."] "..(IdentityTarget and IdentityTarget["name"].." "..IdentityTarget["name2"] or "").."."
                    })
                end

                local Identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Reviveu**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
           

            elseif tipo == "matar" then
                vRPC.SetHealth(SelectedSourcePed, 0)
                TriggerClientEvent("Notify", Source, "verde", "Voce matou o "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    local IdentityTarget = vRP.Identity(SelectedPassport)
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "vermelho",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Matou o jogador ["..SelectedPassport.."] "..(IdentityTarget and IdentityTarget["name"].." "..IdentityTarget["name2"] or "").."."
                    })
                end

                local identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Matou**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..identity["name"].." "..identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })

            elseif tipo == "colete" then
                vRP.SetArmour(SelectedSourcePed, 100)
                TriggerClientEvent("Notify", Source, "verde", "Colete Setado no "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "azul",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Deu um colete para o passaporte ["..SelectedPassport.."]."
                    })
                end

                local identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Deu Colete**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..identity["name"].." "..identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })

            elseif tipo == "tpto" then
                local SelectedSourcePlayerPed = GetPlayerPed(SelectedSourcePed)
				local Coords = GetEntityCoords(SelectedSourcePlayerPed)

				vRP.Teleport(Source, Coords["x"],Coords["y"],Coords["z"])
                TriggerClientEvent("Notify", Source,"verde","Voce foi ate o "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "azul",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Teleportou até o passaporte ["..SelectedPassport.."]."
                    })
                end

                local Identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Tpto**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })

            elseif tipo == "tptome" then
                local MyPed = GetPlayerPed(Source)
				local Coords = GetEntityCoords(MyPed)

				vRP.Teleport(SelectedSourcePed,Coords["x"],Coords["y"],Coords["z"])	
                TriggerClientEvent("Notify", Source, "verde", "Voce puxou o "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "azul",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Trouxe o passaporte no tptome ["..SelectedPassport.."] até si mesmo."
                    })
                end

                local Identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Trouxe um player até ele**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })

            elseif tipo == "fix" then
                local Vehicle,VehNet,VehPlate = vRPC.VehicleList(SelectedSourcePed, 10)
                if Vehicle then
                    local ClosestPeds = vRPC.ClosestPeds(SelectedSourcePed)
                    for _,NearPed in ipairs(ClosestPeds) do
                        async(function()
                            TriggerClientEvent("inventory:repairAdmin", NearPed, VehNet, VehPlate)
                        end)
                    end

                    TriggerClientEvent("Notify", Source, "verde", "Voce deu fix no carro do "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                    local IdentityLog = vRP.Identity(Passport)
                    if IdentityLog then
                        table.insert(PainelLogs, {
                            user_id = Passport,
                            cor = "azul",
                            nome = IdentityLog["name"].." "..IdentityLog["name2"],
                            motivo = "Reparou o veículo do passaporte ["..SelectedPassport.."]."
                        })
                    end

                    local Identity = vRP.Identity(Passport)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Reparou o veiculo do jogador**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                else
                    TriggerClientEvent("Notify", Source, "vermelho", "O "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."] não está perto de um veiculo.", 7000)
                end
            elseif tipo == "reset" then
                if vRP.Request(Source, "Você deseja resetar o passaporte: "..SelectedPassport.." ?", "Sim", "Não") then
                    NationCreato = Tunnel.getInterface("nation_creator")
                    NationCreato.startCreator(SelectedSourcePed)
                    TriggerClientEvent("Notify", Source, "verde","Voce resetou o personagem "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].")
                end
            elseif tipo == "algema" then
                if Player(SelectedSourcePed)["state"]["Handcuff"] then
					Player(SelectedSourcePed)["state"]["Handcuff"] = false
					Player(SelectedSourcePed)["state"]["Commands"] = false
                    ClearPedTasksImmediately(SelectedSourcePed)
                    vRPC.Destroy(SelectedSourcePed)

                    TriggerClientEvent("sounds:source", Source, "uncuff", 0.5)
                    TriggerClientEvent("sounds:source", SelectedSourcePed, "uncuff", 0.5)
                    TriggerClientEvent("Notify", Source, "verde", "Voce desalgemou o "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                    local IdentityLog = vRP.Identity(Passport)
                    if IdentityLog then
                        table.insert(PainelLogs, {
                            user_id = Passport,
                            cor = "azul",
                            nome = IdentityLog["name"].." "..IdentityLog["name2"],
                            motivo = "Desalgemou o passaporte ["..SelectedPassport.."]."
                        })
                    end

                    local identity = vRP.Identity(Passport)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Desalgemou**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..identity.name.." "..identity.name2.." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                else
					Player(SelectedSourcePed)["state"]["Handcuff"] = true
					Player(SelectedSourcePed)["state"]["Commands"] = true
                    ClearPedTasksImmediately(SelectedSourcePed)
                    vRPC.Destroy(SelectedSourcePed)
                    TriggerClientEvent("inventory:Close", SelectedSourcePed)

                    TriggerClientEvent("sounds:source", Source, "cuff", 0.5)
                    TriggerClientEvent("sounds:source", SelectedSourcePed, "cuff", 0.5)
                    TriggerClientEvent("Notify", Source, "verde", "Voce algemou o "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                    local IdentityLog = vRP.Identity(Passport)
                    if IdentityLog then
                        table.insert(PainelLogs, {
                            user_id = Passport,
                            cor = "amarelo",
                            nome = IdentityLog["name"].." "..IdentityLog["name2"],
                            motivo = "Algemou o passaporte ["..SelectedPassport.."]."
                        })
                    end

                    local Identity = vRP.Identity(Passport)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Algemou**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end
            elseif tipo == "ragdoll" then
                TriggerClientEvent("TackleAdmin:Start", SelectedSourcePed)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "amarelo",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Derrubou o passaporte ["..SelectedPassport.."]."
                    })
                end

                local Identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Derrubou**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            elseif tipo == "fogo" then
                TriggerClientEvent("StartEntity:Fire",SelectedSourcePed)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "amarelo",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Tacou fogo no passaporte ["..SelectedPassport.."]."
                    })
                end

                local Identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Tacou Fogo**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })

            elseif tipo == "fome" then
                vRP.DowngradeThirst(SelectedPassport, 50)
				vRP.DowngradeHunger(SelectedPassport, 50)
				vRP.DowngradeStress(SelectedPassport, 50)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "vermelho",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Alterou a fome/sede do passaporte ["..SelectedPassport.."]."
                    })
                end

                local Identity = vRP.Identity(Passport)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Fome / Sede**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })

            elseif tipo == "spec" then
                if Spectate[Passport] then
                    local Ped = GetPlayerPed(Spectate[Passport])
                    if DoesEntityExist(Ped) then
                        SetEntityDistanceCullingRadius(Ped, 0.0)
                    end

                    TriggerClientEvent("ResetSpect:Admin", Source)
                    Spectate[Passport] = nil
                else
                    local SelectedSource = vRP.Source(SelectedPassport)
                    if SelectedSource then
                        local Ped = GetPlayerPed(SelectedSource)

                        if DoesEntityExist(Ped) then
                            SetEntityDistanceCullingRadius(Ped, 999999999.0)
                            Wait(1000)
                            TriggerClientEvent("InitSpectate:Admin", Source, SelectedSource)
                            Spectate[Passport] = SelectedSource

                            local IdentityLog = vRP.Identity(Passport)
                            if IdentityLog then
                                table.insert(PainelLogs, {
                                    user_id = Passport,
                                    cor = "amarelo",
                                    nome = IdentityLog["name"].." "..IdentityLog["name2"],
                                    motivo = "Está espectando o passaporte ["..SelectedPassport.."]."
                                })
                            end

                            local Identity = vRP.Identity(Passport)
                            PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                                embeds = {
                                    {     
                                        title = "**Spectando o jogador**",
                                        fields = {
                                            { 
                                                name = "📝 Author:", 
                                                value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                            },
                                            { 
                                                name = "📝 Author:", 
                                                value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                            },
                                        }, 
                                        footer = { 
                                            text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                            icon_url = "./images/profile.png"
                                        },
                                        thumbnail = { 
                                            url = "./images/profile.png"
                                        },
                                        color = 3092790
                                    }
                                }
                            }), { ["Content-Type"] = "application/json" })
                        end
                    end
                end

            elseif tipo == "freezar" then
                if FreezePlayer[tostring(SelectedPassport)] then
                    FreezePlayer[tostring(SelectedPassport)] = false
                    FreezeEntityPosition(SelectedSourcePed, false)

                    TriggerClientEvent("Notify", Source, "verde", "Você tirou o freeze do "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                    local IdentityLog = vRP.Identity(Passport)
                    if IdentityLog then
                        table.insert(PainelLogs, {
                            user_id = Passport,
                            cor = "vermelho",
                            nome = IdentityLog["name"].." "..IdentityLog["name2"],
                            motivo = "Descongelou o passaporte ["..SelectedPassport.."]."
                        })
                    end

                    local Identity = vRP.Identity(Passport)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Descongelou**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                else
                    FreezePlayer[tostring(SelectedPassport)] = true
                    FreezeEntityPosition(SelectedSourcePed, true)

                    TriggerClientEvent("Notify", Source, "verde", "Você freezou o "..Identity2["name"].." ".. Identity2["name2"].." ["..SelectedPassport.."].", 7000)

                    local IdentityLog = vRP.Identity(Passport)
                    if IdentityLog then
                        table.insert(PainelLogs, {
                            user_id = Passport,
                            cor = "vermelho",
                            nome = IdentityLog["name"].." "..IdentityLog["name2"],
                            motivo = "Congelou o passaporte ["..SelectedPassport.."]."
                        })
                    end

                    local Identity = vRP.Identity(Passport)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Congelou**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end
            end
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Jogador Offline", 7000)
            return false
        end
    end
end

ScreenShotInstances = {}

function athdev.TakeScreenshot(SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    if SelectedPassport then
        local SelectedSource = vRP.Source(SelectedPassport)
        if SelectedSource then
            local screen
            vCLIENT.ScreenShotAction(SelectedSource,Config["Webhooks"]["ScreenShots"],SelectedPassport)

            local time = 0

            while not ScreenShotInstances[SelectedPassport] do
                time = time + 1
                if time >= 5 then
                    break
                end
                Wait(1500)
            end

            screen = ScreenShotInstances[SelectedPassport]
            ScreenShotInstances[SelectedPassport] = nil
            TriggerClientEvent("Notify", Source, "verde", "Voce tirou uma screenshot do passaporte: "..SelectedPassport.."")
            return screen, Passport
        end
    end
end

function athdev.AddScreenShot(ScreenShot,ScreenShotID)
    ScreenShotInstances[ScreenShotID] = ScreenShot
end

function athdev.SendMessageStaff(SelectedPassport,SelectedMessage)
    local Source = source
    local Passport = vRP.Passport(Source)
    local SelectedPassport = parseInt(SelectedPassport)
    local SelectedSource = vRP.Source(SelectedPassport)

    if SelectedSource then
        TriggerClientEvent("Notify", Source, "verde", "Voce enviou uma mensagem para o passaporte: "..SelectedPassport.."", 7000)
        TriggerClientEvent("Notify", SelectedSource, "verde", "Administração: "..SelectedMessage.."", 20000)

        local IdentityLog = vRP.Identity(Passport)
        if IdentityLog then
            table.insert(PainelLogs, {
                user_id = Passport,
                cor = "amarelo",
                nome = IdentityLog["name"].." "..IdentityLog["name2"],
                motivo = "Enviou a mensagem: \""..SelectedMessage.."\" para o passaporte ["..SelectedPassport.."]."
            })
        end

        local Identity = vRP.Identity(Passport)
        local Identity2 = vRP.Identity(SelectedPassport)
        PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
            embeds = {
                {     
                    title = "**Enviou Mensagem**",
                    fields = {
                        { 
                            name = "📝 Author:", 
                            value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                        },
                        { 
                            name = "📝 Author:", 
                            value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                        },
                        { 
                            name = "📦 Mensagem:", 
                            value = ""..SelectedMessage.." ",
                        },
                    }, 
                    footer = { 
                        text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                        icon_url = "./images/profile.png"
                    },
                    thumbnail = { 
                        url = "./images/profile.png"
                    },
                    color = 3092790
                }
            }
        }), { ["Content-Type"] = "application/json" })
        return true
    else
        TriggerClientEvent("Notify", Source, "vermelho", "Voce precisa colocar um Passaporte.")
    end
end




-- Parte das skins
-- Parte das skins
-- Parte das skins
function athdev.ReturnSkinsList()
	local Source = source
	local Passport = vRP.Passport(Source)
    local ReturnTable = {}

	if Passport then
        for Ignore,TableSkin in pairs(Config["Skins"]) do
            table.insert(ReturnTable, { nome = TableSkin["Nome"], set = TableSkin["Spawn"], linkskins = Config["ImagensSkins"], sexo = TableSkin["Sex"] })
        end
	end

    return ReturnTable
end

function athdev.SetSkinStaff(SelectedPassport,SelectedSkin)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)
    local SelectedSource = vRP.Source(SelectedPassport)

    if SelectedSource then
        if vRP.HasPermission(Passport, Config["Perms"]["AddSkins"][1],Config["Perms"]["AddSkins"][2]) then
            vRPC.Skin(SelectedSource, GetHashKey(SelectedSkin))
            Wait(1000)
            vRP.Revive(SelectedSource, 200)

            TriggerClientEvent("Notify", Source, "verde", "Você setou a skin "..SelectedSkin.." no passaporte "..SelectedPassport..".", 7000)

            local Identity2 = vRP.Identity(SelectedPassport)
            local x, y, z = vCLIENT.GetPosition(Source)

            local IdentityLog = vRP.Identity(Passport)
            if IdentityLog then
                table.insert(PainelLogs, {
                    user_id = Passport,
                    cor = "azul",
                    nome = IdentityLog.name.." "..IdentityLog.name2,
                    motivo = "Setou a skin **"..SelectedSkin.."** no passaporte ["..SelectedPassport.."] nas coordenadas ("..x..", "..y..", "..z..")."
                })
            end

            PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                embeds = {
                    {     
                        title = "*Skin setada, *"..SelectedSkin.."**",
                        fields = {
                            { 
                                name = "📝 Author:", 
                                value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                            },
                            { 
                                name = "📝 Player:", 
                                value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                            },
                            { 
                                name = "🌐 Coordenada do Staff:", 
                                    value = ""..x..","..y..","..z.." \n \n " 
                            },
                        }, 
                        footer = { 
                            text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                            icon_url = "./images/profile.png"
                        },
                        thumbnail = { 
                            url = "./images/profile.png"
                        },
                        color = 3092790
                    }
                }
            }), { ["Content-Type"] = "application/json" })
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Skin indisponivel", 7000)
        end

        return true
    else
        TriggerClientEvent("Notify", Source, "vermelho", "Esse jogador esta offline", 7000)
    end
end




-- Parte dos baús de fac
-- Parte dos baús de fac
-- Parte dos baús de fac
function athdev.ReturnChestOrganizationsList()
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local Remember = {}
    local BausFaccoes = {}

    local AllGroups = vRP.Groups()
    for OrganizationName,TableOrganization in pairs(AllGroups) do
        if TableOrganization["Type"] == "Work" then
            local Chest = vRP.GetSrvData("Chest:"..OrganizationName,true)
            if Chest then
                local AmountItens = 0
                for x,b in pairs(Chest) do
                    AmountItens = AmountItens + b["amount"]
                end

                table.insert(BausFaccoes,{ 	
                    user_id = Passport,
                    nome = Identity["name"].." ".. Identity["name2"],
                    color = "#fff",
                    background = "#fff",
                    bau = OrganizationName,
                    tipo = AmountItens.."X Itens"
                })
                Remember[OrganizationName] = true
            end
        end
    end
    for OrganizationName,TableOrganization in pairs(AllGroups) do
        if TableOrganization["Type"] == "Work" and not Remember[OrganizationName] then
            table.insert(BausFaccoes,{ 	
                user_id = Passport,
                nome = Identity["name"].." ".. Identity["name2"],
                color = "#fff",
                background = "#fff",
                bau = OrganizationName,
                tipo = "0x Itens"
            })
        end
    end

    return BausFaccoes
end

function athdev.ReturnChestOrganizationSelected(OrganizationName)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedBauList = {}

    local Chest = vRP.GetSrvData("Chest:"..OrganizationName,true)
    if Chest then
        for k,v in pairs(Chest) do
            table.insert(SelectedBauList,{ 	
                user_id = Passport,
                nome = Identity["name"].." ".. Identity["name2"],
                slot = k,
                item = v["item"],
                amount = parseInt(v["amount"]), 
                name = itemName(v["item"]), 
                index = itemIndex(v["item"]),
                days = v["days"],
                durability = v["durability"],
                linkinventario = Config["ImagensInventario"]
            })
        end
    end

    return SelectedBauList
end

function athdev.DeleteItemChestOrganization(OrganizationName,ItemName,ItemAmount,ItemSlot)
    local Source = source
    local Passport = vRP.Passport(Source)

    if Passport and vRP.HasPermission(Passport, Config["Perms"]["ManageChests"][1],Config["Perms"]["ManageChests"][2]) then
        local ChoosedSlot = 0
        local MyInventory = vRP.Inventory(Passport)

        for i = 1, 200 do
            if not MyInventory[tostring(i)] then
                ChoosedSlot = i
                break
            end
        end

        if ChoosedSlot >= 1 then
            vRP.TakeChest(Passport, "Chest:"..OrganizationName, ItemAmount, ItemSlot, ChoosedSlot)
            return true
        end
    end

    return false
end




-- Parte do gerenciar grupos
-- Parte do gerenciar grupos
-- Parte do gerenciar grupos
function athdev.ReturnAllGroupsList()
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local AllGroupList = {}

    local AllGroups = vRP.Groups()
    for OrganizationName,Ignore in pairs(AllGroups) do
        local Services, Amount = vRP.NumPermission(OrganizationName)

        table.insert(AllGroupList,{
            user_id = Passport,
            nome = Identity["name"].." ".. Identity["name2"],
            color = "#fff",
            background = "#fff",
            empresa = OrganizationName,
            contador = Amount
        })
    end

    return AllGroupList
end

function athdev.ReturnOrganizationListSelected(GroupName)
    local Source = source
    local Passport = vRP.Passport(Source)
    local MyIdentity = vRP.Identity(Passport)
    local SelectedGroupList = {}

    local AllGroups = vRP.Groups()
    local DataGroup = vRP.DataGroups(GroupName)
    if DataGroup then
        if AllGroups[GroupName] then
            for SelectedPass,SelectedHierarchy in pairs(DataGroup) do
                local SelectedPassport = parseInt(SelectedPass)
                local Identity = vRP.Identity(SelectedPassport)
                if Identity then
                    local InfoImage = vRP.Query("athdevLiterally/jesterInstagram", {user_id = SelectedPassport})
                    local SelectedImage = "./images/profile.png"
                    if InfoImage[1] then
                        SelectedImage = InfoImage[1]["avatarURL"]
                    end

                    local ThisGroup = AllGroups[GroupName]
                    local MyHierarchy = ThisGroup["Hierarchy"][SelectedHierarchy]

                    table.insert(SelectedGroupList,{
                        user_id = SelectedPassport,
                        myname = Identity["name"].." "..Identity["name2"],
                        nome = Identity["name"],
                        sobrenome = Identity["name2"],
                        color = "#fff",
                        background = "#fff",
                        emprego = MyHierarchy,
                        img = SelectedImage
                    })
                end
            end
        end
    end

    return SelectedGroupList
end

function athdev.ManageSelectedGroups(SelectedPassport, GroupName, Type)
    local Source = source
    local Passport = vRP.Passport(Source)
    local AllGroups = vRP.Groups()

    if Passport and vRP.HasPermission(Passport, Config["Perms"]["ManageGroups"][1],Config["Perms"]["ManageGroups"][2]) and vRP.HasPermission(SelectedPassport, GroupName) then
        if Type == "upar" then
            local SelectedLevel = 0
            local Datatable = vRP.GetSrvData("Permissions:"..GroupName)
            if Datatable[tostring(SelectedPassport)] then
                if Datatable[tostring(SelectedPassport)] - 1 >= 1 then
                    SelectedLevel = Datatable[tostring(SelectedPassport)] - 1
                else
                    SelectedLevel = Datatable[tostring(SelectedPassport)]
                end
            end

            local IdentityLog = vRP.Identity(Passport)
            local IdentityAffected = vRP.Identity(SelectedPassport)
            if IdentityLog then
                table.insert(PainelLogs, { user_id = Passport, cor = "amarelo", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Realizou um up no id ["..SelectedPassport.."] no grupo ["..GroupName.."]." })

                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "*Player upado do grupo, *"..GroupName.."**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Player:", 
                                    value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                }
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            end

            vRP.SetPermission(SelectedPassport, GroupName, SelectedLevel, false)
        end
        if Type == "rebaixar" then
            local SelectedLevel = 0
            local Datatable = vRP.GetSrvData("Permissions:"..GroupName)
            if Datatable[tostring(SelectedPassport)] then
                if Datatable[tostring(SelectedPassport)] + 1 <= #AllGroups[GroupName]["Hierarchy"] then
                    SelectedLevel = Datatable[tostring(SelectedPassport)] + 1
                else
                    SelectedLevel = Datatable[tostring(SelectedPassport)]
                end
            end

            local IdentityLog = vRP.Identity(Passport)
            local IdentityAffected = vRP.Identity(SelectedPassport)
            if IdentityLog then
                table.insert(PainelLogs, { user_id = Passport, cor = "amarelo", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Realizou um rebaixar no id ["..SelectedPassport.."] no grupo ["..GroupName.."]." })

                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "*Player rebaixado do grupo, *"..GroupName.."**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Player:", 
                                    value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                }
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            end

            vRP.SetPermission(SelectedPassport, GroupName, SelectedLevel, false)
        end
        if Type == "demitir" then
            local IdentityLog = vRP.Identity(Passport)
            local IdentityAffected = vRP.Identity(SelectedPassport)
            if IdentityLog then
                table.insert(PainelLogs, { user_id = Passport, cor = "amarelo", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Realizou uma demissão no id ["..SelectedPassport.."] no grupo ["..GroupName.."]." })

                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "*Player removido do grupo, *"..GroupName.."**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Player:", 
                                    value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                }
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            end

            vRP.RemovePermission(SelectedPassport, GroupName)
        end
    end
end




-- Parte do inventário
-- Parte do inventário
-- Parte do inventário
function athdev.ReturnInventorySelected(SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    local ReturnInventoryTable = {}

    local SelectedPassport = parseInt(SelectedPassport)
    local SelectedInventory = vRP.Inventory(SelectedPassport)
    local Identity = vRP.Identity(SelectedPassport)

    if Passport then
        for Ignore,TableInventory in pairs(SelectedInventory) do
            if itemName(TableInventory["item"]) then
                local splitName = splitString(TableInventory["item"], "-")
				if splitName[2] ~= nil then
					if itemDurability(TableInventory["item"]) then
						TableInventory["durability"] = parseInt(os.time() - splitName[2])
						TableInventory["days"] = itemDurability(TableInventory["item"])
					else
						TableInventory["durability"] = 0
						TableInventory["days"] = 1
					end
				else
					TableInventory["durability"] = 0
					TableInventory["days"] = 1
				end

                table.insert(ReturnInventoryTable,{
                    user_id = SelectedPassport,
                    nome = Identity["name"].." ".. Identity["name2"],
                    item = TableInventory["item"],
                    amount = parseInt(TableInventory["amount"]),
                    name = itemName(TableInventory["item"]),
                    index = itemIndex(TableInventory["item"]),
                    days = TableInventory["days"],
                    durability = TableInventory["durability"],
                    linkinventario = Config["ImagensInventario"]
                })
            end
        end
    end

    return ReturnInventoryTable
end

function athdev.RemoveItemSelectedInventory(SelectedPassport,SelectedItem,SelectedAmount)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)

    if Passport then
        if vRP.HasPermission(Passport, Config["Perms"]["ManageInventory"][1],Config["Perms"]["ManageInventory"][2]) then
            vRP.TakeItem(SelectedPassport, SelectedItem, SelectedAmount, true)
        
            local Identity2 = vRP.Identity(SelectedPassport)
            TriggerClientEvent("Notify", Source, "verde", "Voce retirou "..SelectedAmount.."x "..itemName(SelectedItem).." do "..Identity2["name"].." "..Identity2["name2"].." ["..SelectedPassport.."]", 7000)
            local x, y, z = vCLIENT.GetPosition(Source)

            local IdentityLog = vRP.Identity(Passport)
            if IdentityLog then
                table.insert(PainelLogs, {
                    user_id = Passport,
                    cor = "vermelho",
                    nome = IdentityLog["name"].." "..IdentityLog["name2"],
                    motivo = "Removeu o item **"..parseFormat(SelectedAmount).."x "..itemName(SelectedItem).."** do passaporte ["..SelectedPassport.."]."
                })
            end
        
            PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                embeds = {
                    {     
                        title = "**Removeu Item**",
                        fields = {
                            { 
                                name = "📝 Author:", 
                                value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                            },
                            { 
                                name = "📝 Player:", 
                                value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                            },
                            { 
                                name = "🎁 Item:", 
                                value = " "..parseFormat(SelectedAmount).."x " ..itemName(SelectedItem).."",
                            },
                            { 
                                name = "🌐 Coordenada do Staff:", 
                                    value = ""..x..","..y..","..z.." \n \n " 
                            },
                        }, 
                        footer = { 
                            text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                            icon_url = "./images/profile.png"
                        },
                        thumbnail = { 
                            url = "./images/profile.png"
                        },
                        color = 3092790
                    }
                }
            }), { ["Content-Type"] = "application/json" })

            return true
        end
    end
    
    return false
end




-- Parte da garagem
-- Parte da garagem
-- Parte da garagem
function athdev.ReturnSelectedGarageList(SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    local GaragemTables = {}
    local SelectedPassport = parseInt(SelectedPassport)

    local VehicleQuery = vRP.Query("vehicles/UserVehicles", { Passport = SelectedPassport })
    local Identity = vRP.Identity(SelectedPassport)

    if Passport then
        for Index,TableVehicle in pairs(VehicleQuery) do
            if VehicleName(TableVehicle["vehicle"]) then
                table.insert(GaragemTables,{
                    user_id = SelectedPassport,
                    nome = Identity["name"].." ".. Identity["name2"],
                    index = TableVehicle["vehicle"],
                    name = VehicleName(TableVehicle["vehicle"]),
                    linkgaragem = Config["ImagensGaragem"]
                })
            end
        end
    end

    return GaragemTables
end

function athdev.DeleteVehicleSelected(SelectedPassport,NameVehicle)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)

    if Passport then
        if vRP.HasPermission(Passport, Config["Perms"]["ManageVehicles"][1],Config["Perms"]["ManageVehicles"][2]) then
            vRP.Query("vehicles/removeVehicles", { Passport = SelectedPassport, vehicle = NameVehicle }) 

            local Identity2 = vRP.Identity(SelectedPassport)
            TriggerClientEvent("Notify", Source, "verde", "Voce retirou o carro "..NameVehicle.." do "..Identity2["name"].." "..Identity2["name2"].." ["..SelectedPassport.."]", 7000)

            local IdentityLog = vRP.Identity(Passport)
            if IdentityLog then
                table.insert(PainelLogs, {
                    user_id = Passport,
                    cor = "vermelho",
                    nome = IdentityLog["name"].." "..IdentityLog["name2"],
                    motivo = "Removeu o veículo **"..VehicleName(NameVehicle).."** do passaporte ["..SelectedPassport.."]."
                })
            end

            local x, y, z = vCLIENT.GetPosition(Source)
            PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                embeds = {
                    {     
                        title = "**Removeu Carro**",
                        fields = {
                            { 
                                name = "📝 Author:", 
                                value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."**",
                            },
                            { 
                                name = "📝 Player:", 
                                value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."**",
                            },
                            { 
                                name = "🚗 Carro:", 
                                value = " "..VehicleName(NameVehicle).." ",
                            },
                            { 
                                name = "🌐 Coordenada do Staff:", 
                                    value = ""..x..","..y..","..z.." \n \n " 
                            },
                        }, 
                        footer = { 
                            text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                            icon_url = "./images/profile.png"
                        },
                        thumbnail = { 
                            url = "./images/profile.png"
                        },
                        color = 3092790
                    }
                }
            }), { ["Content-Type"] = "application/json" })

            return true
        end
    end

    return false
end

function athdev.ReturnChestVehicleList(SelectedPassport,SelectedVehicle)
    local Source = source
    local Passport = vRP.Passport(Source)
    local VehicleChestList = {}
    local SelectedPassport = parseInt(SelectedPassport)

    if Passport then
		local Result = vRP.GetSrvData("Trunkchest:"..SelectedPassport..":"..SelectedVehicle)
        local Identity = vRP.Identity(SelectedPassport)

        if Result then
			for k,v in pairs(Result) do
                local splitName = splitString(v["item"], "-")
                if splitName[2] ~= nil then
                    if itemDurability(v["item"]) then
                        v["durability"] = parseInt(os.time() - splitName[2])
                        v["days"] = itemDurability(v["item"])
                    else
                        v["durability"] = 0
                        v["days"] = 1
                    end
                else
                    v["durability"] = 0
                    v["days"] = 1
                end

				table.insert(VehicleChestList,{
                    user_id = SelectedPassport,
                    nome = Identity["name"].." ".. Identity["name2"],
                    slot = k,
                    item = v["item"],
                    amount = parseInt(v["amount"]), 
                    name = itemName(v["item"]), 
                    index = itemIndex(v["item"]),
                    days = v["days"],
                    durability = v["durability"],
                    linkinventario = Config["ImagensInventario"]
                })
			end
        end
    end

    return VehicleChestList
end

function athdev.DeleteSelectedItemChestVehicle(SelectedPassport,VehicleName,ItemName,ItemAmount,ItemSlot)
    local Source = source
    local Passport = vRP.Passport(Source)
    local SelectedPassport = parseInt(SelectedPassport)

    if Passport and vRP.HasPermission(Passport, Config["Perms"]["ManageVehicles"][1],Config["Perms"]["ManageVehicles"][2]) then
        local ChoosedSlot = 0
        local MyInventory = vRP.Inventory(Passport)

        for i = 1, 200 do
            if not MyInventory[tostring(i)] then
                ChoosedSlot = i
                break
            end
        end

        if ChoosedSlot >= 1 then
            local IdentityLog = vRP.Identity(Passport)
            local IdentityAffected = vRP.Identity(SelectedPassport)
            if IdentityLog and IdentityAffected then
                table.insert(PainelLogs, { user_id = Passport, cor = "vermelho", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Removeu o item do baú do veiculo no id ["..SelectedPassport.."] item ["..ItemName.."] no veiculo ["..VehicleName.."]." })

                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Removeu um item do baú**",
                            fields = {
                                {
                                    name = "📝 Author:", 
                                    value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                },
                                {
                                    name = "📝 No passporte:", 
                                    value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                },
                                {
                                    name = "🚗 No veículo:", 
                                    value = "**#"..VehicleName.."** ",
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            end

            vRP.TakeChest(SelectedPassport, "Trunkchest:"..SelectedPassport..":"..VehicleName, ItemAmount, ItemSlot, ChoosedSlot)
            return true
        end
    end

    return false
end




-- Parte de gerenciar players
-- Parte de gerenciar players
-- Parte de gerenciar players
function athdev.ChangeWalletValues(SelectedPassport,SelectedValue,SelectedType)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)
    local SelectedValue = parseInt(SelectedValue)
    local SelectedSource = vRP.Source(SelectedPassport)

    if SelectedSource then
        if vRP.HasPermission(Passport, Config["Perms"]["ManageMoney"][1],Config["Perms"]["ManageMoney"][2]) then
            if SelectedType == "mais" then
                vRP.GenerateItem(SelectedPassport, "dollars", SelectedValue, true)
    
                TriggerClientEvent("Notify", Source, "verde", "Você adicionou "..parseFormat(SelectedValue).." $ para o passaporte: "..SelectedPassport.."", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "vermelho",
                        nome = IdentityLog.name.." "..IdentityLog.name2,
                        motivo = "Spawnou dinheiro na carteira **"..parseFormat(SelectedValue).."$** no passaporte ["..SelectedPassport.."]."
                    })

                    local Identity2 = vRP.Identity(SelectedPassport)
                    local x, y, z = vCLIENT.GetPosition(Source)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Spawn Dinheiro Carteira**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Player:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                    { 
                                        name = "💸 Quantidade:", 
                                        value = " "..parseFormat(SelectedValue).." $ ",
                                    },
                                    { 
                                        name = "🌐 Coordenada do Staff:", 
                                            value = ""..x..","..y..","..z.." \n \n " 
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                return true
            end
            if SelectedType == "menos" then
                vRP.TakeItem(SelectedPassport, "dollars", SelectedValue, true)

                TriggerClientEvent("Notify", Source, "verde", "Voce retirou "..parseFormat(SelectedValue).." $ do passaporte: "..SelectedPassport.."", 7000)

                local Identity2 = vRP.Identity(SelectedPassport)
                local x,y,z = vCLIENT.GetPosition(Source)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "vermelho",
                        nome = IdentityLog.name.." "..IdentityLog.name2,
                        motivo = "Removeu dinheiro no banco **"..parseFormat(SelectedValue).."$** no passaporte ["..SelectedPassport.."]."
                    })

                    local Identity2 = vRP.Identity(SelectedPassport)
                    local x, y, z = vCLIENT.GetPosition(Source)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Remover Dinheiro Banco**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Player:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                    { 
                                        name = "💸 Quantidade:", 
                                        value = " "..parseFormat(SelectedValue).." $ ",
                                    },
                                    { 
                                        name = "🌐 Coordenada do Staff:", 
                                            value = ""..x..","..y..","..z.." \n \n " 
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                return true
            end
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem permissão!", 7000)
        end
    else
        TriggerClientEvent("Notify", Source, "vermelho", "Esse jogador esta offline", 7000)
    end

    return false
end

function athdev.ChangeBankValues(SelectedPassport,SelectedValue,SelectedType)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)
    local SelectedValue = parseInt(SelectedValue)
    local SelectedSource = vRP.Source(SelectedPassport)

    if SelectedSource then
        if vRP.HasPermission(Passport, Config["Perms"]["ManageMoney"][1],Config["Perms"]["ManageMoney"][2]) then
            if SelectedType == "mais" then
                vRP.GiveBank(SelectedPassport, SelectedValue)
    
                TriggerClientEvent("Notify", Source, "verde", "Você adicionou "..parseFormat(SelectedValue).." $ para o passaporte: "..SelectedPassport.."", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "vermelho",
                        nome = IdentityLog.name.." "..IdentityLog.name2,
                        motivo = "Spawnou dinheiro no banco **"..parseFormat(SelectedValue).."$** no passaporte ["..SelectedPassport.."]."
                    })

                    local Identity2 = vRP.Identity(SelectedPassport)
                    local x, y, z = vCLIENT.GetPosition(Source)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Spawn Dinheiro Banco**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Player:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                    { 
                                        name = "💸 Quantidade:", 
                                        value = " "..parseFormat(SelectedValue).." $ ",
                                    },
                                    { 
                                        name = "🌐 Coordenada do Staff:", 
                                            value = ""..x..","..y..","..z.." \n \n " 
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                return true
            end
            if SelectedType == "menos" then
                vRP.PaymentBank(SelectedPassport, SelectedValue)

                TriggerClientEvent("Notify", Source, "verde", "Voce retirou "..parseFormat(SelectedValue).." $ do passaporte: "..SelectedPassport.."", 7000)

                local Identity2 = vRP.Identity(SelectedPassport)
                local x,y,z = vCLIENT.GetPosition(Source)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "vermelho",
                        nome = IdentityLog.name.." "..IdentityLog.name2,
                        motivo = "Retirou dinheiro do banco **"..parseFormat(SelectedValue).."$** no passaporte ["..SelectedPassport.."]."
                    })

                    local Identity2 = vRP.Identity(SelectedPassport)
                    local x, y, z = vCLIENT.GetPosition(Source)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Remover Dinheiro Banco**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Player:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                    { 
                                        name = "💸 Quantidade:", 
                                        value = " "..parseFormat(SelectedValue).." $ ",
                                    },
                                    { 
                                        name = "🌐 Coordenada do Staff:", 
                                            value = ""..x..","..y..","..z.." \n \n " 
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                return true
            end
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem permissão!", 7000)
        end
    else
        TriggerClientEvent("Notify", Source, "vermelho", "Esse jogador esta offline", 7000)
    end

    return false
end

function athdev.ChangeNumberPhoneSelected(SelectedPassport,NewPhoneNumber)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)

    local SelectedSource = vRP.Source(SelectedPassport)
    if SelectedSource then
        if vRP.HasPermission(Passport, Config["Perms"]["ChangeNumber"][1],Config["Perms"]["ChangeNumber"][2]) then
            if not vRP.UserPhone(NewPhoneNumber) then
                local Identity2 = vRP.Identity(SelectedPassport)
                local OldPhoneNumber = Identity2["phone"]

                TriggerEvent("smartphone:updatePhoneNumber", SelectedPassport, NewPhoneNumber)
                vRP.UpgradePhone(SelectedPassport, NewPhoneNumber)

                TriggerClientEvent("Notify", Source, "verde", "Telefone atualizado.", 5000)
                TriggerClientEvent("Notify", Source, "verde", "Voce alterou o celular para "..NewPhoneNumber.." do passaporte: "..SelectedPassport.."", 7000)

                local IdentityLog = vRP.Identity(Passport)
                if IdentityLog then
                    table.insert(PainelLogs, {
                        user_id = Passport,
                        cor = "vermelho",
                        nome = IdentityLog["name"].." "..IdentityLog["name2"],
                        motivo = "Trocou o número de celular do passaporte ["..SelectedPassport.."]: de **"..OldPhoneNumber.."** para **"..NewPhoneNumber.."**."
                    })

                    local x, y, z = vCLIENT.GetPosition(Source)
                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "**Trocou o Celular**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Player:", 
                                        value = "" ..Identity2["name"].." "..Identity2["name2"].." **#"..SelectedPassport.."** ",
                                    },
                                    { 
                                        name = "📱 Antigo Numero:", 
                                        value = " "..OldPhoneNumber.."",
                                    },
                                    { 
                                        name = "📱 Novo Numero:", 
                                        value = " "..NewPhoneNumber.."",
                                    },
                                    { 
                                        name = "🌐 Coordenada do Staff:", 
                                            value = ""..x..","..y..","..z.." \n \n " 
                                    },
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end
    
                return true
            else
                TriggerClientEvent("Notify", Source, "vermelho", "Esse celular não está disponivel!", 7000)
            end
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem permissão!", 7000)
        end
    else
        TriggerClientEvent("Notify", Source, "vermelho", "Esse jogador está offline!", 7000)
    end

    return false
end

function athdev.ChangeSelectedName(SelectedPassport,FirstName,SecondName)
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local SelectedPassport = parseInt(SelectedPassport)

    if SelectedPassport then
        if vRP.HasPermission(Passport, Config["Perms"]["ChangeName"][1],Config["Perms"]["ChangeName"][2]) then
            local Identity3 = vRP.Identity(SelectedPassport)
            local OldName = "" ..Identity3["name"].." "..Identity3["name2"]..""

            vRP.UpgradeNames(SelectedPassport, FirstName, SecondName)

            local Identity2 = vRP.Identity(SelectedPassport)
            TriggerClientEvent("Notify", Source, "verde", "Você trocou o nome do passaporte: "..SelectedPassport.." para "..FirstName.." "..SecondName..".", 7000)

            local IdentityLog = vRP.Identity(Passport)
            if IdentityLog then
                table.insert(PainelLogs, {
                    user_id = Passport,
                    cor = "vermelho",
                    nome = IdentityLog["name"].." "..IdentityLog["name2"],
                    motivo = "Trocou o nome do passaporte ["..SelectedPassport.."]: de **"..OldName.."** para **"..Identity2["name"].." "..Identity2["name2"].."**."
                })

                local x,y,z = vCLIENT.GetPosition(Source)
                PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                    embeds = {
                        {     
                            title = "**Troca de Nome**",
                            fields = {
                                { 
                                    name = "📝 Author:", 
                                    value = "" ..Identity["name"].." "..Identity["name2"].." **#"..Passport.."** ",
                                },
                                { 
                                    name = "📝 Player:", 
                                    value = "" ..OldName.." **#"..SelectedPassport.."** ",
                                },
                                { 
                                    name = "✨ Antigo Nome:", 
                                    value = " "..OldName.."",
                                },
                                { 
                                    name = "✨ Novo Nome:", 
                                    value = "" ..Identity2["name"].." "..Identity2["name2"].."",
                                },
                                { 
                                    name = "🌐 Coordenada do Staff:", 
                                        value = ""..x..","..y..","..z.." \n \n " 
                                },
                            }, 
                            footer = { 
                                text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                icon_url = "./images/profile.png"
                            },
                            thumbnail = { 
                                url = "./images/profile.png"
                            },
                            color = 3092790
                        }
                    }
                }), { ["Content-Type"] = "application/json" })
            end

            return true
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem permissão!", 7000)
        end
    else
        TriggerClientEvent("Notify", Source, "vermelho", "Você precisa colocar um Passaporte!", 7000)
    end

    return false
end




-- Parte dos empregos
-- Parte dos empregos
-- Parte dos empregos
function athdev.AlllJobsList()
    local Source = source
    local Passport = vRP.Passport(Source)
    local JobsListTable = {}

    if Passport then
        local AllGroups = vRP.Groups()
        local Identity = vRP.Identity(Passport)
    
        for JobName,Ignore in pairs(AllGroups) do
            table.insert(JobsListTable, {user_id = Passport, nome = Identity["name"].." ".. Identity["name2"], emprego = JobName, empregotitle = JobName})
        end
    end

    return JobsListTable
end

function athdev.SelectedPassportJobsList(SelectedPassport)
    local Source = source
    local Passport = vRP.Passport(Source)
    local JobsListTable = {}
    local SelectedPassport = parseInt(SelectedPassport)

    if Passport then
        local AllGroups = vRP.Groups()
        local Identity = vRP.Identity(SelectedPassport)
    
        for JobName,Ignore in pairs(AllGroups) do
            local DataGroup = vRP.DataGroups(JobName)
    
            if DataGroup[tostring(SelectedPassport)] then
                table.insert(JobsListTable, {user_id = SelectedPassport, nome = Identity["name"].." ".. Identity["name2"], emprego = JobName, empregotitle = JobName})
            end
        end
    end

    return JobsListTable
end

function athdev.SetNewJobSelectedPassport(SelectedPassport, JobName)
    local Source = source
    local Passport = vRP.Passport(Source)
    local SelectedPassport = parseInt(SelectedPassport)

    if Passport then
        if vRP.HasPermission(Passport, Config["Perms"]["ManageGroups"][1],Config["Perms"]["ManageGroups"][2]) then
            local SelectedSource = vRP.Source(SelectedPassport)
            if SelectedSource then
                vRP.SetPermission(SelectedPassport, JobName)

                local IdentityLog = vRP.Identity(Passport)
                local IdentityAffected = vRP.Identity(SelectedPassport)
                if IdentityLog then
                    table.insert(PainelLogs, { user_id = Passport, cor = "amarelo", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Adicionou um novo grupo ["..JobName.."] no passaporte ["..SelectedPassport.."]." })

                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "*Player adicionado no grupo, *"..JobName.."**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Player:", 
                                        value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                    }
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                TriggerClientEvent("Notify", Source, "verde", "Você adicionou o passaporte "..SelectedPassport.." do grupo "..JobName..".", 7000)
                return true
            else
                TriggerClientEvent("Notify", Source, "vermelho", "Player não encontrado na cidade!", 7000)
            end
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem permissão!", 7000)
        end
    end

    return false
end

function athdev.DeleteSelectedJobPassport(SelectedPassport,JobName)
    local Source = source
    local Passport = vRP.Passport(Source)
    local SelectedPassport = parseInt(SelectedPassport)

    if Passport then
        if vRP.HasPermission(Passport, Config["Perms"]["ManageGroups"][1],Config["Perms"]["ManageGroups"][2]) then
            local SelectedSource = vRP.Source(SelectedPassport)
            if SelectedSource then
                vRP.RemovePermission(SelectedPassport, JobName)

                local IdentityLog = vRP.Identity(Passport)
                local IdentityAffected = vRP.Identity(SelectedPassport)
                if IdentityLog then
                    table.insert(PainelLogs, { user_id = Passport, cor = "amarelo", nome = IdentityLog["name"].." "..IdentityLog["name2"], motivo = "Removeu um grupo ["..JobName.."] no passaporte ["..SelectedPassport.."]." })

                    PerformHttpRequest(Config["Webhooks"]["FastActions"], function(err, text, headers) end, "POST", json.encode({
                        embeds = {
                            {     
                                title = "*Player removido do grupo, *"..JobName.."**",
                                fields = {
                                    { 
                                        name = "📝 Author:", 
                                        value = "" ..IdentityLog["name"].." "..IdentityLog["name2"].." **#"..Passport.."** ",
                                    },
                                    { 
                                        name = "📝 Player:", 
                                        value = "" ..IdentityAffected["name"].." "..IdentityAffected["name2"].." **#"..SelectedPassport.."** ",
                                    }
                                }, 
                                footer = { 
                                    text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S"),
                                    icon_url = "./images/profile.png"
                                },
                                thumbnail = { 
                                    url = "./images/profile.png"
                                },
                                color = 3092790
                            }
                        }
                    }), { ["Content-Type"] = "application/json" })
                end

                TriggerClientEvent("Notify", Source, "verde", "Você removeu o passaporte "..SelectedPassport.." do grupo "..JobName..".", 7000)
                return true
            else
                TriggerClientEvent("Notify", Source, "vermelho", "Player não encontrado na cidade!", 7000)
            end
        else
            TriggerClientEvent("Notify", Source, "vermelho", "Você não tem permissão!", 7000)
        end
    end

    return false
end




-- Parte dos spectate
-- Parte dos spectate
-- Parte dos spectate
AddEventHandler("Disconnect",function(Passport)
	if Spectate[Passport] then
		Spectate[Passport] = nil
	end
end)