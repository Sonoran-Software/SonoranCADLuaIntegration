latestFrame = {};

RegisterNetEvent('SonoranCAD::core:TakeScreenshot', function()
	local source = source
	local unit = GetUnitByPlayerId(source)
	if unit == nil then
		debugLog('Unit not found')
		-- TriggerClientEvent('SonoranCAD::core::ScreenshotOff', source)
		return
	end
	local screenshotDirectory = exports['sonorancad']:createScreenshotDirectory(tostring(unit.id))
	local screenshotName = exports['sonorancad']:createScreenshotFilename(screenshotDirectory)
	local frameName = screenshotName:gsub("%.jpg$", "")
	latestFrame[source] = tonumber(frameName)
	exports['screenshot-basic']:requestClientScreenshot(source, {
		fileName = screenshotDirectory .. '/' .. screenshotName,
		quality = 0.5
	}, function()
	end)
end)

RegisterNetEvent('SonoranCAD::core::bodyCamOff', function()
	local source = source
	latestFrame[source] = nil
	local unit = GetUnitByPlayerId(source)
	if unit == nil then
		debugLog('Unit not found')
		-- TriggerClientEvent('SonoranCAD::core::ScreenshotOff', source)
		return
	end
	local screenshotDirectory = exports['sonorancad']:createScreenshotDirectory(tostring(unit.id))
	exports['sonorancad']:deleteDirectory(screenshotDirectory)
end)