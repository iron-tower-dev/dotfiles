vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' then
      vim.system({ 'make' }, { cwd = ev.data.path })
    end
  end,
})
