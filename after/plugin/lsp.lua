-- Native Neovim 0.11+ LSP with nvim-cmp completion and native snippets.
-- Language servers themselves are external programs and must be installed
-- separately; this file only configures Neovim to use them.

local mason_ok, mason = pcall(require, "mason")
if mason_ok then
  mason.setup()
end

vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.diagnostic.config({
  -- End-of-line virtual text is clipped when a diagnostic is wider than the
  -- editor. Render the complete message as wrapped virtual lines instead.
  virtual_text = false,
  virtual_lines = {
    overflow = "wrap",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
    severity_sort = true,
  },
})

local lsp_group = vim.api.nvim_create_augroup("ksnvim_lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local opts = { buffer = args.buf, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, {
      desc = "LSP: go to definition",
    }))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, {
      desc = "LSP: go to declaration",
    }))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, {
      desc = "LSP: go to implementation",
    }))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, {
      desc = "LSP: hover documentation",
    }))
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, {
      desc = "LSP: code action",
    }))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, {
      desc = "LSP: rename",
    }))
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ bufnr = args.buf })
    end, vim.tbl_extend("force", opts, { desc = "LSP: format buffer" }))

  end,
})

-- Neovim provides the LSP client, but not language-server executables. These
-- configs are intentionally direct, so lsp-zero, Mason, and nvim-lspconfig
-- are not required. A server is enabled only when its executable is present.
local function resolve_go_binary(name)
  local path = vim.fn.exepath(name)
  if path ~= "" then
    return path
  end

  for _, candidate in ipairs({
    vim.fn.expand("~/.go/bin/" .. name),
    vim.fn.expand("~/go/bin/" .. name),
  }) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return name
end

local gopls = resolve_go_binary("gopls")
local terraform_ls = resolve_go_binary("terraform-ls")
local helm_ls = resolve_go_binary("helm_ls")
local yaml_ls = vim.fn.exepath("yaml-language-server")
local actions_ls = vim.fn.exepath("actions-languageserver")
local function github_actions_init_options()
  -- The server expects initializationOptions to exist even when GitHub
  -- authentication is unavailable. Keep authentication disabled by default;
  -- no credentials are read or sent from this configuration.
  return { sessionToken = "", repos = {} }
end
local yaml_schemas = {}
local schemastore_ok, schemastore = pcall(require, "schemastore")
if schemastore_ok then
  yaml_schemas = schemastore.yaml.schemas()
end

local servers = {
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  },

  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    },
  },

  gopls = {
    cmd = { gopls ~= "" and gopls or "gopls" },
    filetypes = { "go", "gomod", "gowork" },
    root_markers = { "go.work", "go.mod", ".git" },
    workspace_required = false,
    settings = {
      gopls = {
        semanticTokens = true,
        gofumpt = true,
      },
    },
  },

  terraformls = {
    cmd = { terraform_ls, "serve" },
    filetypes = {
      "terraform",
      "terraform-vars",
    },
    root_markers = { ".terraform", ".git" },
    workspace_required = false,
  },

  yamlls = {
    cmd = { yaml_ls ~= "" and yaml_ls or "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
    root_markers = { ".git" },
    workspace_required = false,
    settings = {
      yaml = {
        validate = true,
        completion = true,
        format = { enable = true },
        schemaStore = { enable = false, url = "" },
        schemas = yaml_schemas,
        -- Useful for Kubernetes and Crossplane manifests. Project-specific
        -- CRDs can still be attached with a yaml-language-server modeline.
        kubernetesCRDStore = { enable = true },
      },
    },
  },

  gh_actions_ls = {
    cmd = { actions_ls ~= "" and actions_ls or "actions-languageserver", "--stdio" },
    filetypes = { "yaml.ghactions" },
    root_markers = { ".github", ".git" },
    workspace_required = false,
    init_options = github_actions_init_options(),
  },

  helm_ls = {
    cmd = { helm_ls, "serve" },
    filetypes = { "helm", "helmfile" },
    root_markers = { "Chart.yaml", ".git" },
    workspace_required = false,
    settings = {
      ["helm-ls"] = {
        yamlls = {
          enabled = true,
          path = yaml_ls ~= "" and yaml_ls or "yaml-language-server",
          config = {
            completion = true,
            hover = true,
            schemas = { kubernetes = "templates/**" },
          },
        },
      },
    },
  },

  ansiblels = {
    cmd = { "ansible-language-server", "--stdio" },
    filetypes = { "yaml.ansible" },
    root_markers = { "ansible.cfg", ".ansible-lint", ".git" },
    settings = {
      ansible = {
        ansible = { path = "ansible" },
        python = { interpreterPath = "python" },
        validation = {
          enabled = true,
          lint = { enabled = true, path = "ansible-lint" },
        },
      },
    },
  },

  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash", "zsh" },
    root_markers = { ".git" },
    workspace_required = false,
  },

  dockerls = {
    cmd = { "docker-langserver", "--stdio" },
    filetypes = { "dockerfile" },
    root_markers = { "Dockerfile", ".git" },
    workspace_required = false,
  },

  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { "package.json", ".git" },
    workspace_required = false,
  },

  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luacheckrc", ".git" },
    workspace_required = false,
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },

  taplo = {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { "taplo.toml", ".git" },
    workspace_required = false,
  },

  marksman = {
    cmd = { "marksman", "server" },
    filetypes = { "markdown" },
    root_markers = { ".git" },
    workspace_required = false,
  },

  kcl = {
    cmd = { "kcl-language-server" },
    filetypes = { "kcl" },
    root_markers = { "kcl.mod", "kcl.yaml", ".git" },
  },
}

