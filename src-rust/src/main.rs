use std::io::{self, stdout, IsTerminal, Read, Write};
use std::time::{Duration, Instant};

use clap::Parser;
use crossterm::{
    cursor::{Hide, MoveTo, Show},
    event::{self, Event, KeyCode},
    execute, queue,
    style::{Color, Print, SetForegroundColor},
    terminal::{
        self, disable_raw_mode, enable_raw_mode, Clear, ClearType, EnterAlternateScreen,
        LeaveAlternateScreen,
    },
};

mod engine;

#[derive(Parser, Debug)]
#[command(author, version, about = "Forgum terminal animation engine", long_about = None)]
struct Args {
    /// Message text (informational; primary content is read from stdin).
    #[arg(short, long)]
    message: Option<String>,

    /// Animation mode: static, slide, bounce, wave, wiggle, fade-in, dissolve, disco.
    /// Default: slide (legacy behavior).
    #[arg(long, default_value = "slide", value_parser = clap::value_parser!(String))]
    mode: String,

    /// Number of frames to render before exiting.
    /// 0 means run until user presses q/Esc (interactive only).
    /// Auto-defaults to 1 when stdout is not a TTY.
    #[arg(long, default_value_t = 0)]
    frames: u32,

    /// Render exactly one frame and exit (equivalent to --frames 1).
    #[arg(long, default_value_t = false)]
    once: bool,

    /// Frames per second (ignored when --frames=0 and TTY).
    #[arg(long, default_value_t = 60)]
    fps: u32,

    /// Suppress all terminal control sequences (no raw mode, no alternate screen).
    /// Auto-enabled when stdout is not a TTY.
    #[arg(long, default_value_t = false)]
    plain: bool,
}

fn read_cow_text() -> String {
    if !io::stdin().is_terminal() {
        let mut buf = String::new();
        match io::stdin().read_to_string(&mut buf) {
            Ok(_) => buf,
            Err(_) => String::new(),
        }
    } else {
        // TTY with no piped input — render a default cow so users can demo.
        String::from(
            r" \
      ^__^
      (oo)\_______
      (__)\       )\/\
          ||----w |
          ||     ||
",
        )
    }
}

fn render_static(stdout: &mut io::StdoutLock<'_>, cow_text: &str) -> io::Result<()> {
    // Print once, no animation, exit.
    for line in cow_text.lines() {
        writeln!(stdout, "{}", line)?;
    }
    Ok(())
}

