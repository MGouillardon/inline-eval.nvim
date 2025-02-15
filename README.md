# Inline-eval.nvim

Un plugin Neovim qui évalue en temps réel les `console.log` dans vos fichiers JavaScript/TypeScript et affiche les résultats directement à côté du code.

## Installation

Avec [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "MGouillardon/inline-eval.nvim",
  event = { "BufEnter *.js", "BufEnter *.ts" },
  opts = {
    update_interval = 300,
    supported_filetypes = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
    },
  }
}
```

## Utilisation

`:InlineEvalStart` - Démarre l'évaluation en temps réel
`:InlineEvalStop` - Arrête l'évaluation
