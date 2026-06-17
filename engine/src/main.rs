mod framebuffer;
mod compositor;
mod particles;
mod color;
mod protocol;
mod effects;

use protocol::SceneConfig;
use std::io::{self, Read, Write};
use framebuffer::FrameBuffer;
use effects::{Effect, AuroraEffect, EmberEffect, ShatterEffect, PlasmaEffect, LiquidChromeEffect, PortalEffect, GlitchEffect, NeonPulseEffect};
use crossterm::{
    terminal::{enable_raw_mode, disable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen, size},
    execute, cursor, style, event::{self, Event, KeyCode},
};
use std::time::{Duration, Instant};
use std::path::PathBuf;

fn render_loop(config: SceneConfig) -> io::Result<()> {
    let is_bg = config.background.unwrap_or(false);

    if !is_bg {
        enable_raw_mode()?;
        execute!(io::stdout(), crossterm::terminal::EnterAlternateScreen, cursor::Hide)?;
    } else {
        execute!(io::stdout(), cursor::Hide)?;
    }
    let mut stdout = io::stdout();

    let (cols, rows) = size()?;
    let mut fb = FrameBuffer::new(cols as usize, rows as usize);

    let mut effect: Box<dyn Effect> = match config.effect.as_str() {
        "ember" => Box::new(EmberEffect::new(config.cow_text)),
        "shatter" => Box::new(ShatterEffect::new(config.cow_text)),
        "plasma" => Box::new(PlasmaEffect::new(config.cow_text)),
        "liquid-chrome" => Box::new(LiquidChromeEffect::new(config.cow_text)),
        "portal" => Box::new(PortalEffect::new(config.cow_text)),
        "glitch" => Box::new(GlitchEffect::new(config.cow_text)),
        "neon-pulse" => Box::new(NeonPulseEffect::new(config.cow_text)),
        "aurora" | _ => Box::new(AuroraEffect::new(config.cow_text)),
    };

    let target_fps = config.fps.unwrap_or(30);
    let frame_duration = Duration::from_secs_f32(1.0 / target_fps as f32);
    let max_frames = config.duration.unwrap_or(0); // 0 means infinite
    
    let mut last_frame = Instant::now();
    let mut running = true;
    let mut frame_count = 0;

    while running {
        let now = Instant::now();
        let dt = now.duration_since(last_frame).as_secs_f32();
        last_frame = now;

        if !is_bg {
            if event::poll(Duration::from_millis(0))? {
                if let Event::Key(k) = event::read()? {
                    if k.code == KeyCode::Char('q') || k.code == KeyCode::Esc || k.code == KeyCode::Enter {
                        running = false;
                    }
                }
            }
        }

        effect.update(dt);
        fb.clear();
        effect.render(&mut fb);
        
        if is_bg {
            crossterm::queue!(stdout, crossterm::cursor::SavePosition)?;
        }
        fb.render(&mut stdout)?;
        if is_bg {
            crossterm::queue!(stdout, crossterm::cursor::RestorePosition)?;
            stdout.flush()?;
        }

        frame_count += 1;
        if max_frames > 0 && frame_count >= max_frames {
            running = false;
        }

        let elapsed = now.elapsed();
        if elapsed < frame_duration {
            std::thread::sleep(frame_duration - elapsed);
        }
    }

    if !is_bg {
        execute!(stdout, style::ResetColor, cursor::Show, crossterm::terminal::LeaveAlternateScreen)?;
        disable_raw_mode()?;
    } else {
        execute!(stdout, style::ResetColor, cursor::Show)?;
    }
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
    local effect="aurora"
    if [ -f "$config" ]; then
        local parsed=$(grep -oE '"effect"\s*:\s*"[^"]+"' "$config" | cut -d'"' -f4)
        if [ ! -z "$parsed" ]; then
            effect="$parsed"
        fi
    fi
    # Need to escape newlines for JSON properly in shell if needed, but cowsay output is multiline
    # A simple wrapper that replaces newlines with \n for JSON
    local cow="$(cowsay "$@")"
    local json_cow="${{cow//$'\n'/\\n}}"
    json_cow="${{json_cow//\"/\\\"}}"
    echo "{{\"effect\":\"$effect\",\"cow_text\":\"$json_cow\"}}" | forgum-engine
}}
"#, config_path_str),
        "fish" => format!(r#"
function forgum
    set config "{}"
    set effect "aurora"
    if test -f "$config"
        set parsed (grep -oE '"effect"\s*:\s*"[^"]+"' "$config" | cut -d'"' -f4)
        if test -n "$parsed"
            set effect "$parsed"
        end
    end
    set cow (cowsay $argv | string collect)
    # Basic JSON string escaping for fish
    set json_cow (string replace -a '\n' '\\n' "$cow")
    set json_cow (string replace -a '"' '\"' "$json_cow")
    echo "{{\"effect\":\"$effect\",\"cow_text\":\"$json_cow\"}}" | forgum-engine
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
        $effect = "aurora"
        if (Test-Path $configPath) {{
            try {{
                $conf = Get-Content $configPath -Raw | ConvertFrom-Json
                if ($conf.effect) {{ $effect = $conf.effect }}
            }} catch {{}}
        }}
        $payload = @{{ effect = $effect; cow_text = $CowText }} | ConvertTo-Json -Compress
        $payload | & forgum-engine
    }}
}}
"#, config_path_str),
        _ => "echo 'Unsupported shell'".to_string(),
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

    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    
    if buffer.trim().is_empty() {
        eprintln!("No input provided");
        return Ok(());
    }

    let config: SceneConfig = match serde_json::from_str(&buffer) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Failed to parse config: {}", e);
            return Ok(());
        }
    };

    render_loop(config)?;

    Ok(())
}
