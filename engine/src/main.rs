mod framebuffer;
mod particles;
mod color;
mod protocol;
mod effects;
mod terminal;
mod region;
mod scheduler;
mod style_matcher;

use protocol::SceneConfig;
use std::io::{self, Read, Write};
use framebuffer::FrameBuffer;
use region::{RegionAllocator, Rect};
use effects::{
    Effect, AuroraEffect, EmberEffect, ShatterEffect, PlasmaEffect,
    LiquidChromeEffect, PortalEffect, GlitchEffect, NeonPulseEffect, PhysicsEffect,
    StaticEffect, BreathingEffect, LiquidEffect, SwayEffect, BounceEffect,
    FlyingEffect, FireEffect, MatrixEffect, PulseEffect, DissolveEffect,
};
use terminal::Terminal;
use scheduler::Scheduler;
use crossterm::{
    cursor,
    event::{self, Event, KeyCode, KeyEvent, KeyModifiers},
    execute, queue, style,
};
use crossterm::terminal::{self as crossterm_terminal, LeaveAlternateScreen};
use std::time::Duration;
use std::path::PathBuf;

fn is_terminal_stdout() -> bool {
    use std::io::IsTerminal;
    io::stdout().is_terminal()
}

/// Try to open CONOUT$ for direct console output when stdout is piped.
#[cfg(windows)]
fn open_console_out() -> Option<std::io::BufWriter<std::fs::File>> {
    use std::ffi::CString;
    use std::os::windows::io::FromRawHandle;
    use winapi::um::fileapi::{CreateFileA, OPEN_EXISTING};
    use winapi::um::winnt::{GENERIC_READ, GENERIC_WRITE, FILE_SHARE_READ, FILE_SHARE_WRITE};

    let name = CString::new("CONOUT$").unwrap();
    unsafe {
        let handle = CreateFileA(
            name.as_ptr(),
            GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE,
            std::ptr::null_mut(),
            OPEN_EXISTING,
            0,
            std::ptr::null_mut(),
        );
        if handle == winapi::um::handleapi::INVALID_HANDLE_VALUE {
            None
        } else {
            let file = std::fs::File::from_raw_handle(handle as *mut _);
            Some(std::io::BufWriter::new(file))
        }
    }
}

#[cfg(not(windows))]
fn open_console_out() -> Option<std::io::BufWriter<std::fs::File>> {
    None
}

fn get_terminal_size() -> (u16, u16) {
    crossterm::terminal::size().unwrap_or((80, 24))
}

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
        "static" | "talk" => Box::new(StaticEffect::new(cow_text)),
        "breathe" | "breathing" => Box::new(BreathingEffect::new(cow_text)),
        "liquid" | "squish" => Box::new(LiquidEffect::new(cow_text)),
        "sway" => Box::new(SwayEffect::new(cow_text)),
        "bounce" => Box::new(BounceEffect::new(cow_text)),
        "fly" | "flying" => Box::new(FlyingEffect::new(cow_text)),
        "fire" => Box::new(FireEffect::new(cow_text)),
        "matrix" => Box::new(MatrixEffect::new(cow_text)),
        "pulse" => Box::new(PulseEffect::new(cow_text)),
        "dissolve" => Box::new(DissolveEffect::new(cow_text)),
        "abduction" => Box::new(SwayEffect::new(cow_text)),
        "random" => {
            use rand::seq::SliceRandom;
            let effects = [
                "aurora", "ember", "shatter", "plasma", "liquid-chrome",
                "portal", "glitch", "neon-pulse", "physics",
                "breathe", "liquid", "sway", "bounce", "fly",
                "fire", "matrix", "pulse", "dissolve",
            ];
            let mut rng = rand::thread_rng();
            let chosen = *effects.choose(&mut rng).unwrap_or(&"aurora");
            create_effect(chosen, cow_text)
        }
        _ => Box::new(AuroraEffect::new(cow_text)),
    }
}

fn resolve_effect_name(config: &SceneConfig) -> String {
    if config.effect != "auto" && !config.effect.is_empty() {
        return config.effect.clone();
    }
    if let Some(ref style) = config.style {
        return style.clone();
    }
    if let Some(ref cow_file) = config.cow_file {
        let cow_style = style_matcher::get_cow_style(cow_file);
        return cow_style.base.to_lowercase();
    }
    "aurora".to_string()
}

