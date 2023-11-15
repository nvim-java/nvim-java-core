---@class LSPSetupConfig
---@field root_dir fun(filename: string, bufnr: number): string | nil Returns either a filepath (string) or nil. The language server will only start if the function returns a filepath.
---@field name? string Defaults to the server's name (`clangd`, `pyright`, etc.).
---@field filetypes string[] | nil Set of filetypes for which to attempt to resolve {root_dir}
---@field autostart? boolean Controls if the `FileType` autocommand that launches a language server is created. If `false`, allows for deferring language servers until manually launched with `:LspStart` (|lspconfig-commands|).
---@field single_file_support? boolean Determines if a server is started without a matching root directory. See |lspconfig-single-file-support|.
---@field on_new_config fun(new_config: LSPSetupConfig, new_root_dir: string) Function executed after a root directory is detected. This is used to modify the server configuration (including `cmd` itself). Most commonly, this is used to inject additional arguments into `cmd`.
---@field capabilities table<string, string|table|boolean|function> a table which represents the neovim client capabilities. Useful for broadcasting to the server additional functionality (snippets, off-protocol features) provided by plugins.
---@field cmd string[] a list where each entry corresponds to the blankspace delimited part of the command that launches the server. The first entry is the binary used to run the language server. Additional entries are passed as arguments.
---@field handlers table<string, function> a list of handlers which override the function used to process a response from a given language server. Applied only to the server referenced by setup. See |lsp-handler|.
---@field init_options { bundles?: string[], workspaceFolders?: string, settings?: JavaConfigurationSettings, extendedClientCapabilities: table<string, string|boolean|table> }
---@field on_attach fun(client: object, bufnr: number) Callback invoked by Nvim's built-in client when attaching a buffer to a language server. Often used to set Nvim (buffer or global) options or to override the Nvim client properties (`server_capabilities`) after a language server attaches. Most commonly used for settings buffer local keybindings. See |lspconfig-keybindings| for a usage example.
---@field settings table <string, string|table|boolean> The `settings` table is sent in `on_init` via a `workspace/didChangeConfiguration` notification from the Nvim client to the language server. These settings allow a user to change optional runtime settings of the language server.

---@class LSPClientRequestParameters
---@field command string
---@field arguments string | string[] | nil

---@class LSPClientResponse
---@field err LSPClientResponseError

---@class LSPClientResponseError
---@field code number
---@field message string

---@class LSPClient
---@field attached_buffers table<number, boolean>
---@field cancel_request function
---@field commands any[]
---@field config LSPSetupConfig
---@field handlers {[string]: function}
---@field id number
---@field initialized boolean
---@field is_stopped fun(): boolean
---@field messages object
---@field name string
---@field notify fun(method: string, params: object): boolean
---@field offset_encoding string
---@field request fun(method: string, params: LSPClientRequestParameters, callback: fun(err: any, result: any), bufnr?: number): any
---@field request_sync function
---@field requests object
---@field rpc object
---@field server_capabilities object
---@field stop function
---@field supports_method function
---@field workspace_did_change_configuration function
---@field workspace_folders table
