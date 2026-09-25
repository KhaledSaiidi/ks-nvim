# KS Neovim Configuration

KS Neovim is a portable, GitHub-ready Neovim configuration for software,
platform, and DevOps engineering. It is designed to be cloned and used as a
personal editor setup, with first-class support for Python, Go, TypeScript,
Terraform/HCL, Kubernetes, Helm, YAML, Ansible, Shell, Docker, and KCL.

The repository documents the complete keymap and configuration layout so the
setup can be reproduced, maintained, and adapted across machines.

The configuration uses `lazy.nvim`, native Neovim 0.11+ LSP, Mason, Treesitter,
`nvim-cmp`, Telescope, Harpoon, Fugitive, GitSigns, Conform, and Oil.
`mini.icons` provides consistent icons for Which-Key and the file-oriented UI.
`nvim-lint` adds policy/IaC diagnostics, while Overseer runs project commands in
an interactive task list.

## Basics

The leader key is `<Space>`.

Notation used below:

- `n` = Normal mode
- `v` = Visual mode
- `i` = Insert mode
- `LSP` = available after a language server attaches to the buffer
- `Oil` = available inside an Oil file-explorer buffer

Use `<Space>` by itself to open the Which-Key menu and discover available
leader-key commands.

Line numbers are enabled globally for every buffer. The UI also uses a dark,
transparent presentation with Treesitter highlighting where a parser is
available.

## File navigation and search

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `<leader>pv` | Open the legacy netrw explorer |
| `n` | `<leader>e` | Open the Oil file explorer |
| `n` | `-` | Open the current file's parent directory in Oil |
| `n` | `<leader>pf` | Find files with Telescope |
| `n` | `<C-p>` | Search Git-tracked files with Telescope |
| `n` | `<leader>ps` | Search text; prompts for a grep string |

Inside Oil, the plugin's standard actions remain available. Use `g?` inside an
Oil buffer to display its complete action list.

## Completion and snippets

Completion is provided by `nvim-cmp` using the native Neovim snippet engine and
LSP completion sources.

| Mode | Mapping | Action |
| --- | --- | --- |
| `i` | `<C-Space>` | Trigger completion manually |
| `i` / `s` | `<Tab>` | Select next item, expand/jump through a snippet, or trigger completion |
| `i` / `s` | `<S-Tab>` | Select previous item or jump to the previous snippet field |
| `i` | `<CR>` | Confirm the selected completion item |
| `i` | `<C-e>` | Abort the completion menu |

Completion is also enabled for `/`, `?`, and `:` command-line input.

## LSP

These mappings are buffer-local and appear when an LSP server attaches:

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `gd` | Go to definition |
| `n` | `gD` | Go to declaration |
| `n` | `gi` | Go to implementation |
| `n` | `K` | Show hover documentation |
| `n` | `<leader>ca` | Code action |
| `n` | `<leader>rn` | Rename symbol |
| `n` | `<leader>f` | Format using the attached LSP |

GitHub Actions workflow files under `.github/workflows/` are detected as
`yaml.ghactions` and use the dedicated `gh_actions_ls` server, while ordinary
YAML continues to use `yamlls`.

Configured servers:

| Server | File types / purpose |
| --- | --- |
| `ts_ls` | JavaScript and TypeScript |
| `pyright` | Python |
| `gopls` | Go, Go modules, and Go workspaces |
| `terraformls` | Terraform and `.tfvars` |
| `yamlls` | YAML, including Kubernetes and Crossplane schemas |
| `gh_actions_ls` | GitHub Actions workflows |
| `helm_ls` | Helm templates and Helmfile |
| `ansiblels` | Ansible playbooks, tasks, and handlers |
| `bashls` | Shell, Bash, and Zsh |
| `dockerls` | Dockerfiles |
| `jsonls` | JSON and JSONC |
| `lua_ls` | Neovim/Lua configuration |
| `taplo` | TOML |
| `marksman` | Markdown |
| `kcl` | KCL, when `kcl-language-server` is installed |

When a supported file is opened and its server is missing, the configuration
asks whether Mason should install the associated package. Servers that are
already installed or available on `PATH` attach automatically.

## Formatting

Conform formats supported files automatically on save when the formatter is
available.

| Mode | Mapping / command | Action |
| --- | --- | --- |
| `n` / `v` | `<leader>lf` | Format the current buffer |
| `n` | `:FormatDisable` | Disable format-on-save for the current buffer |
| `n` | `:FormatDisable!` | Re-enable format-on-save for the current buffer |

Configured formatters include `ruff`, `gofumpt`, `prettier`, `yamlfmt`,
`terraform_fmt`, `hclfmt`, `shfmt`, `stylua`, and `taplo`.

The LSP filetype layer maps `.tf` files to `terraform` and `.tfvars` files to
`terraform-vars`, so Terraform completion and diagnostics attach correctly on
current Neovim versions.

Helm templates are intentionally not automatically formatted because their Go
template syntax is not valid standalone YAML. Helm LSP support remains active.

## Linting and platform validation

Linters run on buffer enter, insert leave, and after saving. They complement
LSP diagnostics with policy and IaC checks.

| File type | Linters |
| --- | --- |
| Python | `ruff` |
| Go | `golangci-lint` |
| Terraform | `tflint` |
| YAML/Kubernetes | `yamllint`, `kube-linter` |
| Ansible YAML | `yamllint`, `ansible-lint` |
| GitHub Actions | `actionlint`, `yamllint` |
| Dockerfile | `hadolint` |
| Shell | `shellcheck` |

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `<leader>ll` | Run linters for the current buffer |
| `n` | `<leader>le` | Show diagnostics under the cursor |
| `n` | `]d` / `[d` | Next / previous diagnostic |

