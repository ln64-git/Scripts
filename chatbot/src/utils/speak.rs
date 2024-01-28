// region: --- Modules
use std::process::Command;
// endregion: --- Modules


pub fn speak(text: &str) -> Result<(), std::io::Error> {
    println!("{}", text);
    let output = Command::new("aspeak")
        .arg("text")
        .arg(format!("\"{}\"", text))
        .output()?;
    if output.status.success() {
        Ok(())
    } else {
        Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            "Command execution failed",
        ))
    }
}


pub fn speak_clipboard() {
    if let Ok(output) = Command::new("wl-paste").output() {
        let text = String::from_utf8_lossy(&output.stdout);
        // Define characters indicating end of sentence
        let sentence_endings = &['.', '!', '?'];
        // Split the text into sentences
        let mut sentence_index = 0;
        for (i, c) in text.char_indices() {
            if sentence_endings.contains(&c) {
                let sentence = &text[sentence_index..=i];
                speak(sentence.trim());
                sentence_index = i + 1; // Move the start to the next senten
            }
        }
        // Speak the remaining text if there's any
        if sentence_index < text.len() {
            let remaining_sentence = &text[sentence_index..];
            speak(remaining_sentence.trim());
        }
    }
}
