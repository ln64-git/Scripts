// main.rs

#![allow(unused)]

use utils::clipboard::clipboard;
use utils::speak::speak;
use utils::{ollama, speak};

mod utils;

#[tokio::main]
async fn main() {
    let model: &str = "llama2-uncensored";
    let greeting = "Please wait as I compose an explanation...";
    let prompt_prelude = "Briefly explain this...";

    // Read Custom Prompt Prelude from CLI Arguments
    let prompt_prelude = std::env::args()
        .nth(1)
        .unwrap_or_else(|| prompt_prelude.to_string());

    // Read Custom Prompt from Clipboard
    let prompt_input = match clipboard() {
        Ok(text) => text,
        Err(err) => {
            eprintln!("Error: Unable to paste text from the clipboard: {}", err);
            return;
        }
    };

    speak(greeting);
    ollama::generate_text(model, prompt_prelude, prompt_input).await;
}
