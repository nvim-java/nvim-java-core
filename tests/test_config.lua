local temp_path = '/tmp/nvim-java-test-plugins'

vim.opt.rtp:append(temp_path .. '/plenary.nvim')
vim.opt.rtp:append(temp_path .. '/nvim-lspconfig')
