CreateThread(function()
	Config.LoadPlugin('vehreg', function(pluginConfig)
		if pluginConfig.enabled then
			local placeholderReplace = function(message, placeholderTable)
				for k, v in pairs(placeholderTable) do
					message = message:gsub(k, v)
				end
				return message
			end
			RegisterNetEvent(GetCurrentResourceName() .. '::registerVeh', function(primary, plate, class, realName)
				local source = source
				local first = nil;
				local last = nil;
				local dob = nil;
				local sex = nil;
				local mi = nil;
				local age = nil;
				local aka = nil;
				local residence = nil;
				local zip = nil;
				local occupation = nil;
				local height = nil;
				local weight = nil;
				local skin = nil;
				local hair = nil;
				local eyes = nil;
				local emergencyContact = nil;
				local emergencyRelationship = nil;
				local emergencyContactNumber = nil;
				local img = nil;
				exports['sonorancad']:registerApiType('NEW_RECORD', 'general')
				exports['sonorancad']:registerApiType('GET_CHARACTERS', 'civilian')
				exports['sonorancad']:performApiRequest({
					{
						['apiId'] = GetIdentifiers(source)[Config.primaryIdentifier]
					}
				}, 'GET_CHARACTERS', function(res, err)
					if err == 404 then
						TriggerClientEvent('chat:addMessage', source, {
							color = {
								255,
								0,
								0
							},
							multiline = true,
							args = {
								'[CAD - ERROR] ',
								pluginConfig.language.noApiId
							}
						})
						return;
					else
						res = json.decode(res)
						first = res[1].sections[1].fields[1].value;
						last = res[1].sections[1].fields[2].value;
						mi = res[1].sections[1].fields[3].value;
						dob = res[1].sections[1].fields[4].value;
						age = res[1].sections[1].fields[5].value;
						sex = res[1].sections[1].fields[6].value;
						aka = res[1].sections[1].fields[7].value;
						residence = res[1].sections[1].fields[8].value;
						zip = res[1].sections[1].fields[9].value;
						occupation = res[1].sections[1].fields[10].value;
						height = res[1].sections[1].fields[11].value;
						weight = res[1].sections[1].fields[12].value;
						skin = res[1].sections[1].fields[13].value;
						hair = res[1].sections[1].fields[14].value;
						eyes = res[1].sections[1].fields[15].value;
						emergencyContact = res[1].sections[1].fields[16].value;
						emergencyRelationship = res[1].sections[1].fields[17].value;
						emergencyContactNumber = res[1].sections[1].fields[18].value;
						img = res[1].sections[1].fields[1].value;
					end
				end)
				Citizen.Wait(1000)
				if first ~= nil and last ~= nil then
					exports['sonorancad']:performApiRequest({
						{
							['user'] = GetIdentifiers(source)[Config.primaryIdentifier],
							['useDictionary'] = true,
							['recordTypeId'] = 5,
							['replaceValues'] = {
								['first'] = first,
								['last'] = last,
								['mi'] = mi,
								['dob'] = dob,
								['age'] = age,
								['sex'] = sex,
								['aka'] = aka,
								['residence'] = residence,
								['zip'] = zip,
								['occupation'] = occupation,
								['height'] = height,
								['weight'] = weight,
								['skin'] = skin,
								['hair'] = hair,
								['eyes'] = eyes,
								['emergencyContact'] = emergencyContact,
								['emergencyRelationship'] = emergencyRelationship,
								['emergencyContactNumber'] = emergencyContactNumber,
								['color'] = primary,
								['plate'] = plate,
								['type'] = class,
								['model'] = realName,
								['status'] = pluginConfig.defaultRegStatus,
								['_imtoih149'] = pluginConfig.defaultRegExpire,
								['img'] = img
							}
						}
					}, 'NEW_RECORD', function(res)
						res = tostring(res)
						if string.find(res, 'taken') ~= nil then
							TriggerClientEvent('chat:addMessage', source, {
								color = {
									255,
									0,
									0
								},
								multiline = true,
								args = {
									'[CAD - ERROR] ',
									pluginConfig.language.plateAlrRegisted
								}
							})
						else
							local placeHolders = {
								['{{PLATE}}'] = plate,
								['{{FIRST}}'] = first,
								['{{LAST}}'] = last
							}
							TriggerClientEvent('chat:addMessage', source, {
								color = {
									0,
									255,
									0
								},
								multiline = true,
								args = {
									'[CAD - SUCCESS] ',
									placeholderReplace(pluginConfig.language.successReg, placeHolders)
								}
							})
						end
					end)
				end
			end)
		end
	end)
end)
