local M = {}
---@class InitializationOptions
---@field bundles? string[]
---@field workspaceFolders? string
---@field settings? JavaConfigurationSettings

---@class JavaConfigurationSettings
---@field java? JavaConfiguration

---@class JavaConfiguration
---@field autobuild? EnabledOption
---@field cleanup? CleanUpOption
---@field codeGeneration CodeGenerationOption
---@field codeAction CodeActionOption
---@field completion CompletionOptions
---@field configuration? ConfigurationOptions
---@field contentProvider? ContentProvider
---@field eclipse? EclipseOptions
---@field errors? ErrorsOptions
---@field executeCommand? EnabledOption
---@field foldingRange? EnabledOption
---@field format? FormatOption
---@field home? string
---@field implementationsCodeLens? EnabledOption
---@field import? ImportOption
---@field inlayhints? InlayHints
---@field jdt? JDTOptions
---@field maven? MavenOptions
---@field maxConcurrentBuilds? number
---@field memberSortOrder? string
---@field project? ProjectOptions
---@field quickfix? QuickFixOption
---@field referenceCodeLens? EnabledOption
---@field references? ReferencesOption
---@field rename? EnabledOption
---@field saveActions? SaveActions
---@field selectionRange? EnabledOption
---@field settings? SettingsOption
---@field signatureHelp? SignatureHelpOption
---@field sources? SourcesOption
---@field symbols? SymbolsOption
---@field templates? TemplatesOption
---@field trace? TraceOptions
---@field edit? EditOption

---@enum CleanUpOnSaveActions
M.CleanUpOnSaveActions = {
	qualifyMembers = 'qualifyMembers',
	qualifyStaticMembers = 'qualifyStaticMembers',
	addOverride = 'addOverride',
	addDeprecated = 'addDeprecated',
	stringConcatToTextBlock = 'stringConcatToTextBlock',
	invertEquals = 'invertEquals',
	addFinalModifier = 'addFinalModifier',
	instanceofPatternMatch = 'instanceofPatternMatch',
	lambdaExpression = 'lambdaExpression',
	switchExpression = 'switchExpression',
}

---@class CleanUpOption
---@field actionsOnSave? CleanUpOnSaveActions

---@class CodeActionOption
---@field sortMembers SortMembersOption

---@class CodeGenerationOption
---@field generateComments? boolean
---@field hashCodeEquals? HashCodeOption
---@field insertionLocation? string
---@field toString? ToStringOption
---@field useBlocks? boolean

---@enum CompletionMatchCaseOption
M.CompletionMatchCaseOption = {
	off = 'OFF',
	firstletter = 'FIRSTLETTER',
}

---@class CompletionOptions
---@field enabled? boolean
---@field favoriteStaticMembers? string
---@field filteredTypes? string
---@field guessMethodArguments? boolean
---@field importOrder? string
---@field matchCase? CompletionMatchCaseOption
---@field maxResults? number
---@field overwrite? boolean
---@field postfix? EnabledOption

---@class ConfigurationOptions
---@field maven? MavenOption
---@field runtimes? RuntimeOption[]
---@field updateBuildConfiguration UpdateBuildConfigurationKind

---@class ContentProvider
---@field preferred string

---@class EclipseOptions
---@field downloadSources boolean

---@enum ExecutionEnvironment
M.ExecutionEnvironment = {
	J2SE_1_5 = 'J2SE-1.5',
	JavaSE_1_6 = 'JavaSE-1.6',
	JavaSE_1_7 = 'JavaSE-1.7',
	JavaSE_1_8 = 'JavaSE-1.8',
	JavaSE_9 = 'JavaSE-9',
	JavaSE_10 = 'JavaSE-10',
	JavaSE_11 = 'JavaSE-11',
	JavaSE_12 = 'JavaSE-12',
	JavaSE_13 = 'JavaSE-13',
	JavaSE_14 = 'JavaSE-14',
	JavaSE_15 = 'JavaSE-15',
	JavaSE_16 = 'JavaSE-16',
	JavaSE_17 = 'JavaSE-17',
	JavaSE_18 = 'JavaSE-18',
	JAVASE_19 = 'JavaSE-19',
}

