--[[
-- UMPLE OFFLINE
-- by Jacob Sauvé
-- v1.0
-- 2026-03-25
--]]--


-- compile state machine
vim.api.nvim_create_user_command(
    "UmpleStateMachine",
    function()
        -- current filename
        local fname = vim.api.nvim_buf_get_name(0)
        local output_name = os.tmpname() .. '.png'
        vim.cmd("silent !umple -g GvStateDiagram " .. fname)
        -- reconstruct generated diagram name
        local diagram_fname = string.sub(fname, 0, -4) .. "gv"
        vim.cmd("silent !dot -Tpng " .. diagram_fname .. " -Gsize=4,5\\! -Gdpi=1000 -Gratio=fill -o" ..  output_name)
        visualize(output_name)
    end,
    {}
)

-- compile class diagram
vim.api.nvim_create_user_command(
    "UmpleClassDiagram",
    function()
        -- current filename
        local fname = vim.api.nvim_buf_get_name(0)
        local output_name = os.tmpname() .. '.png'
        vim.cmd("silent !umple -g GvClassDiagram " .. fname)
        local diagram_fname = string.sub(fname, 0, -5) .. "cd.gv"
        vim.cmd("silent !dot -Tpng " .. diagram_fname .. " -Gsize=4,5\\! -Gdpi=1000 -Gratio=fill -o" ..  output_name)
        visualize(output_name)
    end,
    {}
)


-- make visualisation window for compiled diagram
-- (helper)
function visualize(diagram_fname)
        local term_buf = vim.api.nvim_create_buf(false, true)
        local enter_window = true
   
        vim.api.nvim_open_win(term_buf, enter_window, {
            relative="editor",
            row = vim.o.lines - 1,
            col = 0,
            width = vim.o.columns,
            height = math.floor((vim.o.lines -1) / 2),
            border = "rounded",
            title = "UmpleVisualizer (q to quit)"
        })
        vim.fn.jobstart("chafa " .. diagram_fname, {
            term = true,
            --on_exit = function()
            --    vim.cmd(":q"); --auto exit when process terminates
            --end,
            vim.keymap.set({'i','n','v'}, 'q', '[[:q<CR>]]', {buffer=true, silent=true})
        })
        vim.cmd "startinsert"
end
