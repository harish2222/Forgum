mod engine;

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
use engine::FrameBuffer;
use std::io::{self, stdout, IsTerminal, Read, Write};
use std::time::{Duration, Instant};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(short, long)]
    message: Option<String>,

    #[arg(long, default_value = "slide")]
    mode: String,
}

fn main() -> io::Result<()> {
    let _args = Args::parse();

    let mut cow_text = String::new();
    if !std::io::stdin().is_terminal() {
        std::io::stdin()
            .read_to_string(&mut cow_text)
            .expect("Failed to read from stdin");
    } else {
        cow_text = r#"
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
        "#
        .to_string();
    }

    let mut stdout = stdout();

    // Setup terminal
    execute!(stdout, EnterAlternateScreen, Hide, Clear(ClearType::All))?;
    enable_raw_mode()?;

    let (term_width, term_height) = terminal::size()?;

    let mut prev_frame = FrameBuffer::new(term_width, term_height);

    let fps = 60;
    let frame_duration = Duration::from_secs_f64(1.0 / fps as f64);

    let mut offset_x: i32 = 0;
    let mut direction_x: i32 = 1;

    let cow_lines: Vec<&str> = cow_text.lines().collect();

    let mut running = true;
    let mut elapsed_frames = 0;

    while running {
        let start = Instant::now();

        // Handle input to quit
        if event::poll(Duration::from_millis(0))? {
            if let Event::Key(key_event) = event::read()? {
                if key_event.code == KeyCode::Char('q') || key_event.code == KeyCode::Esc {
                    running = false;
                }
            }
        }

        // Update state
        if direction_x > 0 && offset_x > (term_width as i32 - 20) {
            direction_x = -1;
        } else if direction_x < 0 && offset_x <= 0 {
            direction_x = 1;
        }
        offset_x += direction_x;

        // Draw to frame buffer
        let mut curr_frame = FrameBuffer::new(term_width, term_height);

        let cow_y = term_height / 2;
        for (i, line) in cow_lines.iter().enumerate() {
            let y = cow_y.saturating_add(i as u16);
            let x = offset_x.max(0) as u16;
            curr_frame.write_str(x, y, line);
        }

        // Render diff
        let diffs = curr_frame.diff(&prev_frame);
        for diff in diffs {
            queue!(
                stdout,
                MoveTo(diff.x, diff.y),
                SetForegroundColor(Color::Green),
                Print(diff.ch)
            )?;
        }
        stdout.flush()?;

        prev_frame = curr_frame;

        let elapsed = start.elapsed();
        if elapsed < frame_duration {
            std::thread::sleep(frame_duration - elapsed);
        }

        elapsed_frames += 1;
        // Limit execution in CI environments so it doesn't hang
        if std::env::var("CI").is_ok() && elapsed_frames > 60 {
            running = false;
        }
    }

    // Restore terminal
    disable_raw_mode()?;
    execute!(stdout, Show, LeaveAlternateScreen)?;

    Ok(())
}