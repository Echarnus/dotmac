-- Keymaps are automatically loaded on the VeryLazy event
local keymap = vim.keymap

-- Neo-tree toggle on the right side
keymap.set("n", "<leader>e", "<cmd>Neotree toggle right<cr>", { desc = "Toggle Explorer (Right)" })

-- Quick navigation
keymap.set("n", "<leader>fe", "<cmd>Neotree focus right<cr>", { desc = "Focus Explorer" })
