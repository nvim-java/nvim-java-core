local M = {}

function M.get_config()
	return {
		init_options = {
			extendedClientCapabilities = {
				classFileContentsSupport = true,
				generateToStringPromptSupport = true,
				hashCodeEqualsPromptSupport = true,
				advancedExtractRefactoringSupport = true,
				advancedOrganizeImportsSupport = true,
				generateConstructorsPromptSupport = true,
				generateDelegateMethodsPromptSupport = true,
				moveRefactoringSupport = true,
				overrideMethodsPromptSupport = true,
				executeClientCommandSupport = true,
				inferSelectionSupport = {
					'extractMethod',
					'extractVariable',
					'extractConstant',
					'extractVariableAllOccurrence',
				},
			},
		},

		handlers = {
			--@TODO
			--overriding '$/progress' is necessary because by default it's using the
			--lspconfig progress handler which prints the wrong value in the latest
			--jdtls version (tested on 1.29.0).
			--https://github.com/neovim/nvim-lspconfig/issues/2897
			['$/progress'] = vim.lsp.handlers['$/progress'],
		},
	}
end

return M