Kubernetes and Crossplane YAML use SchemaStore plus Neovim's Kubernetes CRD
store. Project-specific Crossplane CRDs can be added with a
`yaml-language-server` modeline or a project YAML schema configuration.

## Platform task runner

Overseer provides an interactive, project-local task runner. It discovers
available read-only platform tasks automatically when their command exists.
The built-in tasks include `terraform validate`, `terraform plan`,
`terragrunt plan`, `helm lint .`, `kube-linter lint .`, `ansible-lint`, and
read-only Kubernetes queries. Mutating commands such as `terraform apply` and
`kubectl delete` are intentionally not registered.

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `<leader>ot` | Toggle the task list |
| `n` | `<leader>or` | Select and run a task |
| `n` | `<leader>oa` | Open actions for the selected task |

## Git

### Fugitive and Diffview

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `<leader>gs` | Open Fugitive Git status |
| `n` | `<leader>gdo` | Open Diffview |
| `n` | `<leader>gdc` | Close Diffview |
| `n` | `<leader>gdh` | Show file history in Diffview |

### GitSigns

These mappings are buffer-local in Git repositories:

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `]c` | Go to the next Git hunk |
| `n` | `[c` | Go to the previous Git hunk |
| `n` / `v` | `<leader>hs` | Stage hunk |
| `n` / `v` | `<leader>hr` | Reset hunk |
| `n` | `<leader>hS` | Stage entire buffer |
| `n` | `<leader>hu` | Undo staged hunk |
| `n` | `<leader>hR` | Reset entire buffer |
| `n` | `<leader>hp` | Preview hunk |
| `n` | `<leader>hb` | Show blame for the current line |
| `n` | `<leader>hd` | Diff the current buffer |
| `n` | `<leader>hD` | Diff against the parent revision |
| `n` | `<leader>tb` | Toggle current-line blame |
| `n` | `<leader>td` | Toggle deleted-line display |

## Diagnostics and code navigation

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `<leader>xx` | Toggle workspace diagnostics |
| `n` | `<leader>xX` | Show diagnostics for the current buffer |
| `n` | `<leader>xq` | Toggle the quickfix list |
| `n` | `<leader>xl` | Toggle the location list |
| `n` | `<leader>u` | Toggle UndoTree |

## Harpoon

| Mode | Mapping | Action |
| --- | --- | --- |
| `n` | `<leader>a` | Add the current file to Harpoon |
| `n` | `<C-e>` | Open the Harpoon quick menu |
| `n` | `<C-h>` | Jump to Harpoon file 1 |
| `n` | `<C-t>` | Jump to Harpoon file 2 |
| `n` | `<C-n>` | Jump to Harpoon file 3 |
| `n` | `<C-s>` | Jump to Harpoon file 4 |

## Editing

| Mode | Mapping | Action |
| --- | --- | --- |
| `v` | `J` | Move the selected lines down |
| `v` | `K` | Move the selected lines up |
| `n` / `v` | `gc` | Toggle comments |
| `n` | `gcc` | Toggle the current line's comment |
| `v` | `gc` | Toggle comments on the selection |
| `n` / `v` | `sa{motion}{char}` | Add a surrounding pair |
| `n` | `sd{char}` | Delete a surrounding pair |
| `n` | `sr{old}{new}` | Replace a surrounding pair |

Autopairs automatically inserts matching brackets, quotes, and parentheses.
Mini.ai also extends the standard `a` and `i` text objects.

## Plugin and configuration commands

| Command | Action |
| --- | --- |
| `:Lazy` | Open the lazy.nvim plugin manager |
| `:Lazy sync` | Install/update plugins from the lockfile |
| `:Mason` | Open the Mason package manager |
| `:LspInfo` | Inspect attached and configured LSP servers |
| `:checkhealth` | Run Neovim health checks |
| `:WhichKey` | Open the Which-Key command browser |
| `:OverseerRun` | Select and run an available platform task |
| `:OverseerToggle` | Toggle the Overseer task list |
| `:OverseerTaskAction` | Open actions for the selected task |

## Configuration layout

| File | Responsibility |
| --- | --- |
| `init.lua` | Startup entrypoint and old Packer runtime-path cleanup |
| `lua/ksnvim/lazy.lua` | lazy.nvim bootstrap and plugin declarations |
| `lua/ksnvim/set.lua` | Editor options, line numbers, transparency, highlights |
| `lua/ksnvim/remap.lua` | Core mappings and leader key |
| `after/plugin/lsp.lua` | Native LSP, server definitions, diagnostics, LSP mappings |
| `after/plugin/completion.lua` | nvim-cmp completion and snippet mappings |
| `after/plugin/conform.lua` | Formatters and format-on-save |
| `after/plugin/lint.lua` | IaC, policy, CI, and shell linters |
| `after/plugin/overseer.lua` | Safe interactive project task runner |
| `lua/overseer/template/user/platform.lua` | Auto-discovered read-only platform tasks |
| `after/plugin/treesitter.lua` | Treesitter parsers and highlighting |
| `after/plugin/ui.lua` | Lualine and Which-Key |
| `after/plugin/git.lua` | GitSigns and Diffview |
| `after/plugin/trouble.lua` | Diagnostics and quickfix views |
| `after/plugin/editing.lua` | Autopairs, mini modules, and Oil |

## Keeping this README current

Whenever a mapping is added, removed, or changed:

1. Update the corresponding table in this README.
2. Add a `desc` to the mapping where possible so Which-Key can display it.
3. Verify conflicts with `:verbose nmap <mapping>` or `:verbose imap <mapping>`.
4. Run `:checkhealth` and restart Neovim after plugin/configuration changes.

The authoritative mapping definitions remain in the Lua files listed above;
this README is the human-friendly reference.
