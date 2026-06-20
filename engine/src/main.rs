mod framebuffer;
mod particles;
mod color;
mod protocol;
mod effects;
mod terminal;
mod region;
mod scheduler;

use protocol::SceneConfig;
use std::io::{self, Read, Write};
use framebuffer::FrameBuffer;
use region::{RegionAllocator, Rect};
use effects::{Effect, AuroraEffect, EmberEffect, ShatterEffect, PlasmaEffect, LiquidChromeEffect, PortalEffect, GlitchEffect, NeonPulseEffect, PhysicsEffect};
use terminal::Terminal;
use scheduler::Scheduler;
use crossterm::{
    cursor,
    event::{self, Event, KeyCode, KeyEvent, KeyModifiers},
    execute, queue, style,
};
use std::time::Duration;
use std::path::PathBuf;

fn create_effect(name: &str, cow_text: String) -> Box<dyn Effect> {
    match name {
        "ember" => Box::new(EmberEffect::new(cow_text)),
        "shatter" => Box::new(ShatterEffect::new(cow_text)),
        "plasma" => Box::new(PlasmaEffect::new(cow_text)),
        "liquid-chrome" => Box::new(LiquidChromeEffect::new(cow_text)),
        "portal" => Box::new(PortalEffect::new(cow_text)),
        "glitch" => Box::new(GlitchEffect::new(cow_text)),
        "neon-pulse" => Box::new(NeonPulseEffect::new(cow_text)),
        "physics" => Box::new(PhysicsEffect::new(cow_text)),
        "random" => {
            use rand::seq::SliceRandom;
            let effects = [
                "ember", "shatter", "plasma", "liquid-chrome",
                "portal", "glitch", "neon-pulse", "aurora", "physics",
            ];
            let mut rng = rand::thread_rng();
            let chosen = *effects.choose(&mut rng).unwrap_or(&"aurora");
            create_effect(chosen, cow_text)
        }
        _ => Box::new(AuroraEffect::new(cow_text)),
    }
}

fn render_loop_foreground(config: SceneConfig) -> io::Result<()> {
    let mut term = Terminal::detect();
    let mut stdout = io::stdout();

    execute!(stdout, cursor::Hide)?;

    let (cols, rows) = crossterm::terminal::size()?;
    let mut fb = FrameBuffer::new(cols as usize, rows as usize);
    let mut effect = create_effect(&config.effect, config.cow_text);
    effect.on_resize(cols as usize, rows as usize);

    let mut region_alloc = RegionAllocator::new(Rect::new(0, 0, cols, rows));
    let ob = term.overlay_bounds();
    let overlay_id = region_alloc.allocate(Rect::new(ob.0, ob.1, ob.2, ob.3), 100);

    let mut scheduler = Scheduler::new(config.fps.unwrap_or(30));
    let max_frames = config.duration.unwrap_or(0);
    let mut frame_count: u32 = 0;

    loop {
        let dt = 0.016;

        if event::poll(Duration::from_millis(0))? {
            match event::read()? {
                Event::Key(KeyEvent { code, modifiers, .. }) => {
                    match code {
                        KeyCode::Char('q') | KeyCode::Esc | KeyCode::Enter => break,
                        KeyCode::Char('c') if modifiers.contains(KeyModifiers::CONTROL) => break,
                        _ => {}
                    }
                }
                Event::Resize(new_cols, new_rows) => {
                    term.refresh_size();
                    fb.resize(new_cols as usize, new_rows as usize);
                    region_alloc.resize_canvas(Rect::new(0, 0, new_cols, new_rows));
                    let nob = term.overlay_bounds();
                    region_alloc.resize_region(overlay_id, Rect::new(nob.0, nob.1, nob.2, nob.3));
                    effect.on_resize(new_cols as usize, new_rows as usize);
                }
                _ => {}
            }
        }

        effect.update(dt);
        fb.clear();

        let clip = region_alloc.get(overlay_id)
            .map(|r| r.bounds)
            .unwrap_or(Rect::new(0, 0, cols, rows));
        effect.render(&mut fb, clip);

        fb.compute_damage();

        if scheduler.should_render(fb.damage_count()) {
            queue!(stdout, cursor::SavePosition)?;
            let written = fb.render_region(&mut stdout, clip)?;
            queue!(stdout, cursor::RestorePosition)?;
            stdout.flush()?;
            scheduler.adapt(written);
        } else {
            scheduler.adapt(0);
        }

        frame_count = frame_count.saturating_add(1);
        if max_frames > 0 && frame_count >= max_frames {
            break;
        }

        scheduler.wait_if_needed();
    }

    execute!(stdout, style::ResetColor, cursor::Show)?;
    Ok(())
}

