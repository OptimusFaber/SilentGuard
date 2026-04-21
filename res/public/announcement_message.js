if (first_start){
    let array = [translate("OK"), translate("Open homepage")];
    let index = ask(
        "SilentGuard — cross-platform proxy client (see README on GitHub).",
        NKR_SOFTWARE_NAME,
            array
    );

    if (index == 1){
        open_url("https://github.com/OptimusFaber/SilentGuard");
    }
}
