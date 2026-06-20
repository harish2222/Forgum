use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct SceneConfig {
    #[serde(default)]
    pub r#type: Option<String>,
    pub effect: String,
    pub cow_text: String,
    pub fps: Option<u32>,
    pub duration: Option<u32>,
    pub background: Option<bool>,
    pub overlay_height: Option<u32>,
    #[serde(default)]
    pub style: Option<String>,
    #[serde(default)]
    pub cow_file: Option<String>,
    #[serde(default)]
    pub particles: Option<String>,
    #[serde(default = "default_speed")]
    pub speed: f32,
    #[serde(default)]
    pub amplitude: Option<f32>,
    #[serde(default)]
    pub cycle_interval: Option<f32>,
    #[serde(default)]
    pub max_width: Option<u32>,
    #[serde(default)]
    pub lolcat: Option<LolcatConfig>,
}

fn default_speed() -> f32 {
    1.0
}

#[derive(Debug, Deserialize, Clone)]
pub struct LolcatConfig {
    #[serde(default)]
    pub enabled: bool,
    #[serde(default = "default_frequency")]
    pub frequency: f32,
    #[serde(default = "default_spread")]
    pub spread: f32,
    #[serde(default)]
    pub truecolor: bool,
    #[serde(default = "default_lolcat_target")]
    pub target: String,
}

fn default_frequency() -> f32 { 0.1 }
fn default_spread() -> f32 { 3.0 }
fn default_lolcat_target() -> String { "all".to_string() }