fn render_loop_background(config: SceneConfig) -> io::Result<()> {
    let _term = Terminal::detect();
    let mut stdout = io::stdout();

    // Background mode: DO NOT hide cursor, DO NOT enter raw mode
    // Shell prompt remains fully usable

    let (cols, rows) = crossterm::terminal::size()?;
    let mut fb = FrameBuffer::new(cols as usize, rows as usize);
    let mut effect = create_effect(&config.effect, config.cow_text);
    effect.on_resize(cols as usize, rows as usize);

    let mut region_alloc = RegionAllocator::new(Rect::new(0, 0, cols, rows));

    // Calculate overlay region: top N rows, staying above prompt
    let overlay_height = config.overlay_height.unwrap_or(10) as u16;
    let ob_y1 = overlay_height.min(rows.saturating_sub(3));
    let overlay_id = region_alloc.allocate(Rect::new(0, 0, cols, ob_y1), 100);

    let mut scheduler = Scheduler::new(config.fps.unwrap_or(30));
    let max_frames = config.duration.unwrap_or(0);
    let mut frame_count: u32 = 0;

    loop {
        let dt = 0.016;

        // Non-blocking: just check for quit keys
        if event::poll(Duration::from_millis(0))? {
            if let Event::Key(k) = event::read()? {
                match k.code {
                    KeyCode::Char('q') | KeyCode::Esc | KeyCode::Enter => break,
                    KeyCode::Char('c') if k.modifiers.contains(KeyModifiers::CONTROL) => break,
                    _ => {}
                }
            }
        }

        effect.update(dt);
        fb.clear();

        let clip = region_alloc.get(overlay_id)
            .map(|r| r.bounds)
            .unwrap_or(Rect::new(0, 0, cols, ob_y1));
        effect.render(&mut fb, clip);

        fb.compute_damage();

        if scheduler.should_render(fb.damage_count()) {
            // Save cursor -> render overlay -> restore cursor
            // This keeps the prompt/typing intact
            queue!(stdout, cursor::SavePosition)?;
            let written = fb.render_region(&mut stdout, clip)?;
            queue!(stdout, cursor::RestorePosition)?;
            stdout.flush()?;
            scheduler.adapt(written);
        } else {
            scheduler.adapt(0);
        }

        frame_count = frame_count.saturating_add(1);
        if max_frames > 0 && frame_count >= max_frames {
            break;
        }

        scheduler.wait_if_needed();
    }

    // Clean up: clear the overlay region so prompt is clean
    queue!(stdout, cursor::SavePosition)?;
    for y in 0..ob_y1 {
        queue!(stdout, cursor::MoveTo(0, y))?;
        queue!(stdout, style::Print(" ".repeat(cols as usize)))?;
    }
    queue!(stdout, cursor::RestorePosition)?;
    execute!(stdout, style::ResetColor)?;

    Ok(())
}

fn get_config_path() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        let mut path = PathBuf::from(std::env::var("USERPROFILE").unwrap_or_else(|_| "C:\\".to_string()));
        path.push("Documents");
        path.push("PowerShell");
        path.push("Forgum");
        path.push("config.json");
        path
    }
    #[cfg(not(target_os = "windows"))]
    {
        let mut path = PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| "/".to_string()));
        path.push(".config");
        path.push("Forgum");
        path.push("config.json");
        path
    }
}

