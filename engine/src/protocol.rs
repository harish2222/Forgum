use serde::Deserialize;

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct SceneConfig {
    #[serde(default)]
    pub r#type: Option<String>,
    #[serde(default)]
    pub effect: String,
    #[serde(default)]
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

#[allow(dead_code)]
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

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json;

    #[test]
    fn test_scene_config_from_json_minimal() {
        let json = r#"{"effect":"aurora","cow_text":"Hello"}"#;
        let config: SceneConfig = serde_json::from_str(json).unwrap();
        assert_eq!(config.effect, "aurora");
        assert_eq!(config.cow_text, "Hello");
        assert_eq!(config.speed, 1.0);
        assert!(config.fps.is_none());
        assert!(config.duration.is_none());
        assert!(config.background.is_none());
    }

    #[test]
    fn test_scene_config_from_json_full() {
        let json = r#"{
            "type":"render",
            "effect":"liquid-chrome",
            "cow_text":"Test",
            "fps":30,
            "duration":120,
            "background":true,
            "overlay_height":40,
            "style":"fly",
            "cow_file":"tux.cow",
            "particles":"Fire",
            "speed":2.5,
            "amplitude":3.0,
            "cycle_interval":5.0,
            "max_width":80,
            "lolcat":{"enabled":true,"frequency":0.2,"spread":4.0,"truecolor":true,"target":"stdout"}
        }"#;
        let config: SceneConfig = serde_json::from_str(json).unwrap();
        assert_eq!(config.r#type.as_deref(), Some("render"));
        assert_eq!(config.effect, "liquid-chrome");
        assert_eq!(config.cow_text, "Test");
        assert_eq!(config.fps, Some(30));
        assert_eq!(config.duration, Some(120));
        assert_eq!(config.background, Some(true));
        assert_eq!(config.overlay_height, Some(40));
        assert_eq!(config.style.as_deref(), Some("fly"));
        assert_eq!(config.cow_file.as_deref(), Some("tux.cow"));
        assert_eq!(config.particles.as_deref(), Some("Fire"));
        assert_eq!(config.speed, 2.5);
        assert_eq!(config.amplitude, Some(3.0));
        assert_eq!(config.cycle_interval, Some(5.0));
        assert_eq!(config.max_width, Some(80));
        let lolcat = config.lolcat.unwrap();
        assert!(lolcat.enabled);
        assert!((lolcat.frequency - 0.2).abs() < 0.001);
        assert!((lolcat.spread - 4.0).abs() < 0.001);
        assert!(lolcat.truecolor);
        assert_eq!(lolcat.target, "stdout");
    }

    #[test]
    fn test_scene_config_defaults() {
        let json = r#"{"effect":"plasma","cow_text":"X"}"#;
        let config: SceneConfig = serde_json::from_str(json).unwrap();
        assert!((config.speed - 1.0).abs() < 0.001);
        assert!(config.style.is_none());
        assert!(config.cow_file.is_none());
        assert!(config.particles.is_none());
        assert!(config.amplitude.is_none());
        assert!(config.cycle_interval.is_none());
        assert!(config.max_width.is_none());
        assert!(config.lolcat.is_none());
    }

    #[test]
    fn test_scene_config_init_type() {
        let json = r#"{"type":"init","shell":"bash"}"#;
        let config: SceneConfig = serde_json::from_str(json).unwrap();
        assert_eq!(config.r#type.as_deref(), Some("init"));
        assert_eq!(config.effect, "");
        assert_eq!(config.cow_text, "");
    }

    #[test]
    fn test_lolcat_config_defaults() {
        let json = r#"{}"#;
        let lolcat: LolcatConfig = serde_json::from_str(json).unwrap();
        assert!(!lolcat.enabled);
        assert!((lolcat.frequency - 0.1).abs() < 0.001);
        assert!((lolcat.spread - 3.0).abs() < 0.001);
        assert!(!lolcat.truecolor);
        assert_eq!(lolcat.target, "all");
    }
}
