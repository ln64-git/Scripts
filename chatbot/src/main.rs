#![allow(unused)]

use crate::speak::speak;
use utils::clipboard::clipboard;
use utils::speak;
use ollama_rs::Ollama;
use ollama_rs::generation::completion::request::GenerationRequest;

mod utils;

#[tokio::main]
async fn main() {
    speak("Please wait as I compose an explanation...");
    let args: Vec<String> = std::env::args().collect();
    let custom_prompt = if args.len() > 1 {
        args[1].clone()
    } else {
        "Briefly explain this...".to_string()
    };

    let clipboard_text = match clipboard() {
        Ok(text) => text,
        Err(err) => {
            eprintln!("Error: Unable to paste text from the clipboard: {}", err);
            return;
        }
    };
    let model = "llama2-uncensored";
    let prompt = format!("{} {}", custom_prompt, clipboard_text.to_string());

    let ollama_instance = Ollama::default();
    let mut generation_stream = ollama_instance
        .generate_stream(GenerationRequest::new(model.to_string(), prompt))
        .await
        .unwrap();

    let mut sentence = String::new(); // Initialize an empty string to store the sentence
    let mut sentence_init = true;
    while let Some(result) = futures::stream::StreamExt::next(&mut generation_stream).await {
        let result = result.unwrap();
        for generation_response in result {
            let word = generation_response.response; // Trim leading/trailing whitespace
            sentence.push_str(&word); // Append the word to the sentence
            if word.ends_with('.') || word.ends_with('!') || word.ends_with('?') {
                if !sentence_init {
                    sentence = sentence.chars().skip(1).collect();
                }
                speak(sentence.as_str());
                sentence.clear();
                sentence_init = false;
            }
        }
    }
}

