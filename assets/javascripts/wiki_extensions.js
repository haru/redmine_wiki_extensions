

function add_wiki_extension_sidebar() {
    var sidebar = $('sidebar');
    if (sidebar == null) {
        return;
    }

    var sidebar_area = $('wiki_extentions_sidebar');
    sidebar_area.remove();
    sidebar.insert(sidebar_area);
    sidebar_area.show();

}
