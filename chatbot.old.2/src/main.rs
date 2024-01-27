use ollama_rs::{generation::completion::request::GenerationRequest, Ollama};
use std::process::Command;

#[tokio::main]
async fn main() {
    speak("Please wait as I compose an explanation...");

    let custom_prompt = "Briefly explain this...";
    let clipboard_text = match get_clipboard_text() {
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
                // println!("{}", sentence);
                speak(sentence.as_str());
                sentence.clear();
                sentence_init = false;
            }
        }
    }
}

fn get_clipboard_text() -> Result<String, Box<dyn std::error::Error>> {
    let output = Command::new("wl-paste").output()?;
    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

fn speak(text: &str) {
    println!("{}", text);
    Command::new("aspeak")
        .arg("text")
        .arg(format!("\"{}\"", text)) // Enclose the text in double quotes
        .output()
        .expect("Failed to speak");
}
