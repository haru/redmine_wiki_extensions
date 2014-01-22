/*
# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2014  Haruyuki Iida
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

var auto_preview_interval = 2000;

function add_wiki_extensions_tags_form() {
    var tags_form = $('#wiki_extensions_tag_form');
    $('#attachments_fields').parent().after(tags_form);
}

function set_tag_atuto_complete(taglist) {
    var inputs = $('.wikiext_tag_inputs');

    inputs.each(function(index, obj){
        $(obj).autocomplete({
            source: taglist
        })
    })
}

function setAutPreviewCallback(url, preview_id, form_id, content_id) {
    var content_org = $(content_id).val();
    
    setInterval(function(){
        var content_new = $(content_id).val();
        if (content_new != content_org) {
            $(preview_id).load(url, $(form_id).we_serialize2json());
            content_org = content_new;
        }
    },auto_preview_interval);
}

function setWikiAutoPreview(url) {
    setAutPreviewCallback(url, '#preview', '#wiki_form', '#content_text');
}

function setMessagesAutoPreview(url) {
    setAutPreviewCallback(url, '#preview', '#message-form', '#message_content');
}

function setBoardsAutoPreview(url) {
    setAutPreviewCallback(url, '#preview', '#message-form', '#message_content');
}

function setIssueAutoPreview(url) {
    setAutPreviewCallback(url, '#preview', '#issue-form', '#issue_description');
}

function setIssueNotesAutoPreview(url) {
    setAutPreviewCallback(url, '#preview', '#issue-form', '#notes');
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

    var tbodys = $('.wiki table tbody');
    for (var i = 0; i < tbodys.length; i++) {
        var tbody = tbodys[i];
        if (!is_table_for_sort(tbody)) {
            continue;
        }
        var table = tbody.parentNode;
        var header = tbody.removeChild(tbody.firstChild);
        var thead = table.insertBefore(document.createElement('thead'), tbody);
        thead.appendChild(header);

    }

    $('table').each(function(i) {
        $(this).tablesorter();
    });

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


$.fn.we_serialize2json = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name]) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};