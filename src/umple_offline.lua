--[[
-- UMPLE OFFLINE
-- by Jacob Sauvé
-- v1.0
-- 2026-03-25
--]]--

_G.PREVIEW_CMD = "open" -- CHANGE THIS IF NOT USING OPEN
_G.CLEANUP_DELAY = 1500 -- ms

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
        vim.cmd("silent !dot -Tpng " .. diagram_fname .. " -Gratio=fill -o " ..  output_name)
        visualize(output_name)
    end,
    {}
)



-- make visualisation happen for compiled diagram
-- (helper)
function visualize(diagram_fname)
        vim.notify("Umple diagram generated. Opened using " .. PREVIEW_CMD, vim.log.levels.INFO)
        vim.fn.jobstart({ PREVIEW_CMD,  diagram_fname }, { detach = true })
        -- schedule tempfile deletion
        os.remove(string.sub(diagram_fname, 0, -5)) --cleanup empty file
        vim.defer_fn(function()
            pcall(os.remove, diagram_fname)
            vim.schedule(function()
                print("cleanup completed")
            end)
        end, CLEANUP_DELAY)
end
