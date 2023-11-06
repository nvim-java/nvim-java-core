# :construction: nvim-java (WIP)

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)
![Gradle](https://img.shields.io/badge/Gradle-02303A.svg?style=for-the-badge&logo=Gradle&logoColor=white)
![Apache Maven](https://img.shields.io/badge/Apache%20Maven-C71A36?style=for-the-badge&logo=Apache%20Maven&logoColor=white)

No need to put up with [jdtls](https://github.com/eclipse-jdtls/eclipse.jdt.ls) nonsense anymore.
Just install and start writing `public static void main(String[] args)`.

## Features

:white_check_mark: are supported features. :x: are pending features.

- :white_check_mark: Diagnostics & Auto Completion
- :white_check_mark: Automatic [DAP](https://github.com/mfussenegger/nvim-dap) debug configuration
- :x: Running tests

## Why

- Uses [nvim-lspconfig]() to setup `jdtls`
- Uses `jdtls` and auto loads `jdtls` plugins from [mason.nvim](https://github.com/williamboman/mason.nvim) (If they are installed)
  - Supported plugins are,
    - `lombok` (mason `jdtls` package contains the lombok jar. So no need to installed it separately)
    - `java-test`
    - `java-debug-adapter`
- Typed & documented APIs
- No callback hells I [promise](https://github.com/pyericz/promise-lua)

## How to Use

```lua
local java = require('java')
local dap = require("java.dap")

-- update dap config on attach event
dap.setup_dap_on_attach()

require('lspconfig').jdtls.setup(java.get_config())

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
		local buffer = args.buf

		-- add your language server keymaps here
	end,
	group = vim.api.nvim_create_augroup('LSP Keymaps', {}),
})
```
