---@class JavaConfig
---@field workspace_root string path to the root of workspaces
---@field root_markers string[] list of files that indicates the project root
local config = {
	workspace_root = vim.fn.stdpath('data') .. '/nvim-java/workspaces',

	root_markers = {
		'settings.gradle',
		'settings.gradle.kts',
		'pom.xml',
		'build.gradle',
		'mvnw',
		'gradlew',
		'build.gradle',
		'build.gradle.kts',
		'.git',
	},
}

return config