fn handle_init(shell: &str) {
    let config_path = get_config_path();
    let config_path_str = config_path.to_string_lossy().replace("\\", "\\\\");

    let hook = match shell {
        "bash" | "zsh" => format!(r#"
forgum() {{
    local config="{}"
    local effect="random"
    if [ -f "$config" ]; then
        local parsed=$(grep -oE '"effect"\s*:\s*"[^"]+"' "$config" | cut -d'"' -f4)
        if [ ! -z "$parsed" ]; then
            effect="$parsed"
        fi
    fi
    local cow="$(cowsay "$@")"
    local json_cow="${{cow//$'\n'/\\n}}"
    json_cow="${{json_cow//\"/\\\"}}"
    echo "{{\"effect\":\"$effect\",\"cow_text\":\"$json_cow\",\"background\":true,\"duration\":150}}" | forgum-engine
}}
"#, config_path_str),
        "fish" => format!(r#"
function forgum
    set config "{}"
    set effect "random"
    if test -f "$config"
        set parsed (grep -oE '"effect"\s*:\s*"[^"]+"' "$config" | cut -d'"' -f4)
        if test -n "$parsed"
            set effect "$parsed"
        end
    end
    set cow (cowsay $argv | string collect)
    set json_cow (string replace -a '\n' '\\n' "$cow")
    set json_cow (string replace -a '"' '\"' "$json_cow")
    echo "{{\"effect\":\"$effect\",\"cow_text\":\"$json_cow\",\"background\":true,\"duration\":150}}" | forgum-engine
end
"#, config_path_str),
        "pwsh" | "powershell" => format!(r#"
function Invoke-ForgumEngine {{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$CowText
    )
    process {{
        $configPath = "{}"
        $effect = "random"
        if (Test-Path $configPath) {{
            try {{
                $conf = Get-Content $configPath -Raw | ConvertFrom-Json
                if ($conf.effect) {{ $effect = $conf.effect }}
            }} catch {{}}
        }}
        $payload = @{{ effect = $effect; cow_text = $CowText; background = $true; duration = 150 }} | ConvertTo-Json -Compress
        $payload | & forgum-engine
    }}
}}
"#, config_path_str),
        _ => "echo 'Unsupported shell. Use bash, zsh, fish, or pwsh.'".to_string(),
    };
    println!("{}", hook);
}

fn main() -> io::Result<()> {
    let args: Vec<String> = std::env::args().collect();

    // Handle init subcommand
    if args.len() > 1 && args[1] == "init" {
        let shell = if args.len() > 2 { &args[2] } else { "bash" };
        handle_init(shell);
        return Ok(());
    }

    // Handle help
    if args.len() > 1 && (args[1] == "--help" || args[1] == "-h") {
        println!("forgum-engine v{}", env!("CARGO_PKG_VERSION"));
        println!("Usage: forgum-engine [--daemon] [--help]");
        println!("  Reads JSON config from stdin and renders animation.");
        println!("  --daemon    Run as background daemon");
        println!("  init <shell>  Generate shell hooks for <shell>");
        return Ok(());
    }

    // Read JSON config from stdin
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;

    if buffer.trim().is_empty() {
        eprintln!("No input provided. Pipe JSON config to stdin.");
        return Ok(());
    }

    let config: SceneConfig = match serde_json::from_str(&buffer) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Failed to parse config: {}", e);
            return Ok(());
        }
    };

    let is_bg = config.background.unwrap_or(false);
    let is_daemon = args.iter().any(|a| a == "--daemon");

    // Daemon mode: spawn detached process
    if is_bg && !is_daemon {
        use std::process::{Command, Stdio};
        let current_exe = std::env::current_exe()?;
        let mut child = Command::new(current_exe)
            .arg("--daemon")
            .stdin(Stdio::piped())
            .stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .spawn()?;

        if let Some(mut stdin) = child.stdin.take() {
            stdin.write_all(buffer.as_bytes())?;
        }
        return Ok(());
    }

    // Render: background uses overlay, foreground uses full screen
    if is_bg {
        render_loop_background(config)?;
    } else {
        render_loop_foreground(config)?;
    }

    Ok(())
}
