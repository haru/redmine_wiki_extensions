/**
 * @author Dmitry Manayev
 */

emoticons_image_url = ""
redmine_base_url = ""
/**
 * This class used to add group of elements in tooltip.
 * @param {Object} title
 * @param {Object} scope
 * @param {Object} className
 */
function jsTooltip(title, scope, className) {
    if(typeof jsToolBar.strings == 'undefined') {
        this.title = title || null;
    } else {
        this.title = jsToolBar.strings[title] || title || null;
    }
    this.scope = scope || null;
    this.className = className || null;
}
jsTooltip.prototype = {

    mode: 'wiki',
    elements:{},

    getMode: function() {
        return this.mode;
    },

    setMode: function(mode) {
        this.mode = mode || 'wiki';
    },

    button: function(toolName) {
        var tool = this.elements[toolName];
        if (typeof tool.fn[this.mode] != 'function') return null;
        var b = new jsButton(tool.title, tool.fn[this.mode], this.scope, 'jstb_'+toolName);
        if (tool.icon != undefined) b.icon = tool.icon;
        return b;
    },

    draw: function(){
        if (!this.scope) return null;

        this.tooltip = document.createElement('div');
        if (this.className)
            this.tooltip.className = this.className;
        this.tooltip.title = this.title;

        if (this.icon != undefined) {
            this.tooltip.style.backgroundImage = 'url(' + this.icon + ')';
        }

        // Empty tooltip
        while (this.tooltip.hasChildNodes()) {
            this.tooltip.removeChild(tooltip.firstChild)
        }
        this.toolNodes = {};

        this.a = document.createElement('a');
        this.a.title = 'Smiles';
        this.a.className = 'smiles';
        this.img = document.createElement('img');
        this.img.title = 'Smiles';
        this.img.src = redmine_base_url + '/plugin_assets/redmine_wiki_extensions/images/main_smile.png';
        this.img.id = 'smiles_img'
        this.img.tabIndex = 200;
        this.a.appendChild(this.img);

        this.div = document.createElement('div');
        this.div.id = 'group_of_smiles';

        // Draw toolbar elements
        var b, tool, newTool,k;

        k = 0;
        for (var i in this.elements) {
            b = this.elements[i];

            var disabled =
            b.type == undefined || b.type == ''
            || (b.disabled != undefined && b.disabled)
            || (b.context != undefined && b.context != null && b.context != this.context);

            if (!disabled && typeof this[b.type] == 'function') {
                tool = this[b.type](i);
                if (tool) newTool = tool.draw();
                if ( k%7 == 0 && k != 0) this.div.appendChild(document.createElement('br'));
                if (newTool) {
                    this.toolNodes[i] = newTool;
                    this.div.appendChild(newTool);
                    k++;
                }
            }
        }

        this.a.appendChild(this.div);
        this.tooltip.appendChild(this.a);

        return this.tooltip;
    }
}

jsToolBar.prototype.tooltip =  function(toolName) {
    var tool = this.elements[toolName];
    var b = new jsTooltip(tool.title,this,'jstt_'+toolName);
    if (tool.icon != undefined) b.icon = tool.icon;
    return b;
}


// spacer
jsToolBar.prototype.elements.space5 = {
    type: 'space'
}

//buttons for smiles:

function setEmoticonButtons(buttons, url) {
    emoticons_image_url = url;
    buttons.each(function(button) {
        jsTooltip.prototype.elements[button[1]] = {
            type: 'button',
            title: button[2],
            icon: url + '/' + button[1],
            fn: {
                wiki: function() {
                    this.encloseSelection(button[0])
                }
            }
        }
    })
}



//smiles
jsToolBar.prototype.elements.smiles = {
    type: 'tooltip',
    title: 'Smiles'
}
