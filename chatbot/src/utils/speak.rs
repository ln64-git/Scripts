use std::process::Command;

pub fn speak(text: &str) {
    println!("{}", text);
    Command::new("aspeak")
        .arg("text")
        .arg(format!("\"{}\"", text))
        .output()
        .expect("Failed to speak");
}
