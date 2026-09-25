local tasks = {
  { "Platform: Terraform validate", { "terraform", "validate" } },
  { "Platform: Terraform plan", { "terraform", "plan", "-input=false" } },
  { "Platform: Terragrunt plan", { "terragrunt", "plan" } },
  { "Platform: Helm lint", { "helm", "lint", "." } },
  { "Platform: Kube-linter", { "kube-linter", "lint", "." } },
  { "Platform: Ansible lint", { "ansible-lint" } },
  { "Platform: Kubernetes diff", { "kubectl", "diff", "-f", "." } },
  { "Platform: Kubernetes pods", { "kubectl", "get", "pods", "-A" } },
}

return {
  name = "platform",
  desc = "Safe, read-only platform engineering tasks",
  generator = function()
    local available = {}
    for _, task in ipairs(tasks) do
      local name, cmd = task[1], task[2]
      if vim.fn.executable(cmd[1]) == 1 then
        table.insert(available, {
          name = name,
          desc = table.concat(cmd, " "),
          builder = function()
            return {
              cmd = cmd,
              cwd = vim.fn.getcwd(),
              components = { "default", "on_output_quickfix", "on_exit_set_status" },
            }
          end,
        })
      end
    end
    return available
  end,
}
