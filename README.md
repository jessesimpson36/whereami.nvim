# Where am I?

Navigating large yaml files can be a mess!

This plugin exposes a function which will output the path under the cursor of whatever deeply nested key you're looking at.

For example:

```
global:
  postgresql
    enabled: true
       ^ cursor here
```

If you execute
```
:WhereAmI
```

the output will be
```
global.postgresql.enabled
```

## Installation

Add the following to your plug line (assuming you use vim-plug)
```
Plug 'jessesimpson36/whereami.nvim'
```

Then under your lua section in, add a mapping for it such as:
```
vim.keymap.set("n", "<leader>w", "<cmd>WhereAmI<CR>")
```

Now whenever you hit `<leader>w`, it will call the WhereAmI function and you won't lose your way.