local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

athdev = {}
Tunnel.bindInterface("athdev_staffpainel",athdev)
vSERVER = Tunnel.getInterface("athdev_staffpainel")


-- Parte principal
local StaffOpenPainel = false

RegisterCommand("paineladm", function()
    if not StaffOpenPainel then
        if vSERVER.CheckPermission() then
            NetworkSetInSpectatorMode(false)

            local Nome, Sobrenome, Imagem = vSERVER.ReturnNames()
            local Players2, Police2, Ilegal2, Staff2 = vSERVER.ReturnServices()
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "showMenu",
                nome = Nome,
                sobrenome = Sobrenome,
                imagem = Imagem,

                players = Players2,
                police = Police2,
                ilegal = Ilegal2,
                staff = Staff2
            }) 

            StartScreenEffect("MenuMGSelectionIn", 0, true)
        end
    end
end)

RegisterNUICallback("staffClose",function(data)
	SetNuiFocus(false,false)
	StopScreenEffect("MenuMGSelectionIn")
	StaffOpenPainel = false
end)

function athdev.GetPosition()
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
	return x,y,z
end




-- Parte do teleport
-- Parte do teleport
-- Parte do teleport
RegisterNUICallback("CoordsLista",function(Data,CallBack,imgperfil)
	local TeleportList = vSERVER.ConsultCoordsList()
	if TeleportList then
		CallBack({ teleporteslista = TeleportList })
	end
end)

RegisterNUICallback("teleport",function(Data,CallBack)
	local Ped = PlayerPedId()
	SetEntityCoords(Ped, tonumber(Data["x"]), tonumber(Data["y"]), tonumber(Data["z"]))
end)

RegisterNUICallback("addteleport",function(Data,CallBack)
	if vSERVER.AddTeleport(Data["nome"],Data["coord"]) then
		CallBack({retorno = "done"})
	end
end)

RegisterNUICallback("deleteteleport",function(Data,CallBack)
	if vSERVER.DeleteTeleport(Data["id"],Data["nome"]) then
		CallBack({retorno = "done"})
	end
end)




-- Parte do logs
-- Parte do logs
-- Parte do logs
RegisterNUICallback("LogsLista",function(Data,CallBack)
	local LogsList = vSERVER.ReturnLogsList()
	if LogsList then
		CallBack({ logslista = LogsList })
	end
end)




-- Parte do usuários
-- Parte do usuários
-- Parte do usuários
RegisterNUICallback("ControleLista",function(Data,CallBack)
	local PlayersList = vSERVER.ReturnPlayerList()
	if PlayersList then
		CallBack({ controlelista = PlayersList })
	end
end)




-- Parte do punições
-- Parte do punições
-- Parte do punições
RegisterNUICallback("PunicoesLista",function(Data,CallBack)
	local Warnings = vSERVER.SeeInformationsWarnings()
	if Warnings then
		CallBack({ punicoes = Warnings })
	end
end)

RegisterNUICallback("DeleteAdv",function(Data,CallBack)
	if vSERVER.DeleteAdv(Data["passaporte"], Data["status"], Data["contagem"]) then
		CallBack({ retorno = "done" })
	end
end)



-- Parte do get all
-- Parte do get all
-- Parte do get all
RegisterNUICallback("ItensLista",function(Data,CallBack)
	local ItensList = vSERVER.SeeInformationsItemList()
	if ItensList then
		CallBack({ itens = ItensList })
	end
end)

RegisterNUICallback("garagemLista",function(Data,CallBack)
	local AllVehicles = vSERVER.SeeInformationsAllVeiculos()
	if AllVehicles then
		CallBack({ garagem = AllVehicles })
	end
end)



-- Parte dos sends
-- Parte dos sends
-- Parte dos sends
local ItemCatchName = "nada"
local VehicleCatchName = "nada"

RegisterNUICallback("enviarItem",function(Data,CallBack)
	ItemCatchName = Data["item"]
	CallBack({})
end)

RegisterNUICallback("enviarCarro",function(Data,CallBack)
	VehicleCatchName = Data["carro"]
	CallBack({})
end)

RegisterNUICallback("pegarItemConfirm",function(Data,CallBack)
	if vSERVER.CatchItem(ItemCatchName,Data["quantidade"]) then
		CallBack({retorno = "done"})
	end
end)

