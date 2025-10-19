# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2013  Haruyuki Iida
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

module WikiExtensionsVideoMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Embed video content directly into a webpage \n" +
         "with the video html tag \n\n" +
         " {{video_tag(source)}}" + "\n" +
         " {{video_tag(source, [width, height])}}" + "\n" +
         " {{video_tag(source, [width, height, controls autoplay muted loop preload='none' poster='..'])}}\n\n" +
         "   Parameters:\n" +
         "     source string: id of attachment or http link (required)\n" +
         "     width int: sets the widht dimensions of the video player\n" +
         "     height int: sets the height dimensions\n" +
         "     parm string: all the different kind of parameters controls are set by default\n\n" +
         "   Examples:\n" +
         "      {{video_tag(20)}}\n" +
         "      ...video empeded tag to the attachment nr 20 with a control pannel, max dimensions widht/resolution \n" +
         "      {{video_tag(https://samplelib.com/lib/preview/mp4/sample-5s.mp4, 320, 240, controls autoplay muted)}}\n" +
         "      ...video empeded from a http link, dimension 320x240, with control pannel in autoplay mode and muted"
    macro :video_tag do |obj, args|
      return nil if args.empty?

      attachment = Attachment.find_by(id: h(args[0].strip))
      attachment_path = !attachment ? h(args[0].strip) : url_for(controller: 'attachments', action: 'download', id: attachment.id, filename: attachment.filename)

      # video html tag
      o = '<video src="' + attachment_path + '"'
      o += ' width="' + h(args[1].strip) + '"' if args.length >= 2
      o += ' height="' + h(args[2].strip) + '"' if args.length >= 3
      o += args.length >= 3 ? ' ' + h(args[3].strip) : ' controls'
      o += '>'

      o.html_safe
    end
  end
end
