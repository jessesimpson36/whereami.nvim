" Title:        WhereAmI plugin
" Description:  A plugin to help determine where you are in a YAML file
" Last Change:  10 May 2024
" Maintainer:   Jesse Simpson <https://github.com/jessesimpson36>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_whereami")
    finish
endif
let g:loaded_whereami = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/whereami.nvim/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/aerial.nvim/lua/aerial/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 WhereAmI lua require("whereami").whereami()
command! -nargs=1 JumpToPath lua require("whereami").jumptopath(<q-args>)
command! -nargs=1 JumpToPath2 lua require("whereami").jumptopath2(<q-args>)

