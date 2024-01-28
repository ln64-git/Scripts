// region: --- Modules
mod utils;
use crate::clipboard::clipboard;
use crate::speak::speak_clipboard;
use crate::utils::clipboard;
use std::env;
use utils::speak::speak;
use utils::{ollama, speak};
// endregion: --- Modules

#[tokio::main]
async fn main() {
    speak("Chatbot initialized.");
    let args: Vec<String> = env::args().collect();
    let model = "llama2-uncensored";
    let primary_function = &args[1];
    match primary_function.as_str() {
        "--converse" => {
            return;
        }
        "--speak" => {
            speak::speak_clipboard();
        }
        "--response" => {
            let default_prompt_prelude = "Explain this...";
            let prompt_prelude = args
                .get(2)
                .map(|s| s.as_str())
                .unwrap_or(default_prompt_prelude);
            let prompt_input = match clipboard::clipboard() {
                Ok(text) => text,
                Err(err) => {
                    eprintln!("Error: Unable to paste text from the clipboard: {}", err);
                    return;
                }
            };
            let final_prompt = format!("{} {}", prompt_prelude, prompt_input);
            ollama::generate_text(model, final_prompt).await;
        }
        &_ => return,
    }
}
