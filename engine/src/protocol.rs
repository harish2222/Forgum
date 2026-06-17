use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct SceneConfig {
    pub effect: String,
    pub cow_text: String,
    pub fps: Option<u32>,
}