RegisterNUICallback("pegarCarroConfirmar",function(Data,CallBack)
	if vSERVER.GiveVehicle(VehicleCatchName,Data["passaporte"]) then
		CallBack({retorno = "done"})
	end
end)
--------------------------------
-- [ ENVIAR ID ] --
--------------------------------

local SelectedPassportActions = 0

RegisterNUICallback("EnviarID",function(Data,CallBack)
	if Data["passaporte"] then
		SelectedPassportActions = Data["passaporte"]

		if Data["tipo"] == "SADVS" then
			CallBack({ tipo = Data["tipo"] })
		end

		if Data["tipo"] == "VERPERFIL" then
			local carteira,banco,nome,sobrenome,registro,celular,idade,emprego,vip,coins,img,banner = vSERVER.SeeInformationsProfile(Data["passaporte"])
			CallBack({ tipo = Data["tipo"],carteira = carteira,banco = banco,nome = nome,sobrenome = sobrenome,registro = registro,celular = celular,idade = idade,emprego = emprego,vip = vip,coins = coins,img = img,banner = banner})
		end
	end
end)




-- Parte dos inventários
-- Parte dos inventários
-- Parte dos inventários
RegisterNUICallback("PegarInv",function(Data,CallBack)
	local InventorySelected = vSERVER.ReturnInventorySelected(SelectedPassportActions)
	if InventorySelected then
		CallBack({ inventario = InventorySelected })
	end
end)

RegisterNUICallback("removerItem",function(Data,CallBack)
	if vSERVER.RemoveItemSelectedInventory(SelectedPassportActions,Data["item"],Data["quantidade"]) then
		CallBack({retorno = "done"})
	end
end)




-- Parte dos veículos
-- Parte dos veículos
-- Parte dos veículos
RegisterNUICallback("PegarGaragem",function(Data,CallBack)
	local SelectedGarageList = vSERVER.ReturnSelectedGarageList(SelectedPassportActions)
	if SelectedGarageList then
		CallBack({ garagem = SelectedGarageList })
	end
end)

RegisterNUICallback("removerCarro",function(Data,CallBack)
	if vSERVER.DeleteVehicleSelected(SelectedPassportActions, Data["item"]) then
		CallBack({retorno = "done"})
	end
end)

local SelectedCarNameActions = ""

RegisterNUICallback("verBauCarro",function(Data,CallBack)
	SelectedCarNameActions = Data["carro"]
	CallBack({retorno = "done"})
end)

RegisterNUICallback("verBauCarroList",function(Data,CallBack)
	local VehicleChestList = vSERVER.ReturnChestVehicleList(SelectedPassportActions, SelectedCarNameActions)
	if VehicleChestList then
		CallBack({ carroBau = VehicleChestList })
	end
end)

RegisterNUICallback("removerItemBauCarro",function(Data,CallBack)
	if vSERVER.DeleteSelectedItemChestVehicle(SelectedPassportActions,SelectedCarNameActions,Data["item"],Data["quantidade"],Data["slot"]) then
		CallBack({retorno = "done"})
	end
end)




-- Parte dos empregos
-- Parte dos empregos
-- Parte dos empregos
RegisterNUICallback("PegarEmpregos",function(Data,CallBack)
	local JobsList = vSERVER.SelectedPassportJobsList(SelectedPassportActions)
	if JobsList then
		CallBack({ empregos = JobsList })
	end
end)

RegisterNUICallback("addEmprego",function(data,cb)
	local JobsList = vSERVER.AlllJobsList()
	if JobsList then
		cb({ listEmprego = JobsList })
	end
end)

RegisterNUICallback("removerCargo",function(Data,CallBack)
	if vSERVER.DeleteSelectedJobPassport(SelectedPassportActions,Data["emprego"]) then
		CallBack({retorno = "done"})
	end
end)

RegisterNUICallback("confirmaremprego",function(Data,CallBack)
	if vSERVER.SetNewJobSelectedPassport(SelectedPassportActions,Data["emprego"]) then
		CallBack({retorno = "done"})
	end
end)




-- Parte dos fast actions
-- Parte dos fast actions
-- Parte dos fast actions
RegisterNUICallback("opcoesRapidas",function(Data,CallBack)
	if vSERVER.FastActionsToogle(SelectedPassportActions, Data["tipo"]) then
		CallBack({retorno = "done"})
	end
end)