---@class EnabledOption
---@field enabled boolean

---@class ErrorsOptions
---@field incompleteClasspath IncompleteClasspath

---@class FormatOption
---@field comments? EnabledOption
---@field enabled? boolean
---@field insertSpaces? boolean
---@field onType? EnabledOption
---@field settings? FormatSettingsOption
---@field tabSize? number

---@class FormatSettingsOption
---@field profile? string
---@field url? string

---@class GradleOption
---@field annotationProcessing? EnabledOption
---@field arguments? string
---@field enabled? boolean
---@field home? string
---@field java? HomeOption
---@field jvmArguments? string
---@field offline? EnabledOption
---@field user? HomeOption
---@field version? string
---@field wrapper? GradleWrapperOption

---@class GradleWrapperOption
---@field enabled? boolean
---@field checksums? string

---@class HashCodeOption
---@field useInstanceof? boolean
---@field useJava7Objects? boolean

---@class HomeOption
---@field home string

---@class ImportOption
---@field exclusions string
---@field gradle? GradleOption
---@field maven? MavenImportOption

---@class ImportsOption

---@class IncompleteClasspath
---@field severity SeverityKind

---@class InlayHints
---@field parameterNames ParameterNamesOption

---@class JDTLSOptions
---@field androidSupport? EnabledOption
---@field lombokSupport? EnabledOption
---@field protofBufSupport? EnabledOption

---@class JDTOptions
---@field ls? JDTLSOptions

---@class OrganizeImportsOption
---@field starThreshold? number
---@field staticStarThreshold? number

---@class QuickFixOption
---@field showAt string

---@class MavenOption
---@field userSettings? string
---@field globalSettings? string
---@field notCoveredPluginExecutionSeverity? string

---@class MavenImportOption
---@field enabled? boolean
---@field offline? EnabledOption

---@class MavenOptions
---@field downloadSources? boolean
---@field updateSnapshots? boolean

---@class ParameterNamesOption
---@field enabled boolean
---@field exclusions? string

---@enum ProjectEncodingOption
M.ProjectEncodingOption = {
	ignore = 'IGNORE',
	warning = 'WARNING',
	setdefault = 'SETDEFAULT',
}

---@class ProjectOptions
---@field encoding? ProjectEncodingOption
---@field outputPath? string
---@field referencedLibraries? string
---@field resourceFilters? string
---@field sourcePaths? string

---@class ReferencedLibrariesOption
---@field exclude? string
---@field include string
---@field sources? SourceOption

---@class ReferencesOption
---@field includeAccessors? boolean
---@field includeDecompiledSources? boolean

---@class RuntimeOption
---@field name ExecutionEnvironment
---@field path string
---@field javadoc? string
---@field sources? string
---@field default? boolean

---@class SaveActions
---@field organizeImports boolean

---@class SettingsOption
---@field url? string

---@enum SeverityKind
M.SeverityKind = {
	ignore = 'ignore',
	info = 'info',
	warning = 'warning',
	error = 'error',
}

---@class SignatureHelpOption
---@field enabled boolean
---@field description? EnabledOption

---@class SortMembersOption
---@field avoidVolatileChanges? boolean

---@class SourceOption
---@field library string
---@field source string

---@class SourcesOption
---@field organizeImports OrganizeImportsOption

---@class SymbolsOption
---@field includeSourceMethodDeclarations? boolean

---@class TemplatesOption
---@field fileHeader? string
---@field typeComment? string

---@class ToStringOption
---@field codeStyle? string
---@field limitElements? number
---@field listArrayContents? boolean
---@field skipNullValues? boolean
---@field template? string

---@class TraceOptions
---@field server TraceKind

---@enum TraceKind
M.TraceKind = {
	off = 'off',
	messages = 'messages',
	verbose = 'verbose',
}

---@enum UpdateBuildConfigurationKind
M.UpdateBuildConfigurationKind = {
	disabled = 'disabled',
	interactive = 'interactive',
	automatic = 'automatic',
}

---@class EditOption
---@field validateAllOpenBuffersOnChanges? boolean

return M
