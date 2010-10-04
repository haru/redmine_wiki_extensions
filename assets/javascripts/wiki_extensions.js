/*
# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2010  Haruyuki Iida
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
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

function add_wiki_extensions_tags_form() {
    var tags_form = $('wiki_extensions_tag_form');
    var wiki_form = $('wiki_form');
    var content_comments = $('content_comments');
    tags_form.parentNode.removeChild(tags_form);
    new Insertion.After(content_comments.parentNode, tags_form);
}

function set_tag_atuto_complete(taglist) {
    var inputs = $$('.wikiext_tag_inputs');
    for (var i = 0; i < inputs.length; i++) {
        new Autocompleter.Local(inputs[i], "wikiext_taglist_complete", taglist, {});
    }
}

function setWikiAutoPreview(url) {
    new Field.Observer('content_text',2, function(){
        new Ajax.Updater('preview', url, {
            asynchronous:true,
            evalScripts:true,
            method:'post',
            parameters:Form.serialize('wiki_form')
        });
    });
}

function setMessagesAutoPreview(url) {
    new Field.Observer('message_content',2, function(){
        new Ajax.Updater('preview', url, {
            asynchronous:true,
            evalScripts:true,
            method:'post',
            parameters:Form.serialize('message-form')
        });
    });
}

function setBoardsAutoPreview(url) {
    new Field.Observer('message_content',2, function(){
        new Ajax.Updater('preview', url, {
            asynchronous:true,
            evalScripts:true,
            method:'post',
            parameters:Form.serialize('message-form')
        });
    });
}

function setIssueAutoPreview(url) {
    new Field.Observer('issue_description',2, function(){
        new Ajax.Updater('preview', url, {
            asynchronous:true,
            evalScripts:true,
            method:'post',
            parameters:Form.serialize('issue-form')
        });
    });
}

function setIssueNotesAutoPreview(url) {
    new Field.Observer('notes',2, function(){
        new Ajax.Updater('preview', url, {
            asynchronous:true,
            evalScripts:true,
            method:'post',
            parameters:Form.serialize('issue-form')
        });
    });
}

function is_table_for_sort(tbody) {
    var trs = tbody.getElementsByTagName('tr');
    if (trs.length == 0) {
        return false;
    }
    var tds = trs[0].getElementsByTagName('td');
    if (tds.length != 0) {
        return false;
    }

    return true;
}
function wiki_extension_create_table_header() {

    var tbodys = $$('.wiki table tbody');
    for (var i = 0; i < tbodys.length; i++) {
        var tbody = tbodys[i];
        if (!is_table_for_sort(tbody)) {
            continue;
        }
        var table = tbody.parentNode;
        var header = tbody.removeChild(tbody.firstChild);
        var thead = table.insertBefore(document.createElement('thead'), tbody);
        thead.appendChild(header);
        var ths = thead.getElementsByTagName('th');
        for (var j = 0; j < ths.length; j++) {
            ths[j].addClassName('nocase');
        }
    }

}

/*
 * Author: Dmitry Manayev
 */
var DOM;
var Opera;
var IE;
var Firefox;

function do_some(src, evt) {
  if (!Firefox) {
     cls = src.parentNode.className;
     if (cls=='list_item ExpandOpen') {
        src.parentNode.className = 'list_item ExpandClosed';
     } else {
        src.parentNode.className = 'list_item ExpandOpen';
     }
     window.event.cancelBubble = true;
  } else {
     if (evt.eventPhase!=3) {
        cls = src.parentNode.className;
        if (cls=='list_item ExpandOpen') {
            src.parentNode.className = 'list_item ExpandClosed';
        } else {
            src.parentNode.className = 'list_item ExpandOpen';
        }
     }
  }
}

function Check() {
   if (!Firefox) {
      window.event.cancelBubble = true;
   }
}

DOM = document.getElementById;
Opera = window.opera && DOM;
IE = document.all && !Opera;
Firefox = navigator.userAgent.indexOf("Gecko") >= 0;