// ── Foreground: full-screen animation with alternate screen + raw mode ──────
fn render_loop_foreground(config: SceneConfig) -> io::Result<()> {
    let has_terminal = is_terminal_stdout();
    let effect_name = resolve_effect_name(&config);

    // Piped stdout: print cow_text directly (animation can't render to a pipe)
    if !has_terminal {
        let mut stdout = io::stdout();
        print!("{}", config.cow_text);
        stdout.flush()?;
        return Ok(());
    }

    let mut console_out: Option<std::io::BufWriter<std::fs::File>> = None;

    if has_terminal {
        crossterm_terminal::enable_raw_mode()?;
        let mut stdout = io::stdout();
        execute!(stdout, crossterm_terminal::EnterAlternateScreen, cursor::Hide)?;
    }

    let (cols, rows) = get_terminal_size();
    let mut fb = FrameBuffer::new(cols as usize, rows as usize);
    let effect_name = resolve_effect_name(&config);
    let mut effect = create_effect(&effect_name, config.cow_text);
    effect.on_resize(cols as usize, rows as usize);

    let mut region_alloc = RegionAllocator::new(Rect::new(0, 0, cols, rows));
    let term = Terminal::detect();
    let ob = term.overlay_bounds();
    let overlay_id = region_alloc.allocate(Rect::new(ob.0, ob.1, ob.2, ob.3), 100);
    let mut scheduler = Scheduler::new(config.fps.unwrap_or(30));
    let fps = config.fps.unwrap_or(30) as u32;
    let max_frames = if config.duration.unwrap_or(0) == 0 {
        150
    } else {
        config.duration.unwrap_or(0) * fps
    };
    let mut frame_count: u32 = 0;

    let result = (|| -> io::Result<()> {
        loop {
            let dt = 0.016;

            if let Ok(true) = event::poll(Duration::from_millis(0)) {
                if let Ok(evt) = event::read() {
                    match evt {
                        Event::Key(KeyEvent { code, modifiers, .. }) => {
                            match code {
                                KeyCode::Char('q') | KeyCode::Esc | KeyCode::Enter => break,
                                KeyCode::Char('c') if modifiers.contains(KeyModifiers::CONTROL) => break,
                                _ => {}
                            }
                        }
                        Event::Resize(new_cols, new_rows) => {
                            fb.resize(new_cols as usize, new_rows as usize);
                            region_alloc.resize_canvas(Rect::new(0, 0, new_cols, new_rows));
                            let nob = (0u16, 0u16, new_cols, new_rows.saturating_sub(3).max(1));
                            region_alloc.resize_region(overlay_id, Rect::new(nob.0, nob.1, nob.2, nob.3));
                            effect.on_resize(new_cols as usize, new_rows as usize);
                        }
                        _ => {}
                    }
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
                if let Some(ref mut con) = console_out {
                    let written = fb.render_region(con, clip)?;
                    con.flush()?;
                    scheduler.adapt(written);
                } else {
                    let mut stdout = io::stdout();
                    let written = fb.render_region(&mut stdout, clip)?;
                    stdout.flush()?;
                    scheduler.adapt(written);
                }
            } else {
                scheduler.adapt(0);
            }

            frame_count = frame_count.saturating_add(1);
            if max_frames > 0 && frame_count >= max_frames {
                break;
            }

            scheduler.wait_if_needed();
        }
        Ok(())
    })();

    // Cleanup
    if let Some(ref mut con) = console_out {
        let _ = crossterm::queue!(con, style::ResetColor, cursor::Show);
    }
    if has_terminal {
        let mut stdout = io::stdout();
        let _ = execute!(stdout, style::ResetColor, cursor::Show, LeaveAlternateScreen);
        let _ = crossterm_terminal::disable_raw_mode();
    }

    result
}

// ── Background: overlay animation above shell prompt ────────────────────────
fn render_loop_background(config: SceneConfig) -> io::Result<()> {
    let has_terminal = is_terminal_stdout();
    let effect_name = resolve_effect_name(&config);

    // Piped stdout: print cow_text directly (animation can't render to a pipe)
    if !has_terminal {
        let mut stdout = io::stdout();
        print!("{}", config.cow_text);
        stdout.flush()?;
        return Ok(());
    }

    let mut console_out: Option<std::io::BufWriter<std::fs::File>> = None;
    let mut stdout = io::stdout();
    let (cols, rows) = get_terminal_size();
    let mut fb = FrameBuffer::new(cols as usize, rows as usize);
    let effect_name = resolve_effect_name(&config);
    let mut effect = create_effect(&effect_name, config.cow_text);
    effect.on_resize(cols as usize, rows as usize);

    let mut region_alloc = RegionAllocator::new(Rect::new(0, 0, cols, rows));
    let overlay_height = config.overlay_height.unwrap_or(10) as u16;
    let ob_y1 = overlay_height.min(rows.saturating_sub(3));
    let overlay_id = region_alloc.allocate(Rect::new(0, 0, cols, ob_y1), 100);

    let mut scheduler = Scheduler::new(config.fps.unwrap_or(30));
    let fps = config.fps.unwrap_or(30) as u32;
    let max_frames = if config.duration.unwrap_or(0) == 0 {
        150
    } else {
        config.duration.unwrap_or(0) * fps
    };
    let mut frame_count: u32 = 0;

    let result = (|| -> io::Result<()> {
        loop {
            let dt = 0.016;

            if let Ok(true) = event::poll(Duration::from_millis(0)) {
                if let Ok(evt) = event::read() {
                    match evt {
                        Event::Key(k) => {
                            match k.code {
                                KeyCode::Char('q') | KeyCode::Esc | KeyCode::Enter => break,
                                KeyCode::Char('c') if k.modifiers.contains(KeyModifiers::CONTROL) => break,
                                _ => {}
                            }
                        }
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
                if let Some(ref mut con) = console_out {
                    crossterm::queue!(con, cursor::SavePosition)?;
                    let written = fb.render_region(con, clip)?;
                    crossterm::queue!(con, cursor::RestorePosition)?;
                    con.flush()?;
                    scheduler.adapt(written);
                } else {
                    queue!(stdout, cursor::SavePosition)?;
                    let written = fb.render_region(&mut stdout, clip)?;
                    queue!(stdout, cursor::RestorePosition)?;
                    stdout.flush()?;
                    scheduler.adapt(written);
                }
            } else {
                scheduler.adapt(0);
            }

            frame_count = frame_count.saturating_add(1);
            if max_frames > 0 && frame_count >= max_frames {
                break;
            }

            scheduler.wait_if_needed();
        }
        Ok(())
    })();

    // Clean up: clear the overlay region so prompt is clean
    if let Some(ref mut con) = console_out {
        crossterm::queue!(con, cursor::SavePosition)?;
        for y in 0..ob_y1 {
            crossterm::queue!(con, cursor::MoveTo(0, y))?;
            crossterm::queue!(con, style::Print(" ".repeat(cols as usize)))?;
        }
        crossterm::queue!(con, cursor::RestorePosition)?;
        let _ = crossterm::queue!(con, style::ResetColor);
    } else {
        queue!(stdout, cursor::SavePosition)?;
        for y in 0..ob_y1 {
            queue!(stdout, cursor::MoveTo(0, y))?;
            queue!(stdout, style::Print(" ".repeat(cols as usize)))?;
        }
        queue!(stdout, cursor::RestorePosition)?;
        execute!(stdout, style::ResetColor)?;
    }

    result
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

    if args.len() > 1 && args[1] == "init" {
        let shell = if args.len() > 2 { &args[2] } else { "bash" };
        handle_init(shell);
        return Ok(());
    }

    if args.len() > 1 && (args[1] == "--help" || args[1] == "-h") {
        println!("forgum-engine v{}", env!("CARGO_PKG_VERSION"));
        println!("Usage: forgum-engine [--daemon] [--file <path>] [--help]");
        println!("  Reads JSON config from stdin and renders animation.");
        println!("  --daemon    Run as background daemon");
        println!("  --file      Read JSON config from file instead of stdin");
        println!("  init <shell>  Generate shell hooks for <shell>");
        return Ok(());
    }

    // Read JSON config: from --file or stdin
    let mut buffer = String::new();
    if let Some(file_idx) = args.iter().position(|a| a == "--file") {
        if let Some(path) = args.get(file_idx + 1) {
            buffer = std::fs::read_to_string(path).unwrap_or_default();
        }
    } else {
        io::stdin().read_to_string(&mut buffer)?;
    }

    if buffer.trim().is_empty() {
        eprintln!("No input provided. Pipe JSON config to stdin or use --file <path>.");
        return Ok(());
    }

    let config: SceneConfig = match serde_json::from_str(&buffer) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Failed to parse config: {}", e);
            return Ok(());
        }
    };

    if let Some(ref json_type) = config.r#type {
        if json_type == "init" {
            let parsed: serde_json::Value = serde_json::from_str(&buffer).unwrap_or_default();
            let shell = parsed.get("shell").and_then(|v| v.as_str()).unwrap_or("bash");
            handle_init(shell);
            return Ok(());
        }
    }

    let is_bg = config.background.unwrap_or(false);
    let is_daemon = args.iter().any(|a| a == "--daemon");

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

    if is_bg {
        render_loop_background(config)?;
    } else {
        render_loop_foreground(config)?;
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_config(effect: &str, cow_file: Option<&str>, style: Option<&str>) -> SceneConfig {
        SceneConfig {
            r#type: None,
            effect: effect.to_string(),
            cow_text: "test".to_string(),
            fps: None,
            duration: None,
            background: None,
            overlay_height: None,
            style: style.map(|s| s.to_string()),
            cow_file: cow_file.map(|s| s.to_string()),
            particles: None,
            speed: 1.0,
            amplitude: None,
            cycle_interval: None,
            max_width: None,
            lolcat: None,
        }
    }

    #[test]
    fn test_resolve_effect_explicit() {
        let config = make_config("aurora", None, None);
        assert_eq!(resolve_effect_name(&config), "aurora");
    }

    #[test]
    fn test_resolve_effect_explicit_liquid_chrome() {
        let config = make_config("liquid-chrome", None, None);
        assert_eq!(resolve_effect_name(&config), "liquid-chrome");
    }

    #[test]
    fn test_resolve_effect_auto_with_style() {
        let config = make_config("auto", None, Some("fly"));
        assert_eq!(resolve_effect_name(&config), "fly");
    }

    #[test]
    fn test_resolve_effect_auto_with_cow_file() {
        let config = make_config("auto", Some("tux.cow"), None);
        assert_eq!(resolve_effect_name(&config), "sway");
    }

    #[test]
    fn test_resolve_effect_empty_with_cow_file() {
        let config = make_config("", Some("dragon.cow"), None);
        assert_eq!(resolve_effect_name(&config), "fire");
    }

    #[test]
    fn test_resolve_effect_auto_nothing_defaults_to_aurora() {
        let config = make_config("auto", None, None);
        assert_eq!(resolve_effect_name(&config), "aurora");
    }

    #[test]
    fn test_resolve_effect_auto_unknown_cow_file_returns_talk() {
        let config = make_config("auto", Some("nonexistent.cow"), None);
        assert_eq!(resolve_effect_name(&config), "talk");
    }

    #[test]
    fn test_resolve_effect_style_takes_precedence_over_cow_file() {
        let config = make_config("auto", Some("tux.cow"), Some("matrix"));
        assert_eq!(resolve_effect_name(&config), "matrix");
    }

    #[test]
    fn test_resolve_effect_random_returns_random() {
        let config = make_config("random", None, None);
        assert_eq!(resolve_effect_name(&config), "random");
    }

    #[test]
    fn test_create_effect_random_does_not_panic() {
        let mut effect = create_effect("random", "test".to_string());
        let mut fb = FrameBuffer::new(80, 24);
        effect.update(0.016);
        let clip = Rect::new(0, 0, 80, 24);
        effect.render(&mut fb, clip);
    }

    #[test]
    fn test_create_effect_returns_something() {
        let mut effect = create_effect("aurora", "test".to_string());
        let mut fb = FrameBuffer::new(80, 24);
        effect.update(0.016);
        let clip = Rect::new(0, 0, 80, 24);
        effect.render(&mut fb, clip);
    }

    #[test]
    fn test_create_effect_all_base_styles() {
        let styles = ["aurora", "ember", "shatter", "plasma", "liquid-chrome",
                      "portal", "glitch", "neon-pulse", "physics",
                      "static", "breathe", "liquid", "sway", "bounce",
                      "fly", "fire", "matrix", "pulse", "dissolve"];
        for style in styles {
            let mut effect = create_effect(style, "test".to_string());
            let mut fb = FrameBuffer::new(80, 24);
            effect.update(0.016);
            let clip = Rect::new(0, 0, 80, 24);
            effect.render(&mut fb, clip);
        }
    }
}
