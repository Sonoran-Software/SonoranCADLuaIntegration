RegisterNetEvent('SonoranCAD::core:TakeScreenshot', function()
	local unit = GetUnitByPlayerId(source)
	if unit == nil then
		debugLog('Unit not found')
		return
	end
	local screenshotDirectory = exports['sonorancad']:createScreenshotDirectory(tostring(unit.id))
	local screenshotName = exports['sonorancad']:createScreenshotFilename(screenshotDirectory)
	exports['screenshot-basic']:requestClientScreenshot(source, {
		fileName = screenshotDirectory .. '/' .. screenshotName
	}, function()
	end)
end)
