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

    let ollama = Ollama::default();
    let mut stream = ollama
        .generate_stream(GenerationRequest::new(model.to_string(), prompt))
        .await
        .unwrap();
    while let Some(res) = futures::stream::StreamExt::next(&mut stream).await {
        let res = res.unwrap();
        println!("Response: {:?}", res); // Printing to console
    }
}




fn get_clipboard_text() -> Result<String, Box<dyn std::error::Error>> {
    let output = Command::new("wl-paste").output()?;
    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

fn speak(text: &str) {
    println!("Text to speak: {}", text);
    Command::new("aspeak")
        .arg(text)
        .output()
        .expect("Failed to speak");
}
