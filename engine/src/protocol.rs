use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct SceneConfig {
    pub effect: String,
    pub cow_text: String,
    pub fps: Option<u32>,
    pub duration: Option<u32>,
    pub background: Option<bool>,
    pub region: Option<String>,
    pub position: Option<String>,
    pub overlay_height: Option<u32>,
}
