# Inline-eval.nvim

Un plugin Neovim qui évalue en temps réel les `console.log` dans vos fichiers JavaScript/TypeScript et les `echo`, `print_r`, `var_dump` dans vos fichiers PHP, et affiche les résultats directement à côté du code.

## Installation

Avec [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "MGouillardon/inline-eval.nvim",
  event = { "BufEnter *.js", "BufEnter *.ts", "BufEnter *.php" },
  opts = {
    update_interval = 300,
    supported_filetypes = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "php",
    },
    node_path = "deno", -- Chemin vers l'interpréteur JavaScript/TypeScript
    php_path = "php",   -- Chemin vers l'interpréteur PHP
  }
}
```

## Utilisation

`:InlineEvalStart` - Démarre l'évaluation en temps réel
`:InlineEvalStop` - Arrête l'évaluation

## Fonctionnalités

- Évaluation en temps réel du code JavaScript, TypeScript et PHP
- Affichage des résultats dans une fenêtre flottante
- Support pour différentes fonctions de débogage (`console.log`, `echo`, `print_r`, etc.)
- Configuration personnalisable
