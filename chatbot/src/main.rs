use serde_json::{json, Value};
use std::process::Command;
use tokio::net::TcpListener;
use tokio_tungstenite::accept_async;
use tungstenite::Message;

#[tokio::main]
async fn main() {
    speak("Please wait as I compose an explanation...");

    let custom_prompt = "Briefly explain this...";
    let ollama_model = "llama2-uncensored";
    let clipboard_text = match get_clipboard_text() {
        Ok(text) => text,
        Err(err) => {
            eprintln!("Error: Unable to paste text from the clipboard: {}", err);
            return;
        }
    };
    let final_prompt = format!("{} {}", custom_prompt, clipboard_text);

    let listener = TcpListener::bind("127.0.0.1:11434").await.expect("Failed to bind to address");

    println!("Server listening on 127.0.0.1:11434");

    while let Ok((stream, _)) = listener.accept().await {
        let ollama_model_clone = ollama_model.clone();
        let final_prompt_clone = final_prompt.clone();

        // Spawn a new task for each WebSocket connection
        tokio::spawn(async move {
            if let Err(e) = handle_connection(stream, ollama_model_clone, final_prompt_clone).await {
                eprintln!("Error handling connection: {}", e);
            }
        });
    }
}

async fn handle_connection(
    stream: tokio::net::TcpStream,
    ollama_model: String,
    final_prompt: String,
) -> Result<(), Box<dyn std::error::Error>> {
    let ws_stream = accept_async(stream).await.expect("Error during WebSocket handshake");

    // Send the prompt message to the client
    let request_json = json!({
        "model": ollama_model,
        "prompt": final_prompt,
    });
    let request_message = Message::Text(request_json.to_string());
    ws_stream.send(request_message).await?;

    // Handle messages from the client
    while let Some(Ok(msg)) = ws_stream.next().await {
        match msg {
            Message::Text(response) => {
                if let Ok(json_response) = serde_json::from_str::<Value>(&response) {
                    if let Some(response_str) = json_response.get("response").and_then(|r| r.as_str()) {
                        println!("Response: {}", response_str);
                    } else {
                        println!("Error: Response not found or invalid.");
                    }
                } else {
                    println!("Error: Failed to parse JSON response: {}", response);
                }
            }
            _ => println!("Received non-text message: {:?}", msg),
        }
    }

    Ok(())
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
