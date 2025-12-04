/*
# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2019  Haruyuki Iida
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


function add_wiki_extensions_edit_form(tagname) {
    var formtag = $(tagname);
    $('#wiki_form div.box').append(formtag);
}

function hide_wiki_history_tags() {

    // find startTag content, begins inside first
    // only set this tags, without classnames to "none"
    // end searching when wiki content starts

    const start = document.getElementById('content').firstElementChild;
    const end = document.querySelector('div.wiki.wiki-page');

    let current = start.nextElementSibling;

    while (current && current !== end) {
        const next = current.nextElementSibling;

        if ((current.tagName === 'P' && current.classList == '') ||
            (current.tagName === 'H2' && current.classList == '') ||
            (current.tagName === 'HR' && current.classList == ''))
            current.style.display = 'none';

        current = next;
    }

}

function set_tag_atuto_complete(taglist) {
    var inputs = $('.wikiext_tag_inputs');

    inputs.each(function(index, obj){
        $(obj).autocomplete({
            source: taglist
        })
    })
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