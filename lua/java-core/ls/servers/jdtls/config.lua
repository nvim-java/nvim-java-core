local M = {}

function M.get_config()
	return {
		init_options = {
			extendedClientCapabilities = {
				actionableRuntimeNotificationSupport = true,
				advancedExtractRefactoringSupport = true,
				advancedGenerateAccessorsSupport = true,
				advancedIntroduceParameterRefactoringSupport = true,
				advancedOrganizeImportsSupport = true,
				advancedUpgradeGradleSupport = true,
				classFileContentsSupport = true,
				clientDocumentSymbolProvider = true,
				clientHoverProvider = true,
				executeClientCommandSupport = true,
				extractInterfaceSupport = true,
				generateConstructorsPromptSupport = true,
				generateDelegateMethodsPromptSupport = true,
				generateToStringPromptSupport = true,
				gradleChecksumWrapperPromptSupport = true,
				hashCodeEqualsPromptSupport = true,
				inferSelectionSupport = {
					'extractConstant',
					'extractField',
					'extractInterface',
					'extractMethod',
					'extractVariableAllOccurrence',
					'extractVariable',
				},
				moveRefactoringSupport = true,
				onCompletionItemSelectedCommand = 'editor.action.triggerParameterHints',
				overrideMethodsPromptSupport = true,
			},
		},
	}
end

return M
