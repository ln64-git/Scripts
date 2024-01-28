// generation.rs

use crate::speak::speak;
use ollama_rs::generation::completion::request::GenerationRequest;
use ollama_rs::Ollama;

pub async fn generate_text(model: &str, custom_prompt: String, clipboard_text: String) {
    let ollama_instance = Ollama::default();
    let mut generation_stream = ollama_instance
        .generate_stream(GenerationRequest::new(model.to_string(), custom_prompt))
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
