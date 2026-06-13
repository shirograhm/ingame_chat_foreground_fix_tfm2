use mod_api::*;

fn init(_ctx: &GameCtx) -> ModRegistration {
    let reg = ModRegistration::new("chat_toggle_tfm2");
    reg
}

declare_mod!(init);
