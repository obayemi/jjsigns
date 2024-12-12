# JJSigns.nvim

JJ gutter signs for neovim

> WARNING: VERY VERY WIP

## installation

### lazy.nvim

```lua
{
  "obayemi/jjsigns.nvim",
  config = function()
    require("jjsigns").setup({})
  end,
},
```

## Known issues

- [ ] do not check that the file indeed is part of a jj repo
- [ ] never updates previous cursors
  - lines that have been changed are staying marked after reverting to previous state
  - lines with deleted marker keep the marker after restoring the deleted line
- [ ] never refreshes repo state (commits do not reset changes in already opened files)
- [ ] not async, may become slow
