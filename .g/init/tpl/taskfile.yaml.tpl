version: '3'

tasks:
  live:templ:
    cmds:
      - figlet "Running templ..."
      - |
        go run github.com/a-h/templ/cmd/templ@latest generate\
          --watch --proxy="http://localhost:3000" \
          --open-browser=false
  gen-pages:
    cmds:
      - |
        go run go.quinn.io/go-astro/cmd/generate/pages@latest \
          -pages pages \
          -output internal/router/router.go \
          -package router && \
            goimports -w internal/router/router.go

  live:gen-pages:
    cmds:
      - figlet "Generating pages..."
      - |
        go run github.com/cosmtrek/air@v1.51.0 \
          --build.cmd "task gen-pages" \
          --build.bin "true" \
          --build.delay "100" \
          --build.exclude_dir "" \
          --build.include_dir "pages" \
          --build.include_ext "go"


  live:gen-content:
    cmds:
      - figlet "Generating content..."
      - |
        go run github.com/cosmtrek/air@v1.51.0 \
          --build.cmd "go run go.quinn.io/go-astro/cmd/generate/content@latest -content content" \
          --build.bin "true" \
          --build.delay "100" \
          --build.exclude_dir "" \
          --build.include_dir "content" \
          --build.include_ext "md"

  live:server:
    cmds:
      - figlet "Running server..."
      - |
        go run github.com/cosmtrek/air@v1.51.0 \
          --build.cmd "go build -o ./tmp/main cmd/main.go && templ generate --notify-proxy"
          --build.bin "./tmp/main"
          --build.delay "100" \
          --build.include_ext "go" \
          --build.stop_on_error "false" \
          --misc.clean_on_exit true

  live:tailwind:
    cmds:
      - figlet "Running tailwindcss..."
      - |
        tailwindcss \
          -i ./tailwind.css \
          -o ./internal/web/public/styles.css \
          --watch

  live:assets:
    cmds:
      - figlet "Generating assets..."
      - |
        go run github.com/cosmtrek/air@v1.51.0 \
          --build.cmd "templ generate --notify-proxy" \
          --build.bin "true" \
          --build.delay "100" \
          --build.exclude_dir "" \
          --build.include_dir "internal/web/public" \
          --build.include_ext "css"

  live:
    cmds:
      - |
        task -p \
          live:templ \
          live:server \
          live:gen-pages \
          live:gen-content \
          live:tailwind \
          live:assets