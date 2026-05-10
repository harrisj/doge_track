((yaml-mode . ((lsp-yaml-max-items-computed . 100000))))

(map! :leader
      :desc "Open project database"
      "o d" (cmd! (elsqlite "./data/doge.db")))
;; Now: SPC o d opens your database
