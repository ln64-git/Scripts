use std::process::Command;

pub fn clipboard() -> Result<String, Box<dyn std::error::Error>> {
    let output = Command::new("wl-paste").output()?;
    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

