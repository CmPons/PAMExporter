local function writeHeader(file, sprite)
	local spec = sprite.spec
	local width = spec.width
	local height = spec.height

	file:write("P7\n")
	file:write("WIDTH " .. width .. "\n")
	file:write("HEIGHT" .. height .. "\n")
	-- We assume RGBA
	file:write("DEPTH 4\n")
	-- Check this!
	-- According to documentation, this is correct https://www.aseprite.org/api/colormode#colormode
	file:write("MAXVAL 255\n")
	file:write("TUPLTYPE RGB_ALPHA\n")
	file:write("ENDHDR\n")
end

local function writePixels(file, sprite)
	local sprite_image = Image(sprite)
	for pixelValue in sprite_image:pixels() do
		local r = app.pixelColor.rgbaR(pixelValue())
		local g = app.pixelColor.rgbaG(pixelValue())
		local b = app.pixelColor.rgbaB(pixelValue())
		local a = app.pixelColor.rgbaA(pixelValue())
		file:write(r .. " " .. g .. " " .. b .. " " .. a .. "\n")
	end
end

local function exportFile(path, sprite)
	local file, err = io.open(path, "w+")

	if err ~= nil then
		if file then
			file:close()
		end
		return app.alert({ title = "Error", text = err })
	end
	writeHeader(file, sprite)
	writePixels(file, sprite)
	file:close()
end

function Main()
	local spr = app.activeSprite
	if not spr then
		return app.alert({ title = "Error", text = "You must have a file open in order to export!" })
	end

	if spr.spec.colorMode ~= ColorMode.RGB then
		return app.alert({
			title = "Error",
			text = "Sprite must be of Colormode RGB with Alpha. Other color modes, like grayscale are not supported!",
		})
	end

	local extension = app.fs.fileExtension(spr.filename)
	local sprite_filename = spr.filename:gsub(extension, "pam")

	local dlg = Dialog("PAM Exporter")
	dlg:file({
		id = "exportPath",
		title = "Export",
		open = false,
		save = true,
		filename = sprite_filename,
		filetypes = { "pam" },
	})
	dlg:button({
		id = "exportButton",
		text = "Export",
		onclick = function()
			exportFile(dlg.data.exportPath, spr)
		end,
	})
	dlg:show()
	local data = dlg.data
end

Main()