-- Parte dos change name
-- Parte dos change name
-- Parte dos change name
RegisterNUICallback("trocarnome", function(Data, CallBack)
	if vSERVER.ChangeSelectedName(SelectedPassportActions, Data["PrimeiroNome"], Data["SegundoNome"]) then
		local Nome2, Sobrenome2, Imagem = vSERVER.ReturnNames()
		local Carteira, Banco, Nome, Sobrenome, Registro, Celular, Idade, Emprego, Vip, Coins, Img, Banner = vSERVER.SeeInformationsProfile(SelectedPassportActions)
		CallBack({
			retorno = "done",
			nome = Nome,
			sobrenome = Sobrenome,
			nome2 = Nome2,
			sobrenome2 = Sobrenome2
		})
	end
end)




-- Parte dos change carteira
-- Parte dos change carteira
-- Parte dos change carteira
RegisterNUICallback("trocarcarteira", function(Data, CallBack)
	if vSERVER.ChangeWalletValues(SelectedPassportActions, Data["valor"], Data["tipo"]) then
		local Nome, Sobrenome, Imagem = vSERVER.ReturnNames()
		local Carteira, Banco, Nome2, Sobrenome2, Registro, Celular, Idade, Emprego, Vip, Coins, Img, Banner = vSERVER.SeeInformationsProfile(SelectedPassportActions)
		CallBack({ retorno = "done", carteira = Carteira })
	end
end)




-- Parte dos change bank
-- Parte dos change bank
-- Parte dos change bank
RegisterNUICallback("trocarbanco", function(Data, CallBack)
	if vSERVER.ChangeBankValues(SelectedPassportActions, Data["valor"], Data["tipo"]) then
		local Nome, Sobrenome, Imagem = vSERVER.ReturnNames()
		local Carteira, Banco, Nome2, Sobrenome2, Registro, Celular, Idade, Emprego, Vip, Coins, Img, Banner = vSERVER.SeeInformationsProfile(SelectedPassportActions)
		CallBack({ retorno = "done", banco = Banco })
	end
end)




-- Parte dos change phone
-- Parte dos change phone
-- Parte dos change phone
RegisterNUICallback("trocarcelular",function(Data,CallBack)
	if vSERVER.ChangeNumberPhoneSelected(SelectedPassportActions,Data["celularnovo"]) then
		local Nome, Sobrenome, Imagem = vSERVER.ReturnNames()
		local Carteira, Banco, Nome2, Sobrenome2, Registro, Celular, Idade, Emprego, Vip, Coins, Img, Banner = vSERVER.SeeInformationsProfile(SelectedPassportActions)
		CallBack({retorno = "done",celular = Celular})
	end
end)




-- Parte dos screenshot
-- Parte dos screenshot
-- Parte dos screenshot
Screenshot = exports["screenshot-basic"]

function athdev.ScreenShotAction(ScreenShotLib,ScreenShotID)
    Screenshot:requestScreenshotUpload(ScreenShotLib, "files[]", function(Data)
       local ScreenShotURL = json.decode(Data)["attachments"][1]["url"]
       vSERVER.AddScreenShot(ScreenShotURL, ScreenShotID)
    end)
end

RegisterNUICallback("screenshot",function(Data,CallBack)
	if SelectedPassportActions then
		local ImageReturn,Ignore = vSERVER.TakeScreenshot(parseInt(SelectedPassportActions))
		CallBack({retorno = "done", imagem = ImageReturn})
	end
end)




-- Parte dos send message
-- Parte dos send message
-- Parte dos send message
RegisterNUICallback("enviarMensagem",function(Data,CallBack)
	if vSERVER.SendMessageStaff(SelectedPassportActions, Data["mensagem"]) then
		CallBack({retorno = "done"})
	end
end)




-- Parte dos skins
-- Parte dos skins
-- Parte dos skins
RegisterNUICallback("skinsLista",function(Data,CallBack)
	local SkinsList = vSERVER.ReturnSkinsList()
	if SkinsList then
		CallBack({ skins = SkinsList })
	end
end)

RegisterNUICallback("setarSkin",function(Data,CallBack)
	if vSERVER.SetSkinStaff(SelectedPassportActions, Data["set"]) then
		CallBack({retorno = "done"})
	end
end)

