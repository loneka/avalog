local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")

local DEFINITIONS_URL = "https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau"
local DEFINITIONS_DIR = ".luau-lsp"
local DEFINITIONS_PATH = `{DEFINITIONS_DIR}/globalTypes.d.luau`

local function run(program: string, args: { string }): boolean
	print(`\n> {program} {table.concat(args, " ")}`)
	local result = process.exec(program, args, { env = process.env, stdio = "forward" })
	return result.ok
end

local function ensureDefinitions()
	if fs.isFile(DEFINITIONS_PATH) then
		return
	end

	print(`Downloading Roblox type definitions to {DEFINITIONS_PATH}`)
	local response = net.request(DEFINITIONS_URL)
	if not response.ok then
		error(`Failed to download definitions: {response.statusCode} {response.statusMessage}`)
	end

	if not fs.isDir(DEFINITIONS_DIR) then
		fs.writeDir(DEFINITIONS_DIR)
	end
	fs.writeFile(DEFINITIONS_PATH, response.body)
end

if not run("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" }) then
	process.exit(1)
end

ensureDefinitions()

local checks = {
	{
		name = "luau-lsp",
		program = "luau-lsp",
		args = {
			"analyze",
			"--platform=roblox",
			"--sourcemap=sourcemap.json",
			`--definitions=@roblox={DEFINITIONS_PATH}`,
			"--base-luaurc=.luaurc",
			"--ignore=Packages/**",
			"src",
		},
	},
	{ name = "stylua", program = "stylua", args = { "--check", "src" } },
	{ name = "selene", program = "selene", args = { "src" } },
}

local failed = {}
for _, check in checks do
	if not run(check.program, check.args) then
		table.insert(failed, check.name)
	end
end

print()
if #failed > 0 then
	print(`Failed: {table.concat(failed, ", ")}`)
	process.exit(1)
end

print("All checks passed.")
