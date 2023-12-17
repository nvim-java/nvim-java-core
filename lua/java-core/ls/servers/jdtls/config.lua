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
	}
end

return M