RegisterNetEvent("skinmenuwn")
AddEventHandler("skinmenuwn",function(mhash)
    while not HasModelLoaded(mhash) do
        RequestModel(mhash)
        Citizen.Wait(10)
    end

    if HasModelLoaded(mhash) then
        SetPlayerModel(PlayerId(),mhash)
        SetModelAsNoLongerNeeded(mhash)
    end
end)




-- Parte dos baús facs
-- Parte dos baús facs
-- Parte dos baús facs
local SelectedChestOrganization = ""

RegisterNUICallback("RegisterBauFac",function(Data,CallBack)
	SelectedChestOrganization = Data["bau"]
	CallBack({retorno = "done"})
end)

RegisterNUICallback("bausfacLista",function(Data,CallBack)
	local OrganizationsChestList = vSERVER.ReturnChestOrganizationsList()
	if OrganizationsChestList then
		CallBack({ bausfac = OrganizationsChestList })
	end
end)

RegisterNUICallback("verbausfacLista",function(Data,CallBack)
	local SelectedChestList = vSERVER.ReturnChestOrganizationSelected(SelectedChestOrganization)
	if SelectedChestList then
		CallBack({ verbausfac = SelectedChestList })
	end
end)

RegisterNUICallback("removerItemBauFac",function(Data,CallBack)
	if vSERVER.DeleteItemChestOrganization(SelectedChestOrganization,Data["item"],Data["quantidade"],Data["slot"]) then
		CallBack({retorno = "done"})
	end
end)




-- Parte dos groups
-- Parte dos groups
-- Parte dos groups
local OrganizationSelectedManagePart = ""

RegisterNUICallback("RegisterGroup",function(Data,CallBack)
	OrganizationSelectedManagePart = Data["empresa"]
	CallBack({retorno = "done"})
end)

RegisterNUICallback("verGrousList",function(Data,CallBack)
	local AllGroupsReturn = vSERVER.ReturnAllGroupsList()
	if AllGroupsReturn then
		CallBack({ groups = AllGroupsReturn })
	end
end)

RegisterNUICallback("verPlayersGroup",function(Data,CallBack)
	local PlayersFromOrganization = vSERVER.ReturnOrganizationListSelected(OrganizationSelectedManagePart)
	if PlayersFromOrganization then
		CallBack({ verPlayersGroup = PlayersFromOrganization })
	end
end)

RegisterNUICallback("gerenciarGrupos",function(Data,CallBack)
	vSERVER.ManageSelectedGroups(Data["passaporte"], OrganizationSelectedManagePart, Data["tipo"]) 
	CallBack({retorno = "done"})
end)




-- Parte dos punições
-- Parte dos punições
-- Parte dos punições
RegisterNUICallback("addBan",function(Data,CallBack)
	if vSERVER.AddBan(Data["motivo"],SelectedPassportActions) then
		CallBack({retorno = "done"})
	end
end)

RegisterNUICallback("addKick",function(Data,CallBack)
	if vSERVER.AddKick(Data["motivo"],SelectedPassportActions) then
		CallBack({retorno = "done"})
	end
end)

RegisterNUICallback("addAdv",function(Data,CallBack)
	if vSERVER.AddWarning(Data["motivo"],SelectedPassportActions) then
		CallBack({retorno = "done"})
	end
end)




-- Parte dos extras
-- Parte dos extras
-- Parte dos extras
RegisterNetEvent("TackleAdmin:Start")
AddEventHandler("TackleAdmin:Start",function()
	local Coords = GetEntityForwardVector(PlayerPedId())
	SetPedToRagdollWithFall(PlayerPedId(),10000,10000,0,Coords[1],Coords[2],Coords[3],10.0,0.0,0.0,0.0,0.0,0.0,0.0)
end)

RegisterNetEvent("StartEntity:Fire")
AddEventHandler("StartEntity:Fire",function()
	StartEntityFire(PlayerPedId())
end)

RegisterNetEvent("InitSpectate:Admin")
AddEventHandler("InitSpectate:Admin",function(source)
	if not NetworkIsInSpectatorMode() then
		local Pid = GetPlayerFromServerId(source)
		local Ped = GetPlayerPed(Pid)
		NetworkSetInSpectatorMode(true,Ped)
	end
end)

RegisterNetEvent("ResetSpect:Admin")
AddEventHandler("ResetSpect:Admin",function()
	if NetworkIsInSpectatorMode() then
		NetworkSetInSpectatorMode(false)
	end
end)