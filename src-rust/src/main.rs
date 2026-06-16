mod engine;
use clap::Parser;
use std::io::{self, Read};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// The fortune message
    #[arg(short, long)]
    message: String,

    /// Animation mode (e.g., bounce, dissolve, wave)
    #[arg(long, default_value = "bounce")]
    mode: String,
}

fn main() {
    let _args = Args::parse();

    let mut cow_text = String::new();
    io::stdin().read_to_string(&mut cow_text).expect("Failed to read from stdin");

    let eng = engine::Engine::new();
    let scaled_cow = eng.scale_asset(&cow_text);
    println!("Engine ready. Cow scaled: {}", scaled_cow.len());
}