-- KCL, Helm templates, and common Ansible files are not detected by every
-- Neovim runtime by default.
vim.filetype.add({
  extension = {
    kcl = "kcl",
    mdx = "markdown",
    -- Neovim 0.12 detects .tf as `tf`; map it to terraform-ls' filetype.
    tf = "terraform",
    tfvars = "terraform-vars",
  },
  filename = {
    ["helmfile.yaml"] = "helmfile",
    ["helmfile.yml"] = "helmfile",
    ["playbook.yaml"] = "yaml.ansible",
    ["playbook.yml"] = "yaml.ansible",
    ["site.yaml"] = "yaml.ansible",
    ["site.yml"] = "yaml.ansible",
  },
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghactions",
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.yml"] = "helm",
    [".*/roles/.*/tasks/.*%.yaml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.yml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.yaml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.yml"] = "yaml.ansible",
    [".*/playbook/.*%.yaml"] = "yaml.ansible",
    [".*/playbook/.*%.yml"] = "yaml.ansible",
    [".*/playbooks/.*%.yaml"] = "yaml.ansible",
    [".*/playbooks/.*%.yml"] = "yaml.ansible",
  },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
else
  capabilities.textDocument.completion.completionItem.snippetSupport = true
end
vim.lsp.config("*", { capabilities = capabilities })

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  if vim.fn.executable(config.cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end

-- Ask before installing a missing server when a supported filetype is opened.
-- Mason remains optional: without it, the native LSP setup still works with
-- servers installed elsewhere on PATH.
if mason_ok then
  local package_for_filetype = {
    javascript = { package = "typescript-language-server", server = "ts_ls" },
    javascriptreact = { package = "typescript-language-server", server = "ts_ls" },
    typescript = { package = "typescript-language-server", server = "ts_ls" },
    typescriptreact = { package = "typescript-language-server", server = "ts_ls" },
    python = { package = "pyright", server = "pyright" },
    go = { package = "gopls", server = "gopls" },
    gomod = { package = "gopls", server = "gopls" },
    gowork = { package = "gopls", server = "gopls" },
    terraform = { package = "terraform-ls", server = "terraformls" },
    ["terraform-vars"] = { package = "terraform-ls", server = "terraformls" },
    yaml = { package = "yaml-language-server", server = "yamlls" },
    ["yaml.ghactions"] = { package = "gh-actions-language-server", server = "gh_actions_ls" },
    helm = { package = "helm-ls", server = "helm_ls" },
    helmfile = { package = "helm-ls", server = "helm_ls" },
    ["yaml.ansible"] = { package = "ansible-language-server", server = "ansiblels" },
    sh = { package = "bash-language-server", server = "bashls" },
    bash = { package = "bash-language-server", server = "bashls" },
    zsh = { package = "bash-language-server", server = "bashls" },
    dockerfile = { package = "dockerfile-language-server", server = "dockerls" },
    json = { package = "json-lsp", server = "jsonls" },
    jsonc = { package = "json-lsp", server = "jsonls" },
    lua = { package = "lua-language-server", server = "lua_ls" },
    toml = { package = "taplo", server = "taplo" },
    markdown = { package = "marksman", server = "marksman" },
    kcl = { package = "kcl-language-server", server = "kcl" },
  }

  local prompted = {}
  local function prompt_for_server(bufnr, filetype)
    local requested = package_for_filetype[filetype]
    if not requested or prompted[requested.package] then
      return
    end

    local config = servers[requested.server]
    if not config or vim.fn.executable(config.cmd[1]) == 1 then
      return
    end

    prompted[requested.package] = true
    local registry = require("mason-registry")
    registry.refresh(function()
      if registry.is_installed(requested.package) then
        vim.lsp.enable(requested.server)
        return
      end

      if not registry.has_package(requested.package) then
        vim.notify(
          ("No Mason package is available for %s. Install it manually."):format(requested.package),
          vim.log.levels.WARN
        )
        return
      end

      vim.schedule(function()
        vim.ui.select({ "Install", "Skip" }, {
          prompt = ("Install %s for %s?"):format(requested.package, filetype),
        }, function(choice)
          if choice ~= "Install" then
            return
          end

          local package = registry.get_package(requested.package)
          package:install():once("closed", function()
            vim.schedule(function()
              if package:is_installed() then
                vim.notify(("Installed %s"):format(requested.package), vim.log.levels.INFO)
                vim.lsp.enable(requested.server)
              else
                vim.notify(("Failed to install %s"):format(requested.package), vim.log.levels.ERROR)
              end
            end)
          end)
        end)
      end)
    end)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = lsp_group,
    callback = function(args)
      prompt_for_server(args.buf, vim.bo[args.buf].filetype)
    end,
  })

  vim.schedule(function()
    if vim.bo.filetype ~= "" then
      prompt_for_server(0, vim.bo.filetype)
    end
  end)
end