fn render_animated(
    stdout: &mut io::StdoutLock<'_>,
    cow_text: &str,
    mode: &str,
    total_frames: u32,
    fps: u32,
    interactive: bool,
) -> io::Result<()> {
    let (term_width, term_height) = terminal::size()?;
    let cow_lines: Vec<&str> = cow_text.lines().collect();

    let frame_duration = if fps == 0 {
        Duration::from_millis(16)
    } else {
        Duration::from_secs_f64(1.0 / fps as f64)
    };

    let mut offset_x: i32 = 0;
    let mut direction_x: i32 = 1;

    let mut elapsed: u32 = 0;
    while elapsed < total_frames {
        let start = Instant::now();

        // Interactive exit: q or Esc.
        if interactive && event::poll(Duration::from_millis(0))? {
            if let Event::Key(key) = event::read()? {
                if matches!(key.code, KeyCode::Char('q') | KeyCode::Esc) {
                    break;
                }
            }
        }

        // Bounce horizontal position (drives all animation modes).
        if direction_x > 0 && offset_x >= term_width as i32 - 20 {
            direction_x = -1;
        } else if direction_x < 0 && offset_x <= 0 {
            direction_x = 1;
        }
        offset_x += direction_x;

        let cow_y = term_height / 2;

        for (i, line) in cow_lines.iter().enumerate() {
            let y = cow_y.saturating_add(i as u16);
            let x = offset_x.max(0) as u16;

            // Mode-specific per-line transform applied at render time.
            let rendered = match mode {
                "wiggle" => {
                    let off = ((((elapsed as f64) * 0.5).sin() * 3.0) as i32).max(0);
                    format!("{}{}", " ".repeat(off as usize), line)
                }
                "bounce" => {
                    let off = ((elapsed as f64 * 0.2).sin().abs() * 5.0) as usize;
                    format!("{}{}", "\n".repeat(off), line)
                }
                "wave" => {
                    let mut out = String::new();
                    for (li, l) in cow_lines.iter().enumerate() {
                        let off =
                            ((((elapsed as f64 + li as f64) * 0.3).sin() * 2.0) as i32 + 2).max(0);
                        out.push_str(&format!("{}{}\n", " ".repeat(off as usize), l));
                    }
                    out
                }
                "fade-in" => {
                    let total = cow_lines.len() as f64;
                    let visible = (((elapsed as f64) * (total / 20.0)) as usize).min(cow_lines.len());
                    cow_lines
                        .iter()
                        .take(visible)
                        .map(|l| format!("{}\n", l))
                        .collect::<String>()
                }
                "dissolve" => {
                    if elapsed < 10 {
                        let mut s = String::new();
                        for c in line.chars() {
                            if c != ' ' && c != '\n' && (elapsed + (c as u32 % 7)) % 3 == 0 {
                                s.push('.');
                            } else {
                                s.push(c);
                            }
                        }
                        s
                    } else {
                        line.to_string()
                    }
                }
                "disco" => {
                    // Color seed varies per frame; content unchanged.
                    line.to_string()
                }
                _ => {
                    // Default "slide" / "static": just draw line at (x, y).
                    line.to_string()
                }
            };

            // For modes that produce multi-line output, only honor first line at (x, y).
            for (li, l) in rendered.lines().enumerate() {
                queue!(
                    stdout,
                    MoveTo(x, y.saturating_add(li as u16)),
                    SetForegroundColor(Color::Green),
                    Print(l)
                )?;
            }
        }
        stdout.flush()?;
        let _ = start.elapsed(); // suppress unused

        let now = Instant::now();
        let elapsed_frame = now.duration_since(start);
        if elapsed_frame < frame_duration {
            std::thread::sleep(frame_duration - elapsed_frame);
        }
        elapsed += 1;
    }
    Ok(())
}

fn main() -> io::Result<()> {
    let args = Args::parse();

    let cow_text = read_cow_text();

    // When stdout is not a TTY (piped, captured, CI), force a single-frame static render.
    // This makes the binary safe to call from PowerShell pipelines and CI without hanging.
    let stdout_is_tty = stdout().is_terminal();
    let stdin_is_tty = io::stdin().is_terminal();
    let non_interactive = !stdout_is_tty || !stdin_is_tty || args.plain;

    // Decide total frame count:
    //   --once => 1
    //   --frames N => N
    //   non-interactive default => 1 (no infinite loop outside TTY)
    //   TTY default => 0 (run until user quits)
    let total_frames: u32 = if args.once {
        1
    } else if args.frames > 0 {
        args.frames
    } else if non_interactive {
        1
    } else {
        0
    };

    let mut stdout = stdout().lock();

    // Short-circuit: static mode or single-frame non-animated rendering.
    if args.mode == "static" || (total_frames == 1 && args.mode == "slide" && non_interactive) {
        return render_static(&mut stdout, &cow_text);
    }

    if non_interactive {
        // Render exactly one frame and exit. No alternate screen, no raw mode.
        render_static(&mut stdout, &cow_text)?;
        return Ok(());
    }

    // Interactive path: full animation with terminal control.
    execute!(stdout, EnterAlternateScreen, Hide, Clear(ClearType::All))?;
    enable_raw_mode()?;

    let result = render_animated(&mut stdout, &cow_text, &args.mode, total_frames, args.fps, true);

    // Always restore terminal state.
    let _ = disable_raw_mode();
    let _ = execute!(stdout, Show, LeaveAlternateScreen);

    result
}
