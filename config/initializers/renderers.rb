require 'renderers/markdown_renderer'

ActionView::Template.register_template_handler :md, Renderers::MarkdownRenderer
