return {
  'vim-test/vim-test',
  config = function()
    vim.cmd [[
      function! BufferTermStrategy(cmd)
        exec 'te ' . a:cmd 
      endfunction

      let g:test#custom_strategies = {'bufferterm': function('BufferTermStrategy')}
      let g:test#strategy = 'bufferterm'
    ]]
  end,
  keys = {
    { '<leader>Tf', '<cmd>TestFile<cr>', silent = true, desc = '[T]est [F]ile' },
    { '<leader>Th', '<cmd>TestNearest<cr>', silent = true, desc = '[T]est [N]earest' },
    { '<leader>Tl', '<cmd>TestLast<cr>', silent = true, desc = '[T]est [L]ast' },
  },
}
