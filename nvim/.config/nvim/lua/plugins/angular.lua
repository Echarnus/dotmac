return {
  -- TypeScript/JavaScript LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        angularls = {
          filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
          root_dir = require("lspconfig.util").root_pattern("angular.json", "project.json"),
        },
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
      },
    },
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript",
        "tsx",
        "javascript",
        "html",
        "css",
        "scss",
        "json",
      })
    end,
  },

  -- Auto-close and rename HTML tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {
      filetypes = {
        "html",
        "xml",
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
      },
    },
  },

  -- Emmet for HTML/CSS abbreviations
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "scss", "typescript", "typescriptreact" },
    init = function()
      vim.g.user_emmet_leader_key = "<C-z>"
      vim.g.user_emmet_settings = {
        typescript = {
          extends = "html",
        },
        typescriptreact = {
          extends = "html",
        },
      }
    end,
  },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = function(_, opts)
      require("luasnip.loaders.from_vscode").lazy_load()
      
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      
      ls.add_snippets("typescript", {
        s("ng-component", {
          t({"import { Component } from '@angular/core';", "", "@Component({", "  selector: '"}),
          i(1, "app-component"),
          t({"',", "  templateUrl: './"}),
          i(2, "component"),
          t({".component.html',", "  styleUrls: ['./"}),
          i(3, "component"),
          t({".component.scss']", "})", "export class "}),
          i(4, "Component"),
          t({" {", "  "}),
          i(0),
          t({"", "}"})
        }),
        s("ng-service", {
          t({"import { Injectable } from '@angular/core';", "", "@Injectable({", "  providedIn: 'root'", "})", "export class "}),
          i(1, "Service"),
          t({" {", "  constructor() { }", "", "  "}),
          i(0),
          t({"", "}"})
        }),
        s("ng-module", {
          t({"import { NgModule } from '@angular/core';", "", "@NgModule({", "  declarations: ["}),
          i(1),
          t({"],", "  imports: ["}),
          i(2),
          t({"],", "  providers: ["}),
          i(3),
          t({"],", "  exports: ["}),
          i(4),
          t({"]", "})", "export class "}),
          i(5, "Module"),
          t({" { }"})
        }),
      })
    end,
  },

  -- Conform for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
      },
    },
  },

  -- Telescope extensions for Angular
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>ac",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Angular Components",
            find_command = { "rg", "--files", "--glob", "*.component.ts" },
          })
        end,
        desc = "Find Angular Components",
      },
      {
        "<leader>as",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Angular Services",
            find_command = { "rg", "--files", "--glob", "*.service.ts" },
          })
        end,
        desc = "Find Angular Services",
      },
      {
        "<leader>am",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Angular Modules",
            find_command = { "rg", "--files", "--glob", "*.module.ts" },
          })
        end,
        desc = "Find Angular Modules",
      },
      {
        "<leader>at",
        function()
          local current_file = vim.fn.expand("%:t:r")
          local base_name = current_file:gsub("%.component$", ""):gsub("%.service$", ""):gsub("%.spec$", "")
          require("telescope.builtin").find_files({
            prompt_title = "Related Angular Files",
            default_text = base_name,
          })
        end,
        desc = "Find Related Angular Files",
      },
    },
  },

  -- Which-key integration for Angular keymaps
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>a"] = { name = "+angular" },
      },
    },
  },
}
