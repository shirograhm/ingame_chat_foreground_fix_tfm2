use mod_api::*;

fn init(_ctx: &GameCtx) -> ModRegistration {
    let reg = ModRegistration::new("ingame_chat_foreground_fix_tfm2");
    reg
}

declare_mod!(init);